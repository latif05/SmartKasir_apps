class ActivationState {
  const ActivationState({
    this.isPremium = false,
    this.activatedAt,
    this.codeUsed,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  final bool isPremium;
  final DateTime? activatedAt;
  final String? codeUsed;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  ActivationState copyWith({
    bool? isPremium,
    DateTime? activatedAt,
    String? codeUsed,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool resetMessages = false,
  }) {
    return ActivationState(
      isPremium: isPremium ?? this.isPremium,
      activatedAt: activatedAt ?? this.activatedAt,
      codeUsed: codeUsed ?? this.codeUsed,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: resetMessages ? null : errorMessage ?? this.errorMessage,
      successMessage: resetMessages ? null : successMessage ?? this.successMessage,
    );
  }
}
