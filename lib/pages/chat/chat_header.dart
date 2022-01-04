import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/widgets/common/image_widget.dart';
import 'package:twake/widgets/common/shimmer_loading.dart';

class ChatHeader extends StatelessWidget {
  final bool isDirect;
  final bool isPrivate;
  final int membersCount;
  final String? userId;
  final String icon;
  final String name;
  final Function? onTap;
  final List<Avatar> avatars;

  const ChatHeader(
      {Key? key,
      required this.isDirect,
      this.isPrivate = false,
      this.userId,
      required this.membersCount,
      this.icon = '',
      this.name = '',
      this.onTap,
      this.avatars = const []})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap as void Function()?,
      child: Row(
        children: [
          ImageWidget(
              imageType: isDirect ? ImageType.common : ImageType.channel,
              size: 38,
              imageUrl: isDirect ? avatars.first.link : icon,
              avatars: avatars,
              stackSize: 24,
              name: name),
          SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(
                  key: ValueKey<String>('name'),
                  isLoading: name.isEmpty,
                  width: 60.0,
                  height: 10.0,
                  child: Text(
                    name,
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
                (!isDirect) ? SizedBox(height: 4) : SizedBox.shrink(),
                (!isDirect)
                    ? Text(
                        AppLocalizations.of(context)!
                            .membersPlural(membersCount),
                        style: Theme.of(context).textTheme.headline2!.copyWith(
                            fontSize: 10, fontWeight: FontWeight.w400),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
          SizedBox(width: 15),
        ],
      ),
    );
  }
}
