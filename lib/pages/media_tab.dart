import 'dart:io';
import 'package:flutter/material.dart';
import '../models/event.dart';
import 'detail_page.dart';

class MediaTab extends StatelessWidget {
  final List<EventModel> events;
  const MediaTab({required this.events});

  @override
  Widget build(BuildContext context) {
    final mediaItems =
        events.where((e) => e.imagePath != null || e.videoUrl != null).toList();
    if (mediaItems.isEmpty) return Center(child: Text('Belum ada media'));

    return GridView.builder(
      padding: EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 1),
      itemCount: mediaItems.length,
      itemBuilder: (context, i) {
        final e = mediaItems[i];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EventDetailPage(event: e)),
          ),
          child: Card(
            clipBehavior: Clip.hardEdge,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (e.imagePath != null)
                  Image.file(File(e.imagePath!), fit: BoxFit.cover)
                else
                  Container(
                      color: Colors.black26,
                      child: Center(child: Icon(Icons.videocam))),
                if (e.videoUrl != null)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      color: Colors.black54,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow,
                              size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Video',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
