import 'package:flutter/material.dart';
import 'package:storyteller/screens/GPTScreen.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../Models/Book.dart';
import 'PdfScreen.dart';
import 'package:flutter/gestures.dart';

class EasyReadingScreen extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
  final PdfTextExtractor extractor;
  final Book book;
  final PdfDocument document;
  final int pages;

  const EasyReadingScreen({super.key, required this.extractor, required this.book, required this.document, required this.pages});
}

class _MyHomePageState extends State<EasyReadingScreen> {
  final PageController _pageController = PageController();
  int screen = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RawGestureDetector(
        gestures: <Type, GestureRecognizerFactory>{
          AllowMultipleGestureRecognizer: GestureRecognizerFactoryWithHandlers<AllowMultipleGestureRecognizer>(
                () => AllowMultipleGestureRecognizer(),
                (AllowMultipleGestureRecognizer instance) {},
          ),
        },
        behavior: HitTestBehavior.translucent,
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: [
            PdfScreen(book: widget.book, pages: widget.pages, extractor: widget.extractor, document: widget.document),
            GPTScreen(book: widget.book, extractor: widget.extractor),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (screen == 1){
            screen = 0;
          }
          else{
            screen = 1;
          }
          setState(() {

          });
          _pageController.animateToPage(
            screen,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        },
        child: screen == 1 ?
        const Icon(Icons.book_online_outlined):
        const Icon(Icons.chat),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class AllowMultipleGestureRecognizer extends PanGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}