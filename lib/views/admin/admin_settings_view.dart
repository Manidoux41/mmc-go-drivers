import 'package:flutter/material.dart';
import '../../services/settings_service.dart';

class AdminSettingsView extends StatefulWidget {
  const AdminSettingsView({super.key});

  @override
  State<AdminSettingsView> createState() => _AdminSettingsViewState();
}

class _AdminSettingsViewState extends State<AdminSettingsView> {
  final TextEditingController _urlController = TextEditingController();
  final SettingsService _settingsService = SettingsService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUrl();
  }

  Future<void> _loadCurrentUrl() async {
    final url = await _settingsService.getDatabaseUrl();
    if (url != null) {
      setState(() {
        _urlController.text = url;
      });
    }
  }

  Future<void> _saveUrl() async {
    setState(() => _isSaving = true);
    await _settingsService.saveDatabaseUrl(_urlController.text);
    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuration de la base de données enregistrée')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration Administrateur'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lien de la base de données',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Entrez l\'URL de votre API, Firebase, ou chaîne de connexion SQL/NoSQL.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'URL de connexion',
                hintText: 'https://api.votre-serveur.com',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.link, color: Colors.green),
              ),
            ),
            const SizedBox(height: 30),
            _isSaving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _saveUrl,
                    icon: const Icon(Icons.save),
                    label: const Text('ENREGISTRER LA CONFIGURATION'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
