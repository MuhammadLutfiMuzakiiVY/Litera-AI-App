class DiagnosticProfile {
  const DiagnosticProfile({
    required this.literacyProfile,
    required this.numeracyProfile,
    required this.confidence,
    required this.modelVersion,
  });

  final String literacyProfile;
  final String numeracyProfile;
  final double confidence;
  final String modelVersion;
}

