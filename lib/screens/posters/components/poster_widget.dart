import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../utils/styles.dart';

class PosterWidget extends StatelessWidget {
  final String language, url;
  final void Function({required String language}) onDeleteClick;

  const PosterWidget({
    Key? key,
    required this.language,
    required this.url,
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
            getPosterImageWidget(url: url, ),
            const SizedBox(height: 10,),
            Text(
              "Language: $language",
              style: themeData.textTheme.subtitle2?.copyWith(

              ),
            ),
            const SizedBox(height: 10,),
            deletePosterButtonWidget(language: language),
          ],
        ),
      ),
    );
  }

  Widget getPosterImageWidget({required String url}) {
    return CachedNetworkImage(
      imageUrl: url,
      placeholder: (_, __) => const SpinKitFadingCircle(color: Styles.primaryColor,),
    );
  }

  Widget deletePosterButtonWidget({required String language}) {
    return ElevatedButton(
      onPressed: () {
        onDeleteClick(language: language);
      },
      child: const Text("Delete Poster"),
    );
  }
}