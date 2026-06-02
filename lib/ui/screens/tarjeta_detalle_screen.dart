import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../data/model/tarjeta_model.dart';
import '../viewmodel/cuenta_viewmodel.dart';
import '../viewmodel/transaccion_viewmodel.dart';

class TarjetaDetalleScreen extends ConsumerWidget {
  final Tarjeta tarjeta;

  const TarjetaDetalleScreen({super.key, required this.tarjeta});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCredito = tarjeta.tipo == 'credito';
    final currencyFormatter = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ');
    final logoImage = tarjeta.marca.toLowerCase() == 'visa' ? 'Visa' : tarjeta.marca;

    // 1. Buscamos la cuenta asociada en tiempo real
    final cuentasAsync = ref.watch(cuentasProvider);
    String numeroCuentaStr = 'Cargando...';
    cuentasAsync.whenData((cuentas) {
      try {
        final cuenta = cuentas.firstWhere((c) => (c as dynamic).id == tarjeta.cuentaId);
        final numCta = (cuenta as dynamic).numeroCuenta.toString();
        numeroCuentaStr = '•••• ${numCta.length >= 4 ? numCta.substring(numCta.length - 4) : numCta}';
      } catch (_) {
        numeroCuentaStr = 'No asociada';
      }
    });

    // 2. Traemos todas las transacciones para luego filtrarlas abajo
    final transaccionesAsync = ref.watch(todasTransaccionesProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFED0006),
        title: Text(
          tarjeta.tipoFormateado,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Representación visual de la Tarjeta (Consistente con tarjetas_screen)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isCredito 
                    ? [const Color(0xFF1E1E1E), const Color(0xFF3A3A3A)] // Negro para crédito
                    : [const Color(0xFFED0006), const Color(0xFFB70005)], // Rojo para débito
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isCredito ? Colors.black26 : Colors.red.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tarjeta.tipoFormateado,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        logoImage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    tarjeta.numeroEnmascarado,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Vencimiento', style: TextStyle(color: Colors.white54, fontSize: 10)),
                          Text(
                            DateFormat('MM/yy').format(tarjeta.fechaVencimiento),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                      const Icon(Icons.contactless, color: Colors.white70, size: 28),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Resumen Financiero
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen de la Tarjeta',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInfoRow('Cuenta Asociada', numeroCuentaStr, icon: Icons.account_balance_wallet, iconColor: Colors.blueGrey),
                  const Divider(height: 24),

                  if (isCredito) ...[
                    _buildInfoRow('Línea de crédito', tarjeta.lineaCredito != null ? currencyFormatter.format(tarjeta.lineaCredito) : 'S/ 0.00'),
                    const Divider(height: 24),
                    _buildInfoRow(
                      'Saldo disponible', 
                      tarjeta.saldoDisponible != null ? currencyFormatter.format(tarjeta.saldoDisponible) : 'S/ 0.00',
                      isHighlight: true,
                    ),
                    const Divider(height: 24),
                  ],
                  
                  if (!isCredito && tarjeta.saldoDisponible != null) ...[
                    _buildInfoRow('Saldo Disponible', currencyFormatter.format(tarjeta.saldoDisponible), isHighlight: true),
                    const Divider(height: 24),
                  ],
                  
                  _buildInfoRow('Scotia Puntos', '${tarjeta.puntosAcumulados} pts', icon: Icons.star_rounded, iconColor: Colors.amber),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Opciones de Acción
            _buildActionItem(context, Icons.list_alt, 'Ver Movimientos', () {
              context.push('/movimientos');
            }),
            const SizedBox(height: 12),
            if (isCredito) ...[
              _buildActionItem(context, Icons.stars, 'Ver mis Scotia Puntos', () {
                context.push('/puntos');
              }),
              const SizedBox(height: 12),
              _buildActionItem(context, Icons.receipt_long, 'Meses Sin Intereses (MSI)', () {
                context.push('/msi');
              }),
              const SizedBox(height: 12),
              _buildActionItem(context, Icons.payment, 'Pagar Tarjeta', () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad "Pagar Tarjeta" próximamente')),
                );
              }),
            ],

            const SizedBox(height: 32),
            const Text(
              'Movimientos Recientes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            
            // 3. Renderizamos las transacciones filtradas por la cuenta vinculada
            transaccionesAsync.when(
              data: (todas) {
                // Filtramos las transacciones que pertenezcan a la cuenta de esta tarjeta
                final txs = todas.where((t) => (t as dynamic).cuentaId == tarjeta.cuentaId).toList();
                
                if (txs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text('No hay movimientos recientes.', style: TextStyle(color: Colors.black54)),
                    ),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: txs.take(5).map((t) {
                      final isIncome = (t as dynamic).tipo == 'credito';
                      return Column(
                        children: [
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isIncome ? Colors.green.shade50 : Colors.red.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                color: isIncome ? Colors.green : Colors.red,
                                size: 20,
                              ),
                            ),
                            title: Text((t as dynamic).descripcion, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text(DateFormat('dd MMM yyyy').format((t as dynamic).fecha), style: const TextStyle(fontSize: 12)),
                            trailing: Text(
                              '${isIncome ? '+' : '-'}${currencyFormatter.format((t as dynamic).monto.abs())}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isIncome ? Colors.green : Colors.black87,
                              ),
                            ),
                          ),
                          if (t != txs.take(5).last) const Divider(height: 1, indent: 16, endIndent: 16),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFED0006))),
              error: (e, st) => Center(child: Text('Error al cargar movimientos: $e')),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para las filas de resumen
  Widget _buildInfoRow(String label, String value, {bool isHighlight = false, IconData? icon, Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          Row(
            children: [
              if (icon != null) ...[Icon(icon, color: iconColor, size: 18), const SizedBox(width: 4)],
              Text(
                value,
                style: TextStyle(
                  fontSize: isHighlight ? 18 : 14,
                  fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
                  color: isHighlight ? const Color(0xFFED0006) : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para los botones de acción
  Widget _buildActionItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFED0006).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFED0006)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: Colors.black26),
        onTap: onTap,
      ),
    );
  }
}