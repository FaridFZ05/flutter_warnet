import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warnet Pelanggan Entri',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PelangganFormPage(),
    );
  }
}

class Pelanggan {
  final String kodePelanggan;
  final String namaPelanggan;
  final String jenisPelanggan;
  final DateTime tglMasuk;
  final DateTime jamMasuk;
  final DateTime jamKeluar;
  final Duration lama;
  final double tarif;
  final double totalBiaya;

  Pelanggan({
    required this.kodePelanggan,
    required this.namaPelanggan,
    required this.jenisPelanggan,
    required this.tglMasuk,
    required this.jamMasuk,
    required this.jamKeluar,
    required this.lama,
    required this.tarif,
    required this.totalBiaya,
  });
}

class PelangganFormPage extends StatefulWidget {
  @override
  _PelangganFormPageState createState() => _PelangganFormPageState();
}

class _PelangganFormPageState extends State<PelangganFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _namaController = TextEditingController();
  String? _jenisController;
  DateTime? _tglMasuk;
  DateTime? _jamMasuk;
  DateTime? _jamKeluar;

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      Duration lama = _jamKeluar!.difference(_jamMasuk!);
      double tarif = 10000.0;
      double diskon = 0.0;
      double totalBiaya;

      // Proses diskon
      if (_jenisController == 'VIP' && lama.inHours > 2) {
        diskon = 0.02 * (lama.inMinutes / 60) * tarif;
      } else if (_jenisController == 'GOLD' && lama.inHours > 2) {
        diskon = 0.05 * (lama.inMinutes / 60) * tarif;
      }

      totalBiaya = (lama.inMinutes / 60) * tarif - diskon;

      Pelanggan pelanggan = Pelanggan(
        kodePelanggan: _codeController.text,
        namaPelanggan: _namaController.text,
        jenisPelanggan: _jenisController ?? 'Reguler',
        tglMasuk: _tglMasuk!,
        jamMasuk: _jamMasuk!,
        jamKeluar: _jamKeluar!,
        lama: lama,
        tarif: tarif,
        totalBiaya: totalBiaya,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HasilPage(pelanggan: pelanggan),
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _tglMasuk = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isMasuk) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        final now = DateTime.now();
        final selectedTime =
            DateTime(now.year, now.month, now.day, picked.hour, picked.minute);

        if (isMasuk) {
          _jamMasuk = selectedTime;
        } else {
          _jamKeluar = selectedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Entri Pelanggan'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(labelText: 'Kode Pelanggan'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan Kode Pelanggan';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(labelText: 'Nama Pelanggan'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan Nama Pelanggan';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _jenisController,
                decoration: InputDecoration(labelText: 'Jenis Pelanggan'),
                items: ['Reguler', 'VIP', 'GOLD'].map((jenis) {
                  return DropdownMenuItem<String>(
                    value: jenis,
                    child: Text(jenis),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _jenisController = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Pilih Jenis Pelanggan';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text(
                    'Tanggal Masuk: ${_tglMasuk != null ? DateFormat.yMd().format(_tglMasuk!) : 'Pilih Tanggal'}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              ListTile(
                title: Text(
                    'Jam Masuk: ${_jamMasuk != null ? DateFormat.Hm().format(_jamMasuk!) : 'Pilih Jam'}'),
                trailing: Icon(Icons.access_time),
                onTap: () => _selectTime(context, true),
              ),
              ListTile(
                title: Text(
                    'Jam Keluar: ${_jamKeluar != null ? DateFormat.Hm().format(_jamKeluar!) : 'Pilih Jam'}'),
                trailing: Icon(Icons.access_time),
                onTap: () => _selectTime(context, false),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HasilPage extends StatelessWidget {
  final Pelanggan pelanggan;

  HasilPage({required this.pelanggan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tabel Pelanggan'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Table(
          border: TableBorder.all(),
          columnWidths: const <int, TableColumnWidth>{
            0: IntrinsicColumnWidth(),
            1: FlexColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Kode Pelanggan'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${pelanggan.kodePelanggan}'),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Nama Pelanggan'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${pelanggan.namaPelanggan}'),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Jenis Pelanggan'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${pelanggan.jenisPelanggan}'),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Tanggal Masuk'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${DateFormat.yMd().format(pelanggan.tglMasuk)}'),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Jam Masuk'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${DateFormat.Hm().format(pelanggan.jamMasuk)}'),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Jam Keluar'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${DateFormat.Hm().format(pelanggan.jamKeluar)}'),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Lama Bermain'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      '${pelanggan.lama.inHours} jam ${pelanggan.lama.inMinutes.remainder(60)} menit'),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Tarif'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Rp${pelanggan.tarif.toStringAsFixed(2)}'),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Total Biaya'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Rp${pelanggan.totalBiaya.toStringAsFixed(2)}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
