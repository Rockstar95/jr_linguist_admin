import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:jr_linguist_admin/configs/constants.dart';
import 'package:jr_linguist_admin/configs/typedefs.dart';
import 'package:jr_linguist_admin/controllers/navigation_controller.dart';
import 'package:jr_linguist_admin/models/question_model.dart';
import 'package:jr_linguist_admin/providers/question_provider.dart';
import 'package:jr_linguist_admin/utils/my_print.dart';
import 'package:jr_linguist_admin/utils/myutils.dart';
import 'package:provider/provider.dart';

class QuestionController {
  Future<List<QuestionModel>> getAllQuestions({bool isNotify = true}) async {
    QuestionProvider questionProvider = Provider.of<QuestionProvider>(NavigationController.mainNavigatorKey.currentContext!, listen: false);

    MyPrint.printOnConsole("QuestionController().getQuestionsFromLanguage() called with isNotify:$isNotify");

    List<QuestionModel> questions = <QuestionModel>[];

    questionProvider.isLoadingQuestions = true;
    if(isNotify) questionProvider.notifyListeners();

    MyFirestoreQuerySnapshot querySnapshot = await FirebaseNodes.questionsCollectionReference.orderBy("createdTime", descending: true).get();

    questions.addAll(querySnapshot.docs.map((e) {
      return QuestionModel.fromMap(e.data());
    }));

    MyPrint.printOnConsole("Final Questions Length:${questions.length}");
    questionProvider.questions = questions;
    questionProvider.isLoadingQuestions = false;
    questionProvider.notifyListeners();

    return questions;
  }

  Future<bool> deleteQuestion({required String questionId}) async {
    MyPrint.printOnConsole("QuestionController().deleteQuestion() called with questionId:$questionId");

    bool isDeleted = false;

    if(questionId.isEmpty) return isDeleted;

    isDeleted = await FirebaseNodes.questionsDocumentReference(questionId: questionId).delete().then((value) {
      return true;
    })
    .catchError((e, s) {
      MyPrint.printOnConsole("Error in Deleting Question in QuestionController().deleteQuestion():$e");
      MyPrint.printOnConsole(s);
      return false;
    });

    MyPrint.printOnConsole("isDeleted:$isDeleted");

    return isDeleted;
  }

  Future<String> uploadQuestionImage(Uint8List data) async {
    String imageUrl = "";

    String fileName = "${DateTime.now().millisecondsSinceEpoch}.png";

    final Reference storageRef = FirebaseStorage.instance.ref().child("questions").child(fileName);

    try {
      await storageRef.putData(data);
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in Uploading Question Image in QuestionController().uploadQuestionImage():$e");
      MyPrint.printOnConsole(s);
    }

    imageUrl = await storageRef.getDownloadURL();

    return imageUrl;
  }

  Future<bool> addQuestion({required QuestionModel questionModel}) async {
    MyPrint.printOnConsole("questionModel:$questionModel");

    bool isAdded = await FirebaseNodes.questionsDocumentReference(questionId: questionModel.id).set(questionModel.toMap()).then((value) {
      return true;
    })
    .catchError((e, s) {
      MyPrint.printOnConsole("Error in Adding Question in QuestionController().addQuestion():$e");
      MyPrint.printOnConsole(s);
    });

    MyPrint.printOnConsole("isAdded:$isAdded");

    return isAdded;
  }


  Future<void> addDummyQuestion() async {
    /*QuestionModel questionModel = QuestionModel(
      id: MyUtils.getUniqueId(),
      question: "Recognize the Text",
      questionType: QuestionType.image,
      languageType: LanguagesType.english,
      questionResourceUrl: "https://img.freepik.com/premium-vector/speech-bubble-with-text-hi-hello-design-template-white-bubble-message-hi-yellow-background_578506-193.jpg?w=2000",
      answersMap: {
        "Hello" : true,
        "Hiii" : false,
        "My" : false,
        "Ram" : false,
      },
    );*/

    QuestionModel questionModel = QuestionModel(
      id: MyUtils.getUniqueId(),
      question: "Recognize the Text",
      questionType: QuestionType.audio,
      languageType: LanguagesType.hindi,
      questionResourceUrl: "क्षमा",
      answersMap: {
        "क्षमा" : true,
        "Hello" : false,
        "Hiii" : false,
        "Nice To Meet You" : false,
      },
    );
    MyPrint.printOnConsole("questionModel:$questionModel");

    await FirebaseNodes.questionsDocumentReference(questionId: questionModel.id).set(questionModel.toMap());
    MyPrint.printOnConsole("Dummy Question Created");
  }
}