import 'package:flutter/material.dart';
import 'package:wheelit/classes/Ticket.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wheelit/classes/DatabaseManager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TicketScreen extends StatefulWidget {
  @override
  _TicketScreenState createState() => _TicketScreenState();

  //Metodo usato per convertire DateTime in data e ora comprensibili da un utente
  static List toLocalDateTime(DateTime dt) {
    DateTime dateOriginal = DateTime.tryParse(dt.toString());
    List date = dateOriginal
        .add(Duration(
            hours: dateOriginal
                .timeZoneOffset.inHours)) //aggiungo l'offset del fusorario
        .toUtc()
        .toString()
        .split(" ");
    return date; //il primo elemento è la data, il secondo è l'orario
  }
}

class _TicketScreenState extends State<TicketScreen> {
  List<Ticket> ticketList = [];
  String userEmail = 'pippolippo@gmail.com';
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  User user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    getUserTicket();
  }

  @override
  Widget build(BuildContext context) {
    Function showMessage = (String text) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(text)));
    };
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          title: Text("Your tickets:"),
          backgroundColor: Theme.of(context).accentColor),
      body: ticketList == null
          ? Center(child: CircularProgressIndicator())
          : ticketList.isEmpty
              ? Center(
                  child: Text("No tickets purchased",
                      style: TextStyle(fontSize: 30.0)))
              : ListView(
                  physics: BouncingScrollPhysics(),
                  children: ticketList.map((ticket) {
                    return Card(
                        child: ListTile(
                            trailing: IconButton(
                                icon: Icon(Icons.file_download),
                                onPressed: () async {
                                  String filename = await downloadPdf(ticket);
                                  if (filename != null) {
                                    showMessage(
                                        '${filename.replaceAll('/', '')}.pdf was created');
                                  } else {
                                    showMessage(
                                        'File was not saved due to an error, check your storage');
                                  }
                                }),
                            leading: Icon(Icons.qr_code_rounded),
                            title: Text((ticket.type == TicketType.PASS
                                    ? 'Pass '
                                    : '') +
                                'Ticket bought on: ${ticket.buyDate}'),
                            subtitle: Text(ticket.type == TicketType.PASS
                                ? 'from: ${ticket.startDate} to ${ticket.endDate}'
                                : ''),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                        content: Container(
                                      width: MediaQuery.of(context).size.width -
                                          16.0,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              3,
                                      child: Center(
                                        child: QrImage(
                                            data: ticket.toCode(), size: 500),
                                      ),
                                    ));
                                  });
                            }));
                  }).toList(),
                ),
    );
  }

  Future<void> getUserTicket() async {
    Map tickets = await DatabaseManager.getTicketData(user.email);
    List<Ticket> temp = [];
    tickets.forEach((key, value) {
      temp.add(Ticket.parseString(value.toString()));
    });
    setState(() {
      this.ticketList = temp;
    });
  }
}

Future<String> downloadPdf(Ticket t) async {
  try {
    bool res = await Permission.storage.isDenied;
    if (res) {
      await Permission.storage.request();
    } else {
      final QrPainter imagePainter = QrPainter(
        data: t.toCode(),
        version: QrVersions.auto,
      );
      double imageSize = 300;
      final imageByteData = await imagePainter.toImageData(imageSize);
      final imageuintlist = imageByteData.buffer.asUint8List();
      PdfDocument doc = PdfDocument();
      PdfPage pdfp = doc.pages.add();
      pdfp.graphics.drawImage(
          PdfBitmap(imageuintlist), Rect.fromLTWH(0, 0, imageSize, imageSize));
      PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 24);
      String toWrite = t.toString();
      Size stringSize = font.measureString(toWrite);
      pdfp.graphics.drawString(toWrite, font,
          bounds: Rect.fromLTWH(
              0, imageSize + 20, stringSize.width, stringSize.height));
      Directory appDocumentsDirectory = await getExternalStorageDirectory();
      String filePath = appDocumentsDirectory.absolute.path;
      List filenames = Directory(filePath)
          .listSync(followLinks: false, recursive: false)
          .map((e) {
        String directoryName = e.parent.toString().split('\'')[1];
        return e
            .toString()
            .split(directoryName)[1]
            .replaceAll('\'', '')
            .replaceAll(']', '')
            .replaceAll('.pdf', '');
      }).toList();
      String fileName = '/wheelitTicket';
      int i = 0;
      while (filenames.contains(fileName)) {
        fileName = '/wheelitTicket(${i++})';
      }
      File file = File('$filePath$fileName.pdf');
      file.writeAsBytesSync(doc.save(), mode: FileMode.writeOnly);
      doc.dispose();
      return fileName;
    }
  } catch (error) {
    print('ERROR: ${error.toString()}');
    return null;
  }
  return null;
}
