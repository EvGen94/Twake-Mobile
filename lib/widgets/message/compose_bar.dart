import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_state.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_state.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/file/upload/file_uploading.dart';
import 'package:twake/utils/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/mentions_cubit/mentions_cubit.dart';
import 'package:twake/widgets/common/file_uploading_tile.dart';

// const _categoryHeaderHeight = 40.0;
// const _categoryTitleHeight = _categoryHeaderHeight; // to

class ComposeBar extends StatefulWidget {
  final bool autofocus;
  final Function(String, BuildContext) onMessageSend;
  final Function(String, BuildContext) onTextUpdated;
  final String? initialText;

  ComposeBar({
    required this.onMessageSend,
    required this.onTextUpdated,
    this.autofocus = false,
    this.initialText = '',
  });

  @override
  _ComposeBar createState() => _ComposeBar();
}

class _ComposeBar extends State<ComposeBar> {
  final _userMentionRegex = RegExp(r'(^|\s)@[A-Za-z0-9._-]+$');
  var _emojiVisible = false;
  var _mentionsVisible = false;
  var _forceLooseFocus = false;
  var _canSend = false;

  final _focusNode = FocusNode();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  List<PlatformFile>? _paths;
  String? _extension;
  FileType _pickingType = FileType.any;

  @override
  void initState() {
    super.initState();

    widget.onTextUpdated(widget.initialText ?? '', context);
    if (widget.initialText?.isNotReallyEmpty ?? false) {
      _controller.text = widget.initialText!; // possibly retrieved from cache.
      setState(() {
        _canSend = true;
      });
    }

    _focusNode.addListener(() {
      if (_focusNode.hasPrimaryFocus)
        setState(() {
          _emojiVisible = false;
        });
    });

    _controller.addListener(() {
      if (_controller.selection.base.offset < 0) return;

      var text = _controller.text;
      text = text.substring(0, _controller.selection.base.offset);
      if (_userMentionRegex.hasMatch(text)) {
        Get.find<MentionsCubit>().fetch(
          searchTerm: text.split('@').last.trimRight(),
        );
        Future.delayed(const Duration(milliseconds: 100), () {
          mentionsVisible();
        });
      } else {
        setState(() {
          _mentionsVisible = false;
        });
      }
      // Update for cache handlers
      widget.onTextUpdated(text, context);
      // Sendability  validation
      if (_controller.text.isReallyEmpty && _canSend) {
        setState(() {
          _canSend = false;
        });
      } else if (text.isNotReallyEmpty && !_canSend) {
        setState(() {
          _canSend = true;
        });
      }
    });
  }

  // TODO get rid of _mentionsVisible since can use states of new MentionsCubit
  void mentionsVisible() async {
    final MentionState mentionsState = Get.find<MentionsCubit>().state;
    if (mentionsState is MentionsLoadSuccess) {
      setState(() {
        _mentionsVisible = true;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ComposeBar oldWidget) {
    if (oldWidget.initialText != widget.initialText) {
      _controller.text = widget.initialText ?? '';
    }
    // print('FORCE LOOSE FOCUS: $_forceLooseFocus');
    if (widget.autofocus && !_forceLooseFocus) {
      _focusNode.requestFocus();
    }
    super.didUpdateWidget(oldWidget);
  }

  void toggleEmojiBoard() async {
    if (_focusNode.hasPrimaryFocus) {
      _focusNode.unfocus();
      _forceLooseFocus = true;
    }
    setState(() {
      _emojiVisible = !_emojiVisible;
    });
    if (!_emojiVisible) {
      _forceLooseFocus = false;
      _focusNode.requestFocus();
    }
  }

  void swipeRequestFocus(bool _focus) {
    _focus ? _focusNode.requestFocus() : _focusNode.unfocus();
  }

  void mentionReplace(String username) async {
    var text = _controller.text;
    text = text.substring(0, _controller.selection.base.offset);
    _controller.text = _controller.text.replaceRange(
      text.lastIndexOf('@'),
      _controller.selection.base.offset,
      '@$username ',
    );
    _controller.selection = TextSelection.fromPosition(
      TextPosition(
        offset: text.lastIndexOf('@') + username.length + 2,
      ),
    );
  }

  Future<bool> onBackPress() async {
    if (_emojiVisible) {
      setState(() {
        _emojiVisible = false;
      });
    } else {
      Navigator.pop(context);
    }

    return false;
  }

  void _openFileExplorer() async {
    try {
      _paths = (await FilePicker.platform.pickFiles(
        type: _pickingType,
        allowMultiple: true,
        allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension!.replaceAll(' ', '').split(',')
            : null,
      ))
          ?.files;
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
      return;
    } catch (ex) {
      print(ex);
      return;
    }
    if (!mounted) return;

    _paths?.forEach((element) {
      if(element.path != null) {
        Get.find<FileUploadCubit>().upload(sourcePath: element.path!);
      }
    });

    Get.find<FileUploadCubit>().stream.listen((state) {
       if (state.listFileUploading.isNotEmpty) {
         final hasUploadedFileInStack = state.listFileUploading.any(
                 (element) => element.uploadStatus == FileItemUploadStatus.uploaded);
         if(hasUploadedFileInStack) {
           if(!mounted)
             return;
           setState(() {
             _canSend = true;
           });
         }
       }
    });
  }

  void _fileNumClear() async {
    _paths = [];
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ThreadMessagesCubit, MessagesState>(
      bloc: Get.find<ThreadMessagesCubit>(),
      listener: (context, state) {
        if (state is MessagesLoadSuccessSwipeToReply) {
          swipeRequestFocus(true);
        } else if (state is MessagesInitial) {
          swipeRequestFocus(false);
        }
      },
      child: WillPopScope(
        onWillPop: onBackPress,
        child: Column(
          children: [
            _mentionsVisible
                ? BlocBuilder<MentionsCubit, MentionState>(
                    bloc: Get.find<MentionsCubit>(),
                    builder: (context, state) {
                      if (state is MentionsLoadSuccess) {
                        final List<Widget> _listW = [];
                        _listW.add(Divider(thickness: 1));
                        for (int i = 0; i < state.accounts.length; i++) {
                          _listW.add(
                            InkWell(
                              child: Container(
                                alignment: Alignment.center,
                                height: 40.0,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(width: 15),
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
                                      child: CircleAvatar(
                                        child: state.accounts[i].picture! == ""
                                            ? CircleAvatar(
                                                child: Icon(Icons.person,
                                                    color: Colors.grey),
                                                backgroundColor:
                                                    Colors.blue[50],
                                              )
                                            : Image.network(
                                                state.accounts[i].picture!,
                                                fit: BoxFit.contain,
                                                loadingBuilder:
                                                    (context, child, progress) {
                                                  if (progress == null) {
                                                    return child;
                                                  }

                                                  return CircleAvatar(
                                                    child: Icon(Icons.person,
                                                        color: Colors.grey),
                                                    backgroundColor:
                                                        Colors.blue[50],
                                                  );
                                                },
                                              ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Text(
                                      '${state.accounts[i].fullName} ',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w300),
                                    ),
                                    Expanded(child: SizedBox()),
                                    // Icon(
                                    // Icons.message_rounded,
                                    // color: Colors.grey,
                                    // ),
                                    // SizedBox(width: 15),
                                  ],
                                ),
                              ),
                              onTap: () {
                                Get.find<MentionsCubit>().reset();

                                mentionReplace(state.accounts[i].username);
                                setState(
                                  () {
                                    _mentionsVisible = false;
                                  },
                                );
                              },
                            ),
                          );
                          if (i < state.accounts.length - 1) {
                            _listW.add(Divider(thickness: 1));
                          }
                        }
                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: Dim.heightPercent(30),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: _listW,
                            ),
                          ),
                        );
                      } else if (state is MentionsInitial) {
                        return Container();
                        //Text("Empty");
                      }
                      return Container();
                    },
                  )
                : Container(),
            TextInput(
              controller: _controller,
              scrollController: _scrollController,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              toggleEmojiBoard: toggleEmojiBoard,
              emojiVisible: _emojiVisible,
              onMessageSend: widget.onMessageSend,
              canSend: _canSend,
              openFileExplorer: _openFileExplorer,
              fileNumClear: _fileNumClear,
            ),
            Offstage(
              offstage: !_emojiVisible,
              child: Container(
                height: 250,
                child: EmojiPicker(
                  onEmojiSelected: (cat, emoji) {
                    _controller.text += emoji.emoji;
                    setState(() {
                      _canSend = true;
                    });
                  },
                  config: Config(
                    columns: 7,
                    emojiSizeMax: 32.0,
                    verticalSpacing: 0,
                    horizontalSpacing: 0,
                    initCategory: Category.RECENT,
                    bgColor: Color(0xFFF2F2F2),
                    indicatorColor: Colors.blue,
                    iconColor: Colors.grey,
                    iconColorSelected: Colors.blue,
                    progressIndicatorColor: Colors.blue,
                    showRecentsTab: true,
                    recentsLimit: 28,
                    noRecentsText: AppLocalizations.of(context)!.noRecents,
                    noRecentsStyle:
                        const TextStyle(fontSize: 20, color: Colors.black26),
                    categoryIcons: const CategoryIcons(),
                    buttonMode: ButtonMode.MATERIAL,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TextInput extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ScrollController? scrollController;
  final Function? toggleEmojiBoard;
  final bool? autofocus;
  final bool? emojiVisible;
  final bool canSend;
  final Function onMessageSend;
  final Function? openFileExplorer;
  final Function? fileNumClear;

  TextInput({
    required this.onMessageSend,
    this.controller,
    this.focusNode,
    this.autofocus,
    this.emojiVisible,
    this.scrollController,
    this.toggleEmojiBoard,
    this.openFileExplorer,
    this.canSend = false,
    this.fileNumClear,
  });

  @override
  _TextInputState createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 11.0, bottom: 11.0),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1.5)),
        color: Color(0xfff6f6f6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 14.0),
          _buildAttachment(),
          SizedBox(width: 14.0),
          Expanded(
            child: _buildMessageContent(),
          ),
          _buildSendButton(),
        ],
      ),
    );
  }

  _buildAttachment() => IconButton(
      constraints: BoxConstraints(
        minHeight: 24.0,
        minWidth: 24.0,
      ),
      padding: EdgeInsets.zero,
      icon: Image.asset(imageAttachment),
      onPressed: () => _handleOpenFilePicker(),
      color: Color(0xff8a898e),
    );

  _buildMessageContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Color(0xff979797).withOpacity(0.4),
        ),
      ),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Column(
            children: [
              _buildMessageTextField(),
              BlocBuilder<FileUploadCubit, FileUploadState>(
                bloc: Get.find<FileUploadCubit>(),
                builder: (context, state) {
                    return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: state.listFileUploading.length,
                    itemBuilder: (context, index) {
                      final fileUploading = state.listFileUploading[index];
                      return FileUploadingTile(
                        fileUploading: fileUploading,
                        onCancel: () {
                          Get.find<FileUploadCubit>().cancelFileUploading(fileUploading);
                        }
                      );
                    });
                }
              )
            ],
          ),
          GestureDetector(
            onTap: widget.toggleEmojiBoard as void Function()?,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(imageEmoji, width: 24, height: 24),
            ), //Image.asset('assets/images/attach.png'),
          )
        ],
      ),
    );
  }

  _buildMessageTextField() {
    return TextField(
      style: TextStyle(
        fontSize: 17.0,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      maxLines: 4,
      minLines: 1,
      autofocus: widget.autofocus!,
      focusNode: widget.focusNode,
      scrollController: widget.scrollController,
      controller: widget.controller,
      decoration: InputDecoration(
        contentPadding:
        const EdgeInsets.fromLTRB(12.0, 9.0, 32.0, 9.0),
        hintText: AppLocalizations.of(context)!.newReply,
        hintStyle: TextStyle(
          fontSize: 13.0,
          fontWeight: FontWeight.w500,
          color: Colors.black.withOpacity(0.2),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            style: BorderStyle.none,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            style: BorderStyle.none,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            style: BorderStyle.none,
          ),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  _buildSendButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.canSend
          ? () async {
              widget.onMessageSend(
                await Get.find<MentionsCubit>().completeMentions(widget.controller!.text),
                context,
              );
              widget.controller!.clear();
              widget.fileNumClear!();
              Get.find<FileUploadCubit>().updateAfterSentAllFiles();
            }
          : null,
      child: widget.canSend
          ? Container(
              padding: EdgeInsets.fromLTRB(17.0, 6.0, 18.0, 6.0),
              child: Image.asset(
                'assets/images/send_blue.png',
              ),
            )
          : Container(
              padding: EdgeInsets.fromLTRB(17.0, 6.0, 18.0, 6.0),
              child: Image.asset(
                'assets/images/send.png',
              ),
            ),
    );
  }

  _handleOpenFilePicker() => widget.openFileExplorer?.call();
}
