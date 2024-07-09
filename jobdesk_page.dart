import 'package:flutter/material.dart';
import 'database_helper.dart';

class JobdeskPage extends StatelessWidget {
  final String nfcId;

  JobdeskPage({Key? key, required this.nfcId}) : super(key: key);

  final dbHelper = DatabaseHelper();

  Future<Map<String, dynamic>?> _getJobdesk() async {
    final user = await dbHelper.getUserByNfcId(nfcId);
    if (user.isNotEmpty) {
      var result = await dbHelper.getJobdesk(user[0]['id']);
      return result.isNotEmpty ? result.first : null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobdesk'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getJobdesk(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final jobdesk = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jobdesk Anda',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 20),
                  Table(
                    border: TableBorder.all(color: Colors.black),
                    columnWidths: const <int, TableColumnWidth>{
                      0: FixedColumnWidth(120),
                      1: FlexColumnWidth(),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: <TableRow>[
                      _buildTableRow('Monday', jobdesk['monday']),
                      _buildTableRow('Tuesday', jobdesk['tuesday']),
                      _buildTableRow('Wednesday', jobdesk['wednesday']),
                      _buildTableRow('Thursday', jobdesk['thursday']),
                      _buildTableRow('Friday', jobdesk['friday']),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No jobdesk found'));
          }
        },
      ),
    );
  }

  TableRow _buildTableRow(String day, String task) {
    return TableRow(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            day,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            task,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
