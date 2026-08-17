// src/index.js
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');

const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const familyRoutes = require('./routes/familyRoutes');
const transactionRoutes = require('./routes/transactionRoutes');
const goalRoutes = require('./routes/goalRoutes');
const statementRoutes = require('./routes/statementRoutes');
const checkInRoutes = require('./routes/checkInRoutes');
const assessmentRoutes = require('./routes/assessmentRoutes');
const recoveryRoutes = require('./routes/recoveryRoutes');
const commitmentRoutes = require('./routes/commitmentRoutes');
const professionalRoutes = require('./routes/professionalRoutes');
const consultationRoutes = require('./routes/consultationRoutes');
const chatRoutes = require('./routes/chatRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(morgan('dev'));  

// Register Routes
app.use('/auth', authRoutes);
app.use('/', userRoutes);
app.use('/family', familyRoutes);
app.use('/transactions', transactionRoutes);
app.use('/goals', goalRoutes);
app.use('/statement-imports', statementRoutes); 
app.use('/check-ins', checkInRoutes);
app.use('/family-assessments', assessmentRoutes);
app.use('/recovery-sessions', recoveryRoutes);
app.use('/commitments', commitmentRoutes);
app.use('/professionals', professionalRoutes);
app.use('/consultations', consultationRoutes);
app.use('/chat', chatRoutes);

app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});

module.exports = app;