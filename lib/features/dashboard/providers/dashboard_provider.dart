import 'package:flutter/foundation.dart';
import '../../../core/models/organization.dart';
import '../../../core/services/organization_service.dart';
import '../../../core/services/tenant_service.dart';

class DashboardProvider with ChangeNotifier {
  final OrganizationService _orgService;
  final TenantService _tenantService;

  DashboardProvider(this._orgService, this._tenantService);

  List<Organization> _organizations = [];
  Organization? _selectedOrganization;
  bool _isLoading = false;
  String? _error;

  List<Organization> get organizations => _organizations;
  Organization? get selectedOrganization => _selectedOrganization;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOrganizations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _organizations = await _orgService.getUserOrganizations();
      if (_organizations.isNotEmpty && _selectedOrganization == null) {
        _selectedOrganization = _organizations.first;
        await initializeTenantConnection();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectOrganization(Organization org) async {
    _selectedOrganization = org;
    _error = null;
    notifyListeners();
    await initializeTenantConnection();
  }

  Future<void> initializeTenantConnection() async {
    if (_selectedOrganization == null) return;

    try {
      await _tenantService.initializeTenantClient(_selectedOrganization!.id);
    } catch (e) {
      _error = 'Failed to connect to Supabase: $e';
      notifyListeners();
    }
  }

  bool get hasTenantConnection => _tenantService.tenantClient != null;
}

