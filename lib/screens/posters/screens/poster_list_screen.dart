import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:jr_linguist_admin/controllers/poster_controller.dart';
import 'package:jr_linguist_admin/models/poster_model.dart';
import 'package:jr_linguist_admin/providers/poster_provider.dart';
import 'package:jr_linguist_admin/screens/posters/screens/add_poster_screen.dart';
import 'package:provider/provider.dart';

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

  late PosterProvider posterProvider;
  late PosterController posterController;

  Future<void> deletePoster({required PosterModel model}) async {
    setState(() {
      isLoading = true;
    });

    bool isDeleted = await posterController.deletePoster(posterId: model.id);

    if(isDeleted) {
      posterController.getAlPosters(isNotify: true);

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
    posterProvider = Provider.of<PosterProvider>(context, listen: false);
    posterController = PosterController(posterProvider: posterProvider);

    posterController.getAlPosters(isNotify: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PosterProvider>(
      builder: (BuildContext context, PosterProvider posterProvider, Widget? child) {
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
                child: getPostersList(posterProvider: posterProvider),
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
            posterController.getAlPosters(isNotify: true);
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
        posterController.getAlPosters(isNotify: true);
      },
      child: const Icon(Icons.add),
    );
  }

  Widget getPostersList({required PosterProvider posterProvider}) {
    if(posterProvider.isLoadingPosters) {
      return const Center(
        child: SpinKitFadingCircle(color: Styles.primaryColor),
      );
    }

    List<PosterModel> posters = posterProvider.posters;

    if(posters.isEmpty) {
      return const Center(
        child: Text("No Posters"),
      );
    }

    return ListView.builder(
      itemCount: posters.length,
      itemBuilder: (BuildContext context, int index) {
        PosterModel model = posters[index];

        return PosterWidget(
          language: model.languageType,
          url: model.posterUrl,
          onDeleteClick: ({required String language}) async {
            deletePoster(model: model);
          },
        );
      },
    );
  }
}
