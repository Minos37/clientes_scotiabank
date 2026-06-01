import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/prestamo_viewmodel.dart';
import 'package:intl/intl.dart';

class PrestamosScreen extends ConsumerWidget {
  const PrestamosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prestamosAsync = ref.watch(prestamosListProvider);
    final currencyFormatterPEN = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ');
    final currencyFormatterUSD = NumberFormat.currency(locale: 'en_US', symbol: '\$ ');

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFFED0006),
        title: const Text('Mis Préstamos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: prestamosAsync.when(
        data: (prestamos) {
          if (prestamos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                    child: const Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  const Text('No tienes préstamos vigentes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      'Cuando solicites un préstamo personal o vehicular, aparecerá listado aquí.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: prestamos.length,
            itemBuilder: (context, index) {
              final p = prestamos[index];
              final fmt = p.moneda == 'PEN' ? currencyFormatterPEN : currencyFormatterUSD;
              
              // Calcular progreso del préstamo
              final pctPagado = p.plazoMeses > 0 ? (p.cuotasPagadas / p.plazoMeses) : 0.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    context.push('/prestamo-detalle', extra: p);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFED0006).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                p.tipoFormateado,
                                style: const TextStyle(color: Color(0xFFED0006), fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: p.estado == 'activo'
                                    ? Colors.green.shade50
                                    : p.estado == 'mora'
                                        ? Colors.red.shade50
                                        : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                p.estado.toUpperCase(),
                                style: TextStyle(
                                  color: p.estado == 'activo'
                                      ? Colors.green
                                      : p.estado == 'mora'
                                          ? Colors.red
                                          : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Saldo de Capital Pendiente', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          fmt.format(p.saldoCapital),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Monto Otorgado', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                const SizedBox(height: 2),
                                Text(fmt.format(p.monto), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Cuota Mensual', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                const SizedBox(height: 2),
                                Text(fmt.format(p.cuotaMensual), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFED0006))),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Cuotas: ${p.cuotasPagadas} de ${p.plazoMeses} pagadas', style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
                            Text('${(pctPagado * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pctPagado,
                            color: Colors.green,
                            backgroundColor: Colors.grey.shade100,
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFED0006))),
        error: (e, __) => Center(child: Text('Error al cargar préstamos: $e')),
      ),
    );
  }
}
