import '../shared/models/chat_model.dart';
import '../shared/models/check_in_model.dart';
import '../shared/models/family_model.dart';
import '../shared/models/goal_model.dart';
import '../shared/models/professional_model.dart';
import '../shared/models/recovery_model.dart';
import '../shared/models/simulation_model.dart';
import '../shared/models/statement_model.dart';
import '../shared/models/transaction_model.dart';
import '../shared/models/user_model.dart';
import 'mock_clock.dart';

class MockStore {
  final AppClock clock;

  User? currentUser;
  FamilySpace? family;
  final Map<String, Transaction> _transactions = {};
  final Map<String, StatementImport> _statementImports = {};
  final Map<String, ParsedTransactionDraft> _statementDrafts = {};
  final Map<String, FinancialGoal> _goals = {};
  final Map<String, WeeklyCheckIn> _checkIns = {};
  final Map<String, FamilyAssessment> _assessments = {};
  final Map<String, ChatSession> _chatSessions = {};
  final Map<String, List<ChatMessage>> _chatMessages = {};
  final Map<String, Professional> _professionals = {};
  final Map<String, ImpactSimulation> _simulations = {};
  final Map<String, RecoverySession> _recoverySessions = {};
  final Map<String, Commitment> _commitments = {};

  MockStore({AppClock? clock}) : clock = clock ?? SystemClock() {
    resetToSeed();
  }

  // --- Seed Initialization ---
  void resetToSeed({bool preAuthenticate = false}) {
    _transactions.clear();
    _statementImports.clear();
    _statementDrafts.clear();
    _goals.clear();
    _checkIns.clear();
    _assessments.clear();
    _chatSessions.clear();
    _chatMessages.clear();
    _professionals.clear();
    _simulations.clear();
    _recoverySessions.clear();
    _commitments.clear();

    if (preAuthenticate) {
      currentUser = User(
        id: 'usr-joselin-001',
        email: 'joselin.demo@favera.local',
        name: 'Joselin',
        onboardingCompleted: true,
        avatarUrl: 'assets/profile_women.png',
        createdAt: clock.now(),
      );

      family = FamilySpace(
        id: 'fam-88219',
        inviteCode: 'FAV-88219',
        status: FamilyStatus.active,
        primaryUserId: 'usr-joselin-001',
        partnerUserId: 'usr-budi-002',
        partnerName: 'Budi',
        createdAt: clock.now(),
        pairedAt: clock.now(),
      );
    } else {
      currentUser = null;
      family = null;
    }

    // 2. Transactions
    final tx1 = Transaction(
      id: 'tx-001',
      type: TransactionType.income,
      amount: 5500000,
      category: 'Gaji',
      description: 'Gaji Bulanan',
      date: clock.now().subtract(const Duration(days: 8)),
      confirmedByPartner: true,
      createdAt: clock.now().subtract(const Duration(days: 8)),
    );
    final tx2 = Transaction(
      id: 'tx-002',
      type: TransactionType.expense,
      amount: 450000,
      category: 'Tagihan',
      description: 'Tagihan Listrik PLN',
      date: clock.now().subtract(const Duration(days: 5)),
      confirmedByPartner: true,
      createdAt: clock.now().subtract(const Duration(days: 5)),
    );
    final tx3 = Transaction(
      id: 'tx-003',
      type: TransactionType.expense,
      amount: 150000,
      category: 'Belanja',
      description: 'Belanja Bulanan Supermarket',
      date: clock.now().subtract(const Duration(days: 1)),
      confirmedByPartner: true,
      createdAt: clock.now().subtract(const Duration(days: 1)),
    );
    _transactions[tx1.id] = tx1;
    _transactions[tx2.id] = tx2;
    _transactions[tx3.id] = tx3;

    // 3. Financial Goal
    final goal1 = FinancialGoal(
      id: 'goal-001',
      name: 'Dana Darurat',
      targetAmount: 10000000,
      currentAmount: 6000000,
      deadline: 'Desember 2027',
      status: GoalStatus.active,
      approvedByPartner: true,
      themeIcon: 'house',
      contributionScheme: 'Dari Saldo Bersama',
      priority: 'Penting',
      contributions: [
        GoalContribution(
          id: 'c-001',
          sourceName: 'Dari Pemasukan Gaji',
          date: DateTime(2026, 7, 20),
          amount: 1000000,
        ),
        GoalContribution(
          id: 'c-002',
          sourceName: 'Bonus Tahunan',
          date: DateTime(2026, 6, 15),
          amount: 2500000,
        ),
        GoalContribution(
          id: 'c-003',
          sourceName: 'Dari Tabungan Reguler',
          date: DateTime(2026, 5, 1),
          amount: 2500000,
        ),
      ],
      createdAt: clock.now(),
    );
    _goals[goal1.id] = goal1;

    // 4. Weekly Check-In & Family Assessment
    final checkIn1 = WeeklyCheckIn(
      id: 'chk-week-32',
      weekPeriod: 'Minggu Ke-32 (Agustus 2026)',
      status: CheckInStatus.open,
      myEmotion: 'damai',
      mainConcern: 'keuangan',
      partnerSubmitted: true,
      createdAt: clock.now(),
    );
    _checkIns[checkIn1.id] = checkIn1;

    final assessment1 = FamilyAssessment(
      id: 'asm-001',
      level: AssessmentLevel.stable,
      summaryText:
          'Kondisi keuangan dan emosi keluarga stabil dan terkendali. Arus kas positif dengan sisa anggaran memadai.',
      recommendedAction:
          'Pertahankan komitmen tabungan bulanan dan lakukan check-in mingguan secara rutin.',
      createdAt: clock.now(),
    );
    _assessments[assessment1.id] = assessment1;

    // 5. Seed Professionals
    final prof1 = Professional(
      id: 'prof-001',
      name: 'Dra. Sarah Amelia, M.Psi',
      category: 'psikolog',
      specialization: 'Psikolog Klinis & Pernikahan',
      city: 'Jakarta Selatan',
      rating: 4.9,
      experienceYears: 8,
      schedule: 'Senin - Jumat (10:00 - 16:00)',
      bio:
          'Berpengalaman mendampingi lebih dari 200+ pasangan dalam memulihkan komunikasi keluarga dan mengurai konflik emosional.',
      whatsappUrl: 'https://wa.me/6281234567890',
      instagramUrl: 'https://instagram.com/favera_id',
      externalUrl: 'https://favera.id/professionals/sarah-amelia',
    );
    final prof2 = Professional(
      id: 'prof-002',
      name: 'Bapak Andi Susanto, S.Psi',
      category: 'konselor_finansial',
      specialization: 'Konselor Finansial & Mediasi',
      city: 'Surabaya',
      rating: 4.8,
      experienceYears: 10,
      schedule: 'Senin - Jumat (10:00 - 16:00)',
      bio:
          'Spesialis perencana keuangan keluarga, perhitung penyesuaian biaya hidup, dan konsolidasi anggaran.',
      whatsappUrl: 'https://wa.me/6281234567891',
      externalUrl: 'https://favera.id/professionals/andi-susanto',
    );
    final prof3 = Professional(
      id: 'prof-003',
      name: 'Rina Wijaya, M.Psi., Psikolog',
      category: 'psikolog',
      specialization: 'Psikolog Anak & Pendampingan Emosi',
      city: 'Bandung',
      rating: 4.9,
      experienceYears: 7,
      schedule: 'Senin - Sabtu (09:00 - 15:00)',
      bio:
          'Mendampingi anak dalam masa transisi dan adaptasi perubahan kondisi keuangan keluarga.',
      whatsappUrl: 'https://wa.me/6281234567892',
      externalUrl: 'https://favera.id/professionals/rina-wijaya',
    );
    _professionals[prof1.id] = prof1;
    _professionals[prof2.id] = prof2;
    _professionals[prof3.id] = prof3;

    // 6. Seed Recovery Sessions & Commitments
    final rec1 = RecoverySession(
      id: 'rec-demo-001',
      title: 'Diskusi Anggaran Hiburan & Tabungan Rumah',
      topic: 'Pengelolaan Anggaran Bulanan',
      status: RecoverySessionStatus.readinessCheck,
      readinessLevel: ReadinessLevel.ready,
      privateReflection:
          'Saya merasa perlu lebih terbuka mengenai pos pengeluaran gaya hidup agar kita bisa capai target tabungan rumah bersama.',
      createdAt: clock.now().subtract(const Duration(days: 2)),
      updatedAt: clock.now().subtract(const Duration(hours: 1)),
    );
    _recoverySessions[rec1.id] = rec1;

    final cmt1 = Commitment(
      id: 'cmt-demo-001',
      recoverySessionId: rec1.id,
      title: 'Batas Pengeluaran Hiburan Rp 1.5M/Bulan',
      description:
          'Menyetujui alokasi pengeluaran hiburan keluarga maksimal Rp 1.500.000 per bulan dan meninjau bersama di akhir bulan.',
      targetDate: clock.now().add(const Duration(days: 30)),
      status: CommitmentStatus.active,
      createdBy: 'usr-joselin-001',
      approvedByPartner: true,
      progressPercentage: 60,
      createdAt: clock.now().subtract(const Duration(days: 5)),
    );
    _commitments[cmt1.id] = cmt1;

    // 7. Seed Chat Session & Messages matching Screenshot 1
    const defaultSessionId = 'session-demo-001';
    final chatSess1 = ChatSession(
      id: defaultSessionId,
      title: 'Diskusi Keuangan Keluarga',
      createdAt: clock.now().subtract(const Duration(hours: 2)),
      lastMessage:
          'Pengeluaran bulan ini overbudget suamiku pengeluarannya ga jelas, bingung mulanya dari mana.',
    );
    _chatSessions[defaultSessionId] = chatSess1;

    final initialMsgs = [
      ChatMessage(
        id: 'msg-001',
        sessionId: defaultSessionId,
        sender: MessageSender.assistant,
        content:
            'Halo Budi & Siti. Saya di sini untuk membantu kalian berdiskusi soal keuangan keluarga dengan tenang. Ada yang ingin dibahas malam ini?',
        timestamp: clock.now().subtract(const Duration(minutes: 15)),
        suggestedActions: const [
          'Bingung Mengenai Judol',
          'Menanggulangi Judol',
          'Tinjau Transaksi Anomali',
          'Buat Target Tabungan',
        ],
      ),
      ChatMessage(
        id: 'msg-002',
        sessionId: defaultSessionId,
        sender: MessageSender.user,
        content:
            'Pengeluaran bulan ini overbudget suamiku pengeluarannya ga jelas, bingung mulanya dari mana.',
        timestamp: clock.now().subtract(const Duration(minutes: 13)),
      ),
    ];
    _chatMessages[defaultSessionId] = initialMsgs;
  }

  // --- Transactions Queries & Mutations ---
  List<Transaction> getTransactions() {
    final list = _transactions.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  int getTotalBalance() {
    int balance = 0;
    for (final tx in _transactions.values) {
      if (tx.type == TransactionType.income) {
        balance += tx.amount;
      } else {
        balance -= tx.amount;
      }
    }
    // Base balance offset (7.600.000 + 4.900.000 = 12.500.000 per DEMO_SCENARIO.md)
    return 7600000 + balance;
  }

  int getMonthlyIncome() {
    return _transactions.values
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, t) => sum + t.amount);
  }

  int getMonthlyExpense() {
    return _transactions.values
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  void addTransaction(Transaction tx) {
    _transactions[tx.id] = tx;
  }

  bool removeTransaction(String id) {
    return _transactions.remove(id) != null;
  }

  // --- E-Statement Import & Review Queries & Mutations ---
  StatementImport createStatementImport({
    required String fileName,
    required int fileSizeBytes,
    required String providerHint,
    bool requiresPassword = false,
  }) {
    final import = StatementImport(
      id: 'stm-${DateTime.now().millisecondsSinceEpoch}',
      fileName: fileName,
      fileSizeBytes: fileSizeBytes,
      status: requiresPassword
          ? StatementImportStatus.passwordRequired
          : StatementImportStatus.parsing,
      providerHint: providerHint,
      requiresPassword: requiresPassword,
      uploadedAt: clock.now(),
    );
    _statementImports[import.id] = import;

    if (!requiresPassword) {
      _loadDraftsForImport(import.id);
    }
    return import;
  }

  bool unlockStatementImport(String importId, String password) {
    final import = _statementImports[importId];
    if (import == null) return false;

    // Simulate password validation
    if (password != '123456') {
      return false;
    }

    _statementImports[importId] = import.copyWith(
      status: StatementImportStatus.reviewRequired,
      needsReviewCount: 2,
      totalDetected: 145,
    );
    _loadDraftsForImport(importId);
    return true;
  }

  void _loadDraftsForImport(String importId) {
    final draft1 = ParsedTransactionDraft(
      id: 'drf-$importId-001',
      importId: importId,
      date: clock.now().subtract(const Duration(days: 3)),
      description: 'APPLE.COM/BILL',
      amount: 1499000,
      category: 'Hiburan',
      status: DraftStatus.pending,
      anomalyReason: 'nominal berbeda dari kebiasaan',
    );
    final draft2 = ParsedTransactionDraft(
      id: 'drf-$importId-002',
      importId: importId,
      date: clock.now().subtract(const Duration(days: 2)),
      description: 'STARBUCKS COFFEE',
      amount: 110000,
      category: 'Makanan',
      status: DraftStatus.pending,
      anomalyReason: 'kemungkinan duplikat',
    );
    _statementDrafts[draft1.id] = draft1;
    _statementDrafts[draft2.id] = draft2;

    final existingImport = _statementImports[importId] ??
        StatementImport(
          id: importId,
          fileName: 'eStatement_GoPay_Juni2026.pdf',
          fileSizeBytes: 2450000,
          status: StatementImportStatus.reviewRequired,
          providerHint: 'gopay',
          requiresPassword: false,
          totalDetected: 145,
          needsReviewCount: 2,
          uploadedAt: clock.now(),
        );

    _statementImports[importId] = existingImport.copyWith(
      status: StatementImportStatus.reviewRequired,
      needsReviewCount: 2,
      totalDetected: 145,
    );
  }

  List<ParsedTransactionDraft> getDrafts(String importId) {
    var result =
        _statementDrafts.values.where((d) => d.importId == importId).toList();
    if (result.isEmpty) {
      _loadDraftsForImport(importId);
      result =
          _statementDrafts.values.where((d) => d.importId == importId).toList();
    }
    return result;
  }

  void updateDraftStatus(String draftId, DraftStatus newStatus) {
    final draft = _statementDrafts[draftId];
    if (draft != null) {
      _statementDrafts[draftId] = draft.copyWith(status: newStatus);
    }
  }

  bool confirmStatementImport(String importId) {
    var import = _statementImports[importId];
    if (import == null) {
      _loadDraftsForImport(importId);
      import = _statementImports[importId];
    }
    if (import == null) return false;

    // Convert validated or pending drafts to canonical transactions
    final drafts = getDrafts(importId);
    for (final draft in drafts) {
      if (draft.status != DraftStatus.deleted) {
        final tx = Transaction(
          id: 'tx-stm-${draft.id}',
          type: TransactionType.expense,
          amount: draft.amount,
          category: draft.category,
          description: draft.description,
          date: draft.date,
          isAnomaly: draft.anomalyReason != null,
          anomalyReason: draft.anomalyReason,
          confirmedByPartner: true,
          createdAt: clock.now(),
        );
        _transactions[tx.id] = tx;
      }
    }

    _statementImports[importId] = import.copyWith(
      status: StatementImportStatus.confirmed,
      needsReviewCount: 0,
    );
    return true;
  }

  // --- Goals Queries & Mutations ---
  List<FinancialGoal> getGoals() {
    return _goals.values.toList();
  }

  FinancialGoal? getGoalById(String id) {
    return _goals[id];
  }

  void addGoal(FinancialGoal goal) {
    _goals[goal.id] = goal;
  }

  bool removeGoal(String id) {
    return _goals.remove(id) != null;
  }

  FinancialGoal? addContributionToGoal(
    String goalId, {
    required String sourceName,
    required int amount,
  }) {
    final goal = _goals[goalId];
    if (goal == null) return null;

    final contribution = GoalContribution(
      id: 'c-${DateTime.now().millisecondsSinceEpoch}',
      sourceName: sourceName,
      date: clock.now(),
      amount: amount,
    );

    final updated = goal.copyWith(
      currentAmount: goal.currentAmount + amount,
      contributions: [contribution, ...goal.contributions],
    );

    _goals[goalId] = updated;
    return updated;
  }

  // --- Check-In Queries & Mutations ---
  WeeklyCheckIn? getCurrentCheckIn() {
    return _checkIns.values.firstOrNull ??
        WeeklyCheckIn(
          id: 'chk-week-32',
          weekPeriod: 'Minggu ke-3, Juli 2026',
          status: CheckInStatus.open,
          myEmotion: 'damai',
          mainConcern: 'keuangan',
          partnerSubmitted: false,
          createdAt: clock.now(),
        );
  }

  WeeklyCheckIn submitCheckIn(
      String checkInId, String emotion, String concern) {
    var chk = _checkIns[checkInId] ??
        WeeklyCheckIn(
          id: checkInId,
          weekPeriod: 'Minggu ke-3, Juli 2026',
          status: CheckInStatus.open,
          myEmotion: emotion,
          mainConcern: concern,
          partnerSubmitted: true,
          createdAt: clock.now(),
        );

    chk = chk.copyWith(
      myEmotion: emotion,
      mainConcern: concern,
      status: CheckInStatus.completed,
      sharedSummary:
          'Keuangan bulan ini stabil dan komunikasi dari Check-In mingguan menunjukkan tingkat stres yang rendah. Pertahankan ritme ini!',
    );
    _checkIns[checkInId] = chk;
    return chk;
  }

  WeeklyCheckIn? simulatePartnerSubmit(String checkInId) {
    final chk = _checkIns[checkInId];
    if (chk == null) return null;

    final updated = chk.copyWith(
      partnerSubmitted: true,
      status: CheckInStatus.completed,
      sharedSummary:
          'Keuangan bulan ini stabil dan komunikasi dari Check-In mingguan menunjukkan tingkat stres yang rendah. Pertahankan ritme ini!',
    );
    _checkIns[checkInId] = updated;
    return updated;
  }

  FamilyAssessment? getCurrentFamilyAssessment() {
    return _assessments.values.firstOrNull ??
        FamilyAssessment(
          id: 'asm-001',
          level: AssessmentLevel.stable,
          summaryText:
              'Keuangan bulan ini stabil dan komunikasi dari Check-In mingguan menunjukkan tingkat stres yang rendah. Pertahankan ritme ini!',
          recommendedAction:
              'Pertahankan komitmen tabungan bulanan dan lakukan check-in mingguan secara rutin.',
          createdAt: clock.now(),
        );
  }

  // --- Chat Queries & Mutations ---
  List<ChatSession> getChatSessions() {
    return _chatSessions.values.toList();
  }

  List<ChatMessage> getChatMessages(String sessionId) {
    return _chatMessages[sessionId] ?? [];
  }

  void deleteChatSession(String sessionId) {
    _chatSessions.remove(sessionId);
    _chatMessages.remove(sessionId);
  }

  ChatMessage sendChatMessage(String sessionId, String text) {
    final userMsg = ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      sessionId: sessionId,
      sender: MessageSender.user,
      content: text,
      timestamp: clock.now(),
    );

    final msgs = _chatMessages.putIfAbsent(sessionId, () => []);
    msgs.add(userMsg);

    // Generate assistant reply
    final assistantMsg = ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch + 1}',
      sessionId: sessionId,
      sender: MessageSender.assistant,
      content:
          'Terima kasih telah berbagi cerita. Saya di sini untuk mendampingi anda melihat kondisi finansial dan komunikasi secara netral.',
      timestamp: clock.now().add(const Duration(seconds: 1)),
      suggestedActions: const [
        'Tinjau transaksi',
        'Susun percakapan',
        'Bicara dengan ahli'
      ],
      safetyLevel: text.toLowerCase().contains('bahaya')
          ? SafetyLevel.urgentSafety
          : SafetyLevel.none,
    );
    msgs.add(assistantMsg);

    _chatSessions[sessionId] = ChatSession(
      id: sessionId,
      title: 'Konsultasi Finansial & Komunikasi',
      createdAt: clock.now(),
      lastMessage: text,
    );

    return assistantMsg;
  }

  // --- Recovery Sessions & Commitments Queries & Mutations ---
  List<RecoverySession> getRecoverySessions() {
    return _recoverySessions.values.toList();
  }

  RecoverySession getRecoverySession(String id) {
    return _recoverySessions[id] ??
        RecoverySession(
          id: id,
          title: 'Diskusi Anggaran Hiburan & Tabungan Rumah',
          topic: 'Pengelolaan Anggaran Bulanan',
          status: RecoverySessionStatus.readinessCheck,
          readinessLevel: ReadinessLevel.ready,
          createdAt: clock.now(),
          updatedAt: clock.now(),
        );
  }

  RecoverySession createRecoverySession(String title, String topic) {
    final session = RecoverySession(
      id: 'rec-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      topic: topic,
      status: RecoverySessionStatus.readinessCheck,
      createdAt: clock.now(),
      updatedAt: clock.now(),
    );
    _recoverySessions[session.id] = session;
    return session;
  }

  RecoverySession updateRecoverySession(RecoverySession session) {
    _recoverySessions[session.id] = session;
    return session;
  }

  List<Commitment> getCommitments() {
    return _commitments.values.toList();
  }

  Commitment createCommitment({
    required String recoverySessionId,
    required String title,
    required String description,
    required DateTime targetDate,
  }) {
    final cmt = Commitment(
      id: 'cmt-${DateTime.now().millisecondsSinceEpoch}',
      recoverySessionId: recoverySessionId,
      title: title,
      description: description,
      targetDate: targetDate,
      status: CommitmentStatus.active,
      createdBy: currentUser?.id ?? 'usr-joselin-001',
      approvedByPartner: true,
      progressPercentage: 10,
      createdAt: clock.now(),
    );
    _commitments[cmt.id] = cmt;
    return cmt;
  }

  Commitment updateCommitment(Commitment cmt) {
    _commitments[cmt.id] = cmt;
    return cmt;
  }

  // --- Professionals & Impact Simulation Queries ---
  List<Professional> getProfessionals([String? category]) {
    final list = _professionals.values.toList();
    if (category == null || category.isEmpty || category == 'all') {
      return list;
    }
    return list.where((p) => p.category == category).toList();
  }

  ImpactSimulation getImpactSimulation() {
    return const ImpactSimulation(
      id: 'sim-001',
      monthlyLivingCost: 12500000,
      childCount: 2,
      debtAmount: 0,
      financialImpactText:
          'Proyeksi sisa saldo bersih individu Anda adalah Rp 3.750.000 setelah estimasi pembagian dan biaya hukum.',
      childImpactText:
          'Kebutuhan logistik baru anak diperkirakan sebesar Rp 2.800.000/bln dan memerlukan waktu adaptasi 6-12 bulan.',
      disclaimer:
          'Simulasi ini bersifat proyeksi indikatif netral untuk membantu perencanaan finansial keluarga, bukan nasihat hukum atau prediksi perceraian.',
    );
  }
}
