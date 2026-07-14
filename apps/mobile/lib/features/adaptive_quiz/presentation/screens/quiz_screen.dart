import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:litera_ai_mobile/app/router/route_names.dart';
import 'package:litera_ai_mobile/features/learning/application/quiz_controller.dart';
import 'package:litera_ai_mobile/shared/widgets/app_screen.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({required this.moduleId, super.key});

  final String moduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizControllerProvider(moduleId));
    final controller = ref.read(quizControllerProvider(moduleId).notifier);
    final evaluation = state.evaluation;

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (evaluation != null) {
      return AppScreen(
        title: 'Hasil Quiz',
        children: [
          InfoCard(
            icon: Icons.emoji_events_outlined,
            title: 'Skor ${evaluation.score.toStringAsFixed(0)}',
            body:
                'Mastery meningkat ke ${evaluation.mastery.first.masteryProbability}. ${evaluation.ddaDecision.explanation}',
          ),
          const SizedBox(height: 12),
          InfoCard(
            icon: Icons.tune,
            title: 'DDA Decision',
            body:
                'Next difficulty: ${evaluation.ddaDecision.nextDifficulty}. Reason: ${evaluation.ddaDecision.reasonCode}.',
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => context.go(RouteNames.studentDashboard),
            icon: const Icon(Icons.home_outlined),
            label: const Text('Kembali ke Dashboard'),
          ),
        ],
      );
    }

    final session = state.session;
    final question =
        session == null || session.questions.isEmpty ? null : session.questions.first;
    if (question == null) {
      return AppScreen(
        title: 'Quiz Adaptif',
        children: [
          AppEmptyState(
            title: 'Quiz belum tersedia',
            message: state.errorMessage ?? 'Bank soal quiz masih kosong.',
            action: FilledButton.icon(
              onPressed: controller.start,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ),
        ],
      );
    }

    return AppScreen(
      title: 'Quiz Adaptif',
      children: [
        const LinearProgressIndicator(value: 0.5),
        const SizedBox(height: 16),
        const SectionTitle('Soal 3 dari 6'),
        Text(question.stem),
        const SizedBox(height: 12),
        for (final option in question.options)
          RadioListTile<String>(
            value: option.id,
            groupValue: state.selectedOptionId,
            onChanged: (value) {
              if (value != null) controller.selectOption(value);
            },
            title: Text('${option.label}. ${option.body}'),
          ),
        if (state.errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            state.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: state.isSubmitting ? null : controller.submit,
          icon: state.isSubmitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: const Text('Submit Quiz'),
        ),
      ],
    );
  }
}
