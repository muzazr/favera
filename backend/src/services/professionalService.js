const supabase = require('../config/supabaseClient');

class ProfessionalService {
  static async getProfessionals({ category, city, service_mode, cost_type, limit = 20, cursor }) {
    let query = supabase
      .from('professionals')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(Number(limit) + 1);

    if (category) query = query.eq('category', category);
    if (city) query = query.ilike('city', `%${city}%`);
    if (service_mode) query = query.contains('service_mode', [service_mode]);
    if (cost_type) query = query.eq('cost_type', cost_type);

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

  static async getProfessionalById(professionalId) {
    const { data, error } = await supabase
      .from('professionals')
      .select('*')
      .eq('id', professionalId)
      .single();

    if (error || !data) return null;
    return data;
  }
}

module.exports = ProfessionalService;