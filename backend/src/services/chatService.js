// src/services/chatService.js

const supabase = require('../config/supabaseClient');

/**
 * Membawa konteks dari berbagai tabel berdasarkan context_scope sesi
 */
const buildContextData = async (familyId, userId, contextScope = []) => {
  const contextData = {};

  if (!familyId) return contextData;

  // 1. Ambil summary asesmen keluarga terbaru
  if (contextScope.includes('latest_family_assessment')) {
    const { data: assessment } = await supabase
      .from('family_assessments')
      .select('assessment_week, assessment_status, risk_level, risk_score, domain_scores, summary, recommended_action')
      .eq('family_id', familyId)
      .order('generated_at', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (assessment) {
      contextData.latest_family_assessment = {
        week: assessment.assessment_week,
        status: assessment.assessment_status,
        risk_level: assessment.risk_level,
        domain_scores: assessment.domain_scores,
        summary: assessment.summary || "Belum ada ringkasan AI",
        recommended_action: assessment.recommended_action
      };
    }
  }

  // 2. Ambil Financial Goals jika diminta
  if (contextScope.includes('goals')) {
    const { data: goals } = await supabase
      .from('financial_goals')
      .select('name, target_amount, current_amount, status, deadline')
      .eq('family_id', familyId)
      .limit(5);
    contextData.goals = goals || [];
  }

  // 3. Ambil Commitments jika diminta
  if (contextScope.includes('commitments')) {
    const { data: commitments } = await supabase
      .from('commitments')
      .select('title, action, progress_percent, status')
      .eq('family_id', familyId)
      .limit(5);
    contextData.commitments = commitments || [];
  }

  return contextData;
};

/**
 * Fetch List Sesi Chat dengan Pagination
 */
const fetchSessions = async (userId, limit = 20, cursor = null) => {
  let query = supabase
    .from('chat_sessions')
    .select('*')
    .eq('user_id', userId)
    .neq('status', 'deleted')
    .order('updated_at', { ascending: false })
    .limit(limit);

  if (cursor) {
    query = query.lt('updated_at', cursor);
  }

  const { data, error } = await query;
  if (error) throw error;
  return data || [];
};

/**
 * Buat Sesi Chat Baru
 */
const createSession = async (userId, title, contextScope) => {
  const { data, error } = await supabase
    .from('chat_sessions')
    .insert([{
      user_id: userId,
      title: title || 'Konsultasi Privat',
      context_scope: contextScope,
      status: 'active'
    }])
    .select()
    .single();

  if (error) throw error;
  return data;
};

/**
 * Detail Sesi Chat
 */
const fetchSessionById = async (sessionId, userId) => {
  const { data, error } = await supabase
    .from('chat_sessions')
    .select('*')
    .eq('id', sessionId)
    .eq('user_id', userId)
    .neq('status', 'deleted')
    .maybeSingle();

  if (error) throw error;
  return data;
};

/**
 * Soft Delete / Hard Delete Sesi Chat
 */
const deleteSession = async (sessionId, userId) => {
  const { error } = await supabase
    .from('chat_sessions')
    .delete()
    .eq('id', sessionId)
    .eq('user_id', userId);

  if (error) throw error;
  return true;
};

/**
 * Fetch Pesan dalam Sesi Chat
 */
const fetchMessages = async (sessionId, limit = 20, cursor = null) => {
  let query = supabase
    .from('chat_messages')
    .select('*')
    .eq('session_id', sessionId)
    .order('created_at', { ascending: false })
    .limit(limit);

  if (cursor) {
    query = query.lt('created_at', cursor);
  }

  const { data, error } = await query;
  if (error) throw error;
  
  // Balikkan urutan agar kronologis (lama ke baru)
  return (data || []).reverse();
};

/**
 * Kirim Pesan & Generate Respons AI via Gemini API
 */
const sendMessageAndGenerateResponse = async (session, familyId, userMessageText) => {
  const apiKey = process.env.GEMINI_API_KEY;
  const model = process.env.GEMINI_MODEL || 'gemini-2.5-flash';

  // 1. Simpan pesan user ke DB
  const { data: userMsg, error: userErr } = await supabase
    .from('chat_messages')
    .insert([{
      session_id: session.id,
      role: 'user',
      content: userMessageText,
      suggested_actions: [],
      requires_professional_support: false
    }])
    .select()
    .single();

  if (userErr) throw userErr;

  // 2. Tarik riwayat pesan sebelumnya (maksimal 10 pasang terakhir)
  const { data: rawHistory } = await supabase
    .from('chat_messages')
    .select('role, content')
    .eq('session_id', session.id)
    .order('created_at', { ascending: true })
    .limit(20);

  // Mapping role dari 'assistant' ke 'model' (Gemini API)
  const geminiContents = (rawHistory || []).map(msg => ({
    role: msg.role === 'assistant' ? 'model' : 'user',
    parts: [{ text: msg.content }]
  }));

  // 3. Ambil Konteks Asesmen & Scope Keluarga
  const contextData = await buildContextData(session.family_id || familyId, session.user_id, session.context_scope);

  // 4. Susun System Prompt Khusus (Dengan Aturan Panjang & Empati Adaptif)
  const systemInstruction = `
Kamu adalah AI Konselor Keluarga yang hangat, empati, dan santai seperti teman ngobrol di WhatsApp.

KONTEKS KELUARGA PENGGUNA TERKINI (Gunakan HANYA sebagai latar belakang, jangan dipaksakan masuk ke obrolan):
${JSON.stringify(contextData, null, 2)}

ATURAN UTAMA PERCAKAPAN (SANGAT KETAT):
1. **DILARANG BERCERAMAH / MENGGURUI (NO UNSOLICITED ADVICE):**
   - Jika pengguna HANYA memberi kabar/update, menjawab pertanyaan, atau luapan emosi singkat: **Jawab SINGKAT (Maksimal 2–3 kalimat saja)**.
   - DILARANG memberikan analisis psikologis, ceramah soal hubungan/kejujuran, atau saran finansial panjang lebar jika TIDAK DIMINTA secara eksplisit.
   - Cukup tanggapi dengan empati, ikut senang/lega, atau tanya balik secara singkat.

2. **KAPAN BOLEH MENJAWAB PANJANG?**
   - HANYA jika pengguna secara terang-terangan meminta solusi, panduan, atau strategi (contoh: "Gimana cara ngomongnya?", "Tolong kasih saran", "Langkah-langkahnya apa saja?").

3. **GAYA BAHASA & NADA:**
   - Gunakan bahasa percakapan sehari-hari yang alami, hangat, dan tidak kaku/puitis/berlebihan.

---
CONTOH PERILAKU YANG BENAR:

Pengguna: "tapi untuk itu aku aman, karena besok ayahku akan membayarkannya"
AI BENAR (Maksimal 2 kalimat, tanpa ceramah):
"Wah, syukurlah kalau begitu! Ikut lega dengarnya, setidaknya satu beban kamu sudah terangkat ya."

Pengguna: "aku lagi sedih banget ditinggal suami kerja keluar kota"
AI BENAR (Maksimal 2 kalimat, validasi empati):
"Pasti berat ya rasanya harus pisah rumah sementara. Kamu lagi merasa paling kesepian di momen apa biasanya?"
---

SKEMA JSON OUTPUT WAJIB:
{
  "content": "Pesan balasan AI (Singkat 2-3 kalimat jika pesan user biasa, panjang jika diminta solusi).",
  "intent": "Ringkasan niat pengguna (contoh: 'status_update', 'emotional_vent', 'request_advice')",
  "safety_level": "Pilih salah satu: 'none' | 'concern' | 'high' | 'urgent'",
  "suggested_actions": [
    // Biarkan [] KOSONG jika user hanya sekadar update/curhat dan tidak butuh aksi
  ],
  "requires_professional_support": false
}
`;

  // 5. Panggil Gemini API
  const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;
  
  let assistantResponseData = {
    content: "Terima kasih sudah berbagi. Saya di sini siap mendengarkan dan mendampingi Anda.",
    intent: "general_conversation",
    safety_level: "none",
    suggested_actions: [],
    requires_professional_support: false
  };

  try {
    const response = await fetch(endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        systemInstruction: { parts: [{ text: systemInstruction }] },
        contents: geminiContents,
        generationConfig: {
          responseMimeType: 'application/json',
          temperature: 0.5
        }
      })
    });

    if (response.ok) {
      const resData = await response.json();
      let rawText = resData?.candidates?.[0]?.content?.parts?.[0]?.text;
      if (rawText) {
        rawText = rawText.replace(/```json/g, '').replace(/```/g, '').trim();
        assistantResponseData = JSON.parse(rawText);
      }
    } else {
      console.error('[ChatService] Gemini API Error Response:', await response.text());
    }
  } catch (err) {
    console.error('[ChatService] Failed to generate AI reply, fallback used:', err.message);
  }

  // 6. Simpan pesan Assistant ke DB
  const { data: assistantMsg, error: aiErr } = await supabase
    .from('chat_messages')
    .insert([{
      session_id: session.id,
      role: 'assistant',
      content: assistantResponseData.content,
      intent: assistantResponseData.intent || null,
      safety_level: assistantResponseData.safety_level || 'none',
      suggested_actions: assistantResponseData.suggested_actions || [],
      requires_professional_support: Boolean(assistantResponseData.requires_professional_support),
      prompt_version: 'v1.1.0'
    }])
    .select()
    .single();

  if (aiErr) throw aiErr;

  // 7. Update updated_at sesi chat
  await supabase
    .from('chat_sessions')
    .update({ updated_at: new Date().toISOString() })
    .eq('id', session.id);

  return assistantMsg;
};

module.exports = {
  fetchSessions,
  createSession,
  fetchSessionById,
  deleteSession,
  fetchMessages,
  sendMessageAndGenerateResponse
};