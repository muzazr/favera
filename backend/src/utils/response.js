// src/utils/response.js

/**
 * Mengirimkan response error terstandar sesuai skema API Contract
 */
const sendError = (res, statusCode, code, message, details = [], requestId = null) => {
    return res.status(statusCode).json({
        code,
        message,
        details: details.length > 0 ? details : [],
        request_id: requestId
    });
};

module.exports = { sendError };