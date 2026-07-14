import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:litera_ai_mobile/features/auth/application/auth_controller.dart';
import 'package:litera_ai_mobile/features/diagnostic_assessment/application/diagnostic_assessment_controller.dart';
import 'package:litera_ai_mobile/shared/widgets/app_screen.dart';

class DiagnosticAssessmentScreen extends ConsumerWidget {
  const DiagnosticAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(diagnosticAssessmentControllerProvider);
    final controller = ref.read(diagnosticAssessmentControllerProvider.notifier);
    final session = state.session;
    final question = session?.questions[state.currentIndex];

    if (state.profile != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(authControllerProvider.notifier).submitDiagnostic();
      });
    }

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.errorMessage != null && question == null) {
      return AppScreen(
        title: 'Asesmen Diagnostik',
        children: [
          AppEmptyState(
            title: 'Asesmen belum tersedia',
            message: state.errorMessage!,
            action: FilledButton.icon(
              onPressed: controller.startOrResume,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ),
        ],
      );
    }

    if (question == null) {
      return const AppScreen(
        title: 'Asesmen Diagnostik',
        children: [
          AppEmptyState(
            title: 'Soal kosong',
            message: 'Bank soal belum tersedia untuk asesmen ini.',
          ),
        ],
      );
    }

    return AppScreen(
      title: 'Asesmen Diagnostik',
      children: [
        LinearProgressIndicator(
          value: (state.currentIndex + 1) / (session?.questions.length ?? 1),
        ),
        const SizedBox(height: 16),
        Text(
          'Soal ${state.currentIndex + 1} dari ${session?.questions.length ?? 1}',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 12),
        InfoCard(
          icon: Icons.article_outlined,
          title: 'Konteks STEM',
          body: question.stem,
        ),
        const SizedBox(height: 16),
        const SectionTitle('Pertanyaan'),
        const Text(
          'Kesimpulan mana yang paling tepat berdasarkan konteks di atas?',
        ),
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
              : const Icon(Icons.psychology_alt_outlined),
          label: const Text('Submit Asesmen'),
        ),
      ],
    );
  }
}
