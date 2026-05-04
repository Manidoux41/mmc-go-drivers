import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/subscription_tier.dart';
import '../../viewmodels/subscription_viewmodel.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../services/email_service.dart';
import '../dashboard/dashboard_view.dart';

class PaywallView extends StatelessWidget {
  const PaywallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir mon abonnement'),
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
        side: isCurrent ? BorderSide(color: Theme.of(context).primaryColor, width: 2) : BorderSide.none,
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
                  tier.displayName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${tier.price}€/mois',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).primaryColor,
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
              Center(
                child: Text('ABONNEMENT ACTUEL',
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
              )
            else
              ElevatedButton(
                onPressed: () => _showSubscriptionProcess(context, tier),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tier == SubscriptionTier.diamond ? Colors.orange : Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(tier == SubscriptionTier.free ? 'RESTER ICI' : (tier == SubscriptionTier.diamond ? 'NOUS CONTACTER' : 'S\'ABONNER')),
              ),
          ],
        ),
      ),
    );
  }

  void _showSubscriptionProcess(BuildContext context, SubscriptionTier tier) {
    if (tier == SubscriptionTier.free) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardView()),
        (route) => false,
      );
      return;
    }

    if (tier == SubscriptionTier.diamond) {
      _showDiamondContactForm(context);
      return;
    }

    _showPaymentSheet(context, tier);
  }

  void _showDiamondContactForm(BuildContext context) {
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
        child: const _DiamondContactForm(),
      ),
    );
  }

  void _showPaymentSheet(BuildContext context, SubscriptionTier tier) {
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

class _DiamondContactForm extends StatefulWidget {
  const _DiamondContactForm();

  @override
  State<_DiamondContactForm> createState() => _DiamondContactFormState();
}

class _DiamondContactFormState extends State<_DiamondContactForm> {
  final _messageController = TextEditingController();
  bool _isSent = false;
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final user = loginVM.currentUser;

    if (_isSent) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, color: Color(0xFF00A859), size: 80),
            const SizedBox(height: 20),
            const Text(
              'Demande envoyée !',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Un administrateur de MMCGO Drivers vous recontactera très rapidement pour convenir avec vous de vos besoins.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A859),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('RETOUR'),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Intéressé par le forfait Diamant ?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Ce forfait est destiné aux entreprises. Laissez-nous un message et nous vous recontacterons pour une solution sur-mesure.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _messageController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Vos besoins spécifiques (nombre de chauffeurs, type de flotte...)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 30),
        _isSending
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                onPressed: () async {
                  if (_messageController.text.trim().isEmpty) return;

                  setState(() => _isSending = true);

                  final success = await EmailService.sendDiamondRequest(
                    senderEmail: user?.username ?? 'Email inconnu',
                    senderName: user?.fullName ?? 'Utilisateur Inconnu',
                    message: _messageController.text,
                  );

                  if (mounted) {
                    setState(() {
                      _isSending = false;
                      if (success) {
                        _isSent = true;
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Échec de l\'envoi. Veuillez réessayer.')),
                        );
                      }
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(55),
                ),
                child: const Text('ENVOYER MA DEMANDE'),
              ),
        const SizedBox(height: 20),
      ],
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
  bool _useRealStripe = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SubscriptionViewModel>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Finaliser l\'abonnement',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Text('Abonnement : ${widget.tier.displayName} - ${widget.tier.price}€/mois'),
        const Divider(height: 30),
        
        // Sélecteur de mode de paiement
        SwitchListTile(
          title: const Text('Utiliser Stripe (Fenêtre native)'),
          subtitle: const Text('Nécessite des clés API valides'),
          value: _useRealStripe,
          onChanged: (val) => setState(() => _useRealStripe = val),
        ),

        if (!_useRealStripe) ...[
          const Text('Paiement par Carte Fictive (Mode Test)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 10),
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
        ],
        
        const SizedBox(height: 30),
        viewModel.isProcessing
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                onPressed: () async {
                  final success = await viewModel.subscribe(
                    widget.tier,
                    useStripe: _useRealStripe,
                  );
                  if (success && mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardView()),
                      (route) => false,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Félicitations ! Vous êtes maintenant ${widget.tier.displayName}')),
                    );
                  } else if (!success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Le paiement a échoué ou a été annulé.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(55),
                  backgroundColor: _useRealStripe ? Colors.indigo : Colors.blue.shade800,
                  foregroundColor: Colors.white,
                ),
                child: Text(_useRealStripe ? 'OUVRIR STRIPE' : 'CONFIRMER LE PAIEMENT FICTIF'),
              ),
        const SizedBox(height: 20),
      ],
    );
  }
}
