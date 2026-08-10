import '../shared/models/chat_model.dart';
import '../shared/models/check_in_model.dart';
import '../shared/models/family_model.dart';
import '../shared/models/goal_model.dart';
import '../shared/models/professional_model.dart';
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
      name: 'Dana Darurat Keluarga',
      targetAmount: 10000000,
      currentAmount: 5500000,
      deadline: '2026-12-31',
      status: GoalStatus.active,
      approvedByPartner: true,
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
      name: 'Dr. Sarah Amalia, M.Psi',
      category: 'psikolog',
      specialization: 'Psikolog Perkahwinan & Keluarga',
      city: 'Jakarta Selatan',
      rating: 4.9,
      externalUrl: 'https://favera.id/professionals/sarah-amalia',
    );
    final prof2 = Professional(
      id: 'prof-002',
      name: 'Budi Santoso, CFP®',
      category: 'konselor_finansial',
      specialization: 'Perencana Keuangan Keluarga',
      city: 'Surabaya',
      rating: 4.8,
      externalUrl: 'https://favera.id/professionals/budi-santoso',
    );
    _professionals[prof1.id] = prof1;
    _professionals[prof2.id] = prof2;
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
      id: 'drf-001',
      importId: importId,
      date: clock.now().subtract(const Duration(days: 3)),
      description: 'APPLE.COM/BILL',
      amount: 1499000,
      category: 'Hiburan',
      status: DraftStatus.pending,
      anomalyReason: 'nominal berbeda dari kebiasaan',
    );
    final draft2 = ParsedTransactionDraft(
      id: 'drf-002',
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

    _statementImports[importId] = _statementImports[importId]!.copyWith(
      status: StatementImportStatus.reviewRequired,
      needsReviewCount: 2,
      totalDetected: 145,
    );
  }

  List<ParsedTransactionDraft> getDrafts(String importId) {
    return _statementDrafts.values
        .where((d) => d.importId == importId)
        .toList();
  }

  void updateDraftStatus(String draftId, DraftStatus newStatus) {
    final draft = _statementDrafts[draftId];
    if (draft != null) {
      _statementDrafts[draftId] = draft.copyWith(status: newStatus);
    }
  }

  bool confirmStatementImport(String importId) {
    final import = _statementImports[importId];
    if (import == null) return false;

    // Convert validated drafts to canonical transactions
    final drafts = getDrafts(importId);
    for (final draft in drafts) {
      if (draft.status == DraftStatus.validated) {
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

  void addGoal(FinancialGoal goal) {
    _goals[goal.id] = goal;
  }

  // --- Check-In Queries & Mutations ---
  WeeklyCheckIn? getCurrentCheckIn() {
    return _checkIns.values.firstOrNull;
  }

  void submitCheckIn(String checkInId, String emotion, String concern) {
    final chk = _checkIns[checkInId];
    if (chk != null) {
      _checkIns[checkInId] = chk.copyWith(
        myEmotion: emotion,
        mainConcern: concern,
        status: chk.partnerSubmitted
            ? CheckInStatus.completed
            : CheckInStatus.waitingForPartner,
        sharedSummary: chk.partnerSubmitted
            ? 'Hasil check-in minggu ini menunjukkan komunikasi cukup lancar dengan fokus perhatian pada pengelolaan anggaran bulanan.'
            : null,
      );
    }
  }

  // --- Chat Queries & Mutations ---
  List<ChatSession> getChatSessions() {
    return _chatSessions.values.toList();
  }

  List<ChatMessage> getChatMessages(String sessionId) {
    return _chatMessages[sessionId] ?? [];
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
}
