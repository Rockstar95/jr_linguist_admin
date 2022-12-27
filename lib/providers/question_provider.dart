import 'package:flutter/material.dart';
import 'package:jr_linguist_admin/configs/constants.dart';
import 'package:jr_linguist_admin/models/question_model.dart';

class QuestionProvider extends ChangeNotifier {
  bool isLoadingQuestions = false;
  List<QuestionModel> questions = <QuestionModel>[];
}