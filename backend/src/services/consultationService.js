const { randomUUID: uuidv4 } = require('crypto');
const supabase = require('../config/supabaseClient');

class ConsultationService {
  static async getConsultations(userId, { limit = 20, cursor }) {
    let query = supabase
      .from('consultations')
      .select('*')
      .eq('user_id', userId)
      .order('scheduled_at', { ascending: false })
      .limit(Number(limit) + 1);

    if (cursor) {
      query = query.lt('scheduled_at', cursor);
    }

    const { data, error } = await query;
    if (error) throw error;

    const hasMore = data.length > Number(limit);
    const items = hasMore ? data.slice(0, limit) : data;
    const nextCursor = hasMore && items.length > 0 ? items[items.length - 1].scheduled_at : null;

    return {
      items,
      pagination: {
        next_cursor: nextCursor,
        has_more: hasMore
      }
    };
  }

  static async createConsultation(userId, familyId, payload) {
    const {
      professional_id,
      professional_name,
      service_type,
      scheduled_at,
      meeting_method,
      location_or_link,
      reminder_at,
      visibility
    } = payload;

    const { data, error } = await supabase
      .from('consultations')
      .insert({
        user_id: userId,
        family_id: familyId || null,
        professional_id: professional_id || null,
        professional_name,
        service_type,
        scheduled_at,
        meeting_method,
        location_or_link: location_or_link || null,
        reminder_at: reminder_at || null,
        visibility,
        status: 'planned',
        checklist: [],
        notes: []
      })
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  static async getConsultationById(consultationId, userId) {
    const { data, error } = await supabase
      .from('consultations')
      .select('*')
      .eq('id', consultationId)
      .eq('user_id', userId)
      .single();

    if (error || !data) return null;
    return data;
  }

  static async updateConsultation(consultationId, userId, payload) {
    const existing = await this.getConsultationById(consultationId, userId);
    if (!existing) throw new Error('NOT_FOUND');

    const updateData = {
      ...payload,
      updated_at: new Date().toISOString()
    };

    const { data, error } = await supabase
      .from('consultations')
      .update(updateData)
      .eq('id', consultationId)
      .eq('user_id', userId)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  static async updateChecklist(consultationId, userId, items) {
    const existing = await this.getConsultationById(consultationId, userId);
    if (!existing) throw new Error('NOT_FOUND');

    // Menggabungkan status kelengkapan checklist berdasarkan 'code'
    const updatedChecklist = (existing.checklist || []).map((checkItem) => {
      const match = items.find((i) => i.code === checkItem.code);
      if (match) {
        return {
          ...checkItem,
          completed: match.completed,
          value: match.value !== undefined ? match.value : checkItem.value
        };
      }
      return checkItem;
    });

    // Jika item checklist belum ada di DB, tambahkan baru
    items.forEach((item) => {
      if (!updatedChecklist.some((c) => c.code === item.code)) {
        updatedChecklist.push({
          code: item.code,
          label: item.code,
          completed: item.completed,
          value: item.value || null
        });
      }
    });

    const { data, error } = await supabase
      .from('consultations')
      .update({
        checklist: updatedChecklist,
        updated_at: new Date().toISOString()
      })
      .eq('id', consultationId)
      .eq('user_id', userId)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  static async addNote(consultationId, userId, { content, visibility }) {
    const existing = await this.getConsultationById(consultationId, userId);
    if (!existing) throw new Error('NOT_FOUND');

    const newNote = {
      id: uuidv4(),
      content,
      visibility,
      created_at: new Date().toISOString()
    };

    const updatedNotes = [...(existing.notes || []), newNote];

    const { data, error } = await supabase
      .from('consultations')
      .update({
        notes: updatedNotes,
        updated_at: new Date().toISOString()
      })
      .eq('id', consultationId)
      .eq('user_id', userId)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  static async convertToCommitment(consultationId, userId, familyId, payload) {
    const existing = await this.getConsultationById(consultationId, userId);
    if (!existing) throw new Error('NOT_FOUND');

    const {
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
        consultation_id: consultationId,
        recovery_session_id: payload.recovery_session_id || null,
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
}

module.exports = ConsultationService;