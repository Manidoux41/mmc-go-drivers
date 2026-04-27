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

  static Future<void> generateWeeklyPlanning(DateTime weekStart, Map<String, List<PlanningActivity>> driverActivities) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM');
    final timeFormat = DateFormat('HH:mm');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return [
            pw.Header(level: 0, child: pw.Text('Planning Hebdomadaire Flotte', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Conducteur', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ...List.generate(7, (i) {
                      final day = weekStart.add(Duration(days: i));
                      return pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(dateFormat.format(day), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)));
                    }),
                  ],
                ),
                ...driverActivities.entries.map((entry) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(entry.key)),
                      ...List.generate(7, (i) {
                        final day = weekStart.add(Duration(days: i));
                        final dayActs = entry.value.where((a) => a.startTime.day == day.day && a.startTime.month == day.month).toList();
                        return pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(dayActs.isEmpty ? '-' : dayActs.map((a) => timeFormat.format(a.startTime)).join('\n'), style: const pw.TextStyle(fontSize: 8)),
                        );
                      }),
                    ],
                  );
                }),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'planning_hebdomadaire.pdf');
  }
}
