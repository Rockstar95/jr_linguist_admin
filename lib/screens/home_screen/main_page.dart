import 'package:flutter/material.dart';
import 'package:jr_linguist_admin/screens/questions/screens/questions_list_screen.dart';
import 'package:jr_linguist_admin/utils/my_print.dart';
import 'package:jr_linguist_admin/utils/styles.dart';

class MainPage extends StatefulWidget {
  static const String routeName = "/MainPage";
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  @override
  initState() {
    super.initState();
    MyPrint.printOnConsole("Main Page INIT Called");
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Styles.background,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Home Screen"),
        ),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, QuestionsListScreen.routeName);
                    },
                    child: const Text("Questions List Page"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
