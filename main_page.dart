  import 'package:flutter/material.dart';
  import 'package:geolocator/geolocator.dart';
  import 'database_helper.dart';
  import 'jobdesk_page.dart';

  class MainPage extends StatefulWidget {
    final String nfcId;
    final String name;
    MainPage({Key? key, required this.nfcId, required this.name}) : super(key: key);

    @override
    _MainPageState createState() => _MainPageState();
  }

  class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
    final dbHelper = DatabaseHelper();
    String? _attendanceStatus;
    late AnimationController _animationController;
    late Animation<double> _animation;
    bool _isLoading = false;

    // Koordinat Universitas Bina Nusantara Bandung
    final double binusLatitude = -6.9155373;
    final double binusLongitude = 107.5938642;
    final double maxDistance = 200; 

    @override
    void initState() {
      super.initState();
      _animationController = AnimationController(
        duration: const Duration(seconds: 1),
        vsync: this,
      );
      _animation = CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      );

      _checkAttendanceStatus();
      _animationController.forward();
    }

    @override
    void dispose() {
      _animationController.dispose();
      super.dispose();
    }

    void _checkAttendanceStatus() async {
      final user = await dbHelper.getUserByNfcId(widget.nfcId);
      if (user.isNotEmpty) {
        final attendance = await dbHelper.getAttendance(user[0]['id']);
        if (attendance.isNotEmpty) {
          setState(() {
            _attendanceStatus = attendance.last['status'];
          });
        }
      }
    }

    Future<void> _markAttendance(BuildContext context) async {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = await dbHelper.getUserByNfcId(widget.nfcId);
        if (user.isNotEmpty) {
          Position position = await _determinePosition();
          double distance = Geolocator.distanceBetween(
            binusLatitude,
            binusLongitude,
            position.latitude,
            position.longitude,
          );

          print("Current position: ${position.latitude}, ${position.longitude}");
          print("Distance to Binus: $distance meters");

          if (distance <= maxDistance) {
            await dbHelper.markAttendance(user[0]['id'], DateTime.now().toString(), 'Present');
            _showDialog(context, 'Absen Berhasil', 'Absen anda berhasil, silahkan kembali.');
            setState(() {
              _attendanceStatus = 'Present';
            });
          } else {
            _showDialog(context, 'Absen Gagal', 'Anda tidak berada dalam radius 200 meter dari Universitas Bina Nusantara Bandung.');
          }
        } else {
          _showDialog(context, 'Error', 'User tidak ditemukan.');
        }
      } catch (e) {
        print("Error determining position: $e");
        _showDialog(context, 'Error', 'Terjadi kesalahan saat mendapatkan lokasi: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }

    Future<Position> _determinePosition() async {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied, we cannot request permissions.');
      }

      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
    }

    void _showDialog(BuildContext context, String title, String content) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Halaman Employee'),
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
              if (_attendanceStatus == 'Absent')
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Absen anda tidak disetujui karena tidak ada di tempat!',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              if (_isLoading)
                CircularProgressIndicator()
              else
                ScaleTransition(
                  scale: _animation,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
                      textStyle: TextStyle(fontSize: 18.0),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _markAttendance(context),
                    child: const Text('Absen Sekarang', style: TextStyle(color: Colors.white)),
                  ),
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
                    MaterialPageRoute(builder: (context) => JobdeskPage(nfcId: widget.nfcId)),
                  );
                },
                child: const Text('Lihat Job Desk', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }
  }
