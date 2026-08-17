const supabase = require('../config/supabaseClient');
const { getWeekendWindowWIB, getWIBDateString, getWIBISOString } = require('../utils/dateUtils');
const { evaluateAndSaveFamilyRisk } = require('./riskAssessmentService');
const { getFullFamilyHealthSummary } = require("../utils/summaryAggregator")

/**
 * Helper untuk menghitung string format minggu ISO (contoh: '2026-W32')
 */
const getISOWeekString = (dateString) => {
  if (!dateString) return '2026-W32';
  const d = new Date(dateString);
  d.setHours(0, 0, 0, 0);
  d.setDate(d.getDate() + 4 - (d.getDay() || 7));
  const yearStart = new Date(d.getFullYear(), 0, 1);
  const weekNo = Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
  return `${d.getFullYear()}-W${String(weekNo).padStart(2, '0')}`;
};

const processExpiredCheckIns = async (familyId) => {
  const todayWIB = getWIBDateString();

  const { data: expiredCheckIns } = await supabase
    .from('weekly_check_ins')
    .select('id, family_id')
    .eq('family_id', familyId)
    .lt('week_end', todayWIB)
    .in('status', ['open', 'waiting_for_partner']);

  if (expiredCheckIns && expiredCheckIns.length > 0) {
    for (const checkin of expiredCheckIns) {
      await supabase
        .from('weekly_check_ins')
        .update({ status: 'expired', updated_at: getWIBISOString() })
        .eq('id', checkin.id);
    }
  }
};

const formatWeeklyCheckIn = async (checkin, userId) => {
  const windowInfo = getWeekendWindowWIB();

  const { data: questions } = await supabase
    .from('check_in_questions')
    .select('id, domain, text, answer_type, required, options, scale_min, scale_max, is_safety_critical')
    .eq('questionnaire_version', checkin.questionnaire_version);

  const { data: familyMembers } = await supabase
    .from('family_members')
    .select('user_id')
    .eq('family_id', checkin.family_id);

  const partnerId = familyMembers?.find(m => m.user_id !== userId)?.user_id;

  const { data: submissions } = await supabase
    .from('check_in_submissions')
    .select('user_id, status, answers, submitted_at')
    .eq('checkin_id', checkin.id);

  const mySub = submissions?.find(s => s.user_id === userId);
  const partnerSub = partnerId ? submissions?.find(s => s.user_id === partnerId) : null;

  const { data: assessment } = await supabase
    .from('family_assessments')
    .select('id')
    .eq('checkin_id', checkin.id)
    .maybeSingle();

  return {
    id: checkin.id,
    family_id: checkin.family_id,
    questionnaire_version: checkin.questionnaire_version,
    week_start: checkin.week_start,
    week_end: checkin.week_end,
    status: checkin.status,
    is_window_open: windowInfo.is_window_open,
    questions: questions || [],
    my_answers: mySub?.answers || [],
    my_submission_status: mySub?.status || 'not_started',
    partner_submission_status: partnerSub?.status || 'not_started',
    submitted_at: mySub?.submitted_at || null,
    summary_available: !!assessment // Otomatis bernilai TRUE jika asesmen tersimpan di DB
  };
};

const getCurrentCheckIn = async (userId, familyId) => {
  await processExpiredCheckIns(familyId);

  const { week_start, week_end } = getWeekendWindowWIB();

  let { data: checkin } = await supabase
    .from('weekly_check_ins')
    .select('*')
    .eq('family_id', familyId)
    .eq('week_start', week_start)
    .maybeSingle();

const rawSummary =  await getFullFamilyHealthSummary(familyId);
console.log(rawSummary);
  if (!checkin) {
    const { data: newCheckIn, error } = await supabase
      .from('weekly_check_ins')
      .insert({
        family_id: familyId,
        questionnaire_version: 'v1.0',
        week_start,
        week_end,
        status: 'open'
      })
      .select()
      .single();

    if (error) throw error;
    checkin = newCheckIn;
  }

  return await formatWeeklyCheckIn(checkin, userId);
};

const saveAnswersDraft = async (checkinId, userId, familyId, answers) => {
  const windowInfo = getWeekendWindowWIB();
  if (!windowInfo.is_window_open) {
    throw new Error('WINDOW_CLOSED');
  }

  const checkin = await getCheckInById(checkinId, userId, familyId);
  if (!checkin) return null;

  if (checkin.status === 'expired' || checkin.status === 'completed') {
    throw new Error('CHECKIN_LOCKED');
  }

  const { error } = await supabase
    .from('check_in_submissions')
    .upsert({
      checkin_id: checkinId,
      user_id: userId,
      status: 'draft',
      answers,
      updated_at: getWIBISOString()
    }, { onConflict: 'checkin_id, user_id' });

  if (error) throw error;

  return await getCheckInById(checkinId, userId, familyId);
};

const submitAnswers = async (checkinId, userId, familyId) => {
  const windowInfo = getWeekendWindowWIB();
  if (!windowInfo.is_window_open) {
    throw new Error('WINDOW_CLOSED');
  }

  const checkin = await getCheckInById(checkinId, userId, familyId);
  if (!checkin) return null;

  // Kunci jika check-in expired/completed ATAU user ini sudah pernah submit
  if (
    checkin.status === 'expired' || 
    checkin.status === 'completed' || 
    checkin.my_submission_status === 'submitted'
  ) {
    throw new Error('CHECKIN_LOCKED');
  }

  const nowWIB = getWIBISOString();

  // 1. Update status submission user menjadi 'submitted'
  const { error: subErr } = await supabase
    .from('check_in_submissions')
    .update({
      status: 'submitted',
      submitted_at: nowWIB,
      updated_at: nowWIB
    })
    .eq('checkin_id', checkinId)
    .eq('user_id', userId);

  if (subErr) throw subErr;

  const updatedCheckIn = await getCheckInById(checkinId, userId, familyId);
  let newStatus = 'waiting_for_partner';

  if (updatedCheckIn.partner_submission_status === 'submitted') {
    newStatus = 'completed';
  }

  // 2. Update status weekly_check_ins
  await supabase
    .from('weekly_check_ins')
    .update({ status: newStatus, updated_at: nowWIB })
    .eq('id', checkinId);

  // 3. TRIGGER EVALUASI & SIMPAN ASESMEN RISIKO (Model 2)
  const assessmentWeek = getISOWeekString(updatedCheckIn.week_start);
  try {
    await evaluateAndSaveFamilyRisk(familyId, checkinId, assessmentWeek);
  } catch (err) {
    console.error('[SubmitAnswers] Gagal memicu asesmen risiko:', err);
  }

  // 4. Return data terbaru, summary_available otomatis bernilai true
  return await getCheckInById(checkinId, userId, familyId);
};

const getCheckInList = async (userId, familyId, cursor, limit = 20) => {
  await processExpiredCheckIns(familyId);

  let query = supabase
    .from('weekly_check_ins')
    .select('*')
    .eq('family_id', familyId)
    .order('created_at', { ascending: false })
    .limit(limit + 1);

  if (cursor) {
    query = query.lt('created_at', cursor);
  }

  const { data: items, error } = await query;
  if (error) throw error;

  const hasMore = items.length > limit;
  const listItems = hasMore ? items.slice(0, limit) : items;

  const formattedItems = await Promise.all(
    listItems.map(item => formatWeeklyCheckIn(item, userId))
  );

  const nextCursor = hasMore ? listItems[listItems.length - 1].created_at : null;

  return {
    items: formattedItems,
    pagination: {
      next_cursor: nextCursor,
      has_more: hasMore
    }
  };
};

const getCheckInById = async (checkinId, userId, familyId) => {
  const { data: checkin, error } = await supabase
    .from('weekly_check_ins')
    .select('*')
    .eq('id', checkinId)
    .single();

  if (error || !checkin) return null;
  if (checkin.family_id !== familyId) throw new Error('FORBIDDEN');

  return await formatWeeklyCheckIn(checkin, userId);
};

module.exports = {
  getCurrentCheckIn,
  getCheckInList,
  getCheckInById,
  saveAnswersDraft,
  submitAnswers
};