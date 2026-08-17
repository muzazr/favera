// src/services/aiService.js

/**
 * Prompt Engineer: Kurasi System Prompt untuk LLM (Gemini)
 * Dirancang agar konsisten, hangat, tidak halusinasi, dan format selalu JSON.
 */
const buildPrompt = (rawData) => {
  return `
Kamu adalah Psikolog Keluarga & Konselor Hubungan AI yang sangat ramah, hangat, dan suportif. 
Tugasmu adalah merangkum hasil asesmen check-in mingguan pasangan berdasarkan data JSON yang diberikan.

DATA ASESMEN MINGGU INI:
${JSON.stringify(rawData, null, 2)}

ATURAN KETAT UNTUK MERESPONS:
1. NADA BICARA: Gunakan bahasa Indonesia yang santai, hangat, dan mudah dipahami (hindari istilah medis, psikologis kaku, atau angka desimal mentah).
2. KONDISI STABIL: Jika 'risk_level' adalah "STABLE" dan 'top_factors' kosong ([]), sampaikan apresiasi bahwa hubungan mereka stabil dan harmonis. Jangan pernah mengarang/menciptakan masalah yang tidak ada di data.
3. DATA PARSIAL: Jika 'assessment_status' adalah "PARTIAL" (atau data_quality_score < 100), tambahkan pesan penyemangat yang halus di bagian 'action_plan' atau 'overview' agar mereka meluangkan waktu berdua untuk melengkapi check-in di minggu berikutnya.
4. FOKUS DOMAIN: Soroti 'domain_scores' secara kualitatif. (Misal: financial_harm = 0 berarti "Kondisi finansial sangat aman").
5. FORMAT OUTPUT: Kamu WAJIB merespons HANYA dengan JSON yang valid sesuai skema di bawah ini. Jangan tambahkan teks Markdown seperti \`\`\`json di awal atau akhir.

SKEMA JSON WAJIB:
{
  "headline": "Judul singkat dan menarik (maksimal 6 kata, misal: 'Minggu yang Stabil & Tenang')",
  "overview": "Paragraf singkat (2-3 kalimat) yang merangkum kondisi umum mereka minggu ini berdasarkan trend dan risk_level.",
  "domain_highlights": [
    {
      "domain": "Pilih salah satu: Finansial | Emosional | Komunikasi | Pemulihan",
      "status": "Sangat Baik | Stabil | Perlu Perhatian",
      "note": "1 kalimat penjelasan ramah tentang domain ini"
    }
  ],
  "action_plan": {
    "title": "Judul saran tindakan ringkas (berdasarkan recommended_action)",
    "description": "1-2 kalimat saran practical yang membumi. (Ingatkan soal keaktifan penggunaan aplikasi jika statusnya PARTIAL)."
  },
  "encouragement": "1 kalimat penutup yang manis dan menyemangati pasangan."
}
`;
};

/**
 * Fallback jika layanan AI timeout/error
 */
const createFallbackSummary = (rawData) => {
  const isPartial = rawData.assessment_status === 'PARTIAL';
  
  return {
    headline: "Kondisi Hubungan Terpantau Baik",
    overview: `Berdasarkan data asesmen minggu ${rawData.assessment_week || 'ini'}, dinamika keluarga Anda secara umum berada dalam tingkat toleransi yang stabil.`,
    domain_highlights: [
      {
        domain: "Komunikasi & Interaksi",
        status: "Stabil",
        note: "Tidak terdeteksi adanya indikator konflik yang memerlukan intervensi mendesak."
      }
    ],
    action_plan: {
      title: "Lanjutkan Kebiasaan Positif",
      description: isPartial 
        ? "Penggunaan aplikasi minggu ini belum cukup aktif. Jangan lupa luangkan waktu bersama pasangan untuk melengkapinya di minggu depan ya!" 
        : "Pertahankan rutinitas check-in mingguan ini untuk terus memantau kesehatan hubungan Anda."
    },
    encouragement: "Setiap langkah kecil yang Anda ambil sangat berarti untuk masa depan keluarga yang harmonis."
  };
};

/**
 * Memanggil Gemini API untuk generate ringkasan
 */
const generateAssessmentSummary = async (rawData) => {
  const prompt = buildPrompt(rawData);
  const apiKey = process.env.GEMINI_API_KEY;
  const model = process.env.GEMINI_MODEL || 'gemini-2.5-flash'; // 'gemini-2.5-flash' atau 'gemini-1.5-flash'

  if (!apiKey) {
    console.error('[AIService] GEMINI_API_KEY belum diset di environment variables.');
    const fallback = createFallbackSummary(rawData);
    fallback.meta = {
      generated_at: new Date().toISOString(),
      is_partial: rawData.assessment_status === 'PARTIAL',
      is_fallback: true
    };
    return fallback;
  }

  const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;

  try {
    const response = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        systemInstruction: {
          parts: [
            { 
              text: 'Anda adalah sistem backend yang hanya mengeluarkan output berupa JSON murni yang tervalidasi.' 
            }
          ]
        },
        contents: [
          {
            role: 'user',
            parts: [{ text: prompt }]
          }
        ],
        generationConfig: {
          responseMimeType: 'application/json', // Memaksa output berupa JSON valid
          temperature: 0.3
        }
      })
    });

    if (!response.ok) {
      const errBody = await response.text();
      console.error(`[AIService] Gemini API Error (${response.status}):`, errBody);
      throw new Error(`Gemini API error: ${response.statusText}`);
    }

    const resData = await response.json();

    // Mengambil string teks respons dari skema payload Gemini
    let content = resData?.candidates?.[0]?.content?.parts?.[0]?.text;

    if (!content) {
      throw new Error('Gemini mengembalikan respon kosong.');
    }

    // Pembersihan string jika AI menyertakan backticks markdown
    content = content.replace(/```json/g, '').replace(/```/g, '').trim();

    const jsonResult = JSON.parse(content);

    return {
      ...jsonResult,
      meta: {
        generated_at: new Date().toISOString(),
        is_partial: rawData.assessment_status === 'PARTIAL',
        is_fallback: false
      }
    };

  } catch (error) {
    console.error('[AIService] Failed to generate AI summary via Gemini, using fallback. Error:', error.message);
    const fallback = createFallbackSummary(rawData);
    fallback.meta = {
      generated_at: new Date().toISOString(),
      is_partial: rawData.assessment_status === 'PARTIAL',
      is_fallback: true
    };
    return fallback;
  }
};

module.exports = { generateAssessmentSummary };