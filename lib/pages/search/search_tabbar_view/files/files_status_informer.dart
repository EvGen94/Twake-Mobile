import 'package:flutter/material.dart';
import 'package:twake/blocs/search_cubit/search_state.dart';
import 'package:twake/widgets/common/no_search_results_widget.dart';

class FileStatusInformer extends StatelessWidget {
  final FilesStateStatus status;
  final String searchTerm;
  final Function onResetTap;

  const FileStatusInformer(
      {Key? key,
      required this.status,
      required this.searchTerm,
      required this.onResetTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (status == FilesStateStatus.init) {
      return Column(
        children: [
          SizedBox(height: 40),
          Text(
            '🔎',
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(fontSize: 64.0, fontWeight: FontWeight.w600),
          ),
          Text(
            'Find files by entering keywords in the search',
            style:
                Theme.of(context).textTheme.headline3!.copyWith(fontSize: 14.0),
          ),
        ],
      );
    }

    if (status == FilesStateStatus.loading) {
      return Center(
        child: Container(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(),
        ),
      );
    }

    return NoSearchResultsWidget(
        searchTerm: searchTerm, onResetTap: onResetTap);
  }
}
