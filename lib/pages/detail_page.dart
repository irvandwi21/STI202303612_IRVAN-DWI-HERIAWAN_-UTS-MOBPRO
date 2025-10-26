import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import '../models/event.dart';

class EventDetailPage extends StatefulWidget {
  final EventModel event;
  const EventDetailPage({required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.event.videoUrl != null) {
      _controller = VideoPlayerController.file(File(widget.event.videoUrl!))
        ..initialize().then((_) {
          setState(() => _initialized = true);
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _videoSection() {
    if (widget.event.videoUrl == null) return Text('Tidak ada video');
    if (!_initialized) return CircularProgressIndicator();
    return Column(
      children: [
        AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(_controller!.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow),
              onPressed: () {
                setState(() {
                  _controller!.value.isPlaying
                      ? _controller!.pause()
                      : _controller!.play();
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.stop),
              onPressed: () {
                setState(() {
                  _controller!.pause();
                  _controller!.seekTo(Duration.zero);
                });
              },
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    return Scaffold(
      appBar: AppBar(title: Text(e.title)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (e.imagePath != null)
              Image.file(File(e.imagePath!), height: 220, fit: BoxFit.cover)
            else
              Container(
                height: 220,
                color: Colors.grey[300],
                child: Center(child: Icon(Icons.event, size: 64)),
              ),
            SizedBox(height: 12),
            Text(e.title,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('${e.category} • ${DateFormat.yMMMd().add_jm().format(e.dateTime)}'),
            SizedBox(height: 12),
            Text(e.description),
            SizedBox(height: 20),
            Text('Video Promo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _videoSection(),
          ],
        ),
      ),
    );
  }
}
