import 'dart:async';

import 'package:litera_ai_mobile/features/diagnostic_assessment/domain/entities/diagnostic_question.dart';
import 'package:litera_ai_mobile/features/learning/domain/entities/learning_module.dart';
import 'package:litera_ai_mobile/features/learning/domain/entities/learning_path.dart';
import 'package:litera_ai_mobile/features/learning/domain/entities/quiz.dart';
import 'package:litera_ai_mobile/features/learning/domain/entities/student_progress.dart';
import 'package:litera_ai_mobile/features/learning/domain/repositories/learning_repository.dart';

class MockLearningRepository implements LearningRepository {
  @override
  Future<StudentProgress> getStudentProgress() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const StudentProgress(
      averageMastery: 0.72,
      weeklyProgressLabel: 'Rata-rata mastery 72%. Target berikutnya: 80%.',
      priorityConcepts: ['Inferensi teks', 'Soal cerita', 'Data table'],
    );
  }

  @override
  Future<LearningPath> getCurrentPath() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const LearningPath(
      id: 'path-1',
      status: 'active',
      items: [
        LearningPathItem(
          id: 'path-item-1',
          conceptId: 'concept-inference',
          moduleId: 'demo-module',
          title: 'Inferensi Teks dalam STEM',
          targetDifficulty: 'medium',
          status: 'available',
        ),
        LearningPathItem(
          id: 'path-item-2',
          conceptId: 'concept-word-problem',
          moduleId: 'word-problem-module',
          title: 'Penalaran Soal Cerita',
          targetDifficulty: 'medium',
          status: 'locked',
        ),
      ],
    );
  }

  @override
  Future<LearningModule> getModule(String moduleId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return LearningModule(
      id: moduleId,
      title: 'Inferensi Teks dalam STEM',
      difficulty: 'medium',
      estimatedMinutes: 12,
      contents: const [
        ModuleContent(
          id: 'content-1',
          contentType: 'text',
          sortOrder: 1,
          body: {
            'title': 'Konteks',
            'text':
                'Siswa membaca data penggunaan air sekolah dan menghubungkannya dengan keputusan penghematan.',
          },
        ),
        ModuleContent(
          id: 'content-2',
          contentType: 'example',
          sortOrder: 2,
          body: {
            'title': 'Contoh Berpikir',
            'text':
                'Cari pola, bandingkan bukti, lalu pilih simpulan yang paling didukung data.',
          },
        ),
      ],
    );
  }

  @override
  Future<QuizSession> startQuiz(String moduleId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return QuizSession(
      id: 'quiz-session-1',
      moduleId: moduleId,
      difficulty: 'medium',
      questions: const [
        DiagnosticQuestion(
          id: 'quiz-q-1',
          conceptId: 'concept-inference',
          difficulty: 'medium',
          stem:
              'Data menunjukkan penggunaan air naik tajam pada hari olahraga. Intervensi paling logis adalah...',
          options: [
            DiagnosticOption(id: 'a', label: 'A', body: 'Mengurangi semua kegiatan.'),
            DiagnosticOption(
              id: 'b',
              label: 'B',
              body: 'Menyiapkan titik isi ulang dan jadwal penggunaan air.',
            ),
            DiagnosticOption(id: 'c', label: 'C', body: 'Mengabaikan data.'),
            DiagnosticOption(id: 'd', label: 'D', body: 'Menaikkan difficulty.'),
          ],
        ),
      ],
    );
  }

  @override
  Future<void> saveQuizAnswer({
    required String quizSessionId,
    required String questionId,
    required String selectedOptionId,
    required int responseTimeMs,
    required String idempotencyKey,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<QuizEvaluation> submitQuiz(String quizSessionId) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return const QuizEvaluation(
      score: 80,
      mastery: [
        ConceptMastery(
          conceptId: 'concept-inference',
          masteryProbability: 0.74,
          confidence: 0.81,
        ),
      ],
      ddaDecision: DdaDecision(
        previousDifficulty: 'medium',
        nextDifficulty: 'medium',
        reasonCode: 'keep',
        explanation:
            'Mastery meningkat, tetapi latihan tambahan dibutuhkan agar konsep lebih stabil.',
      ),
    );
  }
}

