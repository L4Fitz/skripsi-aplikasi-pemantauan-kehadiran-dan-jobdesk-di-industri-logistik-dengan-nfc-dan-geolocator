import 'package:flutter/material.dart';
import 'database_helper.dart';

class SupervisorPage extends StatefulWidget {
  final String name;
  SupervisorPage({Key? key, required this.name}) : super(key: key);

  @override
  _SupervisorPageState createState() => _SupervisorPageState();
}

class _SupervisorPageState extends State<SupervisorPage> {
  final dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Supervisor'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text('Halo, ${widget.name}')),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
                textStyle: TextStyle(fontSize: 18.0),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AttendancePage()),
                );
              },
              child: const Text('Lihat Absensi'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
                textStyle: TextStyle(fontSize: 18.0),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageJobdeskPage()),
                );
              },
              child: const Text('Lihat Job Desk'),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendancePage extends StatelessWidget {
  final dbHelper = DatabaseHelper();

  AttendancePage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _getAllAttendance() async {
    return await dbHelper.getAllAttendance();
  }

  void _updateAttendanceStatus(BuildContext context, int id) async {
    await dbHelper.updateAttendanceStatus(id, 'Absent');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status absensi diperbarui menjadi Absent')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Absensi'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getAllAttendance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('User ID: ${snapshot.data![index]['userId']}'),
                  subtitle: Text('Date: ${snapshot.data![index]['date']}, Status: ${snapshot.data![index]['status']}'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _updateAttendanceStatus(context, snapshot.data![index]['id']),
                    child: const Text('Mark Absent'),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No attendance records found'));
          }
        },
      ),
    );
  }
}

class ManageJobdeskPage extends StatefulWidget {
  ManageJobdeskPage({Key? key}) : super(key: key);

  @override
  _ManageJobdeskPageState createState() => _ManageJobdeskPageState();
}

class _ManageJobdeskPageState extends State<ManageJobdeskPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _controllerMonday = TextEditingController();
  final TextEditingController _controllerTuesday = TextEditingController();
  final TextEditingController _controllerWednesday = TextEditingController();
  final TextEditingController _controllerThursday = TextEditingController();
  final TextEditingController _controllerFriday = TextEditingController();

  void _updateJobdesk(int userId) async {
    Map<String, String> jobdesk = {
      'monday': _controllerMonday.text,
      'tuesday': _controllerTuesday.text,
      'wednesday': _controllerWednesday.text,
      'thursday': _controllerThursday.text,
      'friday': _controllerFriday.text,
    };
    await _dbHelper.updateJobdesk(userId, jobdesk);
    setState(() {});
  }

  Future<Map<String, dynamic>?> _getJobdesk(int userId) async {
    var result = await _dbHelper.getJobdesk(userId);
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> _getAllUsers() async {
    return await _dbHelper.getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Job Desk'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var user = snapshot.data![index];
                if (user['role'] == 'supervisor') {
                  return Container(); 
                }
                return ListTile(
                  title: Text('User: ${user['name']}'),
                  subtitle: Text('Role: ${user['role']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      var jobdesk = await _getJobdesk(user['id']);
                      if (jobdesk != null) {
                        _controllerMonday.text = jobdesk['monday'] ?? '';
                        _controllerTuesday.text = jobdesk['tuesday'] ?? '';
                        _controllerWednesday.text = jobdesk['wednesday'] ?? '';
                        _controllerThursday.text = jobdesk['thursday'] ?? '';
                        _controllerFriday.text = jobdesk['friday'] ?? '';
                      }

                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Update Jobdesk for ${user['name']}'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: _controllerMonday,
                                  decoration: const InputDecoration(hintText: "Monday"),
                                ),
                                TextField(
                                  controller: _controllerTuesday,
                                  decoration: const InputDecoration(hintText: "Tuesday"),
                                ),
                                TextField(
                                  controller: _controllerWednesday,
                                  decoration: const InputDecoration(hintText: "Wednesday"),
                                ),
                                TextField(
                                  controller: _controllerThursday,
                                  decoration: const InputDecoration(hintText: "Thursday"),
                                ),
                                TextField(
                                  controller: _controllerFriday,
                                  decoration: const InputDecoration(hintText: "Friday"),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  _updateJobdesk(user['id']);
                                  Navigator.pop(context);
                                },
                                child: const Text('Update'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No users found'));
          }
        },
      ),
    );
  }
}
  