import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:twake/models/message/message.dart';

part 'gallery_state.dart';

const int iterationStep = 7;

class GalleryCubit extends Cubit<GalleryState> {
  GalleryCubit()
      : super(GalleryState(galleryStateStatus: GalleryStateStatus.init));

  void getGalleryAssets() async {
    final PermissionState _permissionExtend =
        await PhotoManager.requestPermissionExtend();
    if (!_permissionExtend.isAuth) {
      emit(GalleryState(
        galleryStateStatus: GalleryStateStatus.failed,
      ));
      return;
    }

    if (state.loadedAssetsAmount == 0)
      emit(state.copyWith(newGalleryStateStatus: GalleryStateStatus.loading));

    List<Uint8List> uint8List = [...state.assetsList];
    List<File> fileList = [...state.fileList];
    List<AssetEntity> recentAssets = [...state.assetEntity];
    File? file;
    Uint8List? uint8;

    final albums = await PhotoManager.getAssetPathList(
        hasAll: true,
        //  onlyAll: true,
        type: RequestType.common,
        filterOption:
            FilterOptionGroup(imageOption: FilterOption(needTitle: true)));

    // we can go through all albums to get all AssetEntity
    final recentAlbum = albums[0];
    final recentAsset = await recentAlbum.getAssetListRange(
      start: state.loadedAssetsAmount,
      //when opening the gallery for the first time loading 17 assets then iterationStep
      end: (state.loadedAssetsAmount == 0)
          ? 17
          : state.loadedAssetsAmount + iterationStep,
    );

    if (recentAsset.length == 0) {
      // if all assets already is loaded - return
      return;
    }
    recentAssets.addAll(recentAsset);

    // Future.forEach recentAssets
    for (var i = state.loadedAssetsAmount; i < recentAssets.length; i++) {
      uint8 = await recentAssets[i].thumbnailData;
      file = await recentAssets[i].file;
      uint8 != null ? uint8List.add(uint8) : null;
      file != null ? fileList.add(file) : null;
    }

    if (uint8List.isEmpty) {
      emit(GalleryState(galleryStateStatus: GalleryStateStatus.failed));
    } else {
      emit(GalleryState(
          galleryStateStatus: GalleryStateStatus.done,
          selectedTab: state.selectedTab,
          assetsList: uint8List,
          assetEntity: recentAssets,
          fileList: fileList,
          loadedAssetsAmount: recentAssets.length));
    }
  }

  void tabChange(int tab) {
    emit(state.copyWith(newSelectedTab: tab));
  }

  void addFileIndex(int index) {
    List<int> indexList = [...state.selectedFilesIndex];
    indexList.contains(index)
        ? indexList.remove(index)
        : indexList.length < 10
            ? indexList.add(index)
            : null;

    emit(GalleryState(
        selectedFilesIndex: indexList,
        galleryStateStatus: GalleryStateStatus.newSelect,
        assetEntity: state.assetEntity,
        assetsList: state.assetsList,
        fileList: state.fileList,
        loadedAssetsAmount: state.loadedAssetsAmount));
  }

  void clearSelection() {
    emit(state.copyWith(newSelectedFilesIndex: []));
  }

  void galleryInit() {
    emit(GalleryState(galleryStateStatus: GalleryStateStatus.init));
  }

  void galleryfailed() {
    emit(GalleryState(galleryStateStatus: GalleryStateStatus.failed));
  }
}
