import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/super_admin_viewmodel.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../models/user.dart';
import '../../models/subscription_tier.dart';

class SuperAdminView extends StatelessWidget {
  const SuperAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MMC Go - Haute Administration'),
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.orange,
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.admin_panel_settings), text: 'Utilisateurs'),
              Tab(icon: Icon(Icons.mail_outline), text: 'Demandes Diamant'),
              Tab(icon: Icon(Icons.code), text: 'Guide SQL Client'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ManageGlobalUsersTab(),
            _ManageRequestsTab(),
            _SqlClientGuideTab(),
          ],
        ),
      ),
    );
  }
}

class _ManageGlobalUsersTab extends StatefulWidget {
  const _ManageGlobalUsersTab();

  @override
  State<_ManageGlobalUsersTab> createState() => _ManageGlobalUsersTabState();
}

class _ManageGlobalUsersTabState extends State<_ManageGlobalUsersTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SuperAdminViewModel>().fetchAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SuperAdminViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) return const Center(child: CircularProgressIndicator());

        return ListView.builder(
          itemCount: viewModel.allUsers.length,
          itemBuilder: (context, index) {
            final user = viewModel.allUsers[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: user.isSuperAdmin ? Colors.orange : Colors.grey.shade200,
                  child: Icon(user.isSuperAdmin ? Icons.star : Icons.person, color: user.isSuperAdmin ? Colors.white : Colors.grey),
                ),
                title: Text(user.fullName ?? 'Utilisateur Sans Nom'),
                subtitle: Text('${user.username} • Tier: ${user.tier.displayName}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (val) async {
                    if (val == 'delete') {
                      _confirmDelete(context, viewModel, user);
                    } else {
                      await _changeTier(context, viewModel, user);
                      viewModel.fetchAllData();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'tier', child: Text('Modifier Forfait')),
                    const PopupMenuItem(value: 'delete', child: Text('Supprimer', style: TextStyle(color: Colors.red))),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, SuperAdminViewModel vm, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'utilisateur ?'),
        content: Text('Voulez-vous vraiment supprimer ${user.fullName} ? Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULER')),
          ElevatedButton(
            onPressed: () {
              vm.deleteUser(user.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('SUPPRIMER'),
          ),
        ],
      ),
    );
  }

  Future<void> _changeTier(BuildContext context, SuperAdminViewModel vm, User user) async {
    final urlController = TextEditingController(text: user.customSupabaseUrl);
    final keyController = TextEditingController(text: user.customSupabaseAnonKey);
    SubscriptionTier selectedTier = user.tier;

    return showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Modifier le forfait'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...SubscriptionTier.values.map((tier) {
                  return RadioListTile<SubscriptionTier>(
                    title: Text(tier.displayName),
                    value: tier,
                    groupValue: selectedTier,
                    onChanged: (val) => setDialogState(() => selectedTier = val!),
                  );
                }),
                if (selectedTier == SubscriptionTier.diamond) ...[
                  const Divider(),
                  const Text('Configuration Décentralisée', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: urlController,
                          decoration: const InputDecoration(labelText: 'URL Supabase Client', border: OutlineInputBorder()),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.content_paste),
                        onPressed: () async {
                          final data = await Clipboard.getData(Clipboard.kTextPlain);
                          if (data?.text != null) urlController.text = data!.text!;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: keyController,
                          decoration: const InputDecoration(labelText: 'Clé Anon Client', border: OutlineInputBorder()),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.content_paste),
                        onPressed: () async {
                          final data = await Clipboard.getData(Clipboard.kTextPlain);
                          if (data?.text != null) keyController.text = data!.text!;
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULER')),
            ElevatedButton(
              onPressed: () async {
                final success = await vm.updateUserTier(
                  user.id, 
                  selectedTier, 
                  customUrl: urlController.text.isEmpty ? null : urlController.text,
                  customKey: keyController.text.isEmpty ? null : keyController.text,
                );
                
                if (context.mounted) {
                  if (success) {
                    Navigator.pop(context);
                    if (selectedTier == SubscriptionTier.diamond) {
                      _showSqlGuideSuggestion(context);
                    }
                  }
                }
              },
              child: const Text('ENREGISTRER'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSqlGuideSuggestion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compte Diamant Activé'),
        content: const Text('Souhaitez-vous consulter le guide SQL pour initialiser la base du client ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('PLUS TARD')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              DefaultTabController.of(context).animateTo(2);
            },
            child: const Text('VOIR LE GUIDE'),
          ),
        ],
      ),
    );
  }
}

class _ManageRequestsTab extends StatelessWidget {
  const _ManageRequestsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<SuperAdminViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          itemCount: viewModel.contactRequests.length,
          itemBuilder: (context, index) {
            final req = viewModel.contactRequests[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(req['sender_name'] ?? 'Inconnu'),
                subtitle: Text(req['sender_email']),
                trailing: req['status'] == 'pending' 
                  ? ElevatedButton(onPressed: () => viewModel.markRequestProcessed(req['id']), child: const Text('TRAITER'))
                  : const Icon(Icons.check_circle, color: Colors.green),
              ),
            );
          },
        );
      },
    );
  }
}

class _SqlClientGuideTab extends StatelessWidget {
  const _SqlClientGuideTab();

  final String _clientSqlScript = '''-- Tables Client Diamant
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  full_name TEXT,
  tier TEXT DEFAULT 'professional'
);
CREATE TABLE IF NOT EXISTS vehicles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  registration TEXT UNIQUE NOT NULL,
  brand TEXT, model TEXT, height FLOAT, length FLOAT, width FLOAT,
  unladen_weight FLOAT, ptac FLOAT, fuel_type TEXT, mileage FLOAT DEFAULT 0
);
CREATE TABLE IF NOT EXISTS activities (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL, type TEXT NOT NULL,
  start_time TIMESTAMP WITH TIME ZONE, end_time TIMESTAMP WITH TIME ZONE,
  departure TEXT, arrival TEXT, vehicle_id UUID REFERENCES vehicles(id),
  driver_id UUID NOT NULL, stops JSONB, file_path TEXT
);
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public" ON profiles FOR ALL USING (true);
CREATE POLICY "Public" ON vehicles FOR ALL USING (true);
CREATE POLICY "Public" ON activities FOR ALL USING (true);''';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('Script d\'initialisation Client Diamant', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.grey.shade900,
            child: Text(_clientSqlScript, style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontFamily: 'monospace')),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () => Clipboard.setData(ClipboardData(text: _clientSqlScript)),
            icon: const Icon(Icons.copy),
            label: const Text('COPIER LE SCRIPT'),
          )
        ],
      ),
    );
  }
}

class AlertBox extends StatelessWidget {
  final String message;
  const AlertBox({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 15),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 13, color: Colors.orangeAccent))),
        ],
      ),
    );
  }
}
