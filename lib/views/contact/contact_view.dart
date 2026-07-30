import 'package:flutter/material.dart';
import 'package:flutter01/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter01/models/contact.dart';

class ContactView extends StatelessWidget {
  ContactView({super.key});

  final List<Contact> contacts = [
    Contact(
      name: 'PERMANENCE EXPLOITATION',
      role: '24h/24 - Urgences planning / pannes',
      phoneNumber: '0237000000',
      type: ContactType.emergency,
    ),
    Contact(
      name: 'Responsable d\'Exploitation',
      role: 'Gestion des services et conducteurs',
      phoneNumber: '0600000001',
      type: ContactType.manager,
    ),
    Contact(
      name: 'Atelier Mécanique',
      role: 'Problèmes techniques / entretien',
      phoneNumber: '0600000002',
      type: ContactType.technical,
    ),
    Contact(
      name: 'Ressources Humaines',
      role: 'Contrats / Paies / Congés',
      phoneNumber: '0237111111',
      type: ContactType.manager,
    ),
    Contact(
      name: 'Gendarmerie Châteaudun',
      role: 'Urgences / Accidents',
      phoneNumber: '17',
      type: ContactType.emergency,
    ),
  ];

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback pour les simulateurs ou si l'URL ne peut pas être lancée
        await launchUrl(launchUri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'appel: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.usefulContacts),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return _buildContactCard(context, contact);
        },
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, Contact contact) {
    Color color;
    IconData icon;

    switch (contact.type) {
      case ContactType.emergency:
        color = Colors.red;
        icon = Icons.warning_amber_rounded;
        break;
      case ContactType.manager:
        color = Colors.blue;
        icon = Icons.person;
        break;
      case ContactType.technical:
        color = Colors.orange;
        icon = Icons.build;
        break;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          contact.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(contact.role),
            const SizedBox(height: 4),
            Text(
              contact.phoneNumber,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.phone, color: Theme.of(context).primaryColor),
          onPressed: () => _makePhoneCall(contact.phoneNumber),
        ),
        onTap: () => _makePhoneCall(contact.phoneNumber),
      ),
    );
  }
}
