import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/writing_cubit/writing_cubit.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/widgets/common/image_widget.dart';
import 'package:twake/widgets/common/shimmer_loading.dart';

class ChatHeader extends StatelessWidget {
  final bool isDirect;
  final bool isPrivate;
  final int membersCount;
  final List<String> users;
  final String channelId;
  final String icon;
  final String name;
  final Function? onTap;
  final List<Avatar> avatars;

  const ChatHeader(
      {Key? key,
      required this.isDirect,
      this.isPrivate = false,
      required this.users,
      required this.channelId,
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
          BlocBuilder<WritingCubit, WritingState>(
            bloc: Get.find<WritingCubit>(),
            builder: (context, state) {
              users.forEach((id) {
                print(id);
              });
              // users.where((id) => state.userId==id)

              if (state.writingStatus == WritingStatus.writing &&
                  state.channelIdMap.containsKey(channelId)) {
                return Container(
                  width: 200,
                  height: 50,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: state.channelIdMap[channelId]!.length,
                    itemBuilder: (context, index) {
                      return Text(
                          state.channelIdMap[channelId]!.elementAt(index),
                          style: Theme.of(context).textTheme.headline4,
                          overflow: TextOverflow.ellipsis);
                    },
                  ),
                );
              } else if (state.writingStatus == WritingStatus.noWriting &&
                  state.channelIdMap.containsKey(channelId)) {
                return Container(
                  width: 200,
                  height: 50,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: state.channelIdMap[channelId]!.length,
                    itemBuilder: (context, index) {
                      return Text(
                          state.channelIdMap[channelId]!.elementAt(index),
                          style: Theme.of(context).textTheme.headline4,
                          overflow: TextOverflow.ellipsis);
                    },
                  ),
                );
              } else {
                return SizedBox.shrink();
              }
            },
          ),
          /*Expanded(
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
          SizedBox(width: 15),*/
        ],
      ),
    );
  }
}
