import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:twake/blocs/file_upload_bloc/file_upload_bloc.dart';
import 'package:twake/models/language_option.dart';
import 'package:twake/repositories/account_repository.dart';
import 'package:twake/services/endpoints.dart';
import 'package:twake/utils/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'account_state.dart';

enum AccountFlowStage {
  info,
  edit,
}

class AccountCubit extends Cubit<AccountState> {
  final AccountRepository accountRepository;

  AccountCubit(this.accountRepository)
      : super(AccountInitial(
          userName: accountRepository.userName.value,
          firstName: accountRepository.firstName.value,
          lastName: accountRepository.lastName.value,
          picture: accountRepository.picture.value,
          language: accountRepository.selectedLanguage().title,
          availableLanguages: accountRepository.language.options,
        ));

  Future<void> fetch() async {
    emit(AccountLoading());
    final result = await accountRepository.reload();

    final availableLanguages = result.language.options ?? <LanguageOption>[];
    final currentLanguage = result.selectedLanguage();
    final languageTitle = currentLanguage.title;

    final loadedState = AccountLoaded(
      userName: result.userName.value,
      firstName: result.firstName.value,
      lastName: result.lastName.value,
      picture: result.picture.value,
      language: languageTitle,
      availableLanguages: availableLanguages,
    );

    emit(loadedState);
  }

  Future<void> saveInfo() async {
    emit(AccountSaving());
    final patchResult = await accountRepository.patch();
    if (patchResult) {
      final savedState = AccountSaved(
        userName: accountRepository.userName.value,
        firstName: accountRepository.firstName.value,
        lastName: accountRepository.lastName.value,
        picture: accountRepository.picture.value,
        language: accountRepository.selectedLanguage().title,
        availableLanguages: accountRepository.language.options,
      );
      emit(savedState);
    } else {
      emit(AccountError(message: 'Account saving failure'));
    }
  }

  Future<void> updateInfo({
    String firstName,
    String lastName,
    String languageTitle,
    String oldPassword,
    String newPassword,
  }) async {
    emit(AccountUpdating());
    final languageCode =
        (languageTitle != null && languageTitle.isNotReallyEmpty)
            ? accountRepository.languageCodeFromTitle(languageTitle)
            : '';
    await accountRepository.update(
      newFirstName: firstName,
      newLastName: lastName,
      newLanguage: languageCode ?? '',
      oldPassword: oldPassword,
      newPassword: newPassword,
    );

    final updatedState = AccountUpdated(
      userName: accountRepository.userName.value,
      firstName: accountRepository.firstName.value,
      lastName: accountRepository.lastName.value,
      oldPassword: oldPassword,
      newPassword: newPassword,
      picture: accountRepository.picture.value,
      language: accountRepository.selectedLanguage().title,
      availableLanguages: accountRepository.language.options,
    );
    emit(updatedState);
  }

  Future<void> updateImage(BuildContext context, String path) async {
    emit(AccountPictureUpdating());
    context.read<FileUploadBloc>()
      ..add(
        StartUpload(
          path: path,
          endpoint: Endpoint.accountPicture,
        ),
      )
      ..listen(
        (FileUploadState state) {
          if (state is FileUploaded) {
            emit(AccountPictureUpdated());
          }
        },
      );
  }

  Future<void> updateAccountFlowStage(AccountFlowStage stage) async {
    emit(AccountFlowStageUpdated(stage));
  }
}
