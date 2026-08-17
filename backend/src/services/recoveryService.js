const supabase = require('../config/supabaseClient');

class RecoveryService {
  /**
   * Mengambil daftar sesi pemulihan untuk keluarga
   */
  static async getSessions(familyId, { limit = 10, cursor, status }) {
    let query = supabase
      .from('recovery_sessions')
      .select('*')
      .eq('family_id', familyId)
      .order('created_at', { ascending: false })
      .limit(Number(limit));

    if (status) {
      query = query.eq('status', status);
    }
    if (cursor) {
      query = query.lt('created_at', cursor);
    }

    const { data, error } = await query;
    if (error) throw error;
    return data;
  }

  /**
   * Membuat sesi pemulihan baru
   */
  static async createSession(familyId, userId, topic, customTopic) {
    // Cari partner dalam keluarga
    const { data: familyMembers } = await supabase
      .from('family_members')
      .select('user_id')
      .eq('family_id', familyId)
      .neq('user_id', userId);

    const partnerUserId = familyMembers && familyMembers.length > 0 ? familyMembers[0].user_id : null;

    const { data, error } = await supabase
      .from('recovery_sessions')
      .insert({
        family_id: familyId,
        initiator_user_id: userId,
        partner_user_id: partnerUserId,
        topic,
        custom_topic: customTopic,
        status: 'READINESS_CHECK'
      })
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  /**
   * Mengambil detail sesi
   */
  static async getSessionById(sessionId, currentUserId) {
    const { data, error } = await supabase
      .from('recovery_sessions')
      .select('*')
      .eq('id', sessionId)
      .single();

    if (error || !data) return null;

    // Masking data refleksi privat pengguna lain demi keamanan psikologis
    if (data.private_reflections) {
      const maskedReflections = {};
      if (data.private_reflections[currentUserId]) {
        maskedReflections[currentUserId] = data.private_reflections[currentUserId];
      }
      data.private_reflections = maskedReflections;
    }

    return data;
  }

  /**
   * Mengisi tingkat kesiapan & keamanan pribadi
   */
  static async submitReadiness(sessionId, userId, readinessLevel, feelsSafe) {
    const session = await this.getSessionById(sessionId, userId);
    if (!session) throw new Error('SESSION_NOT_FOUND');

    const readinessCheck = session.readiness_check || {};
    readinessCheck[userId] = {
      readiness_level: readinessLevel,
      feels_safe: feelsSafe,
      updated_at: new Date().toISOString()
    };

    let nextStatus = session.status;
    
    // Jika tidak merasa aman, sarankan mediasi profesional
    if (!feelsSafe) {
      nextStatus = 'MEDIATION_RECOMMENDED';
    } else {
      // Jika kedua pihak telah mengisi kesiapan
      const userIds = Object.keys(readinessCheck);
      if (userIds.length >= 2 || session.partner_user_id === null) {
        nextStatus = 'PRIVATE_REFLECTION';
      }
    }

    const { data, error } = await supabase
      .from('recovery_sessions')
      .update({
        readiness_check: readinessCheck,
        status: nextStatus,
        updated_at: new Date().toISOString()
      })
      .eq('id', sessionId)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  /**
   * Menyimpan refleksi rahasia pribadi
   */
  static async saveReflection(sessionId, userId, reflectionData) {
    const session = await this.getSessionById(sessionId, userId);
    if (!session) throw new Error('SESSION_NOT_FOUND');

    const { data: fullSession } = await supabase
      .from('recovery_sessions')
      .select('private_reflections')
      .eq('id', sessionId)
      .single();

    const privateReflections = fullSession?.private_reflections || {};
    privateReflections[userId] = {
      ...reflectionData,
      submitted_at: new Date().toISOString()
    };

    const { data, error } = await supabase
      .from('recovery_sessions')
      .update({
        private_reflections: privateReflections,
        updated_at: new Date().toISOString()
      })
      .eq('id', sessionId)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  /**
   * Memicu pembuatan draf pernyataan netral berbasis AI/Sistem
   */
  static async generateStatementDraft(sessionId, userId) {
    const { data: session } = await supabase
      .from('recovery_sessions')
      .select('*')
      .eq('id', sessionId)
      .single();

    if (!session) throw new Error('SESSION_NOT_FOUND');

    const userReflection = session.private_reflections?.[userId];
    if (!userReflection) throw new Error('REFLECTION_NOT_FOUND');

    // Mengolah draf pernyataan non-konfrontatif (AI/Rule-based template)
    const draftText = `Saya menyadari ada kecemasan terkait topik "${session.topic}". Saya merasa ${userReflection.feelings?.join(', ') || 'khawatir'} dan berharap kita bisa mendiskusikan kebutuhan akan ${userReflection.needs?.join(', ') || 'keterbukaan'} secara tenang bersama.`;

    const statementDraft = {
      generated_statement: draftText,
      created_at: new Date().toISOString()
    };

    const { data, error } = await supabase
      .from('recovery_sessions')
      .update({
        statement_draft: statementDraft,
        updated_at: new Date().toISOString()
      })
      .eq('id', sessionId)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  /**
   * Mempublikasikan pernyataan netral kepada pasangan
   */
  static async publishStatement(sessionId, explicitConsent) {
    if (!explicitConsent) {
      throw new Error('CONSENT_REQUIRED');
    }

    const { data: session } = await supabase
      .from('recovery_sessions')
      .select('statement_draft')
      .eq('id', sessionId)
      .single();

    const publishedText = session?.statement_draft?.generated_statement;

    const { data, error } = await supabase
      .from('recovery_sessions')
      .update({
        published_statement: publishedText,
        status: 'WAITING_FOR_PARTNER',
        updated_at: new Date().toISOString()
      })
      .eq('id', sessionId)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  /**
   * Mengirim respons dari pasangan
   */
  static async submitPartnerResponse(sessionId, responseType, note, proposedTime) {
    const partnerResponse = {
      response_type: responseType,
      note: note || null,
      proposed_time: proposedTime || null,
      responded_at: new Date().toISOString()
    };

    const { data, error } = await supabase
      .from('recovery_sessions')
      .update({
        partner_response: partnerResponse,
        status: 'ALIGNMENT',
        updated_at: new Date().toISOString()
      })
      .eq('id', sessionId)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  /**
   * Mengambil ikhtisar Alignment/Keselarasan Pandangan
   */

  /**
   * Menjedakan sesi
   */
  static async pauseSession(sessionId) {
  const { data, error } = await supabase
    .from('recovery_sessions')
    .update({
      status: 'PAUSED',
      updated_at: new Date().toISOString()
    })
    .eq('id', sessionId)
    .select()
    .single();

  if (error) throw error;
  return data;
}

/**
 * Menyelesaikan sesi pemulihan (Tanpa request body)
 */
static async completeSession(sessionId) {
  const { data, error } = await supabase
    .from('recovery_sessions')
    .update({
      status: 'COMPLETED',
      updated_at: new Date().toISOString()
    })
    .eq('id', sessionId)
    .select()
    .single();

  if (error) throw error;
  return data;
}
}

module.exports = RecoveryService;