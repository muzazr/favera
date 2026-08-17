// src/services/assessmentService.js

const supabase = require('../config/supabaseClient'); // Sesuaikan path client supabase Anda

/**
 * Mengambil 1 asesmen keluarga terbaru
 */
const fetchCurrentAssessment = async (familyId) => {
  const { data, error } = await supabase
    .from('family_assessments')
    .select('*')
    .eq('family_id', familyId)
    .order('generated_at', { ascending: false })
    .limit(1)
    .maybeSingle();

  if (error) throw error;
  return data;
};

/**
 * Mengambil daftar riwayat asesmen dengan pagination cursor
 */
const fetchAssessmentHistory = async (familyId, limit = 20, cursor = null) => {
  let query = supabase
    .from('family_assessments')
    .select('*')
    .eq('family_id', familyId)
    .order('generated_at', { ascending: false })
    .limit(limit);

  if (cursor) {
    query = query.lt('generated_at', cursor);
  }

  const { data, error } = await query;

  if (error) throw error;
  return data || [];
};

/**
 * Mengambil 1 asesmen spesifik berdasarkan ID
 */
const fetchAssessmentById = async (assessmentId, familyId) => {
  const { data, error } = await supabase
    .from('family_assessments')
    .select('*')
    .eq('id', assessmentId)
    .eq('family_id', familyId)
    .maybeSingle();

  if (error) throw error;
  return data;
};

/**
 * Menyimpan hasil generate AI summary ke database
 */
const updateAssessmentSummary = async (assessmentId, summaryObj) => {
  const { data, error } = await supabase
    .from('family_assessments')
    .update({ summary: summaryObj })
    .eq('id', assessmentId)
    .select()
    .single();

  if (error) throw error;
  return data;
};

module.exports = {
  fetchCurrentAssessment,
  fetchAssessmentHistory,
  fetchAssessmentById,
  updateAssessmentSummary
};