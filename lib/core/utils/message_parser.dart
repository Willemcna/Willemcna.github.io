import 'dart:core';

class MessageParser {
  // Regex pattern for URLs
  static final _urlPattern = RegExp(
    r'https?://[^\s]+',
    caseSensitive: false,
  );

  // Regex pattern for phone numbers (various formats)
  static final _phonePattern = RegExp(
    r'(\+?\d{1,3}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}|\d{10,}',
  );

  /// Detects if message contains order links (any URL in AI message)
  static bool hasOrderLink(String content, bool isAI) {
    if (!isAI) return false;
    return _urlPattern.hasMatch(content);
  }

  /// Extracts all URLs from message content
  static List<String> extractUrls(String content) {
    return _urlPattern.allMatches(content).map((m) => m.group(0)!).toList();
  }

  /// Detects if message contains human handover (phone number in AI message)
  static bool hasHandover(String content, bool isAI) {
    if (!isAI) return false;
    return _phonePattern.hasMatch(content);
  }

  /// Extracts phone numbers from message content
  static List<String> extractPhoneNumbers(String content) {
    return _phonePattern.allMatches(content).map((m) => m.group(0)!).toList();
  }

  /// Matches product names in message content against product list
  static List<String> matchProducts(String content, List<String> productNames) {
    final foundProducts = <String>[];
    final lowerContent = content.toLowerCase();

    for (final productName in productNames) {
      final lowerProduct = productName.toLowerCase();
      if (lowerContent.contains(lowerProduct)) {
        foundProducts.add(productName);
      }
    }

    return foundProducts;
  }
}

