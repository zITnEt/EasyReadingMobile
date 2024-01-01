import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:storyteller/classes/UserSecureStorage.dart';
import 'package:storyteller/requests/CreateDocumentRequest.dart';
import 'package:storyteller/requests/CreateUserRequest.dart';
import 'package:storyteller/requests/DeleteDocumentRequest.dart';
import 'package:storyteller/requests/GetResponseRequest.dart';
import 'package:storyteller/requests/LoginRequest.dart';
import 'package:supabase/supabase.dart';

import '../requests/CreatePagesRequest.dart';
import '../requests/GetLastProcessedPageRequest.dart';

class ApiService {
  final String _baseUrl = 'https://easyreading.azurewebsites.net:443';
  final http.Client _client;
  final SupabaseClient _supabase;

  String token = "";

  ApiService(this._client, this._supabase);

  Future<String> getLastProcessedPage(GetLastProcessedPageRequest request) async {
    var response =  await _supabase.from("Documents").select('LastProcessedPage').eq("Id", request.id).eq("UserId", int.parse((await UserSecureStorage.getUserId())!));
    return response[0]['LastProcessedPage'].toString();
  }

  Future<String> createDocument(CreateDocumentRequest request) async {
    var response = await _sendPostRequest('api/Document', {
      'Title': request.title,
      'PagesCount': request.pagesCount,
    });
    return response;
  }

  Future<String> createUser(CreateUserRequest request) async {
    token =  await _sendPostRequest('api/Auth/signup', {
      'Email': request.email,
      'Password': request.password,
      'Name': request.name,
    });
    return token;
  }

  Future<String> login(LoginRequest request) async {
    token = await _sendPostRequest('api/Auth/login', {
      'Email': request.email,
      'Password': request.password,
    });

    return token;
  }

  Future<String> getResponse(GetResponseRequest request) async {
    return await _sendPostRequest('api/Chat', {
      'DocumentId': request.documentId,
      'Question': request.question,
    });
  }

  Future<void> deleteDocument(DeleteDocumentRequest request) async {
    await _deleteRequest('api/Document', {
      'Id': request.id,
    });
  }

  Future<String> createPages(CreatePagesRequest request) async {
    var response = await _sendPostRequest('api/Page/CreatePages', {
      'documentId': request.documentId,
      'pages': request.pages.map((page) => page.toJson()).toList(),
    });
    return response;
  }


  Future<String> _sendPostRequest(String endpoint, Map<String, dynamic> data) async {
    var response = await _client.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to call $endpoint: ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  Future<String> _deleteRequest(String endpoint, Map<String, dynamic> data) async{
    var response = await _client.delete(Uri.parse('$_baseUrl/$endpoint'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(data)
    );

    if (response.statusCode == 200) {
      return response.body;
    } else{
      throw Exception('Failed to call $endpoint: ${response.statusCode} ${response.reasonPhrase}');
    }
  }
}

void startServer() async {
  final router = Router();
  http.Client client = http.Client();
  final supabase = SupabaseClient(
    'https://cecmasxdixqlkqqhyzoc.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNlY21hc3hkaXhxbGtxcWh5em9jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDMzMTIyOTksImV4cCI6MjAxODg4ODI5OX0.0eDWXDsU5CfFUNT-UFKrlR6SR-xW8k2h1_s4e2APGRI',
  );

  ApiService api = ApiService(client, supabase);
  api.token = (await UserSecureStorage.getToken()) ?? "";

  // Corresponding endpoint for createDocument
  router.post('/document', (Request req) async {
    final payload = await req.readAsString();
    final Map<String, dynamic> data = json.decode(payload);
    return Response.ok(await api.createDocument(CreateDocumentRequest.fromJson(data)));
  });

  // Corresponding endpoint for createUser
  router.post('/signup', (Request req) async {
    final payload = await req.readAsString();
    final Map<String, dynamic> data = json.decode(payload);
    return Response.ok(await api.createUser(CreateUserRequest.fromJson(data)));
  });

  // Corresponding endpoint for login
  router.post('/login', (Request req) async {
    final payload = await req.readAsString();
    final Map<String, dynamic> data = json.decode(payload);
    return Response.ok(await api.login(LoginRequest.fromJson(data)));
  });

  // Corresponding endpoint for getResponse
  router.post('/chat', (Request req) async {
    final payload = await req.readAsString();
    final Map<String, dynamic> data = json.decode(payload);
    return Response.ok(await api.getResponse(GetResponseRequest.fromJson(data)));
  });

  // Corresponding endpoint for deleteDocument
  router.delete('/document', (Request req) async {
    final payload = await req.readAsString();
    final Map<String, dynamic> data = json.decode(payload);
    await api.deleteDocument(DeleteDocumentRequest.fromJson(data));
    return Response.ok("Success");
  });

  // Corresponding endpoint for createPages
  router.post('/createPages', (Request req) async {
    final payload = await req.readAsString();
    final Map<String, dynamic> data = json.decode(payload);
    return Response.ok(await api.createPages(CreatePagesRequest.fromJson(data)));
  });
  
  router.post('/getLastProcessedPage', (Request req) async{
    final payload = await req.readAsString();
    final Map<String, dynamic> data = json.decode(payload);
    return Response.ok(await api.getLastProcessedPage(GetLastProcessedPageRequest.fromJson(data)));
  });

  var handler = const Pipeline().addMiddleware(logRequests()).addHandler(router);
  await io.serve(handler, InternetAddress.anyIPv4, 8080);
}