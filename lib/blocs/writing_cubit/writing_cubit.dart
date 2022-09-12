import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'writing_state.dart';

class WritingCubit extends Cubit<WritingState> {
  WritingCubit() : super(WritingState(writingStatus: WritingStatus.noWriting));

  void emitNewWriting(String userId, String name, String channelId) async {
    final Map<String, Set<String>> channelIdMap = {...state.channelIdMap};
    channelIdMap.containsKey('$channelId')
        ? channelIdMap[channelId]!.add(name)
        : channelIdMap[channelId] = {name};

    /*emit(state.copyWith(
        newChannelIdMap: channelIdMap,
        newUserId: userId,
        newName: name,
        newWritingStatus: WritingStatus.writing));*/
    emit(WritingState(
        channelIdMap: channelIdMap,
        writingStatus: WritingStatus.writing,
        name: name,
        userId: userId));
    await Future.delayed(Duration(seconds: 1));
    channelIdMap[channelId]!.remove(name);
    emit(WritingState(
        channelIdMap: channelIdMap,
        writingStatus: WritingStatus.noWriting,
        name: name,
        userId: userId));
  }
}
