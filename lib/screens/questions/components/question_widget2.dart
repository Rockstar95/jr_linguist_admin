import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../configs/constants.dart';
import '../../../models/question_model.dart';
import '../../../utils/my_print.dart';
import '../../../utils/styles.dart';

class QuestionWidget2 extends StatelessWidget {
  final QuestionModel questionModel;
  final void Function({required QuestionModel questionModel}) onDeleteClick;

  const QuestionWidget2({
    Key? key,
    required this.questionModel,
    required this.onDeleteClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
        child: Column(
          children: [
            Text(
              questionModel.question,
              style: themeData.textTheme.headline6?.copyWith(

              ),
            ),
            const SizedBox(height: 10,),
            getQuestionResourceWidget(questionModel: questionModel, themeData: themeData),
            const SizedBox(height: 10,),
            getAnswersWidget(answers: questionModel.answers),
            const SizedBox(height: 10,),
            Text(
              "Language: ${questionModel.languageType}",
              style: themeData.textTheme.subtitle2?.copyWith(

              ),
            ),
            const SizedBox(height: 10,),
            deleteQuestionButtonWidget(questionModel: questionModel),
          ],
        ),
      ),
    );
  }

  Widget getQuestionResourceWidget({required QuestionModel questionModel, required ThemeData themeData}) {
    if(questionModel.questionType == QuestionType.image) {
      return CachedNetworkImage(
        imageUrl: questionModel.questionResourceUrl,
        placeholder: (_, __) => const SpinKitFadingCircle(color: Styles.primaryColor,),
      );
    }
    else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              "Word: ${questionModel.questionResourceUrl}",
              style: themeData.textTheme.subtitle2?.copyWith(

              ),
            ),
          const SizedBox(height: 10,),
          ElevatedButton(
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
          ),
        ],
      );
    }
  }

  Widget getAnswersWidget({required Map<String, bool> answers}) {
    MyPrint.printOnConsole("getAnswersWidget called with answers:$answers");
    return Wrap(
      children: answers.keys.map((e) {
        bool isTrue = answers[e] ?? false;

        return Container(
          color: isTrue ? Colors.green : Colors.red,
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(
            e,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget deleteQuestionButtonWidget({required QuestionModel questionModel}) {
    return ElevatedButton(
      onPressed: () {
        onDeleteClick(questionModel: questionModel);
      },
      child: const Text("Delete Question"),
    );
  }
}