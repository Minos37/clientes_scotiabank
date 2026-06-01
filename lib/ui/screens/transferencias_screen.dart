import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TransferenciasScreen extends StatelessWidget {
  const TransferenciasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFFED0006),
        title: const Text(
          'Transferencias',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 20, top: 8),
              child: Text(
                '¿A quién deseas transferir?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            
            _buildTransferOption(
              context,
              title: 'Entre mis cuentas',
              subtitle: 'Transfiere dinero entre tus propias cuentas Scotiabank',
              icon: Icons.sync_alt,
              onTap: () {
                context.push('/formulario-transferencia?tipo=propias');
              },
            ),
            const SizedBox(height: 16),
            
            _buildTransferOption(
              context,
              title: 'A terceros Scotiabank',
              subtitle: 'Cuentas de otras personas dentro de Scotiabank',
              icon: Icons.account_balance,
              onTap: () {
                context.push('/formulario-transferencia?tipo=terceros');
              },
            ),
            const SizedBox(height: 16),
            
            _buildTransferOption(
              context,
              title: 'A otros bancos',
              subtitle: 'Transferencias interbancarias inmediatas o diferidas',
              icon: Icons.domain,
              onTap: () {
                context.push('/formulario-transferencia?tipo=interbancario');
              },
            ),
            const SizedBox(height: 16),

            _buildTransferOption(
              context,
              title: 'A mis tarjetas',
              subtitle: 'Paga tus tarjetas de crédito Scotiabank',
              icon: Icons.credit_card,
              onTap: () {
                // TODO: Navegar a pago de tarjeta
                _showComingSoon(context);
              },
            ),
            const SizedBox(height: 16),

            _buildTransferOption(
              context,
              title: 'A un contacto (Plin / Yape)',
              subtitle: 'Envía dinero usando solo el número de celular',
              icon: Icons.phone_android,
              onTap: () {
                _showComingSoon(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para cada tarjeta de opción
  Widget _buildTransferOption(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFED0006).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFFED0006), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.black26),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Simulación temporal para las rutas no implementadas
  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formulario en desarrollo.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
      ),
    );
  }
}