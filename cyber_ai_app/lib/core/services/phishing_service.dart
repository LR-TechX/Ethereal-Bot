import 'dart:core';

class PhishingCheckResult {
  final bool suspicious;
  final List<String> reasons;
  PhishingCheckResult({required this.suspicious, required this.reasons});
}

class PhishingService {
  PhishingService._();
  static final instance = PhishingService._();

  PhishingCheckResult check(String urlOrDomain) {
    final reasons = <String>[];
    final input = urlOrDomain.trim();

    final uri = _parseUri(input);
    final host = uri?.host.isNotEmpty == true ? uri!.host : input;

    if (uri == null || (uri.scheme != 'https' && uri.scheme.isNotEmpty)) {
      if (uri?.scheme == 'http') {
        reasons.add('Uses HTTP, not HTTPS.');
      }
    }

    // IP literal
    if (RegExp(r'^\d+\.\d+\.\d+\.\d+$').hasMatch(host)) {
      reasons.add('URL uses IP address.');
    }

    // Suspicious TLDs
    const badTlds = ['zip', 'mov', 'tk', 'gq', 'ml'];
    final tld = host.split('.').last.toLowerCase();
    if (badTlds.contains(tld)) {
      reasons.add('Suspicious top-level domain: .$tld');
    }

    // Look-alike domains (simple homoglyph/l33t detection)
    if (host.contains('paypa1') || host.contains('rnicrosoft') || host.contains('go0gle')) {
      reasons.add('Possible look-alike domain (homoglyph).');
    }

    // Excessive subdomains
    if (host.split('.').length > 4) {
      reasons.add('Too many subdomains.');
    }

    // Unicode / punycode
    if (host.startsWith('xn--')) {
      reasons.add('Punycode domain.');
    }

    return PhishingCheckResult(suspicious: reasons.isNotEmpty, reasons: reasons);
  }

  Uri? _parseUri(String input) {
    try {
      if (!input.contains('://')) return Uri.parse('https://$input');
      return Uri.parse(input);
    } catch (_) {
      return null;
    }
  }
}