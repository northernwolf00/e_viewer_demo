import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:flutter/material.dart';

class ChapterDrawer {
  static void show(BuildContext context, EpubController controller) {
    final chapters = controller.getChapters();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header with book info
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Book cover placeholder
                    Container(
                      width: 60,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.book, size: 40),
                    ),
                    const SizedBox(width: 16),
                    // Book title
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Konstruirovanie yazykov:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Ot esperanto do dotrakiiskogo',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Sahypa 11 dan 213',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Chapters list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    final level = _getChapterLevel(chapter);

                    return ListTile(
                      contentPadding: EdgeInsets.only(
                        left: 20 + (level * 20.0),
                        right: 20,
                      ),
                      leading:
                          level > 0 ? const Icon(Icons.circle, size: 6) : null,
                      title: Text(
                        chapter.title,
                        style: TextStyle(
                          fontSize: level > 0 ? 14 : 16,
                          fontWeight:
                              level > 0 ? FontWeight.normal : FontWeight.w500,
                        ),
                      ),
                      trailing: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        controller.display(cfi: chapter.href);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static int _getChapterLevel(EpubChapter chapter) {
    // Simple heuristic: count dots or check if it's a subchapter
    if (chapter.title.startsWith('•') || chapter.title.contains('  ')) {
      return 1;
    }
    return 0;
  }
}
