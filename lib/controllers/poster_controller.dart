import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:jr_linguist_admin/configs/constants.dart';
import 'package:jr_linguist_admin/configs/typedefs.dart';
import 'package:jr_linguist_admin/models/poster_model.dart';
import 'package:jr_linguist_admin/utils/my_print.dart';
import 'package:jr_linguist_admin/utils/myutils.dart';

import '../providers/poster_provider.dart';

class PosterController {
  late PosterProvider _posterProvider;

  PosterController({required PosterProvider? posterProvider}) {
    _posterProvider = posterProvider ?? PosterProvider();
  }

  PosterProvider get posterProvider => _posterProvider;

  Future<List<PosterModel>> getAlPosters({bool isNotify = true}) async {
    PosterProvider provider = posterProvider;

    MyPrint.printOnConsole("PosterController().getAlPosters() called with isNotify:$isNotify");

    List<PosterModel> posters = <PosterModel>[];

    provider.isLoadingPosters = true;
    if(isNotify) provider.notifyListeners();

    MyFirestoreQuerySnapshot querySnapshot = await FirebaseNodes.postersCollectionReference.orderBy("createdTime", descending: true).get();

    posters.addAll(querySnapshot.docs.map((e) {
      return PosterModel.fromMap(e.data());
    }));

    MyPrint.printOnConsole("Final Posters Length:${posters.length}");
    provider.posters = posters;
    provider.isLoadingPosters = false;
    provider.notifyListeners();

    return posters;
  }

  Future<bool> deletePoster({required String posterId}) async {
    MyPrint.printOnConsole("PosterController().deletePoster() called with questionId:$posterId");

    bool isDeleted = false;

    if(posterId.isEmpty) return isDeleted;

    isDeleted = await FirebaseNodes.postersDocumentReference(posterId: posterId).delete().then((value) {
      return true;
    })
    .catchError((e, s) {
      MyPrint.printOnConsole("Error in Deleting Poster in PosterController().deletePoster():$e");
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
      MyPrint.printOnConsole("Error in Uploading Poster Image in PosterController().uploadQuestionImage():$e");
      MyPrint.printOnConsole(s);
    }

    imageUrl = await storageRef.getDownloadURL();

    return imageUrl;
  }

  Future<bool> addPoster({required PosterModel posterModel}) async {
    MyPrint.printOnConsole("posterModel:$posterModel");

    bool isAdded = await FirebaseNodes.postersDocumentReference(posterId: posterModel.id).set(posterModel.toMap()).then((value) {
      return true;
    })
    .catchError((e, s) {
      MyPrint.printOnConsole("Error in Adding Poster in PosterController().addPoster():$e");
      MyPrint.printOnConsole(s);
    });

    MyPrint.printOnConsole("isAdded:$isAdded");

    return isAdded;
  }


  Future<void> addDummyPoster() async {
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

    PosterModel posterModel = PosterModel(
      id: MyUtils.getUniqueId(),
      posterUrl: "https://firebasestorage.googleapis.com/v0/b/jr-linguist-85a69.appspot.com/o/posters%2F1674389236169.png?alt=media&token=374ddd64-3bc4-46ff-a406-01c19d65618a",
      languageType: LanguagesType.hindi,
      createdTime: Timestamp.now(),
      priority: 0,
    );
    MyPrint.printOnConsole("posterModel:$posterModel");

    await FirebaseNodes.postersDocumentReference(posterId: posterModel.id).set(posterModel.toMap());
    MyPrint.printOnConsole("Dummy Poster Created");
  }
}