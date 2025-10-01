import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/core/network/dio_client.dart';
import 'package:kdkd_mobile/feature/auth/models/profile_model.dart';

class SettingProfileApi {
  final Dio dio;

  SettingProfileApi(this.dio);

  Future<Profile?> patchUserProfileDetail(String name, String birthdate) async {
    try {
      final response = await dio.patch(
        '/users/me',
        data: {
          "name": name,
          "birthdate": birthdate,
        },
      );

      return Profile.fromJson(response.data);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> patchUserProfileImage(String filePath) async {
    try {
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath),
      });

      final response = await dio.post(
        '/users/users/me/profile',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }
}

final settingProfileApiProvider = Provider<SettingProfileApi>((ref) {
  final dio = ref.watch(dioProvider);
  return SettingProfileApi(dio);
});
