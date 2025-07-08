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
      'https://api-bwt.thomasgllt.fr/authentication/google', // à changer selon utilisation sur iOS (xcode), android (emulateur) ou si l'api est déployée
      data: {
        'token': tokenDto.token,
        if (tokenDto.schoolName != null) 'schoolName': tokenDto.schoolName,
      },
    );
    return response.data['accessToken'] as String;
  }
}