import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../utils/styles.dart';
import '../../common/components/modal_progress_hud.dart';

class AddQuestionScreen extends StatefulWidget {
  static const String routeName = "/AddQuestionScreen";

  const AddQuestionScreen({Key? key}) : super(key: key);

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const SpinKitFadingCircle(color: Styles.primaryColor),
      child: Container(
        color: Styles.background,
        child: Scaffold(
          appBar: getAppBar(),
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                Text("Add Question")
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar getAppBar() {
    return AppBar(
      title: const Text("Add Question"),
    );
  }
}
