import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/auth_viewmodel.dart';

class MasScreen extends ConsumerWidget {
  const MasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;
    
    final displayName = user?.nombre ?? user?.email.split('@')[0] ?? 'Cliente';
    final displayEmail = user?.email ?? '';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFED0006),
        title: const Text(
          'Más Opciones',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tarjeta de Perfil
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFFDE6E6),
                  child: Icon(Icons.person, color: Color(0xFFED0006), size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      Text(
                        displayEmail,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          _buildMenuSection('Productos y Créditos', [
            _buildMenuItem(context, Icons.account_balance_wallet_outlined, 'Mis Préstamos', () => context.push('/prestamos')),
            _buildMenuItem(context, Icons.savings_outlined, 'Ahorro Programado y Metas', () => context.push('/ahorro')),
            _buildMenuItem(context, Icons.shield_outlined, 'Mis Seguros', () => context.push('/seguros')),
            _buildMenuItem(context, Icons.analytics_outlined, 'Mis Inversiones', () => context.push('/inversiones')),
            _buildMenuItem(context, Icons.stars_outlined, 'Mis Scotia Puntos', () => context.push('/puntos')),
            _buildMenuItem(context, Icons.receipt_long_outlined, 'Meses Sin Intereses (MSI)', () => context.push('/msi')),
          ]),
          
          const SizedBox(height: 24),
          
          _buildMenuSection('Ajustes y Preferencias', [
            _buildMenuItem(context, Icons.person_outline, 'Mi Perfil', () => context.push('/perfil')),
            _buildMenuItem(context, Icons.security, 'Seguridad y Contraseña', () => _showPronto(context)),
            _buildMenuItem(context, Icons.notifications_none, 'Configurar Notificaciones', () => _showPronto(context)),
          ]),
          
          const SizedBox(height: 24),
          
          _buildMenuSection('Soporte', [
            _buildMenuItem(context, Icons.help_outline, 'Centro de Ayuda', () => _showPronto(context)),
            _buildMenuItem(context, Icons.contact_support_outlined, 'Contactar al Banco', () => _showPronto(context)),
            _buildMenuItem(context, Icons.info_outline, 'Acerca de la app', () => _showPronto(context)),
          ]),
          
          const SizedBox(height: 32),
          
          // Botón Real de Cerrar Sesión
          ElevatedButton.icon(
            onPressed: () {
              ref.read(authViewModelProvider.notifier).logout();
              // El GoRouter automáticamente redirigirá al Login debido al authState changes
            },
            icon: const Icon(Icons.logout, color: Color(0xFFED0006)),
            label: const Text('Cerrar Sesión', style: TextStyle(color: Color(0xFFED0006), fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Índice de "Más"
        selectedItemColor: const Color(0xFFED0006),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) context.go('/home');
          if (index == 1) context.go('/tarjetas');
          if (index == 2) context.go('/operaciones');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'Tarjetas'),
          BottomNavigationBarItem(icon: Icon(Icons.compare_arrows), label: 'Operaciones'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Más'),
        ],
      ),
    );
  }

  void _showPronto(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Esta opción se implementará en próximos Sprints')),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
      trailing: const Icon(Icons.chevron_right, color: Colors.black26),
      onTap: onTap,
    );
  }
}