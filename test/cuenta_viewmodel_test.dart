import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clientes_scotiabank/data/model/cuenta_model.dart';
import 'package:clientes_scotiabank/data/model/user_model.dart';
import 'package:clientes_scotiabank/data/repository/cuenta_repository.dart';
import 'package:clientes_scotiabank/ui/viewmodel/cuenta_viewmodel.dart';
import 'package:clientes_scotiabank/ui/viewmodel/auth_viewmodel.dart';

class MockCuentaRepository extends Mock implements CuentaRepository {}

void main() {
  late MockCuentaRepository mockCuentaRepository;
  late UserModel mockUser;
  late Cuenta mockCuenta;

  setUp(() {
    mockCuentaRepository = MockCuentaRepository();
    mockUser = UserModel(id: 'usr123', email: 'test@example.com', nombre: 'Test');
    mockCuenta = Cuenta(
      id: 'acc1',
      userId: 'usr123',
      tipo: 'digital',
      numeroCuenta: '191-1234567-0-12',
      saldo: 1500.0,
      moneda: 'PEN',
      costoMant: 0.0,
      activa: true,
    );
  });

  group('Cuentas Provider Tests', () {
    test('Retorna lista vacía si el usuario no está autenticado', () async {
      final container = ProviderContainer(
        overrides: [
          authViewModelProvider.overrideWith(() => FakeAuthViewModel(null)),
          cuentaRepositoryProvider.overrideWithValue(mockCuentaRepository),
        ],
      );
      addTearDown(container.dispose);

      final accounts = await container.read(cuentasProvider.future);
      expect(accounts, isEmpty);
      verifyNever(() => mockCuentaRepository.getCuentas());
    });

    test('Retorna cuentas del repositorio si el usuario está autenticado', () async {
      when(() => mockCuentaRepository.getCuentas())
          .thenAnswer((_) async => [mockCuenta]);

      final container = ProviderContainer(
        overrides: [
          authViewModelProvider.overrideWith(() => FakeAuthViewModel(mockUser)),
          cuentaRepositoryProvider.overrideWithValue(mockCuentaRepository),
        ],
      );
      addTearDown(container.dispose);

      final accounts = await container.read(cuentasProvider.future);
      expect(accounts, hasLength(1));
      expect(accounts.first.id, 'acc1');
      expect(accounts.first.saldo, 1500.0);
      verify(() => mockCuentaRepository.getCuentas()).called(1);
    });
  });
}

class FakeAuthViewModel extends AuthViewModel {
  final UserModel? _initialUser;

  FakeAuthViewModel(this._initialUser);

  @override
  AuthState build() {
    return AuthState(user: _initialUser);
  }
}
