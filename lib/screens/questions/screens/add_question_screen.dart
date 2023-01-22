import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jr_linguist_admin/configs/constants.dart';
import 'package:jr_linguist_admin/controllers/question_controller.dart';
import 'package:jr_linguist_admin/models/question_model.dart';
import 'package:jr_linguist_admin/providers/question_provider.dart';
import 'package:jr_linguist_admin/utils/my_print.dart';
import 'package:jr_linguist_admin/utils/snakbar.dart';
import 'package:provider/provider.dart';

import '../../../utils/myutils.dart';
import '../../../utils/styles.dart';
import '../../common/components/modal_progress_hud.dart';

class AddQuestionScreen extends StatefulWidget {
  static const String routeName = "/AddQuestionScreen";

  const AddQuestionScreen({Key? key}) : super(key: key);

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  late ThemeData themeData;
  bool isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController questionTextEditingController = TextEditingController();
  TextEditingController questionResourceController = TextEditingController();

  String questionType = QuestionType.audio;
  String languageType = LanguagesType.english;

  late QuestionProvider questionProvider;
  late QuestionController questionController;

  Uint8List? imageFile;
  
  List<String> answersList = <String>[];
  String selectedAnswer = "";

  Future<void> pickImage() async {
    XFile? xFile = await ImagePicker().pickImage(source: ImageSource.gallery,);

    Uint8List? data = await xFile?.readAsBytes();
    if(data != null) {
      imageFile = data;
      setState(() {});
    }
  }

  Future<void> addNewAnswer() async {
    dynamic value = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddNewAnswerDialog();
      },
    );

    if(value is String && value.isNotEmpty && !answersList.contains(value)) {
      answersList.add(value);
      setState(() {});
    }
  }

  Future<void> addQuestionInFirebase({required String question, required String questionType, required String languageType, String audioWord = "",
    Uint8List? imageData, required List<String> answers, required String selectedAnswer}) async {
    isLoading = true;
    setState(() {});

    String imageUrl = "";

    if(questionType == QuestionType.image && imageData != null) {
      imageUrl = await questionController.uploadQuestionImage(imageData);
    }
    MyPrint.printOnConsole("Final imageUrl:$imageUrl");

    Map<String, bool> answersMap = <String, bool>{};
    for (String element in answers) {
      answersMap[element] = selectedAnswer == element;
    }

    QuestionModel questionModel = QuestionModel(
      id: MyUtils.getUniqueId(),
      question: question,
      questionType: questionType,
      languageType: languageType,
      questionResourceUrl: questionType == QuestionType.image ? imageUrl : audioWord,
      answersMap: answersMap,
      createdTime: Timestamp.now(),
    );

    bool isAdded = await questionController.addQuestion(questionModel: questionModel);

    isLoading = false;
    setState(() {});

    if(isAdded) {
      Snakbar.showSuccessSnakbar(context: context, msg: "Question Added successfully");
      Navigator.pop(context);
    }
    else {
      Snakbar.showErrorSnakbar(context: context, msg: "Error in Adding Question");
    }
  }

  @override
  void initState() {
    super.initState();
    questionProvider = Provider.of<QuestionProvider>(context, listen: false);
    questionController = QuestionController(questionProvider: questionProvider);
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const SpinKitFadingCircle(color: Styles.primaryColor),
      child: Container(
        color: Styles.background,
        child: Scaffold(
          appBar: getAppBar(),
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Column(
                    children: [
                      getQuestionTextField(),
                      const SizedBox(height: 10,),
                      getQuestionTypeSelectionDropdown(),
                      const SizedBox(height: 20,),
                      getLanguageTypeSelectionDropdown(),
                      const SizedBox(height: 20,),
                      getQuestionResourceWidgetFromQuestionType(),
                      const SizedBox(height: 20,),
                      getAnswerSelectionWidget(),
                      const SizedBox(height: 20,),
                      getAddQuestionButton(),
                      const SizedBox(height: 20,),
                    ],
                  ),
                ),
              ),
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

  Widget getQuestionTextField() {
    return TextFormField(
      controller: questionTextEditingController,
      decoration: textFieldDecorationWidget(
        hint: "Question",
      ),
      validator: (String? text) {
        if(text?.isEmpty ?? true) {
          return "Question Cannot Be Empty";
        }

        return null;
      },
    );
  }

  Widget getQuestionTypeSelectionDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Select Question Type",
          style: themeData.textTheme.subtitle1,
        ),
        const SizedBox(width: 10,),
        Container(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: DropdownButton<String>(
            value: questionType,
            borderRadius: BorderRadius.circular(10),
            items: QuestionType.types.map((e) {
              return DropdownMenuItem<String>(
                value: e,
                child: Text(e),
              );
            }).toList(),
            onChanged: (String? newValue) {
              questionType = (newValue?.isEmpty ?? true) ? QuestionType.audio : newValue!;
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget getLanguageTypeSelectionDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Select Language Type",
          style: themeData.textTheme.subtitle1,
        ),
        const SizedBox(width: 10,),
        Container(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: DropdownButton<String>(
            value: languageType,
            borderRadius: BorderRadius.circular(10),
            items: LanguagesType.languages.map((e) {
              return DropdownMenuItem<String>(
                value: e,
                child: Text(e),
              );
            }).toList(),
            onChanged: (String? newValue) {
              languageType = (newValue?.isEmpty ?? true) ? LanguagesType.english : newValue!;
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget getQuestionResourceWidgetFromQuestionType() {
    if(questionType == QuestionType.audio) {
      return Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: questionResourceController,
              decoration: textFieldDecorationWidget(
                hint: "Enter Word",
              ),
              validator: (String? text) {
                if(text?.isEmpty ?? true) {
                  return "Word Cannot Be Empty";
                }

                return null;
              },
            ),
          ),
          const SizedBox(width: 5,),
          ElevatedButton(
            onPressed: () async {
              if(questionResourceController.text.isNotEmpty) {
                FlutterTts flutterTts = FlutterTts();
                await flutterTts.speak(questionResourceController.text);
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
    else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if(imageFile != null) Expanded(
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, right: 10),
                  child: Image.memory(imageFile!),
                ),
                InkWell(
                  onTap: () {
                    imageFile = null;
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18, color: Colors.red,),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5,),
          ElevatedButton(
            onPressed: () async {
              pickImage();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.image),
                SizedBox(width: 10,),
                Text("Select Image"),
              ],
            ),
          ),
        ],
      );
    }
  }
  
  Widget getAnswerSelectionWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black,),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          //region Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Add Answers",
                  style: themeData.textTheme.subtitle1?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  addNewAnswer();
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, size: 18, color: Colors.red,),
                ),
              ),
            ],
          ),
          //endregion
          const SizedBox(height: 10,),
          if(answersList.isEmpty) const Text("No Answers"),
          Column(
            children: answersList.map((e) {
              return InkWell(
                onTap: () {
                  selectedAnswer = e;
                  setState(() {});
                },
                child: Chip(
                  onDeleted: () {
                    answersList.remove(e);
                    selectedAnswer = answersList.isNotEmpty ? answersList.first : "";
                    setState(() {});
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  deleteIcon: const Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.white,
                  ),
                  backgroundColor: selectedAnswer != e ? Colors.red : Colors.green,
                  label: Text(
                    e,
                    style: themeData.textTheme.subtitle2?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget getAddQuestionButton() {
    return ElevatedButton(
      onPressed: () {
        bool isFormValidated = _formKey.currentState?.validate() ?? false;
        bool isQuestionTypeValidated = QuestionType.types.contains(questionType);
        bool isLanguageTypeValidated = LanguagesType.languages.contains(languageType);
        bool isQuestionResourceValidated = false;
        bool isAnswersValidated = answersList.length >= 2;
        bool isSelectedAnswersValidated = answersList.contains(selectedAnswer);

        if(questionType == QuestionType.image) {
          isQuestionResourceValidated = imageFile != null;
        }
        else if(questionType == QuestionType.audio) {
          isQuestionResourceValidated = questionResourceController.text.isNotEmpty;
        }

        if(isFormValidated && isQuestionTypeValidated && isLanguageTypeValidated && isQuestionResourceValidated && isAnswersValidated && isSelectedAnswersValidated) {
          addQuestionInFirebase(
            question: questionTextEditingController.text.trim(),
            questionType: questionType,
            languageType: languageType,
            audioWord: questionResourceController.text.trim(),
            imageData: imageFile,
            answers: answersList,
            selectedAnswer: selectedAnswer,
          );
        }
        else if(!isFormValidated) {

        }
        else if(!isQuestionTypeValidated) {
          Snakbar.showErrorSnakbar(context: context, msg: "Select A Valid Question Type");
        }
        else if(!isLanguageTypeValidated) {
          Snakbar.showErrorSnakbar(context: context, msg: "Select A Valid Language Type");
        }
        else if(!isQuestionResourceValidated) {
          Snakbar.showErrorSnakbar(context: context, msg: "Audio Word Cannot be Empty");
        }
        else if(!isAnswersValidated) {
          Snakbar.showErrorSnakbar(context: context, msg: "Atleast 2 Answers should be there");
        }
        else if(!isSelectedAnswersValidated) {
          Snakbar.showErrorSnakbar(context: context, msg: "Selected Answer not from Answers List");
        }
      },
      child: const Text("Add Question"),
    );
  }

  InputDecoration textFieldDecorationWidget({required String hint}) {
    return InputDecoration(
      hintText: hint,
      border: const OutlineInputBorder(),
    );
  }
}

class AddNewAnswerDialog extends StatefulWidget {
  const AddNewAnswerDialog({Key? key}) : super(key: key);

  @override
  State<AddNewAnswerDialog> createState() => _AddNewAnswerDialogState();
}

class _AddNewAnswerDialogState extends State<AddNewAnswerDialog> {
  late ThemeData themeData;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return Dialog(
      child: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add Answers",
                style: themeData.textTheme.subtitle1?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10,),
              TextFormField(
                controller: answerController,
                decoration: const InputDecoration(
                  hintText: "Answer",
                  border: OutlineInputBorder(borderSide: BorderSide()),
                ),
                validator: (String? value) {
                  if(value?.trim().isEmpty ?? true) {
                    return "Answer Cannot Be Empty";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 10,),
              ElevatedButton(
                onPressed: () {
                  if(_formKey.currentState?.validate() ?? false) {
                    Navigator.pop(context, answerController.text.trim());
                  }
                },
                child: const Text("Add Answer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

