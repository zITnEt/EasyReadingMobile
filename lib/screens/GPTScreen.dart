import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:storyteller/requests/CreatePagesRequest.dart';
import 'package:storyteller/requests/GetLastProcessedPageRequest.dart';
import 'package:storyteller/requests/GetResponseRequest.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../Models/Book.dart';

class GPTScreen extends StatefulWidget {
  final Book book;
  final PdfTextExtractor extractor;
  @override
  _GPTScreenState createState() => _GPTScreenState();

  const GPTScreen({super.key, required this.book, required this.extractor});
}

class _GPTScreenState extends State<GPTScreen> {
  final TextEditingController messageController = TextEditingController();
  bool isProcessing = false;
  bool isReady = false;
  bool isAnswering = false;
  bool isError = false;
  String text = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(labelText: 'Message'),
                  ),
                ),
                IconButton(
                  iconSize: 30,
                  onPressed: () async {
                    isError = false;
                    isAnswering = false;
                    isProcessing = false;
                    isReady = false;
                    text = "";
                    final message = "${messageController.text}\nPlease elaborate as much as possible";
                    const url1 = 'http://localhost:8080/createPages';
                    const url2 = 'http://localhost:8080/chat';
                    const url3 = 'http://localhost:8080/getLastProcessedPage';
                    http.Response response;
                    GetLastProcessedPageRequest request3 = GetLastProcessedPageRequest(id: widget.book.postgId);
                    try{
                      response = await http.post(
                        Uri.parse(url3),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode(request3.toJson()),
                      );
                    }
                    on Exception{
                      isError = true;
                      text = "Please check your Internet connection";
                      setState(() {

                      });
                      return;
                    }

                    text = "Processing pages";
                    isProcessing = true;
                    setState(() {

                    });

                    try{
                      int lastPage = int.parse(response.body);
                      List<GetPageDTO> pages = preparePageDTOs(lastPage);
                      if (pages.isNotEmpty){
                        CreatePagesRequest request1 = CreatePagesRequest(documentId: widget.book.postgId, pages: pages);
                        await http.post(
                          Uri.parse(url1),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode(request1.toJson()),
                        );
                      }
                    }
                    on Exception{
                      isError = true;
                      text = "Please check your Internet connection";
                      isProcessing = false;
                      setState(() {
                      });
                      return;
                    }

                    isProcessing = false;
                    isAnswering = true;
                    text = "Generating a response";

                    setState(() {

                    });

                    try{
                      GetResponseRequest request2 = GetResponseRequest(documentId: widget.book.postgId, question: message);
                      http.Response chatResponse = await http.post(
                        Uri.parse(url2),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode(request2.toJson()),
                      );

                      isAnswering = false;
                      isReady = true;
                      text = chatResponse.body;
                      setState(() {

                      });
                    }
                    on Exception{
                      text = "Please check your Internet connection";
                      isError = true;
                      isAnswering = false;
                      setState(() {

                      });
                      return;
                    }
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            if (isProcessing || isAnswering)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(text),
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                    ],
                  ),
                ),
              )
            else if (isError)
              Text(text,
              style: const TextStyle(color: Colors.red, fontSize: 25))
            else if (isReady)
              Expanded(
                  child: SingleChildScrollView(
                    child: Text(text, style: const TextStyle(fontSize: 20)),
                  )
              )
            else
              const Text("Your initial query may require the most time, potentially up to a minute for a server response",
              style: TextStyle(fontSize: 20),)
          ],
        ),
      ),
    );
  }

  List<GetPageDTO> preparePageDTOs(int lastPage){
    if (widget.book.currentPage <= lastPage){
      return List<GetPageDTO>.empty();
    }
    List<GetPageDTO> dtos = List.filled(widget.book.currentPage-lastPage+1, GetPageDTO(body: '', page: 0));

    for (int i = widget.book.currentPage; i >= lastPage; i--){
      dtos[i-lastPage] = GetPageDTO(body: '', page: 0);
      dtos[i-lastPage].body = widget.extractor.extractText(startPageIndex: i, endPageIndex: i);;
      dtos[i-lastPage].page = i + 1;
    }

    return dtos;
  }

}