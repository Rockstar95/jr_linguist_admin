import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jr_linguist_admin/configs/constants.dart';
import 'package:jr_linguist_admin/controllers/poster_controller.dart';
import 'package:jr_linguist_admin/models/poster_model.dart';
import 'package:jr_linguist_admin/providers/poster_provider.dart';
import 'package:jr_linguist_admin/utils/my_print.dart';
import 'package:jr_linguist_admin/utils/snakbar.dart';
import 'package:provider/provider.dart';

import '../../../utils/myutils.dart';
import '../../../utils/styles.dart';
import '../../common/components/modal_progress_hud.dart';

class AddPosterScreen extends StatefulWidget {
  static const String routeName = "/AddPosterScreen";

  const AddPosterScreen({Key? key}) : super(key: key);

  @override
  State<AddPosterScreen> createState() => _AddPosterScreenState();
}

class _AddPosterScreenState extends State<AddPosterScreen> {
  late ThemeData themeData;
  bool isLoading = false;

  late PosterProvider posterProvider;
  late PosterController posterController;

  String languageType = LanguagesType.hindi;

  Uint8List? imageFile;

  List<int> priorities = [];
  int selectedPriority = 0;

  Future<void> pickImage() async {
    XFile? xFile = await ImagePicker().pickImage(source: ImageSource.gallery,);

    Uint8List? data = await xFile?.readAsBytes();
    if(data != null) {
      imageFile = data;
      setState(() {});
    }
  }

  Future<void> addPosterInFirebase({required String languageType, Uint8List? imageData}) async {
    isLoading = true;
    setState(() {});

    String imageUrl = "";

    if(imageData != null) {
      imageUrl = await posterController.uploadPosterImage(imageData);
    }
    MyPrint.printOnConsole("Final poster imageUrl:$imageUrl");

    if(imageUrl.isEmpty) {
      isLoading = false;
      setState(() {});

      Snakbar.showErrorSnakbar(context: context, msg: "Error in Uploading Poster Image");

      return;
    }

    PosterModel posterModel = PosterModel(
      id: MyUtils.getUniqueId(),
      languageType: languageType,
      posterUrl: imageUrl,
      priority: selectedPriority,
      createdTime: Timestamp.now(),
    );

    bool isAdded = await posterController.addPoster(posterModel: posterModel);

    isLoading = false;
    setState(() {});

    if(isAdded) {
      Snakbar.showSuccessSnakbar(context: context, msg: "Poster Added successfully");
      Navigator.pop(context);
    }
    else {
      Snakbar.showErrorSnakbar(context: context, msg: "Error in Adding Poster");
    }
  }

  @override
  void initState() {
    super.initState();
    posterProvider = Provider.of<PosterProvider>(context, listen: false);
    posterController = PosterController(posterProvider: posterProvider);

    priorities = List.generate(5, (index) => index);
    if(!priorities.contains(selectedPriority) && priorities.isNotEmpty) {
      selectedPriority = priorities.first;
    }
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
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Column(
                  children: [
                    getQuestionResourceWidgetFromQuestionType(),
                    const SizedBox(height: 20,),
                    getLanguageTypeSelectionDropdown(),
                    const SizedBox(height: 20,),
                    getPriorityDropdown(),
                    const SizedBox(height: 20,),
                    getAddPosterButton(),
                    const SizedBox(height: 20,),
                  ],
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
      title: const Text("Add Poster"),
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
              languageType = (newValue?.isEmpty ?? true) ? LanguagesType.hindi : newValue!;
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget getPriorityDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Select Priority",
          style: themeData.textTheme.titleMedium,
        ),
        const SizedBox(width: 10,),
        Container(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: DropdownButton<int>(
            value: selectedPriority,
            borderRadius: BorderRadius.circular(10),
            items: priorities.map((e) {
              return DropdownMenuItem<int>(
                value: e,
                child: Text(e.toString()),
              );
            }).toList(),
            onChanged: (int? newValue) {
              selectedPriority = newValue ?? 0;
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget getQuestionResourceWidgetFromQuestionType() {
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

  Widget getAddPosterButton() {
    return ElevatedButton(
      onPressed: () {
        bool isLanguageTypeValidated = LanguagesType.languages.contains(languageType);
        bool isImageValidated = imageFile != null;

        if(isLanguageTypeValidated && isImageValidated) {
          addPosterInFirebase(
            languageType: languageType,
            imageData: imageFile,
          );
        }
        else if(!isLanguageTypeValidated) {
          Snakbar.showErrorSnakbar(context: context, msg: "Select A Valid Language Type");
        }
        else if(!isImageValidated) {
          Snakbar.showErrorSnakbar(context: context, msg: "Image Cannot be Null");
        }
      },
      child: const Text("Add Poster"),
    );
  }
}

