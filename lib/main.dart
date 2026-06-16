import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'theme.dart';

const supabaseUrl = 'https://txxdmukggvahnfrcktfk.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR4eGRtdWtnZ3ZhaG5mcmNrdGZrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE0OTkzNjQsImV4cCI6MjA5NzA3NTM2NH0.PJj65bbdrZ9KqKwj-ctYIty2aHaMcJ3PETOoRJMvDHI';
const authEmailDomain = 'users.cscquiz.app';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    runApp(
      const StartupErrorApp(
        message:
            'Supabase is not configured. Start the app with SUPABASE_URL and SUPABASE_ANON_KEY dart defines.',
      ),
    );
    return;
  }

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );
    final store = AppStore(Supabase.instance.client);
    await store.initialize();
    runApp(AppScope(store: store, child: const CscQuizApp()));
  } catch (error) {
    runApp(StartupErrorApp(message: 'Could not connect to Supabase: $error'));
  }
}

class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(message, textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );
  }
}

class CscQuizApp extends StatelessWidget {
  const CscQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSC Quiz Reviewer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const GateScreen(),
    );
  }
}

class AppScope extends InheritedNotifier<AppStore> {
  const AppScope({super.key, required AppStore store, required super.child})
    : super(notifier: store);

  static AppStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in context');
    return scope!.notifier!;
  }
}

enum UserRole { admin, user }

enum AccountStatus { pending, approved, rejected }

enum QuizMode { overall, area, subArea }

extension FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}

extension QuizModeLabel on QuizMode {
  String get label {
    switch (this) {
      case QuizMode.overall:
        return 'Overall';
      case QuizMode.area:
        return 'Area';
      case QuizMode.subArea:
        return 'Specific Field';
    }
  }
}

class AppUser {
  AppUser({
    required this.id,
    required this.fullName,
    required this.username,
    required this.password,
    required this.role,
    required this.status,
    required this.createdAt,
    this.email,
  });

  final int id;
  final String fullName;
  final String username;
  final String password;
  final UserRole role;
  final AccountStatus status;
  final String? email;
  final DateTime createdAt;
}

class ExamType {
  const ExamType({required this.id, required this.examName});
  final int id;
  final String examName;
}

class ExamArea {
  const ExamArea({
    required this.id,
    required this.examTypeId,
    required this.areaName,
  });

  final int id;
  final int examTypeId;
  final String areaName;
}

class ExamSubArea {
  const ExamSubArea({
    required this.id,
    required this.areaId,
    required this.subAreaName,
  });

  final int id;
  final int areaId;
  final String subAreaName;
}

class Question {
  Question({
    required this.id,
    required this.examTypeId,
    required this.areaId,
    required this.subAreaId,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    this.explanation = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final int id;
  final int examTypeId;
  final int areaId;
  final int subAreaId;
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;
  final String explanation;
  final DateTime createdAt;

  String optionText(String? letter) {
    switch (letter) {
      case 'A':
        return optionA;
      case 'B':
        return optionB;
      case 'C':
        return optionC;
      case 'D':
        return optionD;
      default:
        return 'No answer';
    }
  }

  Question copyWith({
    int? id,
    int? examTypeId,
    int? areaId,
    int? subAreaId,
    String? questionText,
    String? optionA,
    String? optionB,
    String? optionC,
    String? optionD,
    String? correctAnswer,
    String? explanation,
    DateTime? createdAt,
  }) {
    return Question(
      id: id ?? this.id,
      examTypeId: examTypeId ?? this.examTypeId,
      areaId: areaId ?? this.areaId,
      subAreaId: subAreaId ?? this.subAreaId,
      questionText: questionText ?? this.questionText,
      optionA: optionA ?? this.optionA,
      optionB: optionB ?? this.optionB,
      optionC: optionC ?? this.optionC,
      optionD: optionD ?? this.optionD,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class UserAnswer {
  UserAnswer({
    required this.questionId,
    required this.selectedAnswer,
    required this.timeSpentSeconds,
    required this.isTimeout,
    required this.isCorrect,
  });

  final int questionId;
  final String? selectedAnswer;
  final int timeSpentSeconds;
  final bool isTimeout;
  final bool isCorrect;
}

class QuizAttempt {
  QuizAttempt({
    required this.id,
    required this.userId,
    required this.examTypeId,
    this.areaId,
    this.subAreaId,
    required this.quizMode,
    required this.score,
    required this.totalQuestions,
    required this.timeLimitPerQuestion,
    required this.totalTimeSeconds,
    required this.dateTaken,
    required this.answers,
  });

  final int id;
  final int userId;
  final int examTypeId;
  final int? areaId;
  final int? subAreaId;
  final QuizMode quizMode;
  final int score;
  final int totalQuestions;
  final int timeLimitPerQuestion;
  final int totalTimeSeconds;
  final DateTime dateTaken;
  final List<UserAnswer> answers;

  double get percentage =>
      totalQuestions == 0 ? 0 : (score / totalQuestions) * 100;
}

class AnalyticsRow {
  AnalyticsRow({
    required this.examName,
    required this.areaName,
    this.subAreaName,
    required this.totalAnswered,
    required this.totalCorrect,
    required this.avgTime,
  });

  final String examName;
  final String areaName;
  final String? subAreaName;
  final int totalAnswered;
  final int totalCorrect;
  final double avgTime;

  double get accuracy =>
      totalAnswered == 0 ? 0 : (totalCorrect / totalAnswered) * 100;

  String get status {
    final value = accuracy;
    if (value >= 85) return 'Excellent';
    if (value >= 70) return 'Good';
    if (value >= 50) return 'Needs Practice';
    return 'Focus More';
  }
}

class AppStore extends ChangeNotifier {
  AppStore(this._client);

  final SupabaseClient _client;
  final Random _random = Random();
  final List<AppUser> users = [];
  final List<ExamType> examTypes = [];
  final List<ExamArea> examAreas = [];
  final List<ExamSubArea> examSubAreas = [];
  final List<Question> questions = [];
  final List<QuizAttempt> attempts = [];

  int _nextUserId = 1;
  int _nextQuestionId = 1;
  int? _currentUserId;

  AppUser? get currentUser {
    if (_currentUserId == null) return null;
    return users.where((user) => user.id == _currentUserId).firstOrNull;
  }

  bool get isLoggedIn => currentUser != null;
  bool get isAdmin => currentUser?.role == UserRole.admin;
  bool get canAccessDashboard {
    final user = currentUser;
    if (user == null) return false;
    return user.role == UserRole.admin || user.status == AccountStatus.approved;
  }

  Future<void> initialize() async {
    if (_client.auth.currentUser != null) {
      await _loadSessionData();
      if (canAccessDashboard) {
        await _loadCatalog();
        notifyListeners();
      }
    }
  }

  Future<void> _loadCatalog() async {
    final typeRows = await _client.from('exam_types').select().order('id');
    final areaRows = await _client.from('exam_areas').select().order('id');
    final subAreaRows = await _client
        .from('exam_sub_areas')
        .select()
        .order('id');
    final questionRows = await _client.from('questions').select().order('id');

    examTypes
      ..clear()
      ..addAll(
        typeRows.map(
          (row) => ExamType(
            id: _int(row['id']),
            examName: row['exam_name'] as String,
          ),
        ),
      );
    examAreas
      ..clear()
      ..addAll(
        areaRows.map(
          (row) => ExamArea(
            id: _int(row['id']),
            examTypeId: _int(row['exam_type_id']),
            areaName: row['area_name'] as String,
          ),
        ),
      );
    examSubAreas
      ..clear()
      ..addAll(
        subAreaRows.map(
          (row) => ExamSubArea(
            id: _int(row['id']),
            areaId: _int(row['area_id']),
            subAreaName: row['sub_area_name'] as String,
          ),
        ),
      );
    questions
      ..clear()
      ..addAll(questionRows.map(_questionFromRow));
  }

  Future<void> _loadSessionData() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      users.clear();
      attempts.clear();
      _currentUserId = null;
      return;
    }

    final profileRow = await _client
        .from('profiles')
        .select()
        .eq('auth_id', authUser.id)
        .single();
    final profile = _userFromRow(profileRow);
    _currentUserId = profile.id;

    final profileRows = profile.role == UserRole.admin
        ? await _client.from('profiles').select().order('id')
        : [profileRow];
    users
      ..clear()
      ..addAll(profileRows.map(_userFromRow));

    if (profile.role != UserRole.admin &&
        profile.status != AccountStatus.approved) {
      attempts.clear();
      notifyListeners();
      return;
    }

    final attemptRows = profile.role == UserRole.admin
        ? await _client
              .from('quiz_attempts')
              .select()
              .order('date_taken', ascending: false)
        : await _client
              .from('quiz_attempts')
              .select()
              .eq('user_id', profile.id)
              .order('date_taken', ascending: false);
    final answerRows = await _client.from('user_answers').select();
    final answersByAttempt = <int, List<UserAnswer>>{};
    for (final row in answerRows) {
      answersByAttempt
          .putIfAbsent(_int(row['attempt_id']), () => [])
          .add(_answerFromRow(row));
    }

    attempts
      ..clear()
      ..addAll(
        attemptRows.map(
          (row) =>
              _attemptFromRow(row, answersByAttempt[_int(row['id'])] ?? []),
        ),
      );
    notifyListeners();
  }

  AppUser _userFromRow(Map<String, dynamic> row) {
    return AppUser(
      id: _int(row['id']),
      fullName: row['full_name'] as String,
      username: row['username'] as String,
      password: '',
      role: row['role'] == 'admin' ? UserRole.admin : UserRole.user,
      status: _accountStatus(row['status']),
      email: row['email'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  Question _questionFromRow(Map<String, dynamic> row) {
    return Question(
      id: _int(row['id']),
      examTypeId: _int(row['exam_type_id']),
      areaId: _int(row['area_id']),
      subAreaId: _int(row['sub_area_id']),
      questionText: row['question_text'] as String,
      optionA: row['option_a'] as String,
      optionB: row['option_b'] as String,
      optionC: row['option_c'] as String,
      optionD: row['option_d'] as String,
      correctAnswer: row['correct_answer'] as String,
      explanation: row['explanation'] as String? ?? '',
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  UserAnswer _answerFromRow(Map<String, dynamic> row) {
    return UserAnswer(
      questionId: _int(row['question_id']),
      selectedAnswer: row['selected_answer'] as String?,
      timeSpentSeconds: _int(row['time_spent_seconds']),
      isTimeout: row['is_timeout'] as bool,
      isCorrect: row['is_correct'] as bool,
    );
  }

  QuizAttempt _attemptFromRow(
    Map<String, dynamic> row,
    List<UserAnswer> answers,
  ) {
    return QuizAttempt(
      id: _int(row['id']),
      userId: _int(row['user_id']),
      examTypeId: _int(row['exam_type_id']),
      areaId: _nullableInt(row['area_id']),
      subAreaId: _nullableInt(row['sub_area_id']),
      quizMode: QuizMode.values.byName(row['quiz_mode'] as String),
      score: _int(row['score']),
      totalQuestions: _int(row['total_questions']),
      timeLimitPerQuestion: _int(row['time_limit_per_question']),
      totalTimeSeconds: _int(row['total_time_seconds']),
      dateTaken: DateTime.parse(row['date_taken'] as String),
      answers: answers,
    );
  }

  Map<String, dynamic> _questionToRow(Question question) {
    return {
      'exam_type_id': question.examTypeId,
      'area_id': question.areaId,
      'sub_area_id': question.subAreaId,
      'question_text': question.questionText,
      'option_a': question.optionA,
      'option_b': question.optionB,
      'option_c': question.optionC,
      'option_d': question.optionD,
      'correct_answer': question.correctAnswer,
      'explanation': question.explanation,
    };
  }

  int _int(Object? value) => (value as num).toInt();
  int? _nullableInt(Object? value) => value == null ? null : _int(value);

  // Kept only as a readable record of the ZIP's original demo content.
  // Runtime data is loaded from Supabase.
  // ignore: unused_element
  void _seedData() {
    users.add(
      AppUser(
        id: _nextUserId++,
        fullName: 'System Admin',
        username: 'admin',
        password: '',
        role: UserRole.admin,
        status: AccountStatus.approved,
        createdAt: DateTime.now(),
      ),
    );

    examTypes.addAll(const [
      ExamType(id: 1, examName: 'Professional'),
      ExamType(id: 2, examName: 'Sub-Professional'),
    ]);

    examAreas.addAll(const [
      ExamArea(id: 1, examTypeId: 1, areaName: 'Verbal Ability'),
      ExamArea(id: 2, examTypeId: 1, areaName: 'Analytical Ability'),
      ExamArea(id: 3, examTypeId: 1, areaName: 'Numerical Ability'),
      ExamArea(id: 4, examTypeId: 1, areaName: 'General Information'),
      ExamArea(id: 5, examTypeId: 1, areaName: 'Clerical Operations'),
      ExamArea(id: 6, examTypeId: 2, areaName: 'Verbal Ability'),
      ExamArea(id: 7, examTypeId: 2, areaName: 'Numerical Ability'),
      ExamArea(id: 8, examTypeId: 2, areaName: 'General Information'),
      ExamArea(id: 9, examTypeId: 2, areaName: 'Clerical Operations'),
    ]);

    examSubAreas.addAll(const [
      ExamSubArea(id: 1, areaId: 1, subAreaName: 'Grammar and correct usage'),
      ExamSubArea(id: 2, areaId: 1, subAreaName: 'Vocabulary'),
      ExamSubArea(id: 3, areaId: 1, subAreaName: 'Paragraph organization'),
      ExamSubArea(id: 4, areaId: 1, subAreaName: 'Reading comprehension'),
      ExamSubArea(id: 5, areaId: 2, subAreaName: 'Logic and reasoning'),
      ExamSubArea(
        id: 6,
        areaId: 2,
        subAreaName: 'Identifying assumptions and conclusions',
      ),
      ExamSubArea(id: 7, areaId: 2, subAreaName: 'Data interpretation'),
      ExamSubArea(id: 8, areaId: 3, subAreaName: 'Basic mathematics'),
      ExamSubArea(id: 9, areaId: 3, subAreaName: 'Percentages'),
      ExamSubArea(id: 10, areaId: 3, subAreaName: 'Fractions and decimals'),
      ExamSubArea(id: 11, areaId: 3, subAreaName: 'Word problems'),
      ExamSubArea(id: 12, areaId: 3, subAreaName: 'Statistics'),
      ExamSubArea(id: 13, areaId: 4, subAreaName: 'Philippine Constitution'),
      ExamSubArea(id: 14, areaId: 4, subAreaName: 'Philippine history'),
      ExamSubArea(id: 15, areaId: 4, subAreaName: 'Current events'),
      ExamSubArea(id: 16, areaId: 4, subAreaName: 'Environment'),
      ExamSubArea(id: 17, areaId: 4, subAreaName: 'Science and technology'),
      ExamSubArea(id: 18, areaId: 4, subAreaName: 'Government programs'),
      ExamSubArea(id: 19, areaId: 5, subAreaName: 'Filing systems'),
      ExamSubArea(id: 20, areaId: 5, subAreaName: 'Office procedures'),
      ExamSubArea(id: 21, areaId: 5, subAreaName: 'Alphabetizing'),
      ExamSubArea(id: 22, areaId: 5, subAreaName: 'Records management'),
      ExamSubArea(id: 23, areaId: 6, subAreaName: 'Grammar'),
      ExamSubArea(id: 24, areaId: 6, subAreaName: 'Vocabulary'),
      ExamSubArea(id: 25, areaId: 6, subAreaName: 'Reading comprehension'),
      ExamSubArea(id: 26, areaId: 7, subAreaName: 'Basic arithmetic'),
      ExamSubArea(id: 27, areaId: 7, subAreaName: 'Fractions'),
      ExamSubArea(id: 28, areaId: 7, subAreaName: 'Percentages'),
      ExamSubArea(id: 29, areaId: 7, subAreaName: 'Word problems'),
      ExamSubArea(id: 30, areaId: 8, subAreaName: 'Philippine Constitution'),
      ExamSubArea(id: 31, areaId: 8, subAreaName: 'History'),
      ExamSubArea(id: 32, areaId: 8, subAreaName: 'Current events'),
      ExamSubArea(id: 33, areaId: 8, subAreaName: 'Science and environment'),
      ExamSubArea(id: 34, areaId: 9, subAreaName: 'Filing'),
      ExamSubArea(id: 35, areaId: 9, subAreaName: 'Indexing'),
      ExamSubArea(id: 36, areaId: 9, subAreaName: 'Office practices'),
      ExamSubArea(
        id: 37,
        areaId: 9,
        subAreaName: 'Following written instructions',
      ),
    ]);

    addQuestionSilently(
      examTypeId: 1,
      areaId: 1,
      subAreaId: 2,
      questionText: 'Which word is most similar in meaning to “honest”?',
      optionA: 'Truthful',
      optionB: 'Careless',
      optionC: 'Weak',
      optionD: 'Slow',
      correctAnswer: 'A',
      explanation: 'Honest means truthful.',
    );
    addQuestionSilently(
      examTypeId: 1,
      areaId: 3,
      subAreaId: 8,
      questionText:
          'If 5 workers can finish a task in 10 days, how many worker-days are needed?',
      optionA: '15',
      optionB: '25',
      optionC: '50',
      optionD: '100',
      correctAnswer: 'C',
      explanation: '5 workers × 10 days = 50 worker-days.',
    );
    addQuestionSilently(
      examTypeId: 1,
      areaId: 1,
      subAreaId: 1,
      questionText: 'Which sentence is grammatically correct?',
      optionA: 'She go to work every day.',
      optionB: 'She goes to work every day.',
      optionC: 'She going to work every day.',
      optionD: 'She gone to work every day.',
      correctAnswer: 'B',
      explanation: 'For singular subject “She,” use “goes.”',
    );
    addQuestionSilently(
      examTypeId: 1,
      areaId: 2,
      subAreaId: 5,
      questionText:
          'All government employees are public servants. Maria is a government employee. What can be concluded?',
      optionA: 'Maria is a public servant.',
      optionB: 'Maria is a private worker.',
      optionC: 'Maria is unemployed.',
      optionD: 'No conclusion can be made.',
      correctAnswer: 'A',
      explanation: 'The conclusion follows from the two statements.',
    );
    addQuestionSilently(
      examTypeId: 1,
      areaId: 4,
      subAreaId: 13,
      questionText:
          'The 1987 Philippine Constitution establishes which principle?',
      optionA: 'Separation of powers',
      optionB: 'Absolute monarchy',
      optionC: 'One-party rule',
      optionD: 'No elections',
      correctAnswer: 'A',
      explanation:
          'The government has separate executive, legislative, and judicial branches.',
    );
    addQuestionSilently(
      examTypeId: 1,
      areaId: 5,
      subAreaId: 21,
      questionText: 'Which word comes first in alphabetical order?',
      optionA: 'Clerk',
      optionB: 'Claim',
      optionC: 'Client',
      optionD: 'Class',
      correctAnswer: 'D',
      explanation: 'Class comes before Claim, Clerk, and Client.',
    );
    addQuestionSilently(
      examTypeId: 2,
      areaId: 7,
      subAreaId: 26,
      questionText: 'What is 25 + 37?',
      optionA: '52',
      optionB: '62',
      optionC: '72',
      optionD: '82',
      correctAnswer: 'B',
      explanation: '25 + 37 = 62.',
    );
    addQuestionSilently(
      examTypeId: 2,
      areaId: 6,
      subAreaId: 24,
      questionText: 'Which is the correct spelling?',
      optionA: 'Recieve',
      optionB: 'Receive',
      optionC: 'Receeve',
      optionD: 'Reciive',
      correctAnswer: 'B',
      explanation: 'The correct spelling is receive.',
    );
    addQuestionSilently(
      examTypeId: 2,
      areaId: 6,
      subAreaId: 24,
      questionText: 'What is the opposite of “increase”?',
      optionA: 'Add',
      optionB: 'Raise',
      optionC: 'Decrease',
      optionD: 'Improve',
      correctAnswer: 'C',
      explanation: 'The opposite of increase is decrease.',
    );
    addQuestionSilently(
      examTypeId: 2,
      areaId: 8,
      subAreaId: 30,
      questionText: 'What is the supreme law of the Philippines?',
      optionA: 'Civil Code',
      optionB: '1987 Philippine Constitution',
      optionC: 'Labor Code',
      optionD: 'Local ordinance',
      correctAnswer: 'B',
      explanation: 'The Constitution is the supreme law of the country.',
    );
    addQuestionSilently(
      examTypeId: 2,
      areaId: 9,
      subAreaId: 34,
      questionText:
          'In office filing, records are usually arranged to make them easy to:',
      optionA: 'Hide',
      optionB: 'Retrieve',
      optionC: 'Destroy',
      optionD: 'Ignore',
      correctAnswer: 'B',
      explanation: 'The purpose of filing is easy retrieval of records.',
    );
    addQuestionSilently(
      examTypeId: 2,
      areaId: 9,
      subAreaId: 37,
      questionText:
          'If an instruction says “Submit the form before 5 PM,” what should you do?',
      optionA: 'Submit after 5 PM',
      optionB: 'Submit before 5 PM',
      optionC: 'Do not submit',
      optionD: 'Submit next week',
      correctAnswer: 'B',
      explanation:
          'Following written instructions requires submitting before the given deadline.',
    );
  }

  void addQuestionSilently({
    required int examTypeId,
    required int areaId,
    required int subAreaId,
    required String questionText,
    required String optionA,
    required String optionB,
    required String optionC,
    required String optionD,
    required String correctAnswer,
    String explanation = '',
  }) {
    questions.add(
      Question(
        id: _nextQuestionId++,
        examTypeId: examTypeId,
        areaId: areaId,
        subAreaId: subAreaId,
        questionText: questionText,
        optionA: optionA,
        optionB: optionB,
        optionC: optionC,
        optionD: optionD,
        correctAnswer: correctAnswer,
        explanation: explanation,
      ),
    );
  }

  Future<String?> login(String username, String password) async {
    final cleanUsername = username.trim().toLowerCase();
    if (!_validUsername(cleanUsername)) {
      return 'Enter a valid username.';
    }

    try {
      await _client.auth.signInWithPassword(
        email: _authEmail(cleanUsername),
        password: password,
      );
      await _loadSessionData();
      if (canAccessDashboard) {
        await _loadCatalog();
        notifyListeners();
      }
      return null;
    } on AuthException catch (error) {
      if (error.code == 'email_not_confirmed') {
        return 'This account is waiting for email confirmation. Disable Confirm email in Supabase Auth, then delete this pending user and register again.';
      }
      return 'Invalid username or password.';
    } on PostgrestException catch (error) {
      await _client.auth.signOut();
      return 'Account profile could not be loaded: ${error.message}';
    }
  }

  Future<String?> register({
    required String fullName,
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    final cleanName = fullName.trim();
    final cleanUsername = username.trim().toLowerCase();

    if (cleanName.isEmpty ||
        cleanUsername.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      return 'Please complete all fields.';
    }
    if (!_validUsername(cleanUsername)) {
      return 'Username may contain letters, numbers, dots, underscores, and hyphens only.';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match.';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    try {
      final response = await _client.auth.signUp(
        email: _authEmail(cleanUsername),
        password: password,
        data: {'username': cleanUsername, 'full_name': cleanName},
      );
      if (response.session != null) {
        await _client.auth.signOut();
        return null;
      }

      return 'Account created, but Supabase email confirmation is enabled. Disable Confirm email in Authentication > Sign In / Providers > Email, delete this pending user, then register again.';
    } on AuthException catch (error) {
      if (error.code == 'over_email_send_rate_limit' ||
          error.message.toLowerCase().contains('email rate limit')) {
        return 'Supabase email limit reached. Disable Confirm email in Authentication > Sign In / Providers > Email, then wait for the temporary limit to reset before registering again.';
      }
      if (error.code == 'user_already_exists' || error.code == 'email_exists') {
        return 'That username is already registered.';
      }
      if (error.message.toLowerCase().contains('database error')) {
        return 'Registration could not be completed. Check that the username is available and the profile trigger is installed.';
      }
      return error.message;
    } on PostgrestException catch (error) {
      return error.message;
    }
  }

  Future<void> setProfileStatus(int userId, AccountStatus status) async {
    await _client.rpc(
      'set_profile_status',
      params: {'p_profile_id': userId, 'p_status': status.name},
    );
    await _loadSessionData();
    notifyListeners();
  }

  Future<void> refreshSession() async {
    await _loadSessionData();
    if (canAccessDashboard) {
      await _loadCatalog();
      notifyListeners();
    }
  }

  AccountStatus _accountStatus(Object? value) =>
      AccountStatus.values
          .where((status) => status.name == value)
          .firstOrNull ??
      AccountStatus.approved;

  bool _validUsername(String value) =>
      RegExp(r'^[a-z0-9._-]+$').hasMatch(value);
  String _authEmail(String username) => '$username@$authEmailDomain';

  Future<void> logout() async {
    await _client.auth.signOut();
    _currentUserId = null;
    users.clear();
    attempts.clear();
    notifyListeners();
  }

  ExamType? examTypeById(int id) =>
      examTypes.where((item) => item.id == id).firstOrNull;
  ExamArea? areaById(int id) =>
      examAreas.where((item) => item.id == id).firstOrNull;
  ExamSubArea? subAreaById(int id) =>
      examSubAreas.where((item) => item.id == id).firstOrNull;
  Question? questionById(int id) =>
      questions.where((item) => item.id == id).firstOrNull;
  AppUser? userById(int id) => users.where((item) => item.id == id).firstOrNull;

  List<ExamArea> areasForExam(int examTypeId) {
    return examAreas.where((item) => item.examTypeId == examTypeId).toList();
  }

  List<ExamSubArea> subAreasForArea(int areaId) {
    return examSubAreas.where((item) => item.areaId == areaId).toList();
  }

  int questionCountForArea(int areaId) {
    return questions.where((item) => item.areaId == areaId).length;
  }

  int questionCountForSubArea(int subAreaId) {
    return questions.where((item) => item.subAreaId == subAreaId).length;
  }

  String coverageLabel(QuizAttempt attempt) {
    if (attempt.quizMode == QuizMode.area && attempt.areaId != null) {
      return areaById(attempt.areaId!)?.areaName ?? 'Area';
    }
    if (attempt.quizMode == QuizMode.subArea && attempt.subAreaId != null) {
      final sub = subAreaById(attempt.subAreaId!);
      final area = sub == null ? null : areaById(sub.areaId);
      return '${area?.areaName ?? 'Area'} - ${sub?.subAreaName ?? 'Specific Field'}';
    }
    return 'Overall';
  }

  String questionCoverage(Question question) {
    final area = areaById(question.areaId)?.areaName ?? 'Area';
    final sub =
        subAreaById(question.subAreaId)?.subAreaName ?? 'Specific Field';
    return '$area - $sub';
  }

  List<Question> quizQuestions({
    required QuizMode quizMode,
    int? examTypeId,
    int? areaId,
    int? subAreaId,
    int limit = 20,
  }) {
    Iterable<Question> results = questions;

    if (quizMode == QuizMode.overall && examTypeId != null) {
      results = results.where((item) => item.examTypeId == examTypeId);
    }
    if (quizMode == QuizMode.area && areaId != null) {
      final area = areaById(areaId);
      if (area == null) return [];
      results = results.where(
        (item) => item.examTypeId == area.examTypeId && item.areaId == areaId,
      );
    }
    if (quizMode == QuizMode.subArea && subAreaId != null) {
      final subArea = subAreaById(subAreaId);
      if (subArea == null) return [];
      final area = areaById(subArea.areaId);
      if (area == null) return [];
      results = results.where(
        (item) =>
            item.examTypeId == area.examTypeId &&
            item.areaId == area.id &&
            item.subAreaId == subAreaId,
      );
    }

    final list = results.toList()..shuffle(_random);
    return list.take(min(limit, list.length)).toList();
  }

  Future<Question> addQuestion(Question question) async {
    final row = await _client
        .from('questions')
        .insert(_questionToRow(question))
        .select()
        .single();
    final saved = _questionFromRow(row);
    questions.add(saved);
    notifyListeners();
    return saved;
  }

  Future<void> updateQuestion(Question updatedQuestion) async {
    final row = await _client
        .from('questions')
        .update(_questionToRow(updatedQuestion))
        .eq('id', updatedQuestion.id)
        .select()
        .single();
    final saved = _questionFromRow(row);
    final index = questions.indexWhere(
      (question) => question.id == updatedQuestion.id,
    );
    if (index >= 0) {
      questions[index] = saved;
      notifyListeners();
    }
  }

  Future<void> deleteQuestion(int questionId) async {
    await _client.from('questions').delete().eq('id', questionId);
    questions.removeWhere((question) => question.id == questionId);
    notifyListeners();
  }

  Future<QuizAttempt> submitQuiz({
    required QuizMode quizMode,
    required int examTypeId,
    int? areaId,
    int? subAreaId,
    required List<Question> quizQuestions,
    required Map<int, String?> selectedAnswers,
    required Map<int, int> timeSpent,
    required Map<int, bool> timedOut,
    required int timeLimitPerQuestion,
  }) async {
    final reviewAnswers = <UserAnswer>[];

    for (final question in quizQuestions) {
      final selected = selectedAnswers[question.id];
      final safeSelected = ['A', 'B', 'C', 'D'].contains(selected)
          ? selected
          : null;
      final spent = (timeSpent[question.id] ?? 0)
          .clamp(0, timeLimitPerQuestion)
          .toInt();
      final timeout = timedOut[question.id] ?? false;
      final isCorrect =
          safeSelected != null && safeSelected == question.correctAnswer;

      reviewAnswers.add(
        UserAnswer(
          questionId: question.id,
          selectedAnswer: safeSelected,
          timeSpentSeconds: spent,
          isTimeout: timeout,
          isCorrect: isCorrect,
        ),
      );
    }

    final attemptId = _int(
      await _client.rpc(
        'submit_quiz',
        params: {
          'p_exam_type_id': examTypeId,
          'p_area_id': quizMode == QuizMode.overall ? null : areaId,
          'p_sub_area_id': quizMode == QuizMode.subArea ? subAreaId : null,
          'p_quiz_mode': quizMode.name,
          'p_time_limit_per_question': timeLimitPerQuestion,
          'p_answers': reviewAnswers
              .map(
                (answer) => {
                  'question_id': answer.questionId,
                  'selected_answer': answer.selectedAnswer,
                  'time_spent_seconds': answer.timeSpentSeconds,
                  'is_timeout': answer.isTimeout,
                },
              )
              .toList(),
        },
      ),
    );
    final attemptRow = await _client
        .from('quiz_attempts')
        .select()
        .eq('id', attemptId)
        .single();
    final answerRows = await _client
        .from('user_answers')
        .select()
        .eq('attempt_id', attemptId)
        .order('id');
    final savedAnswers = answerRows.map(_answerFromRow).toList();
    final attempt = _attemptFromRow(attemptRow, savedAnswers);
    attempts.add(attempt);
    notifyListeners();
    return attempt;
  }

  List<QuizAttempt> userAttempts(int userId) {
    final list = attempts.where((attempt) => attempt.userId == userId).toList();
    list.sort((a, b) => b.dateTaken.compareTo(a.dateTaken));
    return list;
  }

  QuizAttempt? attemptById(int id) =>
      attempts.where((attempt) => attempt.id == id).firstOrNull;

  List<AnalyticsRow> progressByArea(int userId) {
    final Map<String, _ProgressBucket> buckets = {};
    for (final attempt in userAttempts(userId)) {
      for (final answer in attempt.answers) {
        final question = questionById(answer.questionId);
        if (question == null) continue;
        final exam = examTypeById(question.examTypeId)?.examName ?? 'Exam';
        final area = areaById(question.areaId)?.areaName ?? 'Area';
        final key = '${question.examTypeId}_${question.areaId}';
        buckets.putIfAbsent(
          key,
          () => _ProgressBucket(examName: exam, areaName: area),
        );
        buckets[key]!.add(answer);
      }
    }

    final rows = buckets.values.map((bucket) => bucket.toAreaRow()).toList();
    rows.sort(
      (a, b) => '${a.examName} ${a.areaName}'.compareTo(
        '${b.examName} ${b.areaName}',
      ),
    );
    return rows;
  }

  List<AnalyticsRow> progressBySubArea(int userId) {
    final Map<String, _ProgressBucket> buckets = {};
    for (final attempt in userAttempts(userId)) {
      for (final answer in attempt.answers) {
        final question = questionById(answer.questionId);
        if (question == null) continue;
        final exam = examTypeById(question.examTypeId)?.examName ?? 'Exam';
        final area = areaById(question.areaId)?.areaName ?? 'Area';
        final subArea =
            subAreaById(question.subAreaId)?.subAreaName ?? 'Specific Field';
        final key =
            '${question.examTypeId}_${question.areaId}_${question.subAreaId}';
        buckets.putIfAbsent(
          key,
          () => _ProgressBucket(
            examName: exam,
            areaName: area,
            subAreaName: subArea,
          ),
        );
        buckets[key]!.add(answer);
      }
    }

    final rows = buckets.values.map((bucket) => bucket.toSubAreaRow()).toList();
    rows.sort(
      (a, b) => '${a.examName} ${a.areaName} ${a.subAreaName}'.compareTo(
        '${b.examName} ${b.areaName} ${b.subAreaName}',
      ),
    );
    return rows;
  }

  List<MapEntry<ExamType, int>> questionCountByExamType() {
    return examTypes
        .map(
          (type) => MapEntry(
            type,
            questions
                .where((question) => question.examTypeId == type.id)
                .length,
          ),
        )
        .toList();
  }

  List<MapEntry<ExamArea, int>> questionCountByArea() {
    return examAreas
        .map(
          (area) => MapEntry(
            area,
            questions.where((question) => question.areaId == area.id).length,
          ),
        )
        .toList();
  }
}

class _ProgressBucket {
  _ProgressBucket({
    required this.examName,
    required this.areaName,
    this.subAreaName,
  });

  final String examName;
  final String areaName;
  final String? subAreaName;
  int answered = 0;
  int correct = 0;
  int totalTime = 0;

  void add(UserAnswer answer) {
    answered++;
    if (answer.isCorrect) correct++;
    totalTime += answer.timeSpentSeconds;
  }

  AnalyticsRow toAreaRow() {
    return AnalyticsRow(
      examName: examName,
      areaName: areaName,
      totalAnswered: answered,
      totalCorrect: correct,
      avgTime: answered == 0 ? 0 : totalTime / answered,
    );
  }

  AnalyticsRow toSubAreaRow() {
    return AnalyticsRow(
      examName: examName,
      areaName: areaName,
      subAreaName: subAreaName,
      totalAnswered: answered,
      totalCorrect: correct,
      avgTime: answered == 0 ? 0 : totalTime / answered,
    );
  }
}

class GateScreen extends StatelessWidget {
  const GateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final user = store.currentUser;

    if (user == null) return const WelcomeScreen();
    if (user.role == UserRole.admin) return const AdminDashboardScreen();
    if (user.status == AccountStatus.pending) {
      return const PendingApprovalScreen();
    }
    if (user.status == AccountStatus.rejected) {
      return const RejectedAccountScreen();
    }
    return const UserDashboardScreen();
  }
}

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _AccountStatusScreen(
      title: 'Pending Approval',
      icon: Icons.hourglass_top_rounded,
      color: AppColors.sunshine,
      message:
          'Your account is pending admin approval. Please check again after an administrator approves your account.',
      actionLabel: 'Check status',
      onAction: () => AppScope.of(context).refreshSession(),
    );
  }
}

class RejectedAccountScreen extends StatelessWidget {
  const RejectedAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AccountStatusScreen(
      title: 'Account Rejected',
      icon: Icons.block_rounded,
      color: AppColors.errorRed,
      message:
          'This account was rejected by the administrator. Please contact the administrator if this was a mistake.',
    );
  }
}

class _AccountStatusScreen extends StatelessWidget {
  const _AccountStatusScreen({
    required this.title,
    required this.icon,
    required this.color,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String message;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CircleIcon(icon: icon, color: color),
                  const SizedBox(height: 16),
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(message),
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () async => onAction!(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(actionLabel!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
              children: [
                Row(
                  children: [
                    const _BrandMark(),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                      child: const Text('Log in'),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 720;
                    final intro = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.sunshine,
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                          child: const Text(
                            'CIVIL SERVICE REVIEWER',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Play to gain\nyour knowledge.',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Short, focused quizzes that turn Civil Service exam prep into a daily winning habit.',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: isWide ? 220 : double.infinity,
                          child: FilledButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            ),
                            child: const Text('Get started'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: isWide ? 220 : double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            ),
                            child: const Text('Create an account'),
                          ),
                        ),
                      ],
                    );
                    if (!isWide) {
                      return Column(
                        children: [
                          const _WelcomeArtwork(height: 270),
                          const SizedBox(height: 28),
                          intro,
                        ],
                      );
                    }
                    return SizedBox(
                      height: 470,
                      child: Row(
                        children: [
                          Expanded(child: intro),
                          const SizedBox(width: 44),
                          const Expanded(child: _WelcomeArtwork(height: 450)),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 34),
                Text(
                  'Everything you need to get ready',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 14),
                const Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _FeaturePill(
                      label: 'Professional',
                      icon: Icons.school_rounded,
                      color: AppColors.coral,
                    ),
                    _FeaturePill(
                      label: 'Sub-Professional',
                      icon: Icons.menu_book_rounded,
                      color: AppColors.sky,
                    ),
                    _FeaturePill(
                      label: 'Progress analytics',
                      icon: Icons.auto_graph_rounded,
                      color: AppColors.mint,
                    ),
                    _FeaturePill(
                      label: 'Timed practice',
                      icon: Icons.timer_rounded,
                      color: AppColors.sunshine,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  String? _message;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final store = AppScope.of(context);
    final error = await store.login(_username.text, _password.text);
    if (!mounted) return;
    if (error != null) {
      setState(() => _message = error);
      return;
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const GateScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Login',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_message != null)
              _MessageBox(message: _message!, isError: true),
            TextFormField(
              controller: _username,
              decoration: const InputDecoration(labelText: 'Username'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Username is required.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) => value == null || value.isEmpty
                  ? 'Password is required.'
                  : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 18),
            FilledButton(onPressed: _submit, child: const Text('Login')),
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
              child: const Text('No account yet? Register here'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  String? _message;
  bool _isError = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _fullName.dispose();
    _username.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _message = null;
    });

    try {
      final store = AppScope.of(context);
      final error = await store.register(
        fullName: _fullName.text,
        username: _username.text,
        password: _password.text,
        confirmPassword: _confirmPassword.text,
      );
      if (!mounted) return;
      if (error != null) {
        setState(() {
          _message = error;
          _isError = true;
        });
        return;
      }
      _password.clear();
      _confirmPassword.clear();
      setState(() {
        _message = 'Your account is pending admin approval.';
        _isError = false;
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Create User Account',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_message != null)
              _MessageBox(message: _message!, isError: _isError),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary4,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'Create your account now. An administrator must approve it before you can access the quiz dashboard.',
                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fullName,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Full name is required.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _username,
              decoration: const InputDecoration(labelText: 'Username'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Username is required.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) => value == null || value.length < 6
                  ? 'Password must be at least 6 characters.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmPassword,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
              validator: (value) => value == null || value.isEmpty
                  ? 'Confirm password is required.'
                  : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: Text(_isSubmitting ? 'Please wait...' : 'Create account'),
            ),
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int? _overallExamTypeId;
  int? _areaId;
  int? _subAreaId;

  void _startOverall() {
    if (_overallExamTypeId == null) {
      _showSnack('Select an exam type first.');
      return;
    }
    _startQuiz(quizMode: QuizMode.overall, examTypeId: _overallExamTypeId);
  }

  void _startArea() {
    if (_areaId == null) {
      _showSnack('Select an area first.');
      return;
    }
    final area = AppScope.of(context).areaById(_areaId!);
    _startQuiz(
      quizMode: QuizMode.area,
      examTypeId: area?.examTypeId,
      areaId: _areaId,
    );
  }

  void _startSubArea() {
    if (_subAreaId == null) {
      _showSnack('Select a specific field first.');
      return;
    }
    final store = AppScope.of(context);
    final sub = store.subAreaById(_subAreaId!);
    final area = sub == null ? null : store.areaById(sub.areaId);
    _startQuiz(
      quizMode: QuizMode.subArea,
      examTypeId: area?.examTypeId,
      areaId: area?.id,
      subAreaId: _subAreaId,
    );
  }

  void _startQuiz({
    required QuizMode quizMode,
    int? examTypeId,
    int? areaId,
    int? subAreaId,
  }) {
    final store = AppScope.of(context);
    final list = store.quizQuestions(
      quizMode: quizMode,
      examTypeId: examTypeId,
      areaId: areaId,
      subAreaId: subAreaId,
    );
    if (list.isEmpty) {
      _showSnack('No questions available for this selected coverage yet.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          quizMode: quizMode,
          examTypeId: examTypeId ?? list.first.examTypeId,
          areaId: areaId,
          subAreaId: subAreaId,
          questions: list,
        ),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final user = store.currentUser!;
    final recent = store.userAttempts(user.id).take(5).toList();

    return AppScaffold(
      title: 'Quiz',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready, ${user.fullName.split(' ').first}?',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 6),
                    const Text('Pick a challenge and keep your streak moving.'),
                  ],
                ),
              ),
              _RoundAction(
                icon: Icons.auto_graph_rounded,
                tooltip: 'View my progress',
                color: AppColors.sunshine,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            margin: const EdgeInsets.only(bottom: 22),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.borderGray),
            ),
            child: const Row(
              children: [
                _CircleIcon(
                  icon: Icons.emoji_events_rounded,
                  color: AppColors.sunshine,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Build your exam-day confidence',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Mix full reviews with focused practice.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const _SectionTitle(title: 'Popular games', accent: 'HOT'),
          _QuizSetupCard(
            title: 'Overall challenge',
            description: 'A lively mix of questions from every exam area.',
            icon: Icons.bolt_rounded,
            color: AppColors.coral,
            children: [
              DropdownButtonFormField<int>(
                initialValue: _overallExamTypeId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Exam type'),
                items: store.examTypes
                    .map(
                      (type) => DropdownMenuItem(
                        value: type.id,
                        child: Text(
                          type.examName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _overallExamTypeId = value),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow_rounded),
                onPressed: _startOverall,
                label: const Text('Play overall'),
              ),
            ],
          ),
          _QuizSetupCard(
            title: 'Area sprint',
            description: 'Sharpen one core skill with a targeted round.',
            icon: Icons.track_changes_rounded,
            color: AppColors.mint,
            children: [
              DropdownButtonFormField<int>(
                initialValue: _areaId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Area covered'),
                items: store.examAreas
                    .map(
                      (area) => DropdownMenuItem(
                        value: area.id,
                        enabled: store.questionCountForArea(area.id) > 0,
                        child: Text(
                          '${area.areaName} (${store.questionCountForArea(area.id)})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _areaId = value),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow_rounded),
                onPressed: _startArea,
                label: const Text('Play by area'),
              ),
            ],
          ),
          _QuizSetupCard(
            title: 'Topic focus',
            description: 'Zoom in on one field and make it a strength.',
            icon: Icons.psychology_alt_rounded,
            color: AppColors.sky,
            children: [
              DropdownButtonFormField<int>(
                initialValue: _subAreaId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Specific field'),
                items: store.examSubAreas.map((sub) {
                  return DropdownMenuItem(
                    value: sub.id,
                    enabled: store.questionCountForSubArea(sub.id) > 0,
                    child: Text(
                      '${sub.subAreaName} (${store.questionCountForSubArea(sub.id)})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _subAreaId = value),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow_rounded),
                onPressed: _startSubArea,
                label: const Text('Play topic'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _SectionTitle(title: 'Recent played'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Attempts',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (recent.isEmpty) const Text('No quiz attempts yet.'),
                  ...recent.map((attempt) {
                    final exam =
                        store.examTypeById(attempt.examTypeId)?.examName ??
                        'Exam';
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      title: Text(
                        '$exam - ${store.coverageLabel(attempt)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${formatDateTime(attempt.dateTaken)} • ${attempt.score}/${attempt.totalQuestions} • ${attempt.percentage.toStringAsFixed(2)}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: attempt.percentage >= 70
                              ? AppColors.successGreen.withAlpha(25)
                              : attempt.percentage >= 50
                              ? AppColors.primary4
                              : AppColors.errorRed.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          attempt.percentage >= 70
                              ? Icons.trending_up_rounded
                              : attempt.percentage >= 50
                              ? Icons.trending_down_rounded
                              : Icons.warning_rounded,
                          color: attempt.percentage >= 70
                              ? AppColors.successGreen
                              : attempt.percentage >= 50
                              ? AppColors.primary2
                              : AppColors.errorRed,
                          size: 20,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.primary2,
                        size: 20,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultScreen(attemptId: attempt.id),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.quizMode,
    required this.examTypeId,
    this.areaId,
    this.subAreaId,
    required this.questions,
  });

  final QuizMode quizMode;
  final int examTypeId;
  final int? areaId;
  final int? subAreaId;
  final List<Question> questions;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const int _timeLimit = 60;
  final Map<int, String?> _selectedAnswers = {};
  final Map<int, int> _timeSpent = {};
  final Map<int, bool> _timedOut = {};
  Timer? _timer;
  int _currentIndex = 0;
  int _remainingSeconds = _timeLimit;
  late DateTime _questionStartedAt;
  bool _isFinishing = false;

  Question get _currentQuestion => widget.questions[_currentIndex];

  @override
  void initState() {
    super.initState();
    _showQuestion(0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showQuestion(int index) {
    _timer?.cancel();
    setState(() {
      _currentIndex = index;
      _remainingSeconds = _timeLimit;
      _questionStartedAt = DateTime.now();
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isFinishing) return;
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _nextQuestion(isTimeout: true);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _saveCurrentTime({required bool isTimeout}) {
    final question = _currentQuestion;
    final elapsed = DateTime.now()
        .difference(_questionStartedAt)
        .inSeconds
        .clamp(0, _timeLimit)
        .toInt();
    _timeSpent[question.id] = elapsed;
    if (isTimeout) _timedOut[question.id] = true;
  }

  void _nextQuestion({bool isTimeout = false}) {
    if (_isFinishing) return;
    _saveCurrentTime(isTimeout: isTimeout);
    if (_currentIndex < widget.questions.length - 1) {
      _showQuestion(_currentIndex + 1);
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    if (_isFinishing) return;
    _isFinishing = true;
    _timer?.cancel();

    final store = AppScope.of(context);
    try {
      final attempt = await store.submitQuiz(
        quizMode: widget.quizMode,
        examTypeId: widget.examTypeId,
        areaId: widget.areaId,
        subAreaId: widget.subAreaId,
        quizQuestions: widget.questions,
        selectedAnswers: _selectedAnswers,
        timeSpent: _timeSpent,
        timedOut: _timedOut,
        timeLimitPerQuestion: _timeLimit,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(attemptId: attempt.id)),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isFinishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save quiz result: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final examName = store.examTypeById(widget.examTypeId)?.examName ?? 'Quiz';
    final coverage = widget.quizMode == QuizMode.overall
        ? 'Overall'
        : widget.quizMode == QuizMode.area
        ? store.areaById(widget.areaId ?? 0)?.areaName ?? 'Area'
        : '${store.areaById(widget.areaId ?? 0)?.areaName ?? 'Area'} - ${store.subAreaById(widget.subAreaId ?? 0)?.subAreaName ?? 'Specific Field'}';

    return AppScaffold(
      title: '$examName Quiz',
      showLogout: false,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$examName Quiz',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Coverage: $coverage'),
                  const SizedBox(height: 6),
                  const Text(
                    'Each question has 60 seconds. If time runs out, it will move to the next question and count unanswered item as wrong.',
                  ),
                ],
              ),
            ),
          ),
          Card(
            color: _remainingSeconds <= 10
                ? AppColors.errorRed.withAlpha(25)
                : null,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question ${_currentIndex + 1} of ${widget.questions.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text('Answer before the timer reaches zero.'),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _remainingSeconds <= 10
                          ? AppColors.errorRed
                          : AppColors.primary2,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_remainingSeconds',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(label: Text(store.questionCoverage(_currentQuestion))),
                  const SizedBox(height: 10),
                  Text(
                    '${_currentIndex + 1}. ${_currentQuestion.questionText}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      for (final entry in [
                        MapEntry('A', _currentQuestion.optionA),
                        MapEntry('B', _currentQuestion.optionB),
                        MapEntry('C', _currentQuestion.optionC),
                        MapEntry('D', _currentQuestion.optionD),
                      ])
                        _buildOptionButton(
                          context,
                          entry.key,
                          entry.value,
                          _selectedAnswers[_currentQuestion.id] == entry.key,
                          () => setState(
                            () => _selectedAnswers[_currentQuestion.id] =
                                entry.key,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => _nextQuestion(),
                  child: Text(
                    _currentIndex == widget.questions.length - 1
                        ? 'Submit Quiz'
                        : 'Next Question',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    String option,
    String text,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary4 : AppColors.white,
              border: Border.all(
                color: isSelected ? AppColors.primary2 : AppColors.borderGray,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primary2 : AppColors.primary4,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary2
                          : AppColors.primary3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.primary1,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? AppColors.primary1
                          : AppColors.darkGray,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary2,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.attemptId});

  final int attemptId;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final attempt = store.attemptById(attemptId);
    if (attempt == null) {
      return AppScaffold(
        title: 'Quiz Result',
        child: const Center(child: Text('Attempt not found.')),
      );
    }

    final examName = store.examTypeById(attempt.examTypeId)?.examName ?? 'Exam';

    return AppScaffold(
      title: 'Quiz Result',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quiz Result',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Score',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${attempt.score} / ${attempt.totalQuestions}',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary2,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Accuracy',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: attempt.percentage >= 70
                                    ? AppColors.successGreen
                                    : attempt.percentage >= 50
                                    ? AppColors.primary3
                                    : AppColors.errorRed,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${attempt.percentage.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: AppColors.borderGray),
                  const SizedBox(height: 12),
                  Text(
                    'Exam Type: $examName',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Coverage: ${store.coverageLabel(attempt)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Date Taken: ${formatDateTime(attempt.dateTaken)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Time Limit: ${attempt.timeLimitPerQuestion} seconds per question',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Total Time Used: ${formatSeconds(attempt.totalTimeSeconds)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    children: [
                      FilledButton.icon(
                        icon: const Icon(Icons.dashboard_rounded),
                        onPressed: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserDashboardScreen(),
                          ),
                          (_) => false,
                        ),
                        label: const Text('Dashboard'),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.analytics_rounded),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AnalyticsScreen(),
                          ),
                        ),
                        label: const Text('Analytics'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Answer Review',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...attempt.answers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final answer = entry.value;
                    final question = store.questionById(answer.questionId);
                    if (question == null) return const SizedBox.shrink();
                    final isCorrect = answer.isCorrect;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCorrect
                              ? AppColors.successGreen
                              : AppColors.errorRed,
                          width: 2,
                        ),
                        color: isCorrect
                            ? AppColors.successGreen.withAlpha(25)
                            : AppColors.errorRed.withAlpha(25),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Chip(
                                label: Text(store.questionCoverage(question)),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isCorrect
                                      ? AppColors.successGreen
                                      : AppColors.errorRed,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isCorrect
                                          ? Icons.check_rounded
                                          : Icons.close_rounded,
                                      color: AppColors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isCorrect ? 'Correct' : 'Wrong',
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${index + 1}. ${question.questionText}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Your Answer: ${answer.selectedAnswer == null ? (answer.isTimeout ? 'No answer - time expired' : 'No answer') : '${answer.selectedAnswer}. ${question.optionText(answer.selectedAnswer)}'}',
                          ),
                          Text('Time Used: ${answer.timeSpentSeconds} seconds'),
                          Text(
                            'Correct Answer: ${question.correctAnswer}. ${question.optionText(question.correctAnswer)}',
                          ),
                          Text(
                            answer.isCorrect ? 'Correct' : 'Wrong',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: answer.isCorrect
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          if (question.explanation.trim().isNotEmpty)
                            Text('Explanation: ${question.explanation}'),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final user = store.currentUser!;
    final attempts = store.userAttempts(user.id);
    final totalAttempts = attempts.length;
    final totalScore = attempts.fold<int>(
      0,
      (sum, attempt) => sum + attempt.score,
    );
    final totalQuestions = attempts.fold<int>(
      0,
      (sum, attempt) => sum + attempt.totalQuestions,
    );
    final totalPercent = totalQuestions == 0
        ? 0.0
        : (totalScore / totalQuestions) * 100;
    final areaRows = store.progressByArea(user.id);
    final subRows = store.progressBySubArea(user.id);
    final focusAreas = areaRows.where((row) => row.accuracy < 70).toList();

    return AppScaffold(
      title: 'My Progress Analytics',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Progress Analytics',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'This page shows what areas you are strong in and what areas you should focus on.',
                  ),
                ],
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatCard(
                    title: 'Total Attempts',
                    value: '$totalAttempts',
                    width: _statWidth(constraints.maxWidth),
                  ),
                  _StatCard(
                    title: 'Overall Score',
                    value: '$totalScore / $totalQuestions',
                    width: _statWidth(constraints.maxWidth),
                  ),
                  _StatCard(
                    title: 'Overall Accuracy',
                    value: '${totalPercent.toStringAsFixed(2)}%',
                    width: _statWidth(constraints.maxWidth),
                  ),
                ],
              );
            },
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended Focus Areas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (areaRows.isEmpty)
                    const Text(
                      'No analytics yet. Take at least one quiz first.',
                    )
                  else if (focusAreas.isEmpty)
                    const Text(
                      'Great job. No weak area detected yet based on your current attempts.',
                      style: TextStyle(color: Colors.green),
                    )
                  else
                    ...focusAreas.map(
                      (row) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('${row.examName} - ${row.areaName}'),
                        subtitle: Text(
                          '${row.accuracy.toStringAsFixed(2)}% accuracy. Review and take more practice quizzes in this area.',
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          _AnalyticsTable(
            title: 'Progress by Main Area',
            rows: areaRows,
            includeSubArea: false,
          ),
          _AnalyticsTable(
            title: 'Progress by Specific Field',
            rows: subRows,
            includeSubArea: true,
          ),
        ],
      ),
    );
  }

  double _statWidth(double maxWidth) {
    if (maxWidth > 760) return (maxWidth - 24) / 3;
    return maxWidth;
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _approve(BuildContext context, AppUser user) async {
    try {
      await AppScope.of(
        context,
      ).setProfileStatus(user.id, AccountStatus.approved);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.fullName} has been approved.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not approve user: $error')));
    }
  }

  Future<void> _reject(BuildContext context, AppUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject account?'),
        content: Text('${user.fullName} will not be able to access quizzes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await AppScope.of(
        context,
      ).setProfileStatus(user.id, AccountStatus.rejected);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.fullName} has been rejected.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not reject user: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final totalUsers = store.users
        .where((user) => user.role == UserRole.user)
        .length;
    final totalQuestions = store.questions.length;
    final totalAttempts = store.attempts.length;
    final byType = store.questionCountByExamType();
    final byArea = store.questionCountByArea();
    final pendingUsers = store.users
        .where(
          (user) =>
              user.role == UserRole.user &&
              user.status == AccountStatus.pending,
        )
        .toList();
    final pendingUserCount = pendingUsers.length;

    return AppScaffold(
      title: 'Admin Dashboard',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Dashboard',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Approve new accounts, manage questions, review attempts, and monitor question coverage.',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManageQuestionsScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.quiz_outlined),
                        label: const Text('Manage Questions'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminResultsScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.table_chart_outlined),
                        label: const Text('View Results'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Pending Users',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Chip(label: Text('$pendingUserCount pending')),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Approve pending users to unlock the quiz dashboard, or reject accounts that should not have access.',
                  ),
                  const SizedBox(height: 14),
                  if (pendingUsers.isEmpty)
                    const Text('No pending users yet.')
                  else
                    ...pendingUsers.map(
                      (user) => _PendingUserTile(
                        user: user,
                        onApprove: () => _approve(context, user),
                        onReject: () => _reject(context, user),
                      ),
                    ),
                ],
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth > 760
                  ? (constraints.maxWidth - 24) / 3
                  : constraints.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatCard(
                    title: 'Total Users',
                    value: '$totalUsers',
                    width: width,
                  ),
                  _StatCard(
                    title: 'Total Questions',
                    value: '$totalQuestions',
                    width: width,
                  ),
                  _StatCard(
                    title: 'Total Attempts',
                    value: '$totalAttempts',
                    width: width,
                  ),
                ],
              );
            },
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Questions by Exam Type',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Exam Type')),
                        DataColumn(label: Text('Total Questions')),
                      ],
                      rows: byType
                          .map(
                            (entry) => DataRow(
                              cells: [
                                DataCell(Text(entry.key.examName)),
                                DataCell(Text('${entry.value}')),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Questions by Area Covered',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Exam Type')),
                        DataColumn(label: Text('Area')),
                        DataColumn(label: Text('Total Questions')),
                      ],
                      rows: byArea.map((entry) {
                        final exam =
                            store
                                .examTypeById(entry.key.examTypeId)
                                ?.examName ??
                            'Exam';
                        return DataRow(
                          cells: [
                            DataCell(Text(exam)),
                            DataCell(Text(entry.key.areaName)),
                            DataCell(Text('${entry.value}')),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ManageQuestionsScreen extends StatefulWidget {
  const ManageQuestionsScreen({super.key});

  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  int? _filterExamTypeId;
  int? _filterAreaId;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    var filtered = store.questions.toList();
    if (_filterExamTypeId != null) {
      filtered = filtered
          .where((question) => question.examTypeId == _filterExamTypeId)
          .toList();
    }
    if (_filterAreaId != null) {
      filtered = filtered
          .where((question) => question.areaId == _filterAreaId)
          .toList();
    }
    filtered.sort((a, b) => b.id.compareTo(a.id));

    return AppScaffold(
      title: 'Manage Questions',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage Questions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int?>(
                    initialValue: _filterExamTypeId,
                    decoration: const InputDecoration(labelText: 'Exam Type'),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All Exam Types'),
                      ),
                      ...store.examTypes.map(
                        (type) => DropdownMenuItem<int?>(
                          value: type.id,
                          child: Text(type.examName),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() {
                      _filterExamTypeId = value;
                      _filterAreaId = null;
                    }),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int?>(
                    initialValue: _filterAreaId,
                    decoration: const InputDecoration(
                      labelText: 'Area Covered',
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All Areas'),
                      ),
                      ...store.examAreas
                          .where(
                            (area) =>
                                _filterExamTypeId == null ||
                                area.examTypeId == _filterExamTypeId,
                          )
                          .map(
                            (area) => DropdownMenuItem<int?>(
                              value: area.id,
                              child: Text(
                                '${store.examTypeById(area.examTypeId)?.examName ?? ''} - ${area.areaName}',
                              ),
                            ),
                          ),
                    ],
                    onChanged: (value) => setState(() => _filterAreaId = value),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QuestionFormScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Question'),
                      ),
                      OutlinedButton(
                        onPressed: () => setState(() {
                          _filterExamTypeId = null;
                          _filterAreaId = null;
                        }),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (filtered.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text('No questions found.'),
              ),
            )
          else
            ...filtered.map((question) {
              final exam =
                  store.examTypeById(question.examTypeId)?.examName ?? 'Exam';
              final area = store.areaById(question.areaId)?.areaName ?? 'Area';
              final sub =
                  store.subAreaById(question.subAreaId)?.subAreaName ??
                  'Specific Field';
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(label: Text(exam)),
                          Chip(label: Text(area)),
                          Chip(label: Text(sub)),
                          Chip(
                            label: Text('Correct: ${question.correctAnswer}'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question.questionText,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    QuestionFormScreen(question: question),
                              ),
                            ),
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                _confirmDelete(context, question.id),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Delete'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, int questionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      try {
        await AppScope.of(context).deleteQuestion(questionId);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Question deleted.')));
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not delete question: $error')),
          );
        }
      }
    }
  }
}

class QuestionFormScreen extends StatefulWidget {
  const QuestionFormScreen({super.key, this.question});

  final Question? question;

  @override
  State<QuestionFormScreen> createState() => _QuestionFormScreenState();
}

class _QuestionFormScreenState extends State<QuestionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _question = TextEditingController();
  final _optionA = TextEditingController();
  final _optionB = TextEditingController();
  final _optionC = TextEditingController();
  final _optionD = TextEditingController();
  final _explanation = TextEditingController();
  int? _examTypeId;
  int? _areaId;
  int? _subAreaId;
  String? _correctAnswer;

  bool get isEditing => widget.question != null;

  @override
  void initState() {
    super.initState();
    final question = widget.question;
    if (question != null) {
      _examTypeId = question.examTypeId;
      _areaId = question.areaId;
      _subAreaId = question.subAreaId;
      _correctAnswer = question.correctAnswer;
      _question.text = question.questionText;
      _optionA.text = question.optionA;
      _optionB.text = question.optionB;
      _optionC.text = question.optionC;
      _optionD.text = question.optionD;
      _explanation.text = question.explanation;
    }
  }

  @override
  void dispose() {
    _question.dispose();
    _optionA.dispose();
    _optionB.dispose();
    _optionC.dispose();
    _optionD.dispose();
    _explanation.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_examTypeId == null ||
        _areaId == null ||
        _subAreaId == null ||
        _correctAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    final store = AppScope.of(context);
    final question = Question(
      id: widget.question?.id ?? 0,
      examTypeId: _examTypeId!,
      areaId: _areaId!,
      subAreaId: _subAreaId!,
      questionText: _question.text.trim(),
      optionA: _optionA.text.trim(),
      optionB: _optionB.text.trim(),
      optionC: _optionC.text.trim(),
      optionD: _optionD.text.trim(),
      correctAnswer: _correctAnswer!,
      explanation: _explanation.text.trim(),
      createdAt: widget.question?.createdAt,
    );

    try {
      if (isEditing) {
        await store.updateQuestion(question);
      } else {
        await store.addQuestion(question);
      }
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Question updated.' : 'Question added.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save question: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final areas = _examTypeId == null
        ? <ExamArea>[]
        : store.areasForExam(_examTypeId!);
    final subAreas = _areaId == null
        ? <ExamSubArea>[]
        : store.subAreasForArea(_areaId!);

    return AppScaffold(
      title: isEditing ? 'Edit Question' : 'Add Question',
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Edit Question' : 'Add New Question',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select the exam type, main area, and specific sub-area before typing the question.',
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: _examTypeId,
                      decoration: const InputDecoration(labelText: 'Exam Type'),
                      items: store.examTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type.id,
                              child: Text(type.examName),
                            ),
                          )
                          .toList(),
                      validator: (value) =>
                          value == null ? 'Exam type is required.' : null,
                      onChanged: (value) => setState(() {
                        _examTypeId = value;
                        _areaId = null;
                        _subAreaId = null;
                      }),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: _areaId,
                      decoration: const InputDecoration(
                        labelText: 'Area Covered',
                      ),
                      items: areas
                          .map(
                            (area) => DropdownMenuItem(
                              value: area.id,
                              child: Text(area.areaName),
                            ),
                          )
                          .toList(),
                      validator: (value) =>
                          value == null ? 'Area is required.' : null,
                      onChanged: (value) => setState(() {
                        _areaId = value;
                        _subAreaId = null;
                      }),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: _subAreaId,
                      decoration: const InputDecoration(
                        labelText: 'Specific Field / Topic',
                      ),
                      items: subAreas
                          .map(
                            (sub) => DropdownMenuItem(
                              value: sub.id,
                              child: Text(sub.subAreaName),
                            ),
                          )
                          .toList(),
                      validator: (value) =>
                          value == null ? 'Specific field is required.' : null,
                      onChanged: (value) => setState(() => _subAreaId = value),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _question,
                      decoration: const InputDecoration(labelText: 'Question'),
                      maxLines: 4,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Question is required.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _optionA,
                      decoration: const InputDecoration(labelText: 'Option A'),
                      validator: _required,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _optionB,
                      decoration: const InputDecoration(labelText: 'Option B'),
                      validator: _required,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _optionC,
                      decoration: const InputDecoration(labelText: 'Option C'),
                      validator: _required,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _optionD,
                      decoration: const InputDecoration(labelText: 'Option D'),
                      validator: _required,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _correctAnswer,
                      decoration: const InputDecoration(
                        labelText: 'Correct Answer',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'A', child: Text('A')),
                        DropdownMenuItem(value: 'B', child: Text('B')),
                        DropdownMenuItem(value: 'C', child: Text('C')),
                        DropdownMenuItem(value: 'D', child: Text('D')),
                      ],
                      validator: (value) =>
                          value == null ? 'Correct answer is required.' : null,
                      onChanged: (value) =>
                          setState(() => _correctAnswer = value),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _explanation,
                      decoration: const InputDecoration(
                        labelText: 'Explanation Optional',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 12,
                      children: [
                        FilledButton(
                          onPressed: _save,
                          child: Text(
                            isEditing ? 'Update Question' : 'Save Question',
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty
        ? 'This field is required.'
        : null;
  }
}

class AdminResultsScreen extends StatelessWidget {
  const AdminResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final sorted = store.attempts.toList()
      ..sort((a, b) => b.dateTaken.compareTo(a.dateTaken));

    return AppScaffold(
      title: 'User Quiz Results',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Quiz Results',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (sorted.isEmpty)
                    const Text('No quiz attempts yet.')
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Date Taken')),
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Username')),
                          DataColumn(label: Text('Exam Type')),
                          DataColumn(label: Text('Coverage')),
                          DataColumn(label: Text('Score')),
                          DataColumn(label: Text('Percentage')),
                          DataColumn(label: Text('Time Used')),
                        ],
                        rows: sorted.map((attempt) {
                          final user = store.userById(attempt.userId);
                          final exam =
                              store
                                  .examTypeById(attempt.examTypeId)
                                  ?.examName ??
                              'Exam';
                          return DataRow(
                            cells: [
                              DataCell(Text(formatDateTime(attempt.dateTaken))),
                              DataCell(Text(user?.fullName ?? 'Unknown')),
                              DataCell(Text(user?.username ?? 'unknown')),
                              DataCell(Text(exam)),
                              DataCell(Text(store.coverageLabel(attempt))),
                              DataCell(
                                Text(
                                  '${attempt.score} / ${attempt.totalQuestions}',
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${attempt.percentage.toStringAsFixed(2)}%',
                                ),
                              ),
                              DataCell(
                                Text(formatSeconds(attempt.totalTimeSeconds)),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.showLogout = true,
  });

  final String title;
  final Widget child;
  final bool showLogout;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded, size: 20),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        actions: [
          if (showLogout && store.currentUser != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton.filled(
                tooltip: 'Logout',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  foregroundColor: AppColors.white,
                ),
                onPressed: () async {
                  await store.logout();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const GateScreen()),
                    (_) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
              ),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: child,
        ),
      ),
    );
  }
}

class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              padding: const EdgeInsets.all(20),
              shrinkWrap: true,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 18),
                        child,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Quiz',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: 30,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(width: 6),
        const Icon(
          Icons.emoji_events_rounded,
          color: AppColors.sunshine,
          size: 28,
        ),
      ],
    );
  }
}

class _WelcomeArtwork extends StatelessWidget {
  const _WelcomeArtwork({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            height: height * .58,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.ink, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.ink,
                    offset: Offset(8, 8),
                    blurRadius: 0,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 28,
            bottom: 30,
            width: 95,
            height: 80,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.sunshine,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
          ),
          Positioned(
            right: 28,
            bottom: 30,
            width: 110,
            height: 95,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.coral,
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
            ),
          ),
          Positioned(
            bottom: 38,
            child: Icon(
              Icons.groups_2_rounded,
              size: height * .43,
              color: AppColors.ink,
            ),
          ),
          Positioned(
            top: 8,
            right: 34,
            child: Transform.rotate(
              angle: .15,
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 76,
                color: AppColors.sunshine,
              ),
            ),
          ),
          const Positioned(
            top: 70,
            left: 34,
            child: _CircleIcon(
              icon: Icons.lightbulb_rounded,
              color: AppColors.sky,
            ),
          ),
          const Positioned(
            top: 112,
            right: 8,
            child: _CircleIcon(
              icon: Icons.auto_awesome_rounded,
              color: AppColors.mint,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: AppColors.ink, size: 22),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: _CircleIcon(icon: icon, color: color),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.accent});

  final String title;
  final String? accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          if (accent != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const BoxDecoration(
                color: AppColors.coral,
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              child: Text(
                accent!,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .8,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Card(
          elevation: _isHovered ? 8 : 2,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.color.withAlpha(51),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, size: 32, color: widget.color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: widget.color,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizSetupCard extends StatelessWidget {
  const _QuizSetupCard({
    required this.title,
    required this.description,
    required this.children,
    this.icon = Icons.quiz_rounded,
    this.color = AppColors.paper,
  });

  final String title;
  final String description;
  final List<Widget> children;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.paper.withAlpha(210),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.ink, size: 22),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  child: const Text(
                    'PLAY',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 7),
            Text(
              description,
              style: const TextStyle(color: AppColors.ink, fontSize: 13),
            ),
            const SizedBox(height: 18),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.errorRed : AppColors.successGreen;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingUserTile extends StatelessWidget {
  const _PendingUserTile({required this.user, this.onApprove, this.onReject});

  final AppUser user;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const _CircleIcon(
            icon: Icons.person_rounded,
            color: AppColors.sunshine,
          ),
          SizedBox(
            width: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  '@${user.username} - ${formatDateTime(user.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (user.email != null)
                  SelectableText(
                    user.email!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.sunshine,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Text(
              'Pending',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (onApprove != null)
            FilledButton.icon(
              onPressed: onApprove,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Approve'),
            ),
          if (onReject != null)
            OutlinedButton.icon(
              onPressed: onReject,
              icon: const Icon(Icons.close_rounded),
              label: const Text('Reject'),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.width,
  });

  final String title;
  final String value;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary4,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.trending_up_rounded,
                      color: AppColors.primary2,
                      size: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalyticsTable extends StatelessWidget {
  const _AnalyticsTable({
    required this.title,
    required this.rows,
    required this.includeSubArea,
  });

  final String title;
  final List<AnalyticsRow> rows;
  final bool includeSubArea;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (rows.isEmpty)
              const Text('No quiz records yet.')
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    const DataColumn(label: Text('Exam Type')),
                    const DataColumn(label: Text('Area')),
                    if (includeSubArea)
                      const DataColumn(label: Text('Specific Field')),
                    const DataColumn(label: Text('Correct')),
                    const DataColumn(label: Text('Answered')),
                    const DataColumn(label: Text('Accuracy')),
                    const DataColumn(label: Text('Average Time')),
                    if (!includeSubArea)
                      const DataColumn(label: Text('Status')),
                  ],
                  rows: rows.map((row) {
                    return DataRow(
                      cells: [
                        DataCell(Text(row.examName)),
                        DataCell(Text(row.areaName)),
                        if (includeSubArea)
                          DataCell(Text(row.subAreaName ?? '')),
                        DataCell(Text('${row.totalCorrect}')),
                        DataCell(Text('${row.totalAnswered}')),
                        DataCell(Text('${row.accuracy.toStringAsFixed(2)}%')),
                        DataCell(Text('${row.avgTime.toStringAsFixed(2)} sec')),
                        if (!includeSubArea) DataCell(Text(row.status)),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String formatSeconds(int seconds) {
  final minutes = seconds ~/ 60;
  final remaining = seconds % 60;
  if (minutes <= 0) return '$remaining sec';
  return '$minutes min $remaining sec';
}

String formatDateTime(DateTime value) {
  final y = value.year.toString().padLeft(4, '0');
  final m = value.month.toString().padLeft(2, '0');
  final d = value.day.toString().padLeft(2, '0');
  final h = value.hour.toString().padLeft(2, '0');
  final min = value.minute.toString().padLeft(2, '0');
  return '$y-$m-$d $h:$min';
}
