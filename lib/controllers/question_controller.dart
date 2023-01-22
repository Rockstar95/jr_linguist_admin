import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:jr_linguist_admin/configs/constants.dart';
import 'package:jr_linguist_admin/configs/typedefs.dart';
import 'package:jr_linguist_admin/models/question_model.dart';
import 'package:jr_linguist_admin/providers/question_provider.dart';
import 'package:jr_linguist_admin/utils/my_print.dart';
import 'package:jr_linguist_admin/utils/myutils.dart';

import '../utils/parsing_helper.dart';

class QuestionController {
  late QuestionProvider _questionProvider;

  QuestionController({required QuestionProvider? questionProvider}) {
    _questionProvider = questionProvider ?? QuestionProvider();
  }

  QuestionProvider get questionProvider => _questionProvider;

  Future<List<QuestionModel>> getAllQuestions({bool isNotify = true}) async {
    QuestionProvider provider = questionProvider;

    MyPrint.printOnConsole("QuestionController().getQuestionsFromLanguage() called with isNotify:$isNotify");

    List<QuestionModel> questions = <QuestionModel>[];

    provider.isLoadingQuestions = true;
    if(isNotify) provider.notifyListeners();

    MyFirestoreQuerySnapshot querySnapshot = await FirebaseNodes.questionsCollectionReference.orderBy("createdTime", descending: true).get();

    questions.addAll(querySnapshot.docs.map((e) {
      return QuestionModel.fromMap(e.data());
    }));

    MyPrint.printOnConsole("Final Questions Length:${questions.length}");
    provider.questions = questions;
    provider.isLoadingQuestions = false;
    provider.notifyListeners();

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

  //region Posters
  Future<Map<String, String>> getLanguagewisePostersData({bool isNotify = true}) async {
    MyPrint.printOnConsole("QuestionController().getLanguagewisePostersData() called");

    QuestionProvider provider = questionProvider;

    Map<String, String> data = <String, String>{};

    provider.isLoadingPosters = true;
    if(isNotify) provider.notifyListeners();

    try {
      MyFirestoreDocumentSnapshot snapshot = await FirebaseNodes.languagewisePostersDocumentReference().get();
      MyPrint.printOnConsole("snapshot data:${snapshot.data()}");

      if(snapshot.exists && (snapshot.data() ?? {}).isNotEmpty) {
        snapshot.data()!.forEach((String language, dynamic urlDynamic) {
          String url = ParsingHelper.parseStringMethod(urlDynamic);
          if(url.isNotEmpty) {
            data[language] = url;
          }
        });
      }
      MyPrint.printOnConsole("Final Posters Data:$data");
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in QuestionController().getLanguagewisePostersData():$e");
      MyPrint.printOnConsole(s);
    }

    provider.posters = data;

    provider.isLoadingPosters = false;
    provider.notifyListeners();

    return data;
  }

  Future<bool> updateLanguagewisePostersData({required Map<String, String> data}) async {
    MyPrint.printOnConsole("QuestionController().updateLanguagewisePostersData() called with data:$data");

    bool isUpdated = false;

    try {
      isUpdated = await FirebaseNodes.languagewisePostersDocumentReference().update(data).then((value) {
        return true;
      })
      .catchError((e, s) {
        MyPrint.printOnConsole("Error in QuestionController().updateLanguagewisePostersData():$e");
        MyPrint.printOnConsole(s);
        return false;
      });
      MyPrint.printOnConsole("isUpdated:$isUpdated");
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in QuestionController().updateLanguagewisePostersData():$e");
      MyPrint.printOnConsole(s);
    }

    return isUpdated;
  }

  Future<bool> deletePoster({required String language}) async {
    MyPrint.printOnConsole("QuestionController().deletePoster() called with language:$language");

    bool isDeleted = false;

    if(language.isEmpty) return isDeleted;

    isDeleted = await FirebaseNodes.languagewisePostersDocumentReference().update({language : FieldValue.delete()}).then((value) {
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

  Future<String> uploadPosterImage(Uint8List data) async {
    String imageUrl = "";

    String fileName = "${DateTime.now().millisecondsSinceEpoch}.png";

    final Reference storageRef = FirebaseStorage.instance.ref().child("posters").child(fileName);

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
  //endregion


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