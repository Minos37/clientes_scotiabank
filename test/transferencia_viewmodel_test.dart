import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clientes_scotiabank/data/model/transferencia_model.dart';
import 'package:clientes_scotiabank/data/repository/transferencia_repository.dart';
import 'package:clientes_scotiabank/ui/viewmodel/transferencia_viewmodel.dart';

class MockTransferenciaRepository extends Mock implements TransferenciaRepository {}

void main() {
  late MockTransferenciaRepository mockTransferenciaRepository;

  setUp(() {
    mockTransferenciaRepository = MockTransferenciaRepository();
    registerFallbackValue(
      Transferencia(
        id: '',
        userId: '',
        cuentaOrigenId: '',
        tipo: 'terceros',
        bancoDestino: null,
        cuentaDestino: '',
        nombreDestino: '',
        monto: 0.0,
        moneda: 'PEN',
        comision: 0.0,
        estado: 'completado',
      ),
    );
  });

  group('TransferenciaViewModel Tests', () {
    test('Realizar transferencia exitosa actualiza el estado a success', () async {
      when(() => mockTransferenciaRepository.realizarTransferencia(any()))
          .thenAnswer((_) async => {});

      final container = ProviderContainer(
        overrides: [
          transferenciaRepositoryProvider.overrideWithValue(mockTransferenciaRepository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(transferenciaViewModelProvider.notifier);

      expect(container.read(transferenciaViewModelProvider).isLoading, false);
      expect(container.read(transferenciaViewModelProvider).success, false);

      final future = notifier.realizarTransferencia(
        cuentaOrigenId: 'acc1',
        tipo: 'terceros',
        bancoDestino: 'BBVA',
        cuentaDestino: '193-9876543-0-11',
        nombreDestino: 'María Rojas',
        monto: 250.0,
        moneda: 'PEN',
      );

      expect(container.read(transferenciaViewModelProvider).isLoading, true);

      final result = await future;
      expect(result, true);

      final finalState = container.read(transferenciaViewModelProvider);
      expect(finalState.isLoading, false);
      expect(finalState.success, true);
      expect(finalState.error, null);

      verify(() => mockTransferenciaRepository.realizarTransferencia(any())).called(1);
    });

    test('Realizar transferencia fallida actualiza el estado con el error', () async {
      when(() => mockTransferenciaRepository.realizarTransferencia(any()))
          .thenThrow(Exception('Límite diario excedido'));

      final container = ProviderContainer(
        overrides: [
          transferenciaRepositoryProvider.overrideWithValue(mockTransferenciaRepository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(transferenciaViewModelProvider.notifier);

      final result = await notifier.realizarTransferencia(
        cuentaOrigenId: 'acc1',
        tipo: 'terceros',
        bancoDestino: 'BBVA',
        cuentaDestino: '193-9876543-0-11',
        nombreDestino: 'María Rojas',
        monto: 2000.0,
        moneda: 'PEN',
      );

      expect(result, false);

      final finalState = container.read(transferenciaViewModelProvider);
      expect(finalState.isLoading, false);
      expect(finalState.success, false);
      expect(finalState.error, contains('Límite diario excedido'));
    });
  });
}
