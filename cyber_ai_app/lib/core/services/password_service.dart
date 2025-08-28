import 'dart:math';

class PasswordAssessment {
  final double entropyBits;
  final String verdict;
  final List<String> feedback;
  PasswordAssessment({required this.entropyBits, required this.verdict, required this.feedback});
}

class PasswordService {
  PasswordService._();
  static final instance = PasswordService._();

  PasswordAssessment assess(String password) {
    if (password.isEmpty) {
      return PasswordAssessment(entropyBits: 0, verdict: 'Empty', feedback: ['Enter a password.']);
    }
    final charset = _charsetSize(password);
    final entropy = password.length * (log(charset) / ln2);

    final feedback = <String>[];
    if (password.length < 12) feedback.add('Use at least 12 characters.');
    if (!RegExp(r'[a-z]').hasMatch(password)) feedback.add('Add lowercase letters.');
    if (!RegExp(r'[A-Z]').hasMatch(password)) feedback.add('Add uppercase letters.');
    if (!RegExp(r'[0-9]').hasMatch(password)) feedback.add('Add digits.');
    if (!RegExp(r'[!@#\$%\^&\*\-_=+\[\]{};:,./?]').hasMatch(password)) feedback.add('Add symbols.');
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) feedback.add('Avoid repeated characters.');
    if (RegExp(r'(123|abc|qwerty|password|letmein)', caseSensitive: false).hasMatch(password)) feedback.add('Avoid common patterns.');

    String verdict;
    if (entropy < 28) {
      verdict = 'Very Weak';
    } else if (entropy < 36) {
      verdict = 'Weak';
    } else if (entropy < 60) {
      verdict = 'Reasonable';
    } else if (entropy < 80) {
      verdict = 'Strong';
    } else {
      verdict = 'Very Strong';
    }

    return PasswordAssessment(entropyBits: entropy, verdict: verdict, feedback: feedback);
  }

  int _charsetSize(String s) {
    int size = 0;
    if (RegExp(r'[a-z]').hasMatch(s)) size += 26;
    if (RegExp(r'[A-Z]').hasMatch(s)) size += 26;
    if (RegExp(r'[0-9]').hasMatch(s)) size += 10;
    if (RegExp(r'[!@#\$%\^&\*\-_=+\[\]{};:,./?]').hasMatch(s)) size += 33;
    return size.clamp(1, 95);
  }
}