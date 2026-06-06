import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clientes_scotiabank/data/repository/prestamo_repository.dart';
import 'package:clientes_scotiabank/ui/viewmodel/prestamo_viewmodel.dart';

class MockPrestamoRepository extends Mock implements PrestamoRepository {}

void main() {
  late MockPrestamoRepository mockPrestamoRepository;

  setUp(() {
    mockPrestamoRepository = MockPrestamoRepository();
  });

  group('PrestamoPaymentViewModel Tests', () {
    test('Pagar cuota exitoso actualiza estado a success', () async {
      when(() => mockPrestamoRepository.pagarCuota('cuota123', 'acc123'))
          .thenAnswer((_) async => {});

      final container = ProviderContainer(
        overrides: [
          prestamoRepositoryProvider.overrideWithValue(mockPrestamoRepository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(prestamoPaymentViewModelProvider.notifier);

      expect(container.read(prestamoPaymentViewModelProvider).isLoading, false);
      expect(container.read(prestamoPaymentViewModelProvider).success, false);

      final future = notifier.pagarCuota(
        cuotaId: 'cuota123',
        cuentaId: 'acc123',
        prestamoId: 'prestamo456',
      );

      expect(container.read(prestamoPaymentViewModelProvider).isLoading, true);

      final result = await future;

      expect(result, true);
      final finalState = container.read(prestamoPaymentViewModelProvider);
      expect(finalState.isLoading, false);
      expect(finalState.success, true);
      expect(finalState.error, null);

      verify(() => mockPrestamoRepository.pagarCuota('cuota123', 'acc123')).called(1);
    });

    test('Pagar cuota fallido actualiza estado con error', () async {
      when(() => mockPrestamoRepository.pagarCuota('cuota123', 'acc123'))
          .thenThrow(Exception('Saldo insuficiente'));

      final container = ProviderContainer(
        overrides: [
          prestamoRepositoryProvider.overrideWithValue(mockPrestamoRepository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(prestamoPaymentViewModelProvider.notifier);

      final result = await notifier.pagarCuota(
        cuotaId: 'cuota123',
        cuentaId: 'acc123',
        prestamoId: 'prestamo456',
      );

      expect(result, false);
      final finalState = container.read(prestamoPaymentViewModelProvider);
      expect(finalState.isLoading, false);
      expect(finalState.success, false);
      expect(finalState.error, contains('Saldo insuficiente'));
    });
  });
}
