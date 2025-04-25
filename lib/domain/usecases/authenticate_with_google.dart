import '../../core/usecase.dart';
import '../entities/google_token_dto.dart';
import '../repositories/auth_repository.dart';

class AuthenticateWithGoogle
    implements UseCase<String, GoogleTokenDto> {
  final AuthRepository repository;
  AuthenticateWithGoogle(this.repository);

  @override
  Future<String> call(GoogleTokenDto params) {
    return repository.authenticateWithGoogle(
      params.token,
      schoolName: params.schoolName,
    );
  }
}