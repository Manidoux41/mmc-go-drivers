import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/super_admin_viewmodel.dart';
import '../../models/user.dart';
import '../../models/subscription_tier.dart';

class SuperAdminView extends StatelessWidget {
  const SuperAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MMC Go - Haute Administration'),
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.orange,
            tabs: [
              Tab(icon: Icon(Icons.admin_panel_settings), text: 'Utilisateurs'),
              Tab(icon: Icon(Icons.mail_outline), text: 'Demandes Diamant'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ManageGlobalUsersTab(),
            _ManageRequestsTab(),
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
                  onSelected: (val) {
                    if (val == 'delete') {
                      _confirmDelete(context, viewModel, user);
                    } else {
                      _changeTier(context, viewModel, user);
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

  void _changeTier(BuildContext context, SuperAdminViewModel vm, User user) {
    final urlController = TextEditingController(text: user.customSupabaseUrl);
    final keyController = TextEditingController(text: user.customSupabaseAnonKey);
    SubscriptionTier selectedTier = user.tier;

    showDialog(
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
                  TextField(
                    controller: urlController,
                    decoration: const InputDecoration(labelText: 'URL Supabase Client', hintText: 'https://xyz.supabase.co', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: keyController,
                    decoration: const InputDecoration(labelText: 'Clé Anon Client', border: OutlineInputBorder()),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULER')),
            ElevatedButton(
              onPressed: () {
                vm.updateUserTier(
                  user.id, 
                  selectedTier, 
                  customUrl: urlController.text.isEmpty ? null : urlController.text,
                  customKey: keyController.text.isEmpty ? null : keyController.text,
                );
                Navigator.pop(context);
              },
              child: const Text('ENREGISTRER'),
            ),
          ],
        ),
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
        if (viewModel.contactRequests.isEmpty) {
          return const Center(child: Text('Aucune demande de forfait Diamant.'));
        }

        return ListView.builder(
          itemCount: viewModel.contactRequests.length,
          itemBuilder: (context, index) {
            final req = viewModel.contactRequests[index];
            final date = DateTime.parse(req['created_at']);
            final isProcessed = req['status'] == 'processed';

            return Card(
              margin: const EdgeInsets.all(8),
              color: isProcessed ? Colors.grey.shade50 : Colors.white,
              child: ExpansionTile(
                leading: Icon(Icons.business, color: isProcessed ? Colors.grey : Colors.orange),
                title: Text(req['sender_name'] ?? 'Inconnu'),
                subtitle: Text('Le ${DateFormat('dd/MM/yyyy HH:mm').format(date)}'),
                trailing: isProcessed ? const Icon(Icons.check_circle, color: Colors.green) : null,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${req['sender_email']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(req['message'] ?? 'Pas de message.'),
                        const SizedBox(height: 20),
                        if (!isProcessed)
                          ElevatedButton(
                            onPressed: () => viewModel.markRequestProcessed(req['id']),
                            child: const Text('MARQUER COMME TRAITÉ'),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
