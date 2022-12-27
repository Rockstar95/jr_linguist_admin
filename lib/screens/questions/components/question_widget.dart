import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../configs/constants.dart';
import '../../../models/question_model.dart';
import '../../../utils/my_print.dart';
import '../../../utils/snakbar.dart';

class QuestionWidget extends StatefulWidget {
  final QuestionModel questionModel;
  final void Function()? onRightAnswer, onGivedAnswer;

  const QuestionWidget({Key? key, required this.questionModel, this.onRightAnswer, this.onGivedAnswer}) : super(key: key);

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  late ThemeData themeData;

  List<String> answers = <String>[];

  String? answerValue;

  @override
  void initState() {
    super.initState();
    answers = (widget.questionModel.answers.keys.toList())..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
        child: Column(
          children: [
            Text(
              widget.questionModel.question,
              style: themeData.textTheme.headline6?.copyWith(

              ),
            ),
            const SizedBox(height: 10,),
            getQuestionResourceWidget(questionModel: widget.questionModel),
            const SizedBox(height: 10,),
            getAnswersWidget(answers: answers),
            const SizedBox(height: 10,),
            submitAnswerButtonWidget(),
          ],
        ),
      ),
    );
  }

  Widget getQuestionResourceWidget({required QuestionModel questionModel}) {
    if(questionModel.questionType == QuestionType.image) {
      return CachedNetworkImage(imageUrl: questionModel.questionResourceUrl);
    }
    else {
      return ElevatedButton(
        onPressed: () async {
          if(questionModel.questionResourceUrl.isNotEmpty) {
            FlutterTts flutterTts = FlutterTts();
            await flutterTts.speak(questionModel.questionResourceUrl);
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.volume_up),
            SizedBox(),
            Text("Play Audio"),
          ],
        ),
      );
    }
  }

  Widget getAnswersWidget({required List<String> answers}) {
    MyPrint.printOnConsole("getAnswersWidget called with answers:$answers");
    return Column(
      children: answers.map((e) {
        return RadioListTile<String>(
          value: e,
          groupValue: answerValue,
          onChanged: (String? value) {
            answerValue = value;
            setState(() {});
          },
          title: Text(e),
        );
      }).toList(),
    );
  }

  Widget submitAnswerButtonWidget() {
    return ElevatedButton(
      onPressed: answerValue != null ? () {
        if(widget.questionModel.answers[answerValue] == true) {
          Snakbar.showSuccessSnakbar(context: context, msg: "Right Answer");

          if(widget.onRightAnswer != null) {
            widget.onRightAnswer!();
          }
        }
        else {
          Snakbar.showErrorSnakbar(context: context, msg: "Wrong Answer");
        }
        if(widget.onGivedAnswer != null) {
          widget.onGivedAnswer!();
        }
        // QuestionController().answerQuestion(context: context, questionModel: widget.questionModel, answer: answerValue!);
      } : null,
      child: const Text("Submit"),
    );
  }
}