// src/services/goalService.js
const supabase = require('../config/supabaseClient');

class GoalService {
  /**
   * Mengambil daftar financial goals berdasarkan family_id user
   */
  async getGoals({ familyId, cursor, limit = 20 }) {
    let query = supabase
      .from('financial_goals')
      .select('*')
      .eq('family_id', familyId)
      .order('created_at', { ascending: false })
      .limit(limit);

    if (cursor) {
      query = query.lt('created_at', cursor);
    }

    const { data, error } = await query;
    if (error) throw error;

    const nextCursor = data.length === limit ? data[data.length - 1].created_at : null;

    return {
      items: data,
      pagination: {
        next_cursor: nextCursor,
        has_more: !!nextCursor
      }
    };
  }

  /**
   * Buat financial goal baru
   */
  async createGoal({ userId, familyId, data }) {
    const payload = {
      family_id: familyId,
      created_by_user_id: userId,
      name: data.name,
      target_amount: data.target_amount,
      deadline: data.deadline || null,
      theme: data.theme || null,
      contribution_scheme: data.contribution_scheme,
      priority: data.priority,
      status: 'pending_partner_approval',
      approval: {
        required: true,
        approved_by_user_ids: [userId] // Otomatis disetujui pembuat
      }
    };

    const { data: created, error } = await supabase
      .from('financial_goals')
      .insert([payload])
      .select()
      .single();

    if (error) throw error;
    return created;
  }

  /**
   * Ambil detail goal berdasarkan ID
   */
  async getGoalById({ goalId, familyId }) {
    const { data, error } = await supabase
      .from('financial_goals')
      .select('*')
      .eq('id', goalId)
      .eq('family_id', familyId)
      .single();

    if (error) return null;
    return data;
  }

  /**
   * Update / ajukan perubahan goal
   */
  async updateGoal({ goalId, userId, familyId, updateData }) {
    const existing = await this.getGoalById({ goalId, familyId });
    if (!existing) return null;

    const majorFields = ['target_amount', 'deadline', 'contribution_scheme', 'priority'];
    const isMajorChange = majorFields.some((field) => updateData[field] !== undefined);

    const payload = {
      ...updateData,
      updated_at: new Date().toISOString()
    };

    // Jika ada perubahan signifikan, perbarui status ke pending_partner_approval
    if (isMajorChange) {
      payload.status = 'pending_partner_approval';
      payload.approval = {
        required: true,
        approved_by_user_ids: [userId]
      };
    }

    const { data: updated, error } = await supabase
      .from('financial_goals')
      .update(payload)
      .eq('id', goalId)
      .select()
      .single();

    if (error) throw error;
    return updated;
  }

  /**
   * Setujui atau tolak goal
   */
  async approveOrReject({ goalId, userId, familyId, decision, comment }) {
    const goal = await this.getGoalById({ goalId, familyId });
    if (!goal) return { error: 'NOT_FOUND' };

    let updatedApproval = goal.approval || { required: true, approved_by_user_ids: [] };
    let newStatus = goal.status;

    if (decision === 'approve') {
      if (!updatedApproval.approved_by_user_ids.includes(userId)) {
        updatedApproval.approved_by_user_ids.push(userId);
      }
      // Jika disetujui pasangan, ubah status menjadi active
      newStatus = 'active';
    } else if (decision === 'reject') {
      newStatus = 'cancelled';
    }

    const { data: updated, error } = await supabase
      .from('financial_goals')
      .update({
        status: newStatus,
        approval: updatedApproval,
        updated_at: new Date().toISOString()
      })
      .eq('id', goalId)
      .select()
      .single();

    if (error) throw error;
    return { data: updated };
  }

  /**
   * Tambahkan kontribusi dana ke goal
   */
  async addContribution({ goalId, userId, familyId, contributionData }) {
    const goal = await this.getGoalById({ goalId, familyId });
    if (!goal) return { error: 'NOT_FOUND' };

    // 1. Simpan kontribusi
    const payload = {
      goal_id: goalId,
      contributor_user_id: userId,
      amount: contributionData.amount,
      source: contributionData.source,
      transaction_id: contributionData.transaction_id || null,
      note: contributionData.note || null
    };

    const { data: contribution, error: contribError } = await supabase
      .from('goal_contributions')
      .insert([payload])
      .select()
      .single();

    if (contribError) throw contribError;

    // 2. Update current_amount pada financial_goals
    const newCurrentAmount = Number(goal.current_amount) + Number(contributionData.amount);
    const isCompleted = newCurrentAmount >= goal.target_amount;

    await supabase
      .from('financial_goals')
      .update({
        current_amount: newCurrentAmount,
        status: isCompleted ? 'completed' : goal.status,
        updated_at: new Date().toISOString()
      })
      .eq('id', goalId);

    // 3. Link transaksi jika ada
    if (contributionData.transaction_id) {
      await supabase
        .from('transactions')
        .update({ goal_id: goalId })
        .eq('id', contributionData.transaction_id);
    }

    return { data: contribution };
  }
}

module.exports = new GoalService();