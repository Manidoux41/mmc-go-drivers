import 'package:flutter/material.dart';
import 'package:flutter01/models/subscription_tier.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos de MMC Go'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Image.asset('assets/icon/logoMMCGo.png', height: 100),
                  const SizedBox(height: 10),
                  const Text(
                    'MMC Go Drivers',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Notre Mission',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 10),
            const Text(
              'MMC Go Drivers est né de la volonté de fournir aux transporteurs routiers (voyageurs et marchandises) un outil moderne, capable de gérer à la fois la navigation technique, le planning et la sécurité réglementaire.',
            ),
            const SizedBox(height: 30),
            Text(
              'Nos Tarifs',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 15),
            _buildPriceItem(context, SubscriptionTier.free, "Idéal pour découvrir"),
            _buildPriceItem(context, SubscriptionTier.expert, "Pour les conducteurs indépendants"),
            _buildPriceItem(context, SubscriptionTier.professional, "L'outil complet du quotidien"),
            _buildPriceItem(context, SubscriptionTier.diamond, "La solution d'entreprise"),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'Informations Légales',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('© 2024 MMC Go Développement'),
            const Text('Support : support@mmcgo-drivers.com'),
            const Text('Site Web : www.mmcgo-drivers.com'),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceItem(BuildContext context, SubscriptionTier tier, String sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tier.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(sub, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
          Text(
            '${tier.price} €/mois',
            style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
