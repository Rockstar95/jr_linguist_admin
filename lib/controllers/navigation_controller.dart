import 'package:flutter/material.dart';
import 'package:jr_linguist_admin/screens/home_screen/main_page.dart';
import 'package:jr_linguist_admin/utils/my_print.dart';

import '../screens/questions/screens/add_question_screen.dart';
import '../screens/questions/screens/questions_list_screen.dart';

class NavigationController {
  static final GlobalKey<NavigatorState> mainNavigatorKey = GlobalKey<NavigatorState>();

  Route? onGeneratedRoutes(RouteSettings routeSettings) {
    MyPrint.printOnConsole("OnGeneratedRoutes Called for ${routeSettings.name} with arguments:${routeSettings.arguments}");

    Widget? widget;

    switch(routeSettings.name) {
      case "/" : {
        widget = const MainPage();
        break;
      }
      case MainPage.routeName : {
        widget = const MainPage();
        break;
      }
      case QuestionsListScreen.routeName : {
        widget = const QuestionsListScreen();
        break;
      }
      case AddQuestionScreen.routeName : {
        widget = const AddQuestionScreen();
        break;
      }
    }

    if(widget != null) {
      return MaterialPageRoute(builder: (_) => widget!);
    }
    else {
      return null;
    }
  }
}