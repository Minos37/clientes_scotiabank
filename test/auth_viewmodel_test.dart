import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clientes_scotiabank/data/model/user_model.dart';
import 'package:clientes_scotiabank/data/repository/auth_repository.dart';
import 'package:clientes_scotiabank/ui/viewmodel/auth_viewmodel.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    // Valor por defecto para authStateChanges
    when(() => mockAuthRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
  });

  group('AuthViewModel Tests', () {
    test('Estado inicial es cargado desde el repositorio', () {
      final mockUser = UserModel(id: '123', email: 'test@example.com', nombre: 'Test User');
      when(() => mockAuthRepository.getCurrentUser()).thenReturn(mockUser);

      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ]);
      addTearDown(container.dispose);

      final state = container.read(authViewModelProvider);
      expect(state.user, mockUser);
      expect(state.isLoading, false);
      expect(state.error, null);
    });

    test('Login exitoso actualiza el estado con el usuario', () async {
      final mockUser = UserModel(id: '123', email: 'test@example.com', nombre: 'Test User');
      when(() => mockAuthRepository.getCurrentUser()).thenReturn(null);
      when(() => mockAuthRepository.login('test@example.com', 'password'))
          .thenAnswer((_) async => mockUser);

      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(authViewModelProvider.notifier);

      expect(container.read(authViewModelProvider).user, null);

      final future = notifier.login('test@example.com', 'password');
      expect(container.read(authViewModelProvider).isLoading, true);

      await future;

      final state = container.read(authViewModelProvider);
      expect(state.user, mockUser);
      expect(state.isLoading, false);
      expect(state.error, null);
    });

    test('Login fallido actualiza el estado con el error', () async {
      when(() => mockAuthRepository.getCurrentUser()).thenReturn(null);
      when(() => mockAuthRepository.login('test@example.com', 'password'))
          .thenThrow(Exception('Credenciales inválidas'));

      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(authViewModelProvider.notifier);

      await notifier.login('test@example.com', 'password');

      final state = container.read(authViewModelProvider);
      expect(state.user, null);
      expect(state.isLoading, false);
      expect(state.error, contains('Credenciales inválidas'));
    });

    test('Logout limpia el estado del usuario', () async {
      final mockUser = UserModel(id: '123', email: 'test@example.com', nombre: 'Test User');
      when(() => mockAuthRepository.getCurrentUser()).thenReturn(mockUser);
      when(() => mockAuthRepository.logout()).thenAnswer((_) async => {});

      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(authViewModelProvider.notifier);

      await notifier.logout();

      final state = container.read(authViewModelProvider);
      expect(state.user, null);
      expect(state.isLoading, false);
      expect(state.error, null);
    });
  });
}
