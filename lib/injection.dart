import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/authenticate_with_google.dart';

void init() {
  Get.lazyPut<GoogleSignIn>(() => GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId:
            '242304203312-n8hl0ofv3lgid46blg6kdhfajctves20.apps.googleusercontent.com',
      ));

  // Data source
  Get.lazyPut<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());

  // Repository
  Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(Get.find()));

  // Use case
  Get.lazyPut<AuthenticateWithGoogle>(() => AuthenticateWithGoogle(Get.find()));
}
