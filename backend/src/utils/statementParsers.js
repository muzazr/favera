const pdfParseModule = require('pdf-parse');
const crypto = require('crypto');

// Mengakomodasi pdf-parse v1 maupun v2
const pdfParse = typeof pdfParseModule === 'function' 
    ? pdfParseModule 
    : (pdfParseModule.default || pdfParseModule.PDFParse);

/**
 * Generasi hash unik dari detail transaksi untuk proteksi duplikasi
 */
const generateTransactionHash = (dateStr, amount, direction, description) => {
    const raw = `${dateStr}_${amount}_${direction}_${(description || '').trim()}`;
    return crypto.createHash('md5').update(raw).digest('hex');
};

/**
 * Membersihkan format string nominal uang ke angka murni (Integer)
 * Supports: GoPay Coins (Satuan) & Rupiah (Ribuan)
 */
const parseAmount = (amountStr, isCoins = false) => {
    if (!amountStr) return 0;
    
    // Ambil hanya karakter angka, koma, titik, dan minus
    let clean = String(amountStr).replace(/[^0-9,.-]/g, '');

    // 1. Jika GoPay Coins, ambil nilai murni
    if (isCoins) {
        return Math.abs(parseInt(clean, 10)) || 0;
    }

    // 2. Buang desimal di akhir jika ada (misal: ,00 / .00 / ,0 / .0)
    // Regex ini mencocokkan koma/titik diikuti 1-2 digit di paling akhir string
    clean = clean.replace(/[,.]\d{1,2}$/, '');

    // 3. Hapus semua pemisah ribuan (titik atau koma) yang tersisa
    clean = clean.replace(/[,.]/g, '');

    // 4. Ubah langsung ke Integer murni (tanpa parseFloat & tanpa Math.round)
    return Math.abs(parseInt(clean, 10)) || 0;
};

/**
 * 1. Deteksi Provider Otomatis
 */
const detectProvider = (rawText) => {
    const upper = rawText.toUpperCase();
    if (upper.includes('BANK MANDIRI') || upper.includes('MANDIRI TABUNGAN') || upper.includes('LIVIN')) return 'mandiri';
    if (upper.includes('BANK RAKYAT INDONESIA') || upper.includes('BRIMO') || upper.includes('BRI')) return 'bri';
    if (upper.includes('GOPAY') || upper.includes('GOJEK') || upper.includes('PT DOMPET KARYA ANAK BANGSA')) return 'gopay';
    return 'unknown';
};

/**
 * 2. Parser Bank Mandiri
 */
const parseMandiri = (text) => {
    const lines = text.replace(/\r\n/g, '\n').split('\n');
    const transactions = [];
    let currentTx = null;

    const dateRegex = /^\s*(\d{2}\/\d{2}\/\d{2,4})\s+(\d{2}\/\d{2}\/\d{2,4})?\s*(.*)/;

    for (const line of lines) {
        const trimmed = line.trim();
        if (!trimmed) continue;

        const match = trimmed.match(dateRegex);
        if (match) {
            if (currentTx) transactions.push(currentTx);

            const txDateRaw = match[1];
            const remainder = match[3];

            const amountMatch = remainder.match(/([\d.,]+)\s*([DKdk]|CR|DB)?$/);
            
            let amount = 0;
            let direction = 'expense';
            let description = remainder;

            if (amountMatch) {
                amount = parseAmount(amountMatch[1]);
                const indicator = (amountMatch[2] || '').toUpperCase();
                direction = (indicator === 'K' || indicator === 'CR') ? 'income' : 'expense';
                description = remainder.replace(amountMatch[0], '').trim();
            }

            const [day, month, year] = txDateRaw.split('/');
            const fullYear = year.length === 2 ? `20${year}` : year;
            const isoDate = new Date(`${fullYear}-${month}-${day}T10:00:00.000Z`).toISOString();

            currentTx = {
                transaction_at: isoDate,
                direction,
                amount,
                description: description || 'Transaksi Mandiri',
                category: 'Lainnya',
                payment_channel: 'Bank Mandiri',
                raw_reference_hash: generateTransactionHash(isoDate, amount, direction, description)
            };
        } else if (currentTx) {
            if (!trimmed.includes('HALAMAN') && !trimmed.includes('SALDO') && !trimmed.includes('MUTASI')) {
                currentTx.description += ` ${trimmed}`;
                currentTx.raw_reference_hash = generateTransactionHash(
                    currentTx.transaction_at, 
                    currentTx.amount, 
                    currentTx.direction, 
                    currentTx.description
                );
            }
        }
    }
    if (currentTx) transactions.push(currentTx);
    return transactions;
};

/**
 * 3. Parser Bank BRI
 */
const parseBRI = (text) => {
    const lines = text.replace(/\r\n/g, '\n').split('\n');
    const transactions = [];
    let currentTx = null;

    const dateRegex = /^\s*(\d{2}\/\d{2}\/\d{2,4})\s+(.*)/;

    for (const line of lines) {
        const trimmed = line.trim();
        if (!trimmed) continue;

        const match = trimmed.match(dateRegex);
        if (match) {
            if (currentTx) transactions.push(currentTx);

            const txDateRaw = match[1];
            const remainder = match[2];

            const parts = remainder.split(/\s+/);
            let amount = 0;
            let direction = 'expense';

            const possibleAmounts = parts.filter(p => /^[\d.,]+$/.test(p));
            if (possibleAmounts.length >= 1) {
                amount = parseAmount(possibleAmounts[0]);
            }

            if (remainder.toUpperCase().includes('KM') || remainder.toUpperCase().includes('KREDIT')) {
                direction = 'income';
            }

            const [day, month, year] = txDateRaw.split('/');
            const fullYear = year ? (year.length === 2 ? `20${year}` : year) : new Date().getFullYear().toString();
            const isoDate = new Date(`${fullYear}-${month}-${day}T10:00:00.000Z`).toISOString();

            currentTx = {
                transaction_at: isoDate,
                direction,
                amount,
                description: remainder,
                category: 'Lainnya',
                payment_channel: 'Bank BRI',
                raw_reference_hash: generateTransactionHash(isoDate, amount, direction, remainder)
            };
        } else if (currentTx) {
            currentTx.description += ` ${trimmed}`;
        }
    }
    if (currentTx) transactions.push(currentTx);
    return transactions;
};

/**
 * 4. Parser GoPay
 */
const parseGoPay = (text) => {
    const transactions = [];
    
    const cleanText = text.replace(/\r\n/g, '\n');
    const dateRegex = /(\d{2}\/\d{2}\/\d{4})\s*\n?\s*(\d{2}:\d{2})/g;
    
    const matches = [];
    let match;
    while ((match = dateRegex.exec(cleanText)) !== null) {
        matches.push({
            index: match.index,
            dateRaw: match[1],
            timeRaw: match[2],
            fullMatchLength: match[0].length
        });
    }

    for (let i = 0; i < matches.length; i++) {
        const currentMatch = matches[i];
        const nextIndex = (i + 1 < matches.length) ? matches[i + 1].index : cleanText.length;
        
        const blockText = cleanText.substring(currentMatch.index + currentMatch.fullMatchLength, nextIndex).trim();
        
        const [day, month, year] = currentMatch.dateRaw.split('/');
        const isoDate = new Date(`${year}-${month}-${day}T${currentMatch.timeRaw}:00.000Z`).toISOString();

        const isCoins = blockText.includes('GoPay Coins');
        const blockLines = blockText.split('\n').map(l => l.trim()).filter(Boolean);
        
        let amountVal = 0;
        let direction = 'expense';
        let rawAmountStr = '';

        for (let j = blockLines.length - 1; j >= 0; j--) {
            const line = blockLines[j];
            if (line.includes('Rp') || /^-?\d+$/.test(line)) {
                rawAmountStr = line;
                break;
            }
        }

        if (rawAmountStr.startsWith('-')) {
            direction = 'expense';
        } else if (rawAmountStr.includes('Rp') || isCoins) {
            direction = 'income';
        }

        // Oper parameter isCoins agar parseAmount paham cara penanganannya
        amountVal = parseAmount(rawAmountStr, isCoins);

        let descParts = [];
        for (const line of blockLines) {
            if (line === 'GoPay Saldo' || line === 'GoPay Coins' || line === rawAmountStr) {
                continue;
            }
            descParts.push(line);
        }
        
        let fullDesc = descParts.join(' ');

        fullDesc = fullDesc.replace(/\d{14,}[A-Za-z0-9]*/g, '').trim();
        fullDesc = fullDesc.replace(/\b[a-zA-Z0-9]{6,8}ID\b/gi, '').trim();

        if (!fullDesc) fullDesc = isCoins ? 'Cashback GoPay Coins' : 'Transaksi GoPay';

        transactions.push({
            transaction_at: isoDate,
            direction,
            amount: amountVal, // Tanpa perkalian * 1000
            description: fullDesc,
            category: isCoins ? 'Bonus / Cashback' : 'Lainnya',
            payment_channel: isCoins ? 'GoPay Coins' : 'GoPay',
            raw_reference_hash: generateTransactionHash(isoDate, amountVal, direction, fullDesc)
        });
    }

    return transactions;
};

/**
 * Main Extracting Function
 */
const parseStatementBuffer = async (fileBuffer, password = null) => {
    try {
        const options = password ? { password } : {};

        let pdfData;
        if (typeof pdfParse === 'function' && pdfParse.prototype && pdfParse.prototype.constructor) {
            try {
                const instance = new pdfParse(fileBuffer, options);
                pdfData = typeof instance.parse === 'function' ? await instance.parse() : await instance;
            } catch (e) {
                pdfData = await pdfParse(fileBuffer, options);
            }
        } else {
            pdfData = await pdfParse(fileBuffer, options);
        }

        const rawText = pdfData.text || '';

        const provider = detectProvider(rawText);
        let parsedDrafts = [];

        switch (provider) {
            case 'mandiri':
                parsedDrafts = parseMandiri(rawText);
                break;
            case 'bri':
                parsedDrafts = parseBRI(rawText);
                break;
            case 'gopay':
                parsedDrafts = parseGoPay(rawText);
                break;
            default:
                throw new Error('FORMAT_UNSUPPORTED');
        }

        return { provider, parsedDrafts };
    } catch (err) {
        if (
            err.name === 'PasswordException' || 
            (err.message && err.message.toLowerCase().includes('password')) ||
            err.code === 1
        ) {
            if (!password) {
                const error = new Error('PDF_PASSWORD_REQUIRED');
                error.statusCode = 400;
                throw error;
            } else {
                const error = new Error('PDF_PASSWORD_INCORRECT');
                error.statusCode = 400;
                throw error;
            }
        }

        if (err.message === 'FORMAT_UNSUPPORTED') {
            const error = new Error('Format e-statement tidak dikenali. Hanya mendukung Bank Mandiri, BRI, dan GoPay.');
            error.statusCode = 400;
            throw error;
        }

        throw err;
    }
};

module.exports = { parseStatementBuffer };