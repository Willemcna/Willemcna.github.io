class KPIData {
  final double timeSaved; // in seconds
  final int totalMessages;
  final int orderLinksSent;
  final int handovers;
  // Response efficiency
  final double averageResponseTime; // seconds
  final double p95ResponseTime; // seconds
  final double autoAnsweredPercentage; // 0..100
  // Customer impact
  final int uniqueCustomers;
  final int returningCustomers;
  final List<ProductMention> topProducts;

  KPIData({
    required this.timeSaved,
    required this.totalMessages,
    required this.orderLinksSent,
    required this.handovers,
    required this.averageResponseTime,
    required this.p95ResponseTime,
    required this.autoAnsweredPercentage,
    required this.uniqueCustomers,
    required this.returningCustomers,
    required this.topProducts,
  });
}

class ProductMention {
  final String productName;
  final int mentionCount;

  ProductMention({
    required this.productName,
    required this.mentionCount,
  });
}

