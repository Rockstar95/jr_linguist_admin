import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:jr_linguist_admin/screens/posters/screens/add_poster_screen.dart';
import 'package:provider/provider.dart';

import '../../../controllers/question_controller.dart';
import '../../../providers/question_provider.dart';
import '../../../utils/snakbar.dart';
import '../../../utils/styles.dart';
import '../../common/components/modal_progress_hud.dart';
import '../components/poster_widget.dart';

class PosterListScreen extends StatefulWidget {
  static const String routeName = "/PosterListScreen";

  const PosterListScreen({Key? key}) : super(key: key);

  @override
  State<PosterListScreen> createState() => _PosterListScreenState();
}

class _PosterListScreenState extends State<PosterListScreen> {
  bool isLoading = false;

  late QuestionProvider questionProvider;
  late QuestionController questionController;

  Future<void> deletePoster({required String language}) async {
    setState(() {
      isLoading = true;
    });

    bool isDeleted = await questionController.deletePoster(language: language);

    if(isDeleted) {
      questionController.getLanguagewisePostersData(isNotify: true);

      Snakbar.showSuccessSnakbar(context: context, msg: "Poster Deleted Successfully");
    }
    else {
      Snakbar.showErrorSnakbar(context: context, msg: "Error in Deleting Poster");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    questionProvider = Provider.of<QuestionProvider>(context, listen: false);
    questionController = QuestionController(questionProvider: questionProvider);

    questionController.getLanguagewisePostersData(isNotify: false);
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
              floatingActionButton: getAddPosterButton(),
              body: SafeArea(
                child: getPostersList(questionProvider: questionProvider),
              ),
            ),
          ),
        );
      },
    );
  }

  AppBar getAppBar() {
    return AppBar(
      title: const Text("Posters List"),
      actions: [
        IconButton(
          onPressed: () {
            questionController.getLanguagewisePostersData(isNotify: true);
          },
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget getAddPosterButton() {
    return FloatingActionButton(
      onPressed: () async {
        await Navigator.pushNamed(context, AddPosterScreen.routeName);
        questionController.getLanguagewisePostersData(isNotify: true);
      },
      child: const Icon(Icons.add),
    );
  }

  Widget getPostersList({required QuestionProvider questionProvider}) {
    if(questionProvider.isLoadingPosters) {
      return const Center(
        child: SpinKitFadingCircle(color: Styles.primaryColor),
      );
    }

    Map<String, String> posters = questionProvider.posters;

    List<String> languagesList = posters.keys.toList();

    if(posters.isEmpty) {
      return const Center(
        child: Text("No Posters"),
      );
    }

    return ListView.builder(
      itemCount: languagesList.length,
      itemBuilder: (BuildContext context, int index) {
        String language = languagesList[index];
        String url = posters[language]!;

        return PosterWidget(
          language: language,
          url: url,
          onDeleteClick: ({required String language}) async {
            deletePoster(language: language);
          },
        );
      },
    );
  }
}
