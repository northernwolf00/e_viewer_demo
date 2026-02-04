import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:example/chapter_drawer.dart';
import 'package:example/theme_settings_sheet.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Epub Viewer Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final epubController = EpubController();

  var textSelectionCfi = '';

  bool isLoading = true;

  double progress = 0.0;

  EpubTheme currentTheme = EpubTheme.sepia();
  int currentFontSize = 18;

  void _showThemeSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ThemeSettingsSheet(
        currentTheme: currentTheme,
        currentFontSize: currentFontSize,
        onThemeChanged: (theme) {
          setState(() {
            currentTheme = theme;
          });
          // Theme will be applied on next page load
        },
        onFontSizeChanged: (size) {
          setState(() {
            currentFontSize = size;
          });
          // Font size will be applied on next page load
        },
      ),
    );
  }

  void _showMenu() {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(1000, 80, 0, 0),
      items: [
        const PopupMenuItem(
          value: 'description',
          child: Row(
            children: [
              Icon(Icons.description_outlined),
              SizedBox(width: 12),
              Text('Kitap beýany'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'bookmark',
          child: Row(
            children: [
              Icon(Icons.bookmark_outline),
              SizedBox(width: 12),
              Text('Tekja goş'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'library',
          child: Row(
            children: [
              Icon(Icons.add_circle_outline),
              SizedBox(width: 12),
              Text('Kitaplaryma goş'),
            ],
          ),
        ),
      ],
    ).then((value) {
      // Handle menu selection
      if (value != null) {
        // TODO: Implement menu actions
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '1. Недостижимый идеал',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: _showMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                EpubViewer(
                  initialCfi: 'epubcfi(/6/20!/4/2[introduction]/2[c1_h]/1:0)',
                  epubSource: EpubSource.fromAsset('assets/4.epub'),
                  epubController: epubController,
                  displaySettings: EpubDisplaySettings(
                      flow: EpubFlow.paginated,
                      useSnapAnimationAndroid: false,
                      snap: true,
                      theme: currentTheme,
                      fontSize: currentFontSize,
                      allowScriptedContent: true),
                  selectionContextMenu: ContextMenu(
                    menuItems: [
                      ContextMenuItem(
                        title: "Highlight",
                        id: 1,
                        action: () async {
                          epubController.addHighlight(cfi: textSelectionCfi);
                        },
                      ),
                    ],
                    settings: ContextMenuSettings(
                        hideDefaultSystemContextMenuItems: true),
                  ),
                  onChaptersLoaded: (chapters) {
                    setState(() {
                      isLoading = false;
                    });
                  },
                  onEpubLoaded: () async {
                    print('Epub loaded');
                  },
                  onRelocated: (value) {
                    print("Reloacted to $value");
                    setState(() {
                      progress = value.progress;
                    });
                  },
                  onAnnotationClicked: (cfi, data) {
                    print("Annotation clicked $cfi");
                  },
                  onTextSelected: (epubTextSelection) {
                    textSelectionCfi = epubTextSelection.selectionCfi;
                    print(textSelectionCfi);
                  },
                  onLocationLoaded: () {
                    /// progress will be available after this callback
                    print('on location loaded');
                  },
                  onSelection:
                      (selectedText, cfiRange, selectionRect, viewRect) {
                    print("On selection changes");
                  },
                  onDeselection: () {
                    print("on delection");
                  },
                  onSelectionChanging: () {
                    print("on slection chnages");
                  },
                  onTouchDown: (x, y) {
                    print("Touch down at $x , $y");
                  },
                  onTouchUp: (x, y) {
                    print("Touch up at $x , $y");
                  },
                  selectAnnotationRange: true,
                ),
                Visibility(
                  visible: isLoading,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              ],
            ),
          ),
          // Bottom navigation bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Chapters button
                IconButton(
                  icon: const Icon(Icons.menu, size: 28),
                  onPressed: () => ChapterDrawer.show(context, epubController),
                ),
                // Page indicator
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(progress * 213).round()} / 213',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Theme settings button
                IconButton(
                  icon: const Icon(Icons.text_fields, size: 28),
                  onPressed: _showThemeSettings,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
