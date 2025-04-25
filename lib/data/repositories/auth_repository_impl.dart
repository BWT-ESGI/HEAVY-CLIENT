import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../domain/entities/google_token_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<String> authenticateWithGoogle(String token,
      {String? schoolName}) {
    return remoteDataSource.authenticate(
      GoogleTokenDto(token: token, schoolName: schoolName),
    );
  }
}