import 'package:dio/dio.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';

class FileRepository {
  final _api = ApiService.instance;

  final _files = <File>[];

  FileRepository();

  Future<List<File>> upload({
    required String path,
    String? name,
    required CancelToken cancelToken,
  }) async {
    final multipartFile = await MultipartFile.fromFile(path, filename: name);
    final formData = FormData.fromMap({
      'file': multipartFile,
    });
    final result = await _api.post(
      endpoint: Endpoint.files,
      data: formData,
      cancelToken: cancelToken,
      key: 'resource',
    );

    final file = File.fromJson(json: result);

    _files.add(file);

    return _files;
  }

  Future<File> getFileData({required String id}) async {
    final result = await _api.get(
      endpoint: sprintf(Endpoint.fileMetadata, [Globals.instance.companyId, id]),
      key: 'resource',
    );
    return File.fromJson(json: result);
  }

  void clearFiles() {
    _files.clear();
  }

  void cancelUpload(CancelToken cancelToken) {
    cancelToken.cancel('User aborted');
  }
}
