import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthorInfoPage extends StatelessWidget {
  const AuthorInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Pi Ko", style: TextStyle(fontSize: 20)),
          SizedBox(height: 8),
          Text("Contact: pk2269@nyu.edu"),
          SizedBox(height: 8),
          InkWell(
            child: Text("Visit Website",
                style: TextStyle(
                    decoration: TextDecoration.underline, color: Colors.blue)),
            onTap: () => launch('https://paingthet.com/'),
          ),
        ],
      ),
    );
  }
}
