import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/core/network/dio_client.dart';
import 'package:kdkd_mobile/feature/auth/models/profile_model.dart';

class ProfileApi {
  final Dio dio;

  ProfileApi(this.dio);

  Future<Profile?> getMyProfile() async {
    try {
      final response = await dio.get('/users/me');
      final data = Map<String, dynamic>.from(response.data);

      return Profile.fromJson(data);
    } catch (e) {
      return null;
    }
  }
}

final profileApiProvider = Provider<ProfileApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ProfileApi(dio);
});
