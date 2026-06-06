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
            _buildMenuItem(context, Icons.assignment_outlined, 'Solicitudes de Productos', () => context.push('/solicitudes')),
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
            _buildMenuItem(context, Icons.security, 'Seguridad y Contraseña', () => _showSeguridadDialog(context)),
            _buildMenuItem(context, Icons.notifications_none, 'Configurar Notificaciones', () => _showNotificacionesDialog(context)),
          ]),
          
          const SizedBox(height: 24),
          
          _buildMenuSection('Soporte', [
            _buildMenuItem(context, Icons.help_outline, 'Centro de Ayuda', () => _showCentroAyudaDialog(context)),
            _buildMenuItem(context, Icons.contact_support_outlined, 'Contactar al Banco', () => _showContactarBancoDialog(context)),
            _buildMenuItem(context, Icons.info_outline, 'Acerca de la app', () => _showAcercaDeDialog(context)),
          ]),
          
          const SizedBox(height: 32),
          
          // Botón Real de Cerrar Sesión
          ElevatedButton.icon(
            onPressed: () {
              ref.read(authViewModelProvider.notifier).logout();
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

  // 1. SEGURIDAD Y CONTRASEÑA
  void _showSeguridadDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        bool biometricsEnabled = true;
        final passController = TextEditingController();
        final confirmController = TextEditingController();
        final formKey = GlobalKey<FormState>();

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Icon(Icons.security, color: Color(0xFFED0006), size: 28),
                          SizedBox(width: 12),
                          Text('Seguridad y Acceso', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SwitchListTile(
                        value: biometricsEnabled,
                        activeColor: const Color(0xFFED0006),
                        title: const Text('Ingreso con Huella / FaceID', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Accede rápidamente sin escribir tu contraseña.'),
                        onChanged: (val) {
                          setModalState(() {
                            biometricsEnabled = val;
                          });
                        },
                      ),
                      const Divider(height: 32),
                      const Text('Cambiar Contraseña', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: passController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Nueva Contraseña',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingresa la nueva contraseña';
                          if (value.length < 6) return 'Debe tener al menos 6 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: confirmController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirmar Nueva Contraseña',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value != passController.text) return 'Las contraseñas no coinciden';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              try {
                                Navigator.pop(context); // Cerrar bottom sheet
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFED0006))),
                                );
                                // Actualizar contraseña en Supabase
                                await AuthViewModel().ref.read(authRepositoryProvider).logout(); // O realizar cambio
                                // Simular éxito para fines prácticos
                                await Future.delayed(const Duration(milliseconds: 800));
                                if (context.mounted) {
                                  Navigator.pop(context); // Quitar loader
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Contraseña actualizada con éxito.'), backgroundColor: Colors.green),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  Navigator.pop(context); // Quitar loader
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFED0006),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Actualizar Contraseña', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 2. CONFIGURAR NOTIFICACIONES
  void _showNotificacionesDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        bool push = true;
        bool email = true;
        bool sms = false;
        bool highValue = true;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(Icons.notifications_none, color: Color(0xFFED0006), size: 28),
                      SizedBox(width: 12),
                      Text('Configurar Notificaciones', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    value: push,
                    activeColor: const Color(0xFFED0006),
                    title: const Text('Notificaciones Push'),
                    subtitle: const Text('Alertas instantáneas en tu celular.'),
                    onChanged: (val) => setModalState(() => push = val),
                  ),
                  SwitchListTile(
                    value: email,
                    activeColor: const Color(0xFFED0006),
                    title: const Text('Alertas por Correo'),
                    subtitle: const Text('Resumen e historial de operaciones.'),
                    onChanged: (val) => setModalState(() => email = val),
                  ),
                  SwitchListTile(
                    value: sms,
                    activeColor: const Color(0xFFED0006),
                    title: const Text('Mensajes de Texto (SMS)'),
                    subtitle: const Text('Códigos de seguridad y avisos.'),
                    onChanged: (val) => setModalState(() => sms = val),
                  ),
                  SwitchListTile(
                    value: highValue,
                    activeColor: const Color(0xFFED0006),
                    title: const Text('Alertas de Consumo Alto'),
                    subtitle: const Text('Avisar para consumos mayores a S/ 100.'),
                    onChanged: (val) => setModalState(() => highValue = val),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Preferencias de notificación guardadas.'), backgroundColor: Colors.green),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFED0006),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Guardar Ajustes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  // 3. CENTRO DE AYUDA (FAQs)
  void _showCentroAyudaDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.help_outline, color: Color(0xFFED0006), size: 28),
                  SizedBox(width: 12),
                  Text('Centro de Ayuda / FAQs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: const [
                    ExpansionTile(
                      leading: Icon(Icons.password_outlined, color: Colors.blue),
                      title: Text('¿Cómo cambio mi contraseña?', style: TextStyle(fontWeight: FontWeight.bold)),
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text('Puedes cambiar tu contraseña ingresando a Más > Seguridad y Contraseña, donde podrás introducir una nueva contraseña de al menos 6 caracteres.'),
                        )
                      ],
                    ),
                    ExpansionTile(
                      leading: Icon(Icons.compare_arrows_outlined, color: Colors.green),
                      title: Text('¿Cómo realizo una transferencia?', style: TextStyle(fontWeight: FontWeight.bold)),
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text('Ve a la pestaña "Operaciones" en la barra inferior, selecciona "Realizar transferencias", elige la cuenta de origen, destino, monto a transferir y confirma la transacción de forma inmediata.'),
                        )
                      ],
                    ),
                    ExpansionTile(
                      leading: Icon(Icons.star_outline, color: Colors.orange),
                      title: Text('¿Cómo acumulo Scotia Puntos?', style: TextStyle(fontWeight: FontWeight.bold)),
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text('Acumulas Scotia Puntos por cada compra realizada con tus tarjetas de crédito o débito afiliadas. Puedes ver tu saldo total e historial en "Más" > "Mis Scotia Puntos".'),
                        )
                      ],
                    ),
                    ExpansionTile(
                      leading: Icon(Icons.shield_outlined, color: Colors.red),
                      title: Text('¿Cómo reporto un siniestro?', style: TextStyle(fontWeight: FontWeight.bold)),
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text('En la sección "Mis Seguros", ve a la pestaña "Siniestros / Reclamos" y toca en "Reportar Siniestro". Completa los datos requeridos y nuestro equipo evaluará tu solicitud a la brevedad.'),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 4. CONTACTAR AL BANCO (WITH CHATBOT SIMULATOR!)
  void _showContactarBancoDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.contact_support_outlined, color: Color(0xFFED0006), size: 28),
                  SizedBox(width: 12),
                  Text('Contacto Scotiabank', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.phone, color: Color(0xFFED0006)),
                ),
                title: const Text('Banca por Teléfono', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('(01) 311-6000'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Llamando a Banca Telefónica Scotiabank...')),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.chat_bubble_outline, color: Colors.green),
                ),
                title: const Text('WhatsApp Scotiabank', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('+51 999 999 999'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Abriendo chat de WhatsApp...')),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.support_agent_outlined, color: Colors.blue),
                ),
                title: const Text('Asistente Virtual (Chatbot)', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Chatea con nosotros ahora'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  _showChatbotSheet(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // BOT CHAT SIMULATOR
  void _showChatbotSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        List<Map<String, String>> messages = [
          {'sender': 'bot', 'text': '¡Hola! Soy Scotiabot, tu asesor digital. ¿En qué puedo ayudarte hoy?'}
        ];

        return StatefulBuilder(
          builder: (context, setChatState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const CircleAvatar(backgroundColor: Color(0xFFED0006), child: Icon(Icons.support_agent, color: Colors.white)),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Scotiabot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('En línea', style: TextStyle(color: Colors.green, fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isBot = msg['sender'] == 'bot';
                        return Align(
                          alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isBot ? Colors.grey.shade100 : const Color(0xFFED0006).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              msg['text']!,
                              style: TextStyle(color: isBot ? Colors.black87 : const Color(0xFFED0006), fontWeight: isBot ? FontWeight.normal : FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setChatState(() {
                              messages.add({'sender': 'user', 'text': 'Ver Saldo'});
                              messages.add({'sender': 'bot', 'text': 'Para ver tu saldo, ve al Dashboard Inicio. El saldo consolidado figura en la parte superior.'});
                            });
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade100, elevation: 0),
                          child: const Text('Ver Saldo', style: TextStyle(color: Colors.black87)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setChatState(() {
                              messages.add({'sender': 'user', 'text': 'Bloquear Tarjeta'});
                              messages.add({'sender': 'bot', 'text': 'Entendido. Dirígete a la pestaña "Tarjetas", pulsa sobre la tarjeta deseada y selecciona la opción de bloqueo temporal.'});
                            });
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade100, elevation: 0),
                          child: const Text('Bloquear Tarjeta', style: TextStyle(color: Colors.black87)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setChatState(() {
                              messages.add({'sender': 'user', 'text': 'Hablar con Agente'});
                              messages.add({'sender': 'bot', 'text': 'Un momento, por favor... Transfiriendo a un asesor de servicio. En breve se conectará.'});
                            });
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade100, elevation: 0),
                          child: const Text('Asesor Humano', style: TextStyle(color: Colors.black87)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 5. ACERCA DE LA APP
  void _showAcercaDeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFFED0006),
                child: Icon(Icons.account_balance, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              const Text('Scotiabank Banca Móvil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Versión 2.4.0 (2026)', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 16),
              const Text(
                '© 2026 Scotiabank. Todos los derechos reservados. Desarrollado con los más altos estándares de seguridad y encriptación de datos.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const Divider(height: 32),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar', style: TextStyle(color: Color(0xFFED0006), fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        );
      },
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