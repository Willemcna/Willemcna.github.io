import 'package:flutter/material.dart';
import '../../../core/models/organization.dart';

class OrganizationSwitcher extends StatelessWidget {
  final List<Organization> organizations;
  final Organization? selectedOrganization;
  final Function(Organization) onOrganizationSelected;

  const OrganizationSwitcher({
    super.key,
    required this.organizations,
    this.selectedOrganization,
    required this.onOrganizationSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (organizations.isEmpty) {
      return const SizedBox.shrink();
    }

    return DropdownButton<Organization>(
      value: selectedOrganization,
      items: organizations.map((org) {
        return DropdownMenuItem<Organization>(
          value: org,
          child: Text(org.name),
        );
      }).toList(),
      onChanged: (org) {
        if (org != null) {
          onOrganizationSelected(org);
        }
      },
      hint: const Text('Select Organization'),
    );
  }
}

