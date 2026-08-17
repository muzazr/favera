/**
 * Utility Penanggalan Baku Zona Waktu Asia/Jakarta (WIB)
 */

// Mendapatkan string tanggal 'YYYY-MM-DD' dalam WIB
const getWIBDateString = (date = new Date()) => {
  const formatter = new Intl.DateTimeFormat('en-CA', {
    timeZone: 'Asia/Jakarta',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  });
  return formatter.format(date); // Output: "YYYY-MM-DD"
};

// Mendapatkan nama hari dalam WIB (0 = Minggu, 1 = Senin, ..., 5 = Jumat, 6 = Sabtu)
const getWIBDayOfWeek = (date = new Date()) => {
  const dayStr = new Intl.DateTimeFormat('en-US', {
    timeZone: 'Asia/Jakarta',
    weekday: 'short'
  }).format(date);

  const daysMap = { Sun: 0, Mon: 1, Tue: 2, Wed: 3, Thu: 4, Fri: 5, Sat: 6 };
  return daysMap[dayStr];
};

// Mendapatkan timestamp ISO dalam WIB
const getWIBISOString = () => {
  return new Date().toLocaleString('sv-SE', { timeZone: 'Asia/Jakarta' }).replace(' ', 'T') + '+07:00';
};

/**
 * Menghitung rentang Jumat - Minggu untuk Check-In mingguan (WIB)
 */
const getWeekendWindowWIB = (refDate = new Date()) => {
  const todayStr = getWIBDateString(refDate);
  const dayOfWeek = getWIBDayOfWeek(refDate); // 0 (Sun) - 6 (Sat)

  // Hitung selisih hari menuju hari Jumat terdekat dari siklus minggu ini
  let diffToFriday = 0;
  if (dayOfWeek === 5) diffToFriday = 0;       // Jumat
  else if (dayOfWeek === 6) diffToFriday = -1;  // Sabtu
  else if (dayOfWeek === 0) diffToFriday = -2;  // Minggu
  else diffToFriday = 5 - dayOfWeek;           // Senin - Kamis (menuju Jumat mendatang)

  const friday = new Date(refDate);
  friday.setDate(friday.getDate() + diffToFriday);

  const sunday = new Date(friday);
  sunday.setDate(friday.getDate() + 2);

  const isRealWeekend = dayOfWeek === 5 || dayOfWeek === 6 || dayOfWeek === 0;

  // Modus DEV: Izinkan akses kapan saja jika NODE_ENV !== 'production'
  const IS_DEV = process.env.NODE_ENV !== 'production' || process.env.ENABLE_DEV_MODE === 'true';

  return {
    is_window_open: IS_DEV ? true : isRealWeekend, // <--- Mode Dev selalu TRUE
    is_real_weekend: isRealWeekend,
    week_start: getWIBDateString(friday),
    week_end: getWIBDateString(sunday)
  };
};

module.exports = {
  getWIBDateString,
  getWIBDayOfWeek,
  getWIBISOString,
  getWeekendWindowWIB
};