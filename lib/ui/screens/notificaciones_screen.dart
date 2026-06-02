import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../viewmodel/notificacion_viewmodel.dart';

class NotificacionesScreen extends ConsumerWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificacionesAsync = ref.watch(notificacionesStreamProvider);
    final countNoLeidas = ref.watch(notificacionesNoLeidasCountProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFED0006),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Notificaciones',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          if (countNoLeidas > 0)
            TextButton(
              onPressed: () {
                ref.read(notificacionNotifierProvider.notifier).marcarTodasComoLeidas();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Todas las notificaciones marcadas como leídas')),
                );
              },
              child: const Text(
                'Marcar leídas',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
        ],
      ),
      body: notificacionesAsync.when(
        data: (notificaciones) {
          if (notificaciones.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notificaciones.length,
            itemBuilder: (context, index) {
              final n = notificaciones[index];
              return _buildNotificationCard(context, ref, n);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFED0006)),
        ),
        error: (e, st) => Center(
          child: Text('Error al cargar notificaciones: $e'),
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
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 64,
                color: Color(0xFFED0006),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '¡Estás al día!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'No tienes notificaciones pendientes en este momento.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, WidgetRef ref, dynamic n) {
    final bool leida = n.leida;
    final DateTime fecha = n.fecha;
    final String fechaFormateada = DateFormat('dd/MM/yyyy hh:mm a').format(fecha);

    IconData icon;
    Color iconColor;
    Color bgIconColor;

    switch (n.tipo) {
      case 'pago_vencido':
        icon = Icons.warning_amber;
        iconColor = Colors.red.shade700;
        bgIconColor = Colors.red.shade50;
        break;
      case 'cuota_proxima':
        icon = Icons.calendar_month;
        iconColor = Colors.amber.shade800;
        bgIconColor = Colors.amber.shade50;
        break;
      case 'movimiento':
        icon = Icons.swap_horiz;
        iconColor = Colors.blue.shade700;
        bgIconColor = Colors.blue.shade50;
        break;
      case 'oferta':
        icon = Icons.local_offer;
        iconColor = Colors.green.shade700;
        bgIconColor = Colors.green.shade50;
        break;
      case 'seguridad':
        icon = Icons.security;
        iconColor = Colors.purple.shade700;
        bgIconColor = Colors.purple.shade50;
        break;
      case 'aprobacion':
        icon = Icons.check_circle_outline;
        iconColor = Colors.teal.shade700;
        bgIconColor = Colors.teal.shade50;
        break;
      case 'rechazo':
        icon = Icons.error_outline;
        iconColor = Colors.deepOrange.shade700;
        bgIconColor = Colors.deepOrange.shade50;
        break;
      default:
        icon = Icons.notifications_none;
        iconColor = Colors.grey.shade700;
        bgIconColor = Colors.grey.shade100;
    }

    return Dismissible(
      key: Key(n.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(notificacionNotifierProvider.notifier).marcarComoLeida(n.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.archive_outlined, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: leida ? Colors.white : const Color(0xFFFDECEE), // Tono rojo muy suave si no está leída
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: leida ? Colors.grey.shade200 : const Color(0xFFFCD3D7),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            if (!leida) {
              ref.read(notificacionNotifierProvider.notifier).marcarComoLeida(n.id);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono tipo
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: bgIconColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                // Contenido
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              n.titulo,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: leida ? FontWeight.w600 : FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (!leida)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFED0006),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        n.mensaje,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: leida ? Colors.grey.shade700 : Colors.black87,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        fechaFormateada,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
