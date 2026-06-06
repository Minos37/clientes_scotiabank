import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/model/solicitud_model.dart';
import '../viewmodel/solicitud_viewmodel.dart';

class SolicitudesScreen extends ConsumerStatefulWidget {
  const SolicitudesScreen({super.key});

  @override
  ConsumerState<SolicitudesScreen> createState() => _SolicitudesScreenState();
}

class _SolicitudesScreenState extends ConsumerState<SolicitudesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormatter = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final solicitudesAsync = ref.watch(solicitudesProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFED0006),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Solicitudes en Línea',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: const [
            Tab(text: 'Mis Solicitudes'),
            Tab(text: 'Solicitar Producto'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // PESTAÑA 1: MIS SOLICITUDES
          solicitudesAsync.when(
            data: (solicitudes) {
              if (solicitudes.isEmpty) {
                return _buildEmptyState(
                  Icons.assignment_outlined,
                  'No tienes solicitudes activas',
                  'Aquí podrás hacer seguimiento a tus solicitudes de cuentas, tarjetas, préstamos, seguros e inversiones.',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: solicitudes.length,
                itemBuilder: (context, index) {
                  return _buildSolicitudCard(solicitudes[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFED0006))),
            error: (e, st) => Center(child: Text('Error al cargar solicitudes: $e')),
          ),

          // PESTAÑA 2: SOLICITAR PRODUCTO
          _buildProductosGrid(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
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
              child: Icon(icon, size: 64, color: const Color(0xFFED0006)),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _tabController.animateTo(1);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFED0006),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Solicitar un Producto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSolicitudCard(Solicitud solicitud) {
    final dateStr = solicitud.createdAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(solicitud.createdAt!.toLocal())
        : 'Reciente';

    // Determinar color de fondo y texto del estado principal
    Color badgeColor;
    Color badgeTextColor;
    switch (solicitud.estado) {
      case 'pendiente':
        badgeColor = Colors.orange.shade50;
        badgeTextColor = Colors.orange.shade800;
        break;
      case 'en_revision':
        badgeColor = Colors.blue.shade50;
        badgeTextColor = Colors.blue.shade800;
        break;
      case 'aprobada':
        badgeColor = Colors.green.shade50;
        badgeTextColor = Colors.green.shade800;
        break;
      case 'desembolsada':
        badgeColor = Colors.teal.shade50;
        badgeTextColor = Colors.teal.shade800;
        break;
      case 'rechazada':
        badgeColor = Colors.red.shade50;
        badgeTextColor = Colors.red.shade800;
        break;
      default:
        badgeColor = Colors.grey.shade100;
        badgeTextColor = Colors.grey.shade800;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    solicitud.productoFormateado,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    solicitud.estadoFormateado,
                    style: TextStyle(color: badgeTextColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Solicitado el $dateStr',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            const Divider(height: 24),
            
            // Datos específicos de la solicitud
            if (solicitud.datosSolicitud != null && solicitud.datosSolicitud!.isNotEmpty) ...[
              const Text(
                'Detalles de la solicitud:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 6),
              ...solicitud.datosSolicitud!.entries.map((entry) {
                final key = entry.key;
                final val = entry.value;
                String displayKey = key;
                String displayVal = val.toString();

                if (key == 'moneda') displayKey = 'Moneda';
                if (key == 'monto_mensual_estimado') {
                  displayKey = 'Monto Estimado';
                  displayVal = currencyFormatter.format(val);
                }
                if (key == 'ingreso_mensual') {
                  displayKey = 'Ingreso Mensual';
                  displayVal = currencyFormatter.format(val);
                }
                if (key == 'limite_deseado') {
                  displayKey = 'Límite Deseado';
                  displayVal = currencyFormatter.format(val);
                }
                if (key == 'monto_prestamo') {
                  displayKey = 'Monto del Préstamo';
                  displayVal = currencyFormatter.format(val);
                }
                if (key == 'plazo_meses') {
                  displayKey = 'Plazo Solicitado';
                  displayVal = '$val meses';
                }
                if (key == 'tipo_plan') displayKey = 'Plan';
                if (key == 'monto_cobertura') {
                  displayKey = 'Monto Cobertura';
                  displayVal = currencyFormatter.format(val);
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(displayKey, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      Text(displayVal, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],

            if (solicitud.comentario != null && solicitud.comentario!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Comentario del Banco:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      solicitud.comentario!,
                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Visual Stepper/Timeline
            _buildTimeline(solicitud.estado),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(String estado) {
    final states = ['pendiente', 'en_revision', 'aprobada', 'desembolsada'];
    final labels = ['Pendiente', 'Evaluación', 'Aprobado', 'Activado'];

    if (estado == 'rechazada') {
      return Row(
        children: [
          const Icon(Icons.cancel, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Esta solicitud ha sido rechazada. Comunícate con soporte para más información.',
              style: TextStyle(color: Colors.red.shade800, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          )
        ],
      );
    }

    final currentIndex = states.indexOf(estado);

    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(states.length, (index) {
            final isCompleted = index <= currentIndex;
            final isLast = index == states.length - 1;

            return Expanded(
              child: Row(
                children: [
                  // Círculo
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted ? const Color(0xFFED0006) : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        isCompleted ? Icons.check : Icons.circle,
                        color: Colors.white,
                        size: isCompleted ? 14 : 6,
                      ),
                    ),
                  ),
                  // Línea conectora
                  if (!isLast)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index < currentIndex ? const Color(0xFFED0006) : Colors.grey.shade300,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(labels.length, (index) {
            final isCurrent = index == currentIndex;
            return Expanded(
              child: Text(
                labels[index],
                textAlign: index == 0
                    ? TextAlign.left
                    : (index == labels.length - 1 ? TextAlign.right : TextAlign.center),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent ? const Color(0xFFED0006) : Colors.grey.shade600,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildProductosGrid(BuildContext context) {
    final categories = [
      _ProductCategory(
        title: 'Cuentas de Ahorro',
        icon: Icons.savings_outlined,
        items: [
          _ProductItem(
            id: 'cuenta_digital',
            name: 'Cuenta Digital',
            description: 'Sin comisiones, 100% digital e intereses atractivos.',
            icon: Icons.phonelink_ring_outlined,
          ),
          _ProductItem(
            id: 'cuenta_sueldo',
            name: 'Cuenta Sueldo',
            description: 'Recibe tu salario con múltiples beneficios y descuentos exclusivos.',
            icon: Icons.monetization_on_outlined,
          ),
          _ProductItem(
            id: 'cuenta_power',
            name: 'Cuenta Power',
            description: 'Maximiza tus ahorros con tasas súper preferenciales.',
            icon: Icons.electric_bolt_outlined,
          ),
        ],
      ),
      _ProductCategory(
        title: 'Tarjetas',
        icon: Icons.credit_card,
        items: [
          _ProductItem(
            id: 'tarjeta_credito',
            name: 'Tarjeta de Crédito',
            description: 'Acumula Scotia Puntos y disfruta de compras sin intereses.',
            icon: Icons.credit_card_outlined,
          ),
          _ProductItem(
            id: 'tarjeta_debito',
            name: 'Tarjeta de Débito',
            description: 'Paga de forma rápida y segura en millones de establecimientos.',
            icon: Icons.payment_outlined,
          ),
        ],
      ),
      _ProductCategory(
        title: 'Préstamos y Financiamiento',
        icon: Icons.handshake_outlined,
        items: [
          _ProductItem(
            id: 'prestamo_personal',
            name: 'Préstamo Personal',
            description: 'Efectivo al instante con cuotas fijas a tu medida.',
            icon: Icons.money_outlined,
          ),
          _ProductItem(
            id: 'adelanto_sueldo',
            name: 'Adelanto de Sueldo',
            description: 'Recibe liquidez antes de tu día de pago de manera ágil.',
            icon: Icons.price_check_outlined,
          ),
          _ProductItem(
            id: 'credito_vehicular',
            name: 'Crédito Vehicular',
            description: 'Financia tu auto nuevo o seminuevo con tasas bajas.',
            icon: Icons.directions_car_outlined,
          ),
          _ProductItem(
            id: 'credito_hipotecario',
            name: 'Crédito Hipotecario',
            description: 'Cumple el sueño de tu casa propia con las mejores facilidades.',
            icon: Icons.home_outlined,
          ),
        ],
      ),
      _ProductCategory(
        title: 'Seguros',
        icon: Icons.health_and_safety_outlined,
        items: [
          _ProductItem(
            id: 'seguro_oncologico',
            name: 'Seguro Oncológico',
            description: 'Protección integral y apoyo médico ante el cáncer.',
            icon: Icons.medical_services_outlined,
          ),
          _ProductItem(
            id: 'seguro_vehicular',
            name: 'Seguro Vehicular',
            description: 'Cobertura completa contra choques, robos y asistencia en ruta.',
            icon: Icons.car_repair_outlined,
          ),
          _ProductItem(
            id: 'seguro_hogar',
            name: 'Seguro de Hogar',
            description: 'Protege tu vivienda y su contenido frente a robos o sismos.',
            icon: Icons.house_outlined,
          ),
        ],
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, catIndex) {
        final category = categories[catIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
              child: Row(
                children: [
                  Icon(category.icon, color: const Color(0xFFED0006)),
                  const SizedBox(width: 8),
                  Text(
                    category.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
            ),
            ...category.items.map((item) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFED0006).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, color: const Color(0xFFED0006)),
                  ),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item.description, style: const TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    _showApplicationForm(context, item);
                  },
                ),
              );
            }).toList(),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  void _showApplicationForm(BuildContext context, _ProductItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ApplicationFormSheet(item: item);
      },
    ).then((success) {
      if (success == true) {
        // Regresar a la primera pestaña de mis solicitudes
        _tabController.animateTo(0);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Solicitud enviada con éxito! Está en evaluación.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }
}

class _ProductCategory {
  final String title;
  final IconData icon;
  final List<_ProductItem> items;

  _ProductCategory({required this.title, required this.icon, required this.items});
}

class _ProductItem {
  final String id;
  final String name;
  final String description;
  final IconData icon;

  _ProductItem({required this.id, required this.name, required this.description, required this.icon});
}

class _ApplicationFormSheet extends ConsumerStatefulWidget {
  final _ProductItem item;

  const _ApplicationFormSheet({required this.item});

  @override
  ConsumerState<_ApplicationFormSheet> createState() => _ApplicationFormSheetState();
}

class _ApplicationFormSheetState extends ConsumerState<_ApplicationFormSheet> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores dinámicos
  String _selectedMoneda = 'PEN';
  final _estimadoController = TextEditingController();
  final _plazoController = TextEditingController(text: '12');
  final _planController = TextEditingController(text: 'Plan Clásico');
  
  @override
  void dispose() {
    _estimadoController.dispose();
    _plazoController.dispose();
    _planController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> datos = {};

      if (widget.item.id.contains('cuenta')) {
        datos = {
          'moneda': _selectedMoneda,
          'monto_mensual_estimado': double.tryParse(_estimadoController.text) ?? 1000.0,
        };
      } else if (widget.item.id == 'tarjeta_credito') {
        datos = {
          'ingreso_mensual': double.tryParse(_estimadoController.text) ?? 3000.0,
          'limite_deseado': (double.tryParse(_estimadoController.text) ?? 3000.0) * 1.5,
        };
      } else if (widget.item.id == 'tarjeta_debito') {
        datos = {
          'moneda': _selectedMoneda,
        };
      } else if (widget.item.id.contains('prestamo') || widget.item.id.contains('credito') || widget.item.id == 'adelanto_sueldo') {
        datos = {
          'monto_prestamo': double.tryParse(_estimadoController.text) ?? 5000.0,
          'plazo_meses': int.tryParse(_plazoController.text) ?? 12,
        };
      } else if (widget.item.id.contains('seguro')) {
        datos = {
          'tipo_plan': _planController.text,
          'monto_cobertura': double.tryParse(_estimadoController.text) ?? 50000.0,
        };
      }

      final res = await ref.read(solicitudNotifierProvider.notifier).crearSolicitud(
        producto: widget.item.id,
        datosSolicitud: datos,
      );

      if (res && mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(solicitudNotifierProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(widget.item.icon, color: const Color(0xFFED0006), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Solicitud de ${widget.item.name}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.item.description,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const Divider(height: 32),
              
              if (status.error != null) ...[
                Text(
                  status.error!,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
              ],

              // FORMULARIO DINÁMICO SEGÚN TIPO DE PRODUCTO
              if (widget.item.id.contains('cuenta') || widget.item.id == 'tarjeta_debito') ...[
                const Text('Moneda de la Cuenta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedMoneda,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'PEN', child: Text('Soles (S/)')),
                    DropdownMenuItem(value: 'USD', child: Text('Dólares (US\$)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedMoneda = val;
                      });
                    }
                  },
                ),
                if (widget.item.id != 'tarjeta_debito') ...[
                  const SizedBox(height: 16),
                  const Text('Monto de depósitos mensuales estimado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _estimadoController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Ej. 2500',
                      prefixText: _selectedMoneda == 'PEN' ? 'S/ ' : '\$ ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Este campo es obligatorio';
                      if (double.tryParse(val) == null) return 'Ingresa un monto válido';
                      return null;
                    },
                  ),
                ],
              ] 
              else if (widget.item.id == 'tarjeta_credito') ...[
                const Text('Ingresos Netos Mensuales', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _estimadoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Ej. 3500',
                    prefixText: 'S/ ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Por favor, ingresa tu ingreso mensual';
                    if (double.tryParse(val) == null) return 'Ingresa un monto válido';
                    if (double.parse(val) < 1000) return 'El ingreso mínimo para calificar es S/ 1,000';
                    return null;
                  },
                ),
              ] 
              else if (widget.item.id.contains('prestamo') || widget.item.id.contains('credito') || widget.item.id == 'adelanto_sueldo') ...[
                const Text('Monto del Préstamo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _estimadoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Ej. 10000',
                    prefixText: 'S/ ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Ingresa el monto solicitado';
                    final v = double.tryParse(val);
                    if (v == null) return 'Ingresa un monto válido';
                    if (v < 500) return 'El monto mínimo es S/ 500';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Plazo de devolución (meses)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _plazoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Ej. 12',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Ingresa el número de meses';
                    final v = int.tryParse(val);
                    if (v == null) return 'Ingresa un plazo válido';
                    if (v < 3 || v > 72) return 'El plazo debe ser de 3 a 72 meses';
                    return null;
                  },
                ),
              ] 
              else if (widget.item.id.contains('seguro')) ...[
                const Text('Tipo de Plan de Seguro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _planController.text,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Plan Clásico', child: Text('Clásico - Cobertura Base')),
                    DropdownMenuItem(value: 'Plan Gold', child: Text('Gold - Cobertura Intermedia')),
                    DropdownMenuItem(value: 'Plan Platinum', child: Text('Platinum - Cobertura Total')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      _planController.text = val;
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Monto de Cobertura Deseado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _estimadoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Ej. 50000',
                    prefixText: 'S/ ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Ingresa el monto de cobertura';
                    if (double.tryParse(val) == null) return 'Ingresa un número válido';
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 32),
              
              // Botón de Envío
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: status.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFED0006),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: status.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Enviar Solicitud',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
