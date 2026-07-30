import 'package:flutter/material.dart';
import 'package:flutter01/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter01/models/subscription_tier.dart';
import 'package:flutter01/viewmodels/subscription_viewmodel.dart';
import 'package:flutter01/viewmodels/login_viewmodel.dart';
import 'package:flutter01/models/user.dart';
import 'package:flutter01/services/email_service.dart';
import 'package:flutter01/views/dashboard/dashboard_view.dart';
import 'package:flutter01/config/colors.dart';

class PaywallView extends StatelessWidget {
  const PaywallView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chooseSubscription),
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
    final l10n = AppLocalizations.of(context)!;
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
                child: Text(l10n.currentSubscription,
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
                child: Text(tier == SubscriptionTier.free ? l10n.stayHere : (tier == SubscriptionTier.diamond ? l10n.contactUs : l10n.subscribeAction)),
              ),
          ],
        ),
      ),
    );
  }

  void _showSubscriptionProcess(BuildContext context, SubscriptionTier tier) {
    final user = Provider.of<LoginViewModel>(context, listen: false).currentUser;

    if (tier == SubscriptionTier.free) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardView()),
        (route) => false,
      );
      return;
    }

    if (tier == SubscriptionTier.diamond) {
      if (user?.isSuperAdmin ?? false) {
        // Pour les super-admins, activation directe du Diamant
        _PaymentSimulationFormState.activateDiamond(context, user!);
      } else {
        _showDiamondContactForm(context);
      }
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
      final l10n = AppLocalizations.of(context)!;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.secondaryGreen, size: 80),
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
                backgroundColor: AppColors.secondaryGreen,
                minimumSize: const Size.fromHeight(50),
              ),
              child: Text(l10n.cancel), // Utilisation de cancel pour "RETOUR"
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

                  if (!mounted) return;

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
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
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

  static Future<void> activateDiamond(BuildContext context, User user) async {
    final subVM = Provider.of<SubscriptionViewModel>(context, listen: false);
    final success = await subVM.subscribe(SubscriptionTier.diamond, useStripe: false);
    if (success && context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardView()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Accès Super-Admin Diamant Activé !')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SubscriptionViewModel>(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.finalizeSubscription,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Text('${l10n.tier} : ${widget.tier.displayName} - ${widget.tier.price}€/mois'),
        const Divider(height: 30),
        
        SwitchListTile(
          title: Text(l10n.useStripe),
          subtitle: const Text('Nécessite des clés API valides'),
          value: _useRealStripe,
          onChanged: (val) => setState(() => _useRealStripe = val),
        ),

        if (!_useRealStripe) ...[
          Text(l10n.dummyPayment, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 10),
          TextField(
            controller: _cardNumberController,
            decoration: InputDecoration(labelText: l10n.cardNumber, prefixIcon: const Icon(Icons.credit_card)),
            keyboardType: TextInputType.number,
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _expiryController,
                  decoration: InputDecoration(labelText: l10n.expiryDate, hintText: 'MM/YY'),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: TextField(
                  controller: _cvcController,
                  decoration: InputDecoration(labelText: l10n.cvc),
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

                  if (!mounted) return;

                  if (success) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardView()),
                      (route) => false,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.congratsSubscription(widget.tier.displayName))),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.paymentFailed)),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(55),
                  backgroundColor: _useRealStripe ? Colors.indigo : Colors.blue.shade800,
                  foregroundColor: Colors.white,
                ),
                child: Text(_useRealStripe ? 'OUVRIR STRIPE' : l10n.confirmDummyPayment),
              ),
        const SizedBox(height: 20),
      ],
    );
  }
}
