import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:jr_linguist_admin/controllers/question_controller.dart';
import 'package:jr_linguist_admin/models/question_model.dart';
import 'package:jr_linguist_admin/providers/question_provider.dart';
import 'package:jr_linguist_admin/screens/common/components/modal_progress_hud.dart';
import 'package:jr_linguist_admin/screens/questions/screens/add_question_screen.dart';
import 'package:jr_linguist_admin/utils/snakbar.dart';
import 'package:provider/provider.dart';

import '../../../utils/styles.dart';
import '../components/question_widget2.dart';

class QuestionsListScreen extends StatefulWidget {
  static const String routeName = "/QuestionsListScreen";

  const QuestionsListScreen({Key? key}) : super(key: key);

  @override
  State<QuestionsListScreen> createState() => _QuestionsListScreenState();
}

class _QuestionsListScreenState extends State<QuestionsListScreen> {
  bool isLoading = false;

  Future<void> deleteQuestion({required String questionId}) async {
    setState(() {
      isLoading = true;
    });

    bool isDeleted = await QuestionController().deleteQuestion(questionId: questionId);

    if(isDeleted) {
      QuestionController().getAllQuestions(isNotify: true);

      Snakbar.showSuccessSnakbar(context: context, msg: "Question Deleted Successfully");
    }
    else {
      Snakbar.showErrorSnakbar(context: context, msg: "Error in Deleting Question");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    QuestionController().getAllQuestions(isNotify: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuestionProvider>(
      builder: (BuildContext context, QuestionProvider questionProvider, Widget? child) {
        return ModalProgressHUD(
          inAsyncCall: isLoading,
          progressIndicator: const SpinKitFadingCircle(color: Styles.primaryColor),
          child: Container(
            color: Styles.background,
            child: Scaffold(
              appBar: getAppBar(),
              backgroundColor: Colors.transparent,
              floatingActionButton: getAddQuestionButton(),
              body: SafeArea(
                child: getQuestionsList(questionProvider: questionProvider),
              ),
            ),
          ),
        );
      },
    );
  }

  AppBar getAppBar() {
    return AppBar(
      title: const Text("Questions List"),
      actions: [
        IconButton(
          onPressed: () {
            QuestionController().getAllQuestions();
          },
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget getAddQuestionButton() {
    return FloatingActionButton(
      onPressed: () async {
        await Navigator.pushNamed(context, AddQuestionScreen.routeName);
        QuestionController().getAllQuestions(isNotify: true);
      },
      child: const Icon(Icons.add),
    );
  }

  Widget getQuestionsList({required QuestionProvider questionProvider}) {
    if(questionProvider.isLoadingQuestions) {
      return const Center(
        child: SpinKitFadingCircle(color: Styles.primaryColor),
      );
    }

    List<QuestionModel> questions = questionProvider.questions;

    if(questions.isEmpty) {
      return const Center(
        child: Text("No Questions"),
      );
    }

    return ListView.builder(
      itemCount: questions.length,
      itemBuilder: (BuildContext context, int index) {
        QuestionModel questionModel = questions[index];

        return QuestionWidget2(
          questionModel: questionModel,
          onDeleteClick: ({required QuestionModel questionModel}) async {
            deleteQuestion(questionId: questionModel.id);
          },
        );
      },
    );
  }
}
