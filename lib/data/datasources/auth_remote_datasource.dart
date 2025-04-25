import 'package:dio/dio.dart';
import '../../domain/entities/google_token_dto.dart';

abstract class AuthRemoteDataSource {
  Future<String> authenticate(GoogleTokenDto tokenDto);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio client;
  AuthRemoteDataSourceImpl() : client = Dio();

  @override
  Future<String> authenticate(GoogleTokenDto tokenDto) async {
    final response = await client.post(
      'http://localhost:3000/authentication/google',
      data: {
        'token': tokenDto.token,
        if (tokenDto.schoolName != null) 'schoolName': tokenDto.schoolName,
      },
    );
    return response.data['accessToken'] as String;
  }
}