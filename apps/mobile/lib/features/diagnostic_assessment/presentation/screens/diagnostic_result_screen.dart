import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:litera_ai_mobile/features/auth/application/auth_controller.dart';
import 'package:litera_ai_mobile/shared/widgets/app_screen.dart';

class DiagnosticResultScreen extends ConsumerWidget {
  const DiagnosticResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScreen(
      title: 'Profil Belajar',
      children: [
        const InfoCard(
          icon: Icons.insights_outlined,
          title: 'Developing Reader',
          body:
              'Kamu mulai mampu memahami informasi eksplisit, dan akan dilatih membuat inferensi dari teks kontekstual.',
        ),
        const SizedBox(height: 12),
        const InfoCard(
          icon: Icons.functions,
          title: 'Transitional Numeracy',
          body:
              'Kamu cukup kuat di prosedur dasar dan perlu latihan soal cerita berbasis penalaran.',
        ),
        const SizedBox(height: 16),
        const SectionTitle('Learning path awal'),
        const InfoCard(
          icon: Icons.route_outlined,
          title: 'Inferensi Teks STEM',
          body: 'Difficulty awal: medium. Target mastery: 80%.',
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () {
            ref
                .read(authControllerProvider.notifier)
                .continueAfterDiagnosticResult();
          },
          icon: const Icon(Icons.play_arrow),
          label: const Text('Mulai Belajar'),
        ),
      ],
    );
  }
}

