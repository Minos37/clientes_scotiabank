import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../viewmodel/cuenta_ahorro_viewmodel.dart';
import '../viewmodel/cuenta_viewmodel.dart';

class AhorroScreen extends ConsumerStatefulWidget {
  const AhorroScreen({super.key});

  @override
  ConsumerState<AhorroScreen> createState() => _AhorroScreenState();
}

class _AhorroScreenState extends ConsumerState<AhorroScreen> {
  final currencyFormatterPEN = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ');
  final currencyFormatterUSD = NumberFormat.currency(locale: 'en_US', symbol: '\$ ');

  @override
  Widget build(BuildContext context) {
    final metasAsync = ref.watch(cuentasAhorroProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFFED0006),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Mis Metas de Ahorro',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tarjeta de Resumen Curva
          _buildSummaryHeader(metasAsync),
          
          // Lista de metas
          Expanded(
            child: metasAsync.when(
              data: (metas) {
                if (metas.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: metas.length,
                  itemBuilder: (context, index) {
                    final meta = metas[index];
                    return _buildGoalCard(meta);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFED0006))),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFED0006),
        onPressed: () => _showCrearMetaModal(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nueva Meta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSummaryHeader(AsyncValue<List<dynamic>> metasAsync) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFED0006),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: metasAsync.maybeWhen(
        data: (metas) {
          final totalSoles = metas
              .where((m) => m.moneda == 'PEN')
              .fold<double>(0.0, (sum, m) => sum + m.saldo);
          final totalDolares = metas
              .where((m) => m.moneda == 'USD')
              .fold<double>(0.0, (sum, m) => sum + m.saldo);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Ahorrado Programado',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currencyFormatterPEN.format(totalSoles),
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    currencyFormatterUSD.format(totalDolares),
                    style: const TextStyle(color: Colors.white70, fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          );
        },
        orElse: () => const Text(
          'Cargando resumen...',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFED0006).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.savings_outlined, size: 64, color: Color(0xFFED0006)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aún no tienes metas de ahorro',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea una meta para organizar tu dinero a una tasa preferencial de 3.5% TREA.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(dynamic meta) {
    final formatter = meta.moneda == 'PEN' ? currencyFormatterPEN : currencyFormatterUSD;
    final double progreso = meta.metaAhorro > 0 ? (meta.saldo / meta.metaAhorro) : 0.0;
    final int porcentaje = (progreso * 100).clamp(0, 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFED0006).withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.flag_outlined, color: Color(0xFFED0006)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Meta de Ahorro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${meta.tasaInteres}% TREA Anual', style: TextStyle(color: Colors.green.shade700, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
                Text(
                  '$porcentaje%',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFED0006)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ahorrado', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(formatter.format(meta.saldo), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Objetivo', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(formatter.format(meta.metaAhorro), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black54)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progreso,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFED0006)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAhorrarRetirarModal(context, meta, isAhorro: false),
                    icon: const Icon(Icons.outbox, size: 18),
                    label: const Text('Retirar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFED0006),
                      side: const BorderSide(color: Color(0xFFED0006)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAhorrarRetirarModal(context, meta, isAhorro: true),
                    icon: const Icon(Icons.add_card, size: 18, color: Colors.white),
                    label: const Text('Ahorrar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFED0006),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCrearMetaModal(BuildContext context) {
    final metaController = TextEditingController();
    String moneda = 'PEN';
    String? cuentaId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final cuentasAsync = ref.watch(cuentasProvider);

            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Crear nueva Meta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 20),
                  const Text('Moneda de la meta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Soles (S/)'),
                        selected: moneda == 'PEN',
                        selectedColor: const Color(0xFFED0006).withOpacity(0.15),
                        onSelected: (val) {
                          if (val) setModalState(() => moneda = 'PEN');
                        },
                      ),
                      const SizedBox(width: 12),
                      ChoiceChip(
                        label: const Text('Dólares (\$)'),
                        selected: moneda == 'USD',
                        selectedColor: const Color(0xFFED0006).withOpacity(0.15),
                        onSelected: (val) {
                          if (val) setModalState(() => moneda = 'USD');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Monto Objetivo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: metaController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'ej. 5000.00',
                      prefixText: moneda == 'PEN' ? 'S/ ' : '\$ ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Vincular a cuenta regular (Opcional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  cuentasAsync.when(
                    data: (cuentas) {
                      final cuentasFiltradas = cuentas.where((c) => c.moneda == moneda).toList();
                      if (cuentasFiltradas.isEmpty) {
                        return const Text('No tienes cuentas en esta moneda.', style: TextStyle(color: Colors.red));
                      }
                      return DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        value: cuentaId,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: cuentasFiltradas.map((c) {
                          final u = c.numeroCuenta.length > 4 ? c.numeroCuenta.substring(c.numeroCuenta.length - 4) : c.numeroCuenta;
                          return DropdownMenuItem<String>(
                            value: c.id,
                            child: Text('Cuenta •••• $u (Saldo: ${moneda == "PEN" ? "S/" : "\$"} ${c.saldo})'),
                          );
                        }).toList(),
                        onChanged: (val) => setModalState(() => cuentaId = val),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (e, st) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final double? obj = double.tryParse(metaController.text);
                        if (obj == null || obj <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ingresa un monto objetivo válido')),
                          );
                          return;
                        }

                        final ok = await ref.read(cuentaAhorroNotifierProvider.notifier).crearMeta(
                              metaAhorro: obj,
                              tasaInteres: 3.5,
                              moneda: moneda,
                              cuentaId: cuentaId,
                            );

                        if (ok && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Meta de ahorro creada con éxito')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFED0006),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Crear Meta', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAhorrarRetirarModal(BuildContext context, dynamic meta, {required bool isAhorro}) {
    final montoController = TextEditingController();
    String? cuentaId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final cuentasAsync = ref.watch(cuentasProvider);

            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAhorro ? 'Ahorrar para Meta' : 'Retirar de Meta',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isAhorro ? 'Selecciona la cuenta de origen' : 'Selecciona la cuenta de destino',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  cuentasAsync.when(
                    data: (cuentas) {
                      final cuentasFiltradas = cuentas.where((c) => c.moneda == meta.moneda).toList();
                      if (cuentasFiltradas.isEmpty) {
                        return const Text('No tienes cuentas disponibles en esta moneda.', style: TextStyle(color: Colors.red));
                      }
                      
                      return DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        value: cuentaId,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: cuentasFiltradas.map((c) {
                          final u = c.numeroCuenta.length > 4 ? c.numeroCuenta.substring(c.numeroCuenta.length - 4) : c.numeroCuenta;
                          return DropdownMenuItem<String>(
                            value: c.id,
                            child: Text('Cuenta •••• $u (Saldo: ${meta.moneda == "PEN" ? "S/" : "\$"} ${c.saldo})'),
                          );
                        }).toList(),
                        onChanged: (val) => setModalState(() => cuentaId = val),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (e, st) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 20),
                  const Text('Monto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: montoController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      prefixText: meta.moneda == 'PEN' ? 'S/ ' : '\$ ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final double? monto = double.tryParse(montoController.text);
                        if (monto == null || monto <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ingresa un monto válido')),
                          );
                          return;
                        }

                        if (cuentaId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Selecciona una cuenta de ahorros regular')),
                          );
                          return;
                        }

                        bool ok;
                        if (isAhorro) {
                          ok = await ref.read(cuentaAhorroNotifierProvider.notifier).ahorrar(
                                cuentaAhorroId: meta.id,
                                monto: monto,
                                cuentaOrigenId: cuentaId!,
                              );
                        } else {
                          ok = await ref.read(cuentaAhorroNotifierProvider.notifier).retirar(
                                cuentaAhorroId: meta.id,
                                monto: monto,
                                cuentaDestinoId: cuentaId!,
                              );
                        }

                        if (ok && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isAhorro ? 'Ahorro procesado con éxito' : 'Retiro liberado con éxito')),
                          );
                        } else {
                          // Mostrar error
                          final err = ref.read(cuentaAhorroNotifierProvider).error ?? 'Error desconocido';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Fallo: $err')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFED0006),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        isAhorro ? 'Confirmar Ahorro' : 'Confirmar Retiro',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
