import 'package:flutter/material.dart';
import 'package:jr_linguist_admin/models/poster_model.dart';

class PosterProvider extends ChangeNotifier {
  bool isLoadingPosters = false;
  List<PosterModel> posters = <PosterModel>[];
}