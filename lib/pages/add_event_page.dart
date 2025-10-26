import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';

class AddEventPage extends StatefulWidget {
  final EventModel? event;
  const AddEventPage({this.event});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = Uuid();
  final _picker = ImagePicker();

  late TextEditingController _titleCtl;
  late TextEditingController _descCtl;
  String _category = 'Seminar';
  DateTime _selectedDateTime = DateTime.now();
  String? _imagePath;
  String? _videoUrl;

  final List<String> _kategoriOptions = [
    'Seminar',
    'Workshop',
    'Ulang Tahun',
    'Kegiatan Kampus',
    'Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _titleCtl = TextEditingController(text: e?.title ?? '');
    _descCtl = TextEditingController(text: e?.description ?? '');
    _category = e?.category ?? _category;
    _selectedDateTime = e?.dateTime ?? DateTime.now();
    _imagePath = e?.imagePath;
    _videoUrl = e?.videoUrl;
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _descCtl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool fromCamera) async {
    final XFile? file = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 80,
    );
    if (file != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final newPath = '${appDir.path}/${_uuid.v4()}.jpg';
      await File(file.path).copy(newPath);
      setState(() => _imagePath = newPath);
    }
  }

  Future<void> _pickVideo() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final newPath = '${appDir.path}/${_uuid.v4()}.mp4';
      await File(file.path).copy(newPath);
      setState(() => _videoUrl = newPath);
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null) return;
    setState(() {
      _selectedDateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final id = widget.event?.id ?? _uuid.v4();
    final event = EventModel(
      id: id,
      title: _titleCtl.text.trim(),
      description: _descCtl.text.trim(),
      category: _category,
      dateTime: _selectedDateTime,
      imagePath: _imagePath,
      videoUrl: _videoUrl,
    );
    Navigator.pop(context, event);
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat.yMMMd().add_jm().format(_selectedDateTime);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Tambah Event' : 'Edit Event'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _titleCtl,
                  decoration: InputDecoration(
                    labelText: 'Judul Event',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Judul wajib diisi' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _descCtl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _category,
                  items: _kategoriOptions
                      .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v ?? _category),
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Waktu: $dateStr'),
                  trailing: ElevatedButton.icon(
                    onPressed: _pickDateTime,
                    icon: Icon(Icons.calendar_today),
                    label: Text('Pilih Waktu'),
                  ),
                ),
                SizedBox(height: 12),
                Text('Foto / Poster',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(true),
                      icon: Icon(Icons.camera_alt),
                      label: Text('Camera'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(false),
                      icon: Icon(Icons.photo),
                      label: Text('Gallery'),
                    ),
                    if (_imagePath != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ElevatedButton.icon(
                          onPressed: () => setState(() => _imagePath = null),
                          icon: Icon(Icons.delete),
                          label: Text('Hapus'),
                        ),
                      ),
                  ],
                ),
                if (_imagePath != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.file(File(_imagePath!),
                        height: 180, fit: BoxFit.cover),
                  ),
                SizedBox(height: 12),
                Text('Video Promo (opsional)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickVideo,
                      icon: Icon(Icons.video_library),
                      label: Text('Ambil Video'),
                    ),
                    if (_videoUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ElevatedButton.icon(
                          onPressed: () => setState(() => _videoUrl = null),
                          icon: Icon(Icons.delete),
                          label: Text('Hapus'),
                        ),
                      ),
                  ],
                ),
                if (_videoUrl != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Video tersimpan (lihat di halaman detail/media)'),
                  ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _save,
                  icon: Icon(Icons.save),
                  label: Text('Simpan Event'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddEventTabLauncher extends StatelessWidget {
  final ValueChanged<EventModel> onSave;
  const AddEventTabLauncher({required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: Icon(Icons.add),
        label: Text('Buat Event Baru'),
        onPressed: () async {
          final result = await Navigator.push<EventModel>(
            context,
            MaterialPageRoute(builder: (_) => AddEventPage()),
          );
          if (result != null) onSave(result);
        },
      ),
    );
  }
}
