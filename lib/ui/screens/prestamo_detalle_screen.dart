import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/prestamo_model.dart';
import '../../data/model/cuota_prestamo_model.dart';
import '../viewmodel/cuenta_viewmodel.dart';
import '../viewmodel/prestamo_viewmodel.dart';
import 'package:intl/intl.dart';

class PrestamoDetalleScreen extends ConsumerStatefulWidget {
  final Prestamo prestamo;
  const PrestamoDetalleScreen({super.key, required this.prestamo});

  @override
  ConsumerState<PrestamoDetalleScreen> createState() => _PrestamoDetalleScreenState();
}

class _ParcelTile extends StatelessWidget {
  final CuotaPrestamo cuota;
  final NumberFormat formatter;

  const _ParcelTile({required this.cuota, required this.formatter});

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help_outline;

    if (cuota.estado == 'pagada') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
    } else if (cuota.estado == 'mora') {
      statusColor = Colors.red;
      statusIcon = Icons.error_outline;
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.schedule;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cuota ${cuota.numeroCuota} de ${cuota.estado.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(
                  'Vence: ${DateFormat('dd/MM/yyyy').format(cuota.fechaVenc)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatter.format(cuota.montoCuota),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
              ),
              Text(
                'Cap: ${formatter.format(cuota.capital)}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrestamoDetalleScreenState extends ConsumerState<PrestamoDetalleScreen> {
  String? _selectedAccountId;

  void _showPayInstallmentSheet(BuildContext context, CuotaPrestamo cuota, NumberFormat formatter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Consumer(
              builder: (context, ref, child) {
                final cuentasAsync = ref.watch(cuentasProvider);
                final payState = ref.watch(prestamoPaymentViewModelProvider);

                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                  ),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                    top: 24,
                    left: 24,
                    right: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pagar Cuota ${cuota.numeroCuota}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'Monto de la Cuota: ${formatter.format(cuota.montoCuota)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFED0006)),
                      ),
                      const SizedBox(height: 16),
                      const Text('Seleccionar Cuenta de Débito', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),

                      cuentasAsync.when(
                        data: (cuentas) {
                          final penCuentas = cuentas.where((c) => c.moneda == widget.prestamo.moneda).toList();
                          if (penCuentas.isEmpty) {
                            return Text('No tienes cuentas disponibles en ${widget.prestamo.moneda} para pagar.', style: const TextStyle(color: Colors.black87));
                          }
                          _selectedAccountId ??= penCuentas.first.id;
                          
                          return DropdownButtonFormField<String>(
                            value: _selectedAccountId,
                            dropdownColor: Colors.white,
                            style: const TextStyle(color: Colors.black87, fontSize: 14),
                            isExpanded: true,
                            decoration: InputDecoration(
                              hintStyle: TextStyle(color: Colors.grey.shade600),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            items: penCuentas.map((c) {
                              final ultimos = c.numeroCuenta.length > 4 ? c.numeroCuenta.substring(c.numeroCuenta.length - 4) : c.numeroCuenta;
                              return DropdownMenuItem(
                                value: c.id,
                                child: Text('Cuenta ${c.tipo.toUpperCase()} •••• $ultimos (${c.moneda == 'PEN' ? 'S/' : '\$'} ${c.saldo.toStringAsFixed(2)})'),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedAccountId = val),
                          );
                        },
                        loading: () => const LinearProgressIndicator(color: Color(0xFFED0006)),
                        error: (_, __) => const Text('Error al cargar cuentas bancarias'),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: payState.isLoading || _selectedAccountId == null
                              ? null
                              : () async {
                                  final success = await ref
                                      .read(prestamoPaymentViewModelProvider.notifier)
                                      .pagarCuota(
                                        cuotaId: cuota.id,
                                        cuentaId: _selectedAccountId!,
                                        prestamoId: widget.prestamo.id,
                                      );

                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('¡Cuota pagada con éxito!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.pop(context); // Cierra bottomsheet
                                    // Volver a cargar el detalle o actualizar el estado del préstamo
                                    Navigator.pop(context); // Regresa a la lista
                                  } else if (context.mounted) {
                                    final errorMsg = ref.read(prestamoPaymentViewModelProvider).error ?? 'Error desconocido';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Fallo al pagar cuota: $errorMsg'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFED0006),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: payState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Confirmar Pago', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cuotasAsync = ref.watch(cuotasListProvider(widget.prestamo.id));
    final currencyFormatterPEN = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ');
    final currencyFormatterUSD = NumberFormat.currency(locale: 'en_US', symbol: '\$ ');
    final fmt = widget.prestamo.moneda == 'PEN' ? currencyFormatterPEN : currencyFormatterUSD;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFFED0006),
        title: const Text('Detalle de Préstamo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: cuotasAsync.when(
        data: (cuotas) {
          // Obtener la siguiente cuota pendiente para el pago directo
          final cuotasPendientes = cuotas.where((c) => c.estado == 'pendiente' || c.estado == 'mora').toList();
          final siguienteCuota = cuotasPendientes.isNotEmpty ? cuotasPendientes.first : null;

          return CustomScrollView(
            slivers: [
              // Cabecera Resumen Préstamo
              SliverToBoxAdapter(
                child: Container(
                  color: const Color(0xFFED0006),
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.prestamo.tipoFormateado, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            fmt.format(widget.prestamo.saldoCapital),
                            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              'TEA ${widget.prestamo.tasaAnual.toStringAsFixed(2)}%',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text('Saldo Capital Pendiente', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ),

              // Siguiente cuota a pagar (si hay alguna)
              if (siguienteCuota != null)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                      border: Border.all(color: Colors.red.shade100, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline, color: Color(0xFFED0006)),
                            const SizedBox(width: 10),
                            const Text('Siguiente Vencimiento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6)),
                              child: Text(
                                'Vence: ${DateFormat('dd/MM/yyyy').format(siguienteCuota.fechaVenc)}',
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Monto de la Cuota', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                const SizedBox(height: 2),
                                Text(
                                  fmt.format(siguienteCuota.montoCuota),
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _showPayInstallmentSheet(context, siguienteCuota, fmt);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFED0006),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Pagar Cuota', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // Cronograma de pagos
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      const Text(
                        'Cronograma de Pagos',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const Spacer(),
                      Text(
                        '${widget.prestamo.cuotasPagadas}/${widget.prestamo.plazoMeses} Pagadas',
                        style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final c = cuotas[index];
                      return Column(
                        children: [
                          _ParcelTile(cuota: c, formatter: fmt),
                          if (index < cuotas.length - 1) const Divider(),
                        ],
                      );
                    },
                    childCount: cuotas.length,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFED0006))),
        error: (e, __) => Center(child: Text('Error al cargar cronograma: $e')),
      ),
    );
  }
}
