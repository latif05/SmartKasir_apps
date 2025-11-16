class ActivationStatus {
  const ActivationStatus({
    required this.isPremium,
    this.activatedAt,
    this.codeUsed,
  });

  final bool isPremium;
  final DateTime? activatedAt;
  final String? codeUsed;
}

