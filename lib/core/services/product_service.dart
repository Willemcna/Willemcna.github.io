import '../services/tenant_service.dart';

class ProductService {
  final TenantService _tenantService;

  ProductService(this._tenantService);

  /// Get all products from the tenant database
  Future<List<String>> getProductNames() async {
    final client = _tenantService.tenantClient;
    if (client == null) throw Exception('Tenant client not initialized');

    try {
      // Note: Table name might be "Products 01_duplicate" based on schema
      // Using a more flexible approach
      final response = await client
          .from('Products 01_duplicate')
          .select('Name')
          .not('Name', 'is', null);

      final productNames = <String>[];
      for (final item in response) {
        final name = item['Name'] as String?;
        if (name != null && name.isNotEmpty) {
          productNames.add(name);
        }
      }

      return productNames;
    } catch (e) {
      // Try alternative table name if first fails
      try {
        final response = await client
            .from('products')
            .select('Name')
            .not('Name', 'is', null);

        final productNames = <String>[];
        for (final item in response) {
          final name = item['Name'] as String?;
          if (name != null && name.isNotEmpty) {
            productNames.add(name);
          }
        }
        return productNames;
      } catch (_) {
        // Try lowercase column name fallback
        try {
          final response = await client
              .from('products')
              .select('name')
              .not('name', 'is', null);
          final productNames = <String>[];
          for (final item in response) {
            final name = item['name'] as String?;
            if (name != null && name.isNotEmpty) {
              productNames.add(name);
            }
          }
          return productNames;
        } catch (__) {
        throw Exception('Failed to fetch products: $e');
        }
      }
    }
  }
}

