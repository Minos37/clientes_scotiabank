import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../viewmodel/cuenta_viewmodel.dart';
import '../viewmodel/tarjeta_viewmodel.dart';

class OperacionesScreen extends ConsumerWidget {
  const OperacionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFFED0006),
        title: const Text(
          'Operaciones',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Cabecera curva roja
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFED0006),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: const Text(
              '¿Qué te gustaría hacer hoy?',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          
          // Lista de operaciones agrupadas
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                _buildOperationGroup('Transferencias', [
                  _buildOperationItem(context, Icons.swap_horiz, 'Realizar transferencias', 'Entre tus cuentas, a terceros y otros bancos', onTap: () {
                    context.push('/transferencias');
                  }),
                  _buildOperationItem(context, Icons.qr_code_scanner, 'Transferir con QR', 'Paga escaneando códigos QR de Plin o Niubiz', onTap: () {
                    _showQRTransferSheet(context);
                  }, isLast: true),
                ]),
                
                const SizedBox(height: 24),
                
                _buildOperationGroup('Pagos y Recargas', [
                  _buildOperationItem(context, Icons.receipt_long, 'Pago de Servicios', 'Agua, luz, teléfono, colegios y más', onTap: () {
                    context.push('/pagos');
                  }),
                  _buildOperationItem(context, Icons.credit_score, 'Pago de Tarjetas', 'Paga tus tarjetas de crédito Scotiabank u otros', onTap: () {
                    _showPagoTarjetasSheet(context, ref);
                  }),
                  _buildOperationItem(context, Icons.phone_android, 'Recargas de Celular', 'Claro, Movistar, Entel y Bitel', onTap: () {
                    _showRecargasCelularSheet(context, ref);
                  }, isLast: true),
                ]),
                
                const SizedBox(height: 24),
                
                _buildOperationGroup('Cambio de Moneda', [
                  _buildOperationItem(context, Icons.currency_exchange, 'Cambio de Dólares', 'Compra y venta con tipo de cambio preferencial', onTap: () {
                    context.push('/cambio-divisas');
                  }, isLast: true),
                ]),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Índice de "Operaciones"
        selectedItemColor: const Color(0xFFED0006),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            context.go('/home');
          } else if (index == 1) {
            context.go('/tarjetas');
          } else if (index == 3) {
            context.go('/mas');
          }
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

  Widget _buildOperationGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildOperationItem(BuildContext context, IconData icon, String title, String subtitle, {VoidCallback? onTap, bool isLast = false}) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFED0006).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: const Color(0xFFED0006), size: 26),
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
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Divider(height: 1, indent: 68, endIndent: 16, color: Colors.grey.shade100),
      ],
    );
  }

  // 1. TRANSFERIR CON QR
  void _showQRTransferSheet(BuildContext context) {
    Timer? scanTimer;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        int activeTab = 0; // 0: Escanear, 1: Mi QR
        bool scanFinished = false;
        final amountController = TextEditingController();
        final formKey = GlobalKey<FormState>();

        return StatefulBuilder(
          builder: (context, setModalState) {
            // Iniciar simulador de escaneo
            if (activeTab == 0 && !scanFinished && scanTimer == null) {
              scanTimer = Timer(const Duration(seconds: 3), () {
                if (context.mounted) {
                  setModalState(() {
                    scanFinished = true;
                  });
                }
              });
            }

            void changeTab(int index) {
              setModalState(() {
                activeTab = index;
                if (index == 1) {
                  scanTimer?.cancel();
                  scanTimer = null;
                } else {
                  scanFinished = false;
                }
              });
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => changeTab(0),
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Escanear QR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: activeTab == 0 ? const Color(0xFFED0006) : Colors.grey.shade100,
                          foregroundColor: activeTab == 0 ? Colors.white : Colors.black87,
                          elevation: 0,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => changeTab(1),
                        icon: const Icon(Icons.qr_code),
                        label: const Text('Mi Código QR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: activeTab == 1 ? const Color(0xFFED0006) : Colors.grey.shade100,
                          foregroundColor: activeTab == 1 ? Colors.white : Colors.black87,
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Expanded(
                    child: activeTab == 0
                        ? (scanFinished
                            ? Form(
                                key: formKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.green, size: 54),
                                    const SizedBox(height: 12),
                                    const Text('QR Escaneado Correctamente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    const SizedBox(height: 6),
                                    const Text('Destinatario: Juan Pérez Villacorta', style: TextStyle(fontSize: 15, color: Colors.black87)),
                                    const Text('Destino: Plin (Interbank)', style: TextStyle(fontSize: 13, color: Colors.black54)),
                                    const SizedBox(height: 24),
                                    TextFormField(
                                      controller: amountController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Monto a Transferir',
                                        prefixText: 'S/ ',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      validator: (val) {
                                        if (val == null || val.isEmpty) return 'Ingresa el monto';
                                        if (double.tryParse(val) == null || double.parse(val) <= 0) return 'Monto inválido';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (formKey.currentState!.validate()) {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Transferencia Plin de S/ ${amountController.text} realizada con éxito.'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFED0006),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: const Text('Enviar Dinero con Plin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: const Color(0xFFED0006), width: 3),
                                    ),
                                    child: const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.camera_alt, color: Colors.white70, size: 48),
                                          SizedBox(height: 8),
                                          Text('Apunte a un código QR', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                          SizedBox(height: 12),
                                          SizedBox(width: 80, child: LinearProgressIndicator(color: Color(0xFFED0006), backgroundColor: Colors.white10)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text('Simulando escaneo de cámara...', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                                ],
                              ))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.qr_code, size: 160, color: Colors.black87),
                                    const SizedBox(height: 12),
                                    const Text('Plin / Yape / Niubiz', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text('Muestra este código para que te transfieran', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Código QR guardado en galería.')),
                                  );
                                },
                                icon: const Icon(Icons.share),
                                label: const Text('Compartir Mi QR'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade50,
                                  foregroundColor: const Color(0xFFED0006),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      scanTimer?.cancel();
    });
  }

  // 2. PAGO DE TARJETAS
  void _showPagoTarjetasSheet(BuildContext context, WidgetRef ref) {
    final cuentasAsync = ref.watch(cuentasProvider);
    final tarjetasAsync = ref.watch(tarjetasProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        String? selectedCuentaId;
        String? selectedTarjetaId;
        final tarjetaExternaController = TextEditingController();
        final montoController = TextEditingController();
        bool isTarjetaPropia = true;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
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
                          Icon(Icons.credit_score, color: Color(0xFFED0006), size: 28),
                          SizedBox(width: 12),
                          Text('Pagar Tarjeta de Crédito', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 32),
                      
                      // Tipo de tarjeta (Propia vs Externa)
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('Tarjeta Propia')),
                              selected: isTarjetaPropia,
                              selectedColor: const Color(0xFFED0006).withOpacity(0.1),
                              labelStyle: TextStyle(
                                color: isTarjetaPropia ? const Color(0xFFED0006) : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (val) {
                                setModalState(() {
                                  isTarjetaPropia = true;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('Otra Tarjeta')),
                              selected: !isTarjetaPropia,
                              selectedColor: const Color(0xFFED0006).withOpacity(0.1),
                              labelStyle: TextStyle(
                                color: !isTarjetaPropia ? const Color(0xFFED0006) : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (val) {
                                setModalState(() {
                                  isTarjetaPropia = false;
                                  selectedTarjetaId = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Selector de tarjeta propia
                      if (isTarjetaPropia) ...[
                        const Text('Selecciona tu Tarjeta de Crédito', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        tarjetasAsync.when(
                          data: (tarjetas) {
                            final creditCards = tarjetas.where((t) => t.tipo == 'credito').toList();
                            if (creditCards.isEmpty) {
                              return const Text('No tienes tarjetas de crédito registradas.', style: TextStyle(color: Colors.grey));
                            }
                            
                            return DropdownButtonFormField<String>(
                              value: selectedTarjetaId,
                              hint: const Text('Seleccionar Tarjeta'),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              items: creditCards.map((t) {
                                final lastDigits = t.numeroEnmascarado.length > 4 ? t.numeroEnmascarado.substring(t.numeroEnmascarado.length - 4) : t.numeroEnmascarado;
                                return DropdownMenuItem(
                                  value: t.id,
                                  child: Text('Crédito Scotiabank •••• $lastDigits (Disp: S/ ${t.saldoDisponible ?? 0.0})'),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setModalState(() {
                                  selectedTarjetaId = val;
                                });
                              },
                              validator: (val) => val == null ? 'Selecciona una tarjeta' : null,
                            );
                          },
                          loading: () => const CircularProgressIndicator(),
                          error: (e, st) => Text('Error: $e'),
                        ),
                      ] else ...[
                        const Text('Ingresa el Número de Tarjeta (16 dígitos)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: tarjetaExternaController,
                          keyboardType: TextInputType.number,
                          maxLength: 16,
                          decoration: InputDecoration(
                            hintText: '4557 •••• •••• ••••',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            counterText: '',
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Ingresa el número de tarjeta';
                            if (val.length != 16) return 'Debe tener 16 dígitos';
                            return null;
                          },
                        ),
                      ],
                      
                      const SizedBox(height: 16),

                      // Selector de Cuenta de Origen
                      const Text('Pagar desde Cuenta de Ahorro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      cuentasAsync.when(
                        data: (cuentas) {
                          return DropdownButtonFormField<String>(
                            value: selectedCuentaId,
                            hint: const Text('Seleccionar Cuenta de Origen'),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            items: cuentas.map((c) {
                              final lastDigits = c.numeroCuenta.length > 4 ? c.numeroCuenta.substring(c.numeroCuenta.length - 4) : c.numeroCuenta;
                              return DropdownMenuItem(
                                value: c.id,
                                child: Text('${c.tipo == 'corriente' ? 'Corriente' : 'Ahorros'} •••• $lastDigits (S/ ${c.saldo})'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setModalState(() {
                                selectedCuentaId = val;
                              });
                            },
                            validator: (val) => val == null ? 'Selecciona cuenta de origen' : null,
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (e, st) => Text('Error: $e'),
                      ),
                      
                      const SizedBox(height: 16),

                      // Monto a Pagar
                      const Text('Monto a Pagar (S/)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: montoController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '0.00',
                          prefixText: 'S/ ',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Ingresa el monto a pagar';
                          if (double.tryParse(val) == null || double.parse(val) <= 0) return 'Monto inválido';
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Pago de tarjeta por S/ ${montoController.text} realizado correctamente.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFED0006),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Confirmar Pago', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  // 3. RECARGAS DE CELULAR
  void _showRecargasCelularSheet(BuildContext context, WidgetRef ref) {
    final cuentasAsync = ref.watch(cuentasProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        String selectedOperador = 'Claro';
        double selectedMonto = 10.0;
        String? selectedCuentaId;
        final celularController = TextEditingController();

        final operadores = ['Claro', 'Movistar', 'Entel', 'Bitel'];
        final montos = [5.0, 10.0, 20.0, 30.0, 50.0];

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
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
                          Icon(Icons.phone_android, color: Color(0xFFED0006), size: 28),
                          SizedBox(width: 12),
                          Text('Recarga de Celular', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 32),

                      // Operador
                      const Text('Selecciona el Operador', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedOperador,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: operadores.map((op) => DropdownMenuItem(value: op, child: Text(op))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              selectedOperador = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Celular
                      const Text('Número de Celular (9 dígitos)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: celularController,
                        keyboardType: TextInputType.phone,
                        maxLength: 9,
                        decoration: InputDecoration(
                          hintText: '999 999 999',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          counterText: '',
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Ingresa el número de celular';
                          if (val.length != 9 || !val.startsWith('9')) return 'Número celular inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Monto de Recarga
                      const Text('Monto de Recarga (S/)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: montos.map((m) {
                          final isSelected = selectedMonto == m;
                          return ChoiceChip(
                            label: Text('S/ ${m.toInt()}'),
                            selected: isSelected,
                            selectedColor: const Color(0xFFED0006).withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: isSelected ? const Color(0xFFED0006) : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setModalState(() {
                                  selectedMonto = m;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Cuenta de origen
                      const Text('Pagar desde Cuenta de Ahorro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      cuentasAsync.when(
                        data: (cuentas) {
                          return DropdownButtonFormField<String>(
                            value: selectedCuentaId,
                            hint: const Text('Seleccionar Cuenta de Origen'),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            items: cuentas.map((c) {
                              final lastDigits = c.numeroCuenta.length > 4 ? c.numeroCuenta.substring(c.numeroCuenta.length - 4) : c.numeroCuenta;
                              return DropdownMenuItem(
                                value: c.id,
                                child: Text('${c.tipo == 'corriente' ? 'Corriente' : 'Ahorros'} •••• $lastDigits (S/ ${c.saldo})'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setModalState(() {
                                selectedCuentaId = val;
                              });
                            },
                            validator: (val) => val == null ? 'Selecciona cuenta de origen' : null,
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (e, st) => Text('Error: $e'),
                      ),

                      const SizedBox(height: 32),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Recarga de S/ ${selectedMonto.toInt()} a $selectedOperador ($celularController.text) exitosa.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFED0006),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Confirmar Recarga', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
}