import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/subscription_tier.dart';
import '../../viewmodels/subscription_viewmodel.dart';
import '../dashboard/dashboard_view.dart';

class PaywallView extends StatelessWidget {
  const PaywallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir mon abonnement'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTierCard(context, SubscriptionTier.free),
          _buildTierCard(context, SubscriptionTier.expert),
          _buildTierCard(context, SubscriptionTier.professional),
          _buildTierCard(context, SubscriptionTier.diamond),
        ],
      ),
    );
  }

  Widget _buildTierCard(BuildContext context, SubscriptionTier tier) {
    final viewModel = Provider.of<SubscriptionViewModel>(context, listen: false);
    final isCurrent = viewModel.currentUser?.tier == tier;

    return Card(
      elevation: isCurrent ? 8 : 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: isCurrent ? const BorderSide(color: Colors.green, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tier.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${tier.price}€/mois',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              tier.description,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
            ),
            const SizedBox(height: 20),
            if (isCurrent)
              const Center(
                child: Text('ABONNEMENT ACTUEL',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              )
            else
              ElevatedButton(
                onPressed: () => _showPaymentSheet(context, tier),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tier == SubscriptionTier.diamond ? Colors.orange : Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(tier == SubscriptionTier.free ? 'RESTER ICI' : 'S\'ABONNER'),
              ),
          ],
        ),
      ),
    );
  }

  void _showPaymentSheet(BuildContext context, SubscriptionTier tier) {
    if (tier == SubscriptionTier.free) {
      // Si on choisit de rester en gratuit, on accède quand même au tableau de bord
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardView()),
        (route) => false,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: _PaymentSimulationForm(tier: tier),
      ),
    );
  }
}

class _PaymentSimulationForm extends StatefulWidget {
  final SubscriptionTier tier;
  const _PaymentSimulationForm({required this.tier});

  @override
  State<_PaymentSimulationForm> createState() => _PaymentSimulationFormState();
}

class _PaymentSimulationFormState extends State<_PaymentSimulationForm> {
  final _cardNumberController = TextEditingController(text: '4242 4242 4242 4242');
  final _expiryController = TextEditingController(text: '12/26');
  final _cvcController = TextEditingController(text: '123');

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SubscriptionViewModel>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paiement via Stripe (Simulation)',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Text('Abonnement : ${widget.tier.name} - ${widget.tier.price}€/mois'),
        const SizedBox(height: 20),
        TextField(
          controller: _cardNumberController,
          decoration: const InputDecoration(labelText: 'Numéro de carte', prefixIcon: Icon(Icons.credit_card)),
          keyboardType: TextInputType.number,
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _expiryController,
                decoration: const InputDecoration(labelText: 'Date d\'expiration', hintText: 'MM/YY'),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: TextField(
                controller: _cvcController,
                decoration: const InputDecoration(labelText: 'CVC'),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        viewModel.isProcessing
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                onPressed: () async {
                  final success = await viewModel.subscribe(
                    widget.tier,
                    _cardNumberController.text,
                    _expiryController.text,
                    _cvcController.text,
                  );
                  if (success && mounted) {
                    Navigator.pop(context); // Ferme le formulaire
                    
                    // On redirige vers le Dashboard pour donner accès aux fonctionnalités
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardView()),
                      (route) => false,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Félicitations ! Vous êtes maintenant ${widget.tier.name}')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(55),
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                ),
                child: const Text('CONFIRMER LE PAIEMENT'),
              ),
        const SizedBox(height: 20),
      ],
    );
  }
}
