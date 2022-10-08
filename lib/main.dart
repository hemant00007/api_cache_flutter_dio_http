import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

const String SETTINGS_BOX = "settings";
const String API_BOX = "api_data";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(SETTINGS_BOX);
  await Hive.openBox(API_BOX);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    print(Hive.box(SETTINGS_BOX).get("welcome_shown"));
    return ValueListenableBuilder(
      valueListenable: Hive.box(SETTINGS_BOX).listenable(),
      builder: (context, box, child) =>
      box.get('welcome_shown', defaultValue: false)
          ? HomePage()
          : WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {



  @override

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Welcome Page"),
            ElevatedButton(
              onPressed: () async {
                var box = Hive.box(SETTINGS_BOX);
                box.put("welcome_shown", true);
              },
              child: Text("Get Started"),
            )
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home page'),
      ),
      body: FutureBuilder(
          future: ApiService().getDioPost(),
          builder: (context, snapshot) {
            if(!snapshot.hasData) return CircularProgressIndicator();
            final List posts = snapshot.data['data'];
            var seconddata = snapshot.data['support'];

            return Column(
              children: [
                SizedBox(height: 10,),
                Text("page is ${snapshot.data['page']}"),
                Text("Per page${snapshot.data['per_page']}"),
                Text("total ${snapshot.data['total']}"),
                Text("Total pages ${snapshot.data['total_pages']}"),
                Text("Text is ${seconddata['text']}"),
                SizedBox(height: 30,),
                Expanded(
                  child: ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context,index){
                        return Container(
                          width: double.infinity,
                            height: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),

                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0,right: 8),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(posts[index]['first_name']),
                                      Text(posts[index]['last_name']),
                                    ],
                                  ),
                                  Spacer(),
                                  Container(
                                    width: 60,
                                    height: 60,
                                    child: CachedNetworkImage(
                                      imageUrl: posts[index]['avatar'].toString(),height: 50,
                                      imageBuilder: (context, imageProvider) => Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),

                                      placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                    ),
                                  ),

                                ],
                              ),
                            ));
                      }),
                  // child: ListView(
                  //   padding: const EdgeInsets.all(16.0),
                  //   children: <Widget>[
                  //     Text("This is a home page"),
                  //     ...posts.map((p)=>ListTile(
                  //       title: Text(p['email']),
                  //       trailing:CachedNetworkImage(
                  //         imageUrl: p['avatar'],height: 50,
                  //         imageBuilder: (context, imageProvider) => Container(
                  //           decoration: BoxDecoration(
                  //             image: DecorationImage(
                  //               image: imageProvider,
                  //               fit: BoxFit.cover,
                  //             ),
                  //           ),
                  //         ),
                  //
                  //         placeholder: (context, url) =>
                  //         const CircularProgressIndicator(),
                  //         errorWidget: (context, url, error) => const Icon(Icons.error),
                  //       ),
                  //         // leading:Image.network(p['avatar'],height: 100)
                  //     )),
                  //     ElevatedButton(
                  //       onPressed: () {
                  //         Hive.box(SETTINGS_BOX).put('welcome_shown',false);
                  //       },
                  //       child: Text("Clear"),
                  //     )
                  //   ],
                  // ),
                ),
              ],
            );
          }
      ),
    );
  }
}


class ApiService {
  static var client = dio.Dio();
  // with http
  // Future getPosts() async {
  //   Uri url = Uri.parse('https://jsonplaceholder.typicode.com/posts');
  //   final posts = Hive.box(API_BOX).get('posts',defaultValue: []);
  //   if(posts.isNotEmpty) return posts;
  //   final http.Response res = await http.get(url);
  //   final resjson = jsonDecode(res.body);
  //   Hive.box(API_BOX).put("posts", resjson);
  //   return resjson;
  // }

  Future getDioPost() async {
    // String url = 'https://jsonplaceholder.typicode.com/posts';
    String url = 'https://reqres.in/api/users?page=2';
   final posts = Hive.box(API_BOX).get('posts',defaultValue: []);
    if(posts.isNotEmpty) return posts;
    try {
      dio.Response res = await client.get(url);
      if(res.statusCode==200){
        print("Success hemant");
        Hive.box(API_BOX).put("posts", res.data);
        return res.data;
      }
    }on TimeoutException catch(_){
      return null;
    }


  }
}
// up gari 0696 out krna hai