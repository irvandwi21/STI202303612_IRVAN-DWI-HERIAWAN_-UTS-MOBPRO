import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../services/storage_service.dart';
import 'add_event_page.dart';
import 'detail_page.dart';
import 'media_tab.dart';

class EventHomePage extends StatefulWidget {
  @override
  _EventHomePageState createState() => _EventHomePageState();
}

class _EventHomePageState extends State<EventHomePage> {
  List<EventModel> _events = [];
  bool _loading = true;
  int _currentIndex = 0;

  // Warna tema hijau natural
  final Color primaryGreen = const Color(0xFF81C784); // hijau muda
  final Color accentGreen = const Color(0xFF388E3C); // hijau tua
  final Color softCream = const Color(0xFFFFF8E1); // krem lembut

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _loading = true);
    final events = await StorageService.readEvents();
    setState(() {
      _events = events..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      _loading = false;
    });
  }

  Future<void> _addOrUpdate(EventModel event) async {
    final idx = _events.indexWhere((e) => e.id == event.id);
    if (idx >= 0) {
      _events[idx] = event;
    } else {
      _events.add(event);
    }
    await StorageService.writeEvents(_events);
    await _loadEvents();
  }

  Future<void> _delete(String id) async {
    _events.removeWhere((e) => e.id == id);
    await StorageService.writeEvents(_events);
    await _loadEvents();
  }

  void _openAdd([EventModel? e]) async {
    final result = await Navigator.push<EventModel>(
      context,
      MaterialPageRoute(builder: (_) => AddEventPage(event: e)),
    );
    if (result != null) {
      await _addOrUpdate(result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event berhasil disimpan')),
      );
    }
  }

  void _openDetail(EventModel e) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailPage(event: e)),
    );
  }

  Widget _buildEventList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "🌿 Halo 👋",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Belum ada event yang tersimpan.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 4),
              Text(
                "Yuk, tambahkan acara pertamamu!",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _events.length,
      itemBuilder: (context, i) {
        final e = _events[i];
        return Card(
          elevation: 5,
          shadowColor: accentGreen.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: ListTile(
            onTap: () => _openDetail(e),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            title: Text(
              e.title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87),
            ),
            subtitle: Text(
              '${e.category} • ${DateFormat.yMMMd().add_jm().format(e.dateTime)}',
              style: const TextStyle(color: Colors.black54),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'edit') _openAdd(e);
                if (v == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Hapus Event'),
                      content: Text('Yakin ingin menghapus "${e.title}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) _delete(e.id);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Hapus')),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildEventList();
      case 1:
        return AddEventTabLauncher(onSave: _addOrUpdate);
      case 2:
        return MediaTab(events: _events);
      default:
        return _buildEventList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "My Event Planner",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [softCream, primaryGreen.withOpacity(0.25)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _buildBody(),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _openAdd(),
              label: const Text("Tambah Event"),
              icon: const Icon(Icons.add),
              backgroundColor: accentGreen,
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 10, offset: Offset(0, -3))
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: accentGreen,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_rounded),
              label: "Daftar",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline_rounded),
              label: "Tambah",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.perm_media_rounded),
              label: "Media",
            ),
          ],
        ),
      ),
    );
  }
}
