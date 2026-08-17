const supabase = require('../config/supabaseClient');

class CommitmentService {
  /**
   * Mengambil daftar commitment bersama untuk satu keluarga
   */
  static async getCommitments(familyId, { limit = 20, cursor }) {
    let query = supabase
      .from('commitments')
      .select('*')
      .eq('family_id', familyId)
      .order('created_at', { ascending: false })
      .limit(Number(limit) + 1);

    if (cursor) {
      query = query.lt('created_at', cursor);
    }

    const { data, error } = await query;
    if (error) throw error;

    const hasMore = data.length > Number(limit);
    const items = hasMore ? data.slice(0, limit) : data;
    const nextCursor = hasMore && items.length > 0 ? items[items.length - 1].created_at : null;

    return {
      items,
      pagination: {
        next_cursor: nextCursor,
        has_more: hasMore
      }
    };
  }

  /**
   * Membuat draft commitment baru
   */
  static async createCommitment(familyId, userId, payload) {
    const {
      recovery_session_id,
      consultation_id,
      title,
      action,
      responsible_user_ids,
      start_date,
      due_date,
      success_indicator,
      evaluation_date
    } = payload;

    const { data, error } = await supabase
      .from('commitments')
      .insert({
        family_id: familyId,
        recovery_session_id: recovery_session_id || null,
        consultation_id: consultation_id || null,
        title,
        action,
        responsible_user_ids: responsible_user_ids || [userId],
        start_date,
        due_date: due_date || null,
        success_indicator,
        evaluation_date: evaluation_date || null,
        progress_percent: 0,
        status: 'draft',
        evidence: [],
        approved_by_user_ids: [userId]
      })
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  /**
   * Mengambil detail commitment berdasarkan ID
   */
  static async getCommitmentById(commitmentId, familyId) {
    const { data, error } = await supabase
      .from('commitments')
      .select('*')
      .eq('id', commitmentId)
      .eq('family_id', familyId)
      .single();

    if (error || !data) return null;
    return data;
  }

  /**
   * Revisi commitment
   */
  static async reviseCommitment(commitmentId, familyId, userId, payload) {
    const existing = await this.getCommitmentById(commitmentId, familyId);
    if (!existing) throw new Error('NOT_FOUND');

    const {
      recovery_session_id,
      consultation_id,
      title,
      action,
      responsible_user_ids,
      start_date,
      due_date,
      success_indicator,
      evaluation_date
    } = payload;

    const { data, error } = await supabase
      .from('commitments')
      .update({
        recovery_session_id: recovery_session_id || existing.recovery_session_id,
        consultation_id: consultation_id || existing.consultation_id,
        title: title || existing.title,
        action: action || existing.action,
        responsible_user_ids: responsible_user_ids || existing.responsible_user_ids,
        start_date: start_date || existing.start_date,
        due_date: due_date !== undefined ? due_date : existing.due_date,
        success_indicator: success_indicator || existing.success_indicator,
        evaluation_date: evaluation_date !== undefined ? evaluation_date : existing.evaluation_date,
        status: 'revised',
        approved_by_user_ids: [userId],
        updated_at: new Date().toISOString()
      })
      .eq('id', commitmentId)
      .eq('family_id', familyId)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  /**
   * Setujui atau tolak commitment
   */
  static async approveCommitment(commitmentId, familyId, userId, decision, comment) {
    const commitment = await this.getCommitmentById(commitmentId, familyId);
    if (!commitment) throw new Error('NOT_FOUND');

    let updatedApprovedUsers = [...(commitment.approved_by_user_ids || [])];
    let newStatus = commitment.status;

    if (decision === 'approve') {
      if (!updatedApprovedUsers.includes(userId)) {
        updatedApprovedUsers.push(userId);
      }
      newStatus = 'active';
    } else if (decision === 'reject') {
      newStatus = 'draft';
    }

    const { data, error } = await supabase
      .from('commitments')
      .update({
        status: newStatus,
        approved_by_user_ids: updatedApprovedUsers,
        updated_at: new Date().toISOString()
      })
      .eq('id', commitmentId)
      .eq('family_id', familyId)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  /**
   * Perbarui progres dan bukti commitment
   */
  static async updateProgress(commitmentId, familyId, userId, progressPercent, note, evidenceInput) {
    const commitment = await this.getCommitmentById(commitmentId, familyId);
    if (!commitment) throw new Error('NOT_FOUND');

    const updatedEvidence = [...(commitment.evidence || [])];

    if (evidenceInput && evidenceInput.type && evidenceInput.value) {
      updatedEvidence.push({
        type: evidenceInput.type,
        value: evidenceInput.value,
        created_by_user_id: userId,
        created_at: new Date().toISOString()
      });
    }

    let newStatus = commitment.status;
    if (progressPercent === 100) {
      newStatus = 'completed';
    }

    const { data, error } = await supabase
      .from('commitments')
      .update({
        progress_percent: progressPercent,
        evidence: updatedEvidence,
        status: newStatus,
        updated_at: new Date().toISOString()
      })
      .eq('id', commitmentId)
      .eq('family_id', familyId)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  /**
   * Tandai commitment selesai
   */
  static async completeCommitment(commitmentId, familyId) {
    const commitment = await this.getCommitmentById(commitmentId, familyId);
    if (!commitment) throw new Error('NOT_FOUND');

    const { data, error } = await supabase
      .from('commitments')
      .update({
        status: 'completed',
        progress_percent: 100,
        updated_at: new Date().toISOString()
      })
      .eq('id', commitmentId)
      .eq('family_id', familyId)
      .select()
      .single();

    if (error) throw error;
    return data;
  }
}

module.exports = CommitmentService;