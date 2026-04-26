import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/planning_activity.dart';

class PdfService {
  static Future<void> generateAndSharePlanning(DateTime date, List<PlanningActivity> activities) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
    final timeFormat = DateFormat('HH:mm');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Feuille de Route Chauffeur', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text(dateFormat.format(date)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                data: <List<String>>[
                  <String>['Horaire', 'Activité', 'Détails / Trajet', 'Véhicule'],
                  ...activities.map((act) => [
                        '${timeFormat.format(act.startTime)} - ${timeFormat.format(act.endTime)}',
                        act.title,
                        act.departure != null ? '${act.departure} -> ${act.arrival}' : '-',
                        act.busNumber ?? '-',
                      ]),
                ],
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 40),
                child: pw.Text('Document généré via Bus Driver Toolbox', style: const pw.TextStyle(color: PdfColors.grey)),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'planning_${date.day}_${date.month}.pdf');
  }
}
