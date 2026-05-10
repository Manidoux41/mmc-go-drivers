import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../viewmodels/document_viewmodel.dart';
import '../../models/driver_document.dart';

class DocumentView extends StatelessWidget {
  const DocumentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Documents'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<DocumentViewModel>(
        builder: (context, viewModel, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.documents.length,
            itemBuilder: (context, index) {
              final doc = viewModel.documents[index];
              return _buildDocumentCard(context, viewModel, doc);
            },
          );
        },
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, DocumentViewModel viewModel, DriverDocument doc) {
    final bool hasFile = doc.filePath != null;
    final bool isExpired = doc.isExpired;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isExpired ? const BorderSide(color: Colors.red, width: 2) : BorderSide.none,
      ),
      child: ExpansionTile(
        leading: Icon(
          _getDocumentIcon(doc.type),
          color: hasFile ? Theme.of(context).primaryColor : Colors.grey,
        ),
        title: Text(
          doc.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          isExpired 
            ? 'EXPIRÉ' 
            : (doc.expiryDate != null 
                ? 'Expire le : ${DateFormat('dd/MM/yyyy').format(doc.expiryDate!)}' 
                : 'Date de validité non saisie'),
          style: TextStyle(
            color: isExpired ? Colors.red : Colors.grey,
            fontWeight: isExpired ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (hasFile)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb 
                      ? Image.network(doc.filePath!, height: 200, width: double.infinity, fit: BoxFit.cover)
                      : Image.file(
                          File(doc.filePath!),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                  )
                else
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file, color: Colors.grey),
                        Text('Aucun document chargé', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showPickerOptions(context, viewModel, doc),
                      icon: const Icon(Icons.add_a_photo),
                      label: Text(hasFile ? 'Remplacer' : 'Ajouter'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _selectExpiryDate(context, viewModel, doc),
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Validité'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.license: return Icons.badge;
      case DocumentType.fimo: return Icons.school;
      case DocumentType.chrono: return Icons.timer;
      case DocumentType.vitale: return Icons.health_and_safety;
      case DocumentType.identity: return Icons.perm_identity;
    }
  }

  void _showPickerOptions(BuildContext context, DocumentViewModel viewModel, DriverDocument doc) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () {
                viewModel.pickDocument(doc.id, ImageSource.camera);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir dans la galerie'),
              onTap: () {
                viewModel.pickDocument(doc.id, ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectExpiryDate(BuildContext context, DocumentViewModel viewModel, DriverDocument doc) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: doc.expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 15)),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      viewModel.updateExpiryDate(doc.id, picked);
    }
  }
}
