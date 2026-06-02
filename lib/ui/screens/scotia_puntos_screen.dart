import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/model/tarjeta_model.dart';
import '../viewmodel/scotia_puntos_viewmodel.dart';
import '../viewmodel/tarjeta_viewmodel.dart';

class ScotiaPuntosScreen extends ConsumerStatefulWidget {
  const ScotiaPuntosScreen({super.key});

  @override
  ConsumerState<ScotiaPuntosScreen> createState() => _ScotiaPuntosScreenState();
}

class _ScotiaPuntosScreenState extends ConsumerState<ScotiaPuntosScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  // Catálogo de premios estáticos para canje
  final List<Map<String, dynamic>> _catalog = [
    {
      'id': 'gf_falabella_50',
      'title': 'Gift Card Falabella S/ 50',
      'points': 800,
      'category': 'Tiendas por Departamento',
      'icon': Icons.card_giftcard,
      'color': Colors.green,
    },
    {
      'id': 'gf_cencosud_100',
      'title': 'Gift Card Cencosud S/ 100',
      'points': 1500,
      'category': 'Supermercados',
      'icon': Icons.shopping_bag_outlined,
      'color': Colors.blue,
    },
    {
      'id': 'cashback_200',
      'title': 'Cashback S/ 200 en Cuenta',
      'points': 3000,
      'category': 'Efectivo',
      'icon': Icons.monetization_on_outlined,
      'color': Colors.teal,
    },
    {
      'id': 'desc_luz_30',
      'title': 'Descuento S/ 30 en Servicios',
      'points': 500,
      'category': 'Servicios',
      'icon': Icons.lightbulb_outline,
      'color': Colors.amber,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final puntosTotalesAsync = ref.watch(puntosTotalesProvider);
    final movimientosAsync = ref.watch(movimientosPuntosProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFED0006),
        title: const Text(
          'Scotia Puntos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Mi Historial'),
            Tab(text: 'Canjear Premios'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pestaña 1: Mi Historial
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(movimientosPuntosProvider);
              ref.invalidate(puntosTotalesProvider);
            },
            color: const Color(0xFFED0006),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tarjeta Balance de Puntos
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E1E1E), Color(0xFF3E3E3E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.stars_rounded, color: Colors.amber, size: 56),
                        const SizedBox(height: 12),
                        const Text(
                          'PUNTOS ACUMULADOS',
                          style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1),
                        ),
                        const SizedBox(height: 8),
                        puntosTotalesAsync.when(
                          data: (total) => Text(
                            '$total pts',
                            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                          ),
                          loading: () => const SizedBox(
                            height: 44,
                            width: 44,
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                          error: (e, _) => const Text(
                            '--',
                            style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '¡Usa tus Scotia Puntos para canjear gift cards, servicios o cashback!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Historial de Movimientos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  // Lista de movimientos
                  movimientosAsync.when(
                    data: (movimientos) {
                      if (movimientos.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          alignment: Alignment.center,
                          child: const Text(
                            'No tienes movimientos de puntos registrados.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        );
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: movimientos.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final mov = movimientos[index];
                            final isAcumula = mov.tipoMovimiento == 'acumulacion';
                            final isCanje = mov.tipoMovimiento == 'canje';

                            IconData icon;
                            Color iconBg;
                            Color iconColor;
                            String ptsPrefix;
                            Color ptsColor;

                            if (isAcumula) {
                              icon = Icons.add_circle_outline;
                              iconBg = Colors.green.shade50;
                              iconColor = Colors.green;
                              ptsPrefix = '+';
                              ptsColor = Colors.green;
                            } else if (isCanje) {
                              icon = Icons.card_giftcard_outlined;
                              iconBg = Colors.red.shade50;
                              iconColor = Colors.red;
                              ptsPrefix = '';
                              ptsColor = Colors.red;
                            } else {
                              icon = Icons.event_busy_outlined;
                              iconBg = Colors.grey.shade100;
                              iconColor = Colors.grey;
                              ptsPrefix = '';
                              ptsColor = Colors.grey;
                            }

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: iconBg,
                                child: Icon(icon, color: iconColor),
                              ),
                              title: Text(
                                mov.descripcion ?? 'Movimiento de Puntos',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              subtitle: Text(
                                DateFormat('dd MMM yyyy, hh:mm a').format(mov.fecha),
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                              trailing: Text(
                                '$ptsPrefix${mov.puntos} pts',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ptsColor,
                                  fontSize: 15,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFFED0006))),
                    ),
                    error: (e, st) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text('Error al cargar movimientos: $e')),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Pestaña 2: Catálogo de Premios
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Elige tu beneficio',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Text(
                  'Canjea de inmediato tus puntos acumulados por cualquiera de estos premios.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _catalog.length,
                  itemBuilder: (context, index) {
                    final item = _catalog[index];
                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: InkWell(
                        onTap: () => _openRedeemDialog(context, item),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (item['color'] as Color).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: item['color'] as Color,
                                  size: 28,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                item['category'] as String,
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['title'] as String,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.stars_rounded, color: Colors.amber, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${item['points']} pts',
                                      style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openRedeemDialog(BuildContext context, Map<String, dynamic> item) {
    // Verificar si el usuario tiene tarjetas de crédito con puntos suficientes
    final tarjetasAsync = ref.read(tarjetasProvider);
    final int itemPointsRequired = item['points'] as int;

    tarjetasAsync.when(
      data: (tarjetas) {
        final creditCards = tarjetas.where((t) => t.tipo == 'credito' && t.activa).toList();

        if (creditCards.isEmpty) {
          _showErrorSnackBar(context, 'No tienes tarjetas de crédito activas para realizar el canje.');
          return;
        }

        // Mostrar BottomSheet de Canje
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) {
            return _RedeemBottomSheet(
              item: item,
              creditCards: creditCards,
              pointsRequired: itemPointsRequired,
              onRedeemConfirmed: (selectedCardId) async {
                Navigator.pop(context); // Cerrar bottom sheet
                _executeRedeem(selectedCardId, item);
              },
            );
          },
        );
      },
      loading: () => _showErrorSnackBar(context, 'Cargando información de tarjetas...'),
      error: (e, _) => _showErrorSnackBar(context, 'Error al obtener tarjetas: $e'),
    );
  }

  Future<void> _executeRedeem(String tarjetaId, Map<String, dynamic> item) async {
    // Mostrar loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFED0006)),
      ),
    );

    final success = await ref.read(scotiaPuntosNotifierProvider.notifier).canjearPuntos(
          tarjetaId: tarjetaId,
          puntos: item['points'] as int,
          descripcion: 'Canje: ${item['title']}',
        );

    if (mounted) {
      Navigator.pop(context); // Cerrar loading dialog
    }

    if (success) {
      _showSuccessDialog(item);
    } else {
      final errorMsg = ref.read(scotiaPuntosNotifierProvider).error ?? 'Error desconocido';
      _showErrorSnackBar(context, errorMsg);
    }
  }

  void _showSuccessDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 72),
              const SizedBox(height: 16),
              const Text(
                '¡Canje Exitoso!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                'Has canjeado con éxito:\n"${item['title']}"',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              Text(
                'por ${item['points']} Scotia Puntos.',
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.amber),
              ),
              const SizedBox(height: 12),
              Text(
                'El código de tu gift card o el abono correspondiente se procesará en las próximas 24 horas y se enviará a tu correo electrónico registrado.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFED0006),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Entendido', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
      ),
    );
  }
}

class _RedeemBottomSheet extends StatefulWidget {
  final Map<String, dynamic> item;
  final List<Tarjeta> creditCards;
  final int pointsRequired;
  final Function(String) onRedeemConfirmed;

  const _RedeemBottomSheet({
    required this.item,
    required this.creditCards,
    required this.pointsRequired,
    required this.onRedeemConfirmed,
  });

  @override
  State<_RedeemBottomSheet> createState() => _RedeemBottomSheetState();
}

class _RedeemBottomSheetState extends State<_RedeemBottomSheet> {
  String? _selectedCardId;

  @override
  void initState() {
    super.initState();
    // Pre-seleccionar la primera tarjeta con puntos suficientes si existe
    final cardConPuntos = widget.creditCards.firstWhere(
      (c) => c.puntosAcumulados >= widget.pointsRequired,
      orElse: () => widget.creditCards.first,
    );
    _selectedCardId = cardConPuntos.id;
  }

  @override
  Widget build(BuildContext context) {
    final selectedCard = widget.creditCards.firstWhere((c) => c.id == _selectedCardId);
    final hasEnoughPoints = selectedCard.puntosAcumulados >= widget.pointsRequired;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Confirmar Canje',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Info del Premio
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(widget.item['icon'] as IconData, color: widget.item['color'] as Color, size: 36),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Costo: ${widget.pointsRequired} pts',
                        style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Selecciona la Tarjeta de Crédito origen',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          // Dropdown de tarjetas
          DropdownButtonFormField<String>(
            value: _selectedCardId,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: widget.creditCards.map((c) {
              return DropdownMenuItem<String>(
                value: c.id,
                child: Text('${c.tipoFormateado} (${c.numeroEnmascarado}) - ${c.puntosAcumulados} pts'),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedCardId = val;
              });
            },
          ),
          const SizedBox(height: 16),
          if (!hasEnoughPoints)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Puntos insuficientes en la tarjeta seleccionada. Necesitas ${widget.pointsRequired} pts pero tienes ${selectedCard.puntosAcumulados} pts.',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          // Botón Canjear
          ElevatedButton(
            onPressed: hasEnoughPoints ? () => widget.onRedeemConfirmed(_selectedCardId!) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFED0006),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Confirmar Canje',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
