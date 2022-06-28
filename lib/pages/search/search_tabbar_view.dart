import 'package:flutter/material.dart';
import 'package:twake/pages/search/search_tabbar_view/search_chats_view.dart';

class SearchTabBarView extends StatelessWidget {
  const SearchTabBarView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        Text('in development'),
        SearchChatsView(),
        Text('in development'),
        Text('in development'),
        // SearchContactsView(),
      ],
    );
  }
}
