-- ============================================================
-- SUPABASE — Script de configuración completa
-- Portal Financiero · MVP v1.0
-- Productos y Servicios: Cuentas, Tarjetas, Préstamos,
--   Inversiones, Seguros y Servicios Digitales
-- ============================================================
-- INSTRUCCIONES:
-- 1. Ir a tu proyecto en supabase.com
-- 2. Abrir el SQL Editor (ícono de terminal en el sidebar)
-- 3. Pegar este script completo y ejecutar con "Run"
-- ============================================================


-- ══════════════════════════════════════════════════════════
-- MÓDULO 1 · CUENTAS Y AHORRO
-- ══════════════════════════════════════════════════════════

-- ── 1a. Cuentas de uso diario ─────────────────────────────
CREATE TABLE IF NOT EXISTS public.cuentas (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tipo            TEXT NOT NULL CHECK (tipo IN (
                    'digital',      -- Cuenta Digital (sin costo mantenimiento)
                    'sueldo',       -- Cuenta Sueldo
                    'power',        -- Cuenta Power
                    'meta',         -- Cuenta Meta
                    'dolares',      -- Ahorro en dólares
                    'cts',          -- Depósito CTS
                    'afp'           -- Retiro AFP
                  )),
  numero_cuenta   TEXT NOT NULL UNIQUE,
  saldo           NUMERIC(14,2) NOT NULL DEFAULT 0,
  moneda          TEXT NOT NULL DEFAULT 'PEN' CHECK (moneda IN ('PEN','USD')),
  costo_mant      NUMERIC(8,2) NOT NULL DEFAULT 0,   -- 0 para Cuenta Digital
  fecha_apertura  DATE DEFAULT CURRENT_DATE,
  activa          BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ DEFAULT now()
);

-- ── 1b. Cuentas de ahorro e inversión a corto plazo ───────
CREATE TABLE IF NOT EXISTS public.cuentas_ahorro (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  cuenta_id       UUID REFERENCES public.cuentas(id) ON DELETE SET NULL,
  saldo           NUMERIC(14,2) NOT NULL DEFAULT 0,
  meta_ahorro     NUMERIC(14,2) NOT NULL DEFAULT 10000,
  tasa_interes    NUMERIC(5,2) NOT NULL DEFAULT 3.5,  -- % anual
  moneda          TEXT NOT NULL DEFAULT 'PEN' CHECK (moneda IN ('PEN','USD')),
  fecha_apertura  DATE DEFAULT CURRENT_DATE
);

-- ── 1c. Transacciones (movimientos de cuenta) ─────────────
CREATE TABLE IF NOT EXISTS public.transacciones (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  cuenta_id       UUID REFERENCES public.cuentas(id) ON DELETE SET NULL,
  tipo            TEXT NOT NULL CHECK (tipo IN ('debito','credito')),
  canal           TEXT NOT NULL DEFAULT 'app' CHECK (canal IN (
                    'app','web','agencia','cajero','plin','qr','transferencia_intl'
                  )),
  descripcion     TEXT NOT NULL,
  monto           NUMERIC(14,2) NOT NULL,
  moneda          TEXT NOT NULL DEFAULT 'PEN',
  referencia      TEXT,                               -- nro de operación externo
  fecha           TIMESTAMPTZ DEFAULT now()
);


-- ══════════════════════════════════════════════════════════
-- MÓDULO 2 · TARJETAS Y MEDIOS DE PAGO
-- ══════════════════════════════════════════════════════════

-- ── 2a. Tarjetas ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.tarjetas (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  cuenta_id           UUID REFERENCES public.cuentas(id) ON DELETE SET NULL,
  tipo                TEXT NOT NULL CHECK (tipo IN ('credito','debito')),
  numero_enmascarado  TEXT NOT NULL,                  -- ej. **** **** **** 1234
  marca               TEXT NOT NULL CHECK (marca IN ('Visa','Mastercard','Amex')),
  fecha_vencimiento   DATE NOT NULL,
  linea_credito       NUMERIC(12,2),                  -- solo para crédito
  saldo_disponible    NUMERIC(12,2),
  activa              BOOLEAN NOT NULL DEFAULT TRUE,
  puntos_acumulados   INTEGER NOT NULL DEFAULT 0,     -- Scotia Puntos
  created_at          TIMESTAMPTZ DEFAULT now()
);

-- ── 2b. Programas de lealtad (Scotia Puntos) ─────────────
CREATE TABLE IF NOT EXISTS public.scotia_puntos (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tarjeta_id      UUID REFERENCES public.tarjetas(id) ON DELETE CASCADE,
  tipo_movimiento TEXT NOT NULL CHECK (tipo_movimiento IN ('acumulacion','canje','expiracion')),
  puntos          INTEGER NOT NULL,
  descripcion     TEXT,
  fecha           TIMESTAMPTZ DEFAULT now()
);

-- ── 2c. Meses sin intereses ───────────────────────────────
CREATE TABLE IF NOT EXISTS public.meses_sin_intereses (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tarjeta_id      UUID NOT NULL REFERENCES public.tarjetas(id) ON DELETE CASCADE,
  comercio        TEXT NOT NULL,
  monto_total     NUMERIC(12,2) NOT NULL,
  plazo_meses     INTEGER NOT NULL CHECK (plazo_meses IN (3,6,9,12,18,24)),
  cuota_mensual   NUMERIC(10,2) NOT NULL,
  cuotas_pagadas  INTEGER NOT NULL DEFAULT 0,
  estado          TEXT NOT NULL DEFAULT 'activo' CHECK (estado IN ('activo','completado','cancelado')),
  fecha_inicio    DATE DEFAULT CURRENT_DATE
);

-- ── 2d. Pagos de servicios ────────────────────────────────
CREATE TABLE IF NOT EXISTS public.pagos_servicios (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  cuenta_id        UUID REFERENCES public.cuentas(id) ON DELETE SET NULL,
  tarjeta_id       UUID REFERENCES public.tarjetas(id) ON DELETE SET NULL,
  servicio         TEXT NOT NULL CHECK (servicio IN (
                     'agua','luz','gas','telefono','cable','internet',
                     'colegio','universidad','municipalidad','otro'
                   )),
  proveedor        TEXT NOT NULL,                     -- ej. SEDAPAL, ENEL
  numero_contrato  TEXT NOT NULL,
  monto            NUMERIC(10,2) NOT NULL,
  estado           TEXT NOT NULL DEFAULT 'completado' CHECK (estado IN (
                     'pendiente','completado','fallido'
                   )),
  canal            TEXT NOT NULL DEFAULT 'app' CHECK (canal IN ('app','web','agencia')),
  fecha            TIMESTAMPTZ DEFAULT now()
);

-- ── 2e. Transferencias ────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.transferencias (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  cuenta_origen_id    UUID REFERENCES public.cuentas(id) ON DELETE SET NULL,
  tipo                TEXT NOT NULL CHECK (tipo IN (
                        'interna','cci','plin','qr','swift','cheque_exterior'
                      )),
  banco_destino       TEXT,
  cuenta_destino      TEXT,
  nombre_destino      TEXT NOT NULL,
  monto               NUMERIC(14,2) NOT NULL,
  moneda              TEXT NOT NULL DEFAULT 'PEN' CHECK (moneda IN ('PEN','USD')),
  tipo_cambio         NUMERIC(8,4),                   -- aplicado si hay conversión
  comision            NUMERIC(8,2) NOT NULL DEFAULT 0,
  estado              TEXT NOT NULL DEFAULT 'completado' CHECK (estado IN (
                        'pendiente','completado','fallido','reversado'
                      )),
  referencia          TEXT,
  fecha               TIMESTAMPTZ DEFAULT now()
);

-- ── 2f. Cambio de divisas ─────────────────────────────────
CREATE TABLE IF NOT EXISTS public.cambio_divisas (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  cuenta_id       UUID REFERENCES public.cuentas(id) ON DELETE SET NULL,
  operacion       TEXT NOT NULL CHECK (operacion IN ('compra','venta')),  -- compra/venta de USD
  monto_origen    NUMERIC(14,2) NOT NULL,
  moneda_origen   TEXT NOT NULL CHECK (moneda_origen IN ('PEN','USD')),
  tipo_cambio     NUMERIC(8,4) NOT NULL,
  monto_destino   NUMERIC(14,2) NOT NULL,
  moneda_destino  TEXT NOT NULL CHECK (moneda_destino IN ('PEN','USD')),
  canal           TEXT NOT NULL DEFAULT 'app',        -- tipo cambio preferencial en app
  fecha           TIMESTAMPTZ DEFAULT now()
);


-- ══════════════════════════════════════════════════════════
-- MÓDULO 3 · PRÉSTAMOS Y CRÉDITOS
-- ══════════════════════════════════════════════════════════

-- ── 3a. Préstamos personales ──────────────────────────────
CREATE TABLE IF NOT EXISTS public.prestamos (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tipo            TEXT NOT NULL CHECK (tipo IN (
                    'personal',         -- Préstamo Personal
                    'adelanto_sueldo',  -- Adelanto de Sueldo
                    'convenio',         -- Préstamo por Convenio
                    'vehicular',        -- Crédito Vehicular
                    'hipotecario',      -- Crédito Hipotecario
                    'mi_vivienda',      -- Programa Mi Vivienda
                    'libre_garantia'    -- Libre disponibilidad con garantía hipotecaria
                  )),
  monto           NUMERIC(14,2) NOT NULL,
  moneda          TEXT NOT NULL DEFAULT 'PEN' CHECK (moneda IN ('PEN','USD')),
  plazo_meses     INTEGER NOT NULL,
  tasa_anual      NUMERIC(5,2) NOT NULL,              -- TNA %
  cuota_mensual   NUMERIC(12,2) NOT NULL,
  cuotas_pagadas  INTEGER NOT NULL DEFAULT 0,
  saldo_capital   NUMERIC(14,2) NOT NULL,
  proposito       TEXT,
  garantia        TEXT,                               -- para hipotecario/vehicular
  estado          TEXT NOT NULL DEFAULT 'activo' CHECK (estado IN (
                    'pendiente','activo','pagado','mora','cancelado'
                  )),
  fecha_desembolso DATE,
  created_at      TIMESTAMPTZ DEFAULT now()
);

-- ── 3b. Cuotas de préstamos ───────────────────────────────
CREATE TABLE IF NOT EXISTS public.cuotas_prestamo (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  prestamo_id     UUID NOT NULL REFERENCES public.prestamos(id) ON DELETE CASCADE,
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  numero_cuota    INTEGER NOT NULL,
  monto_cuota     NUMERIC(12,2) NOT NULL,
  capital         NUMERIC(12,2) NOT NULL,
  intereses       NUMERIC(12,2) NOT NULL,
  fecha_venc      DATE NOT NULL,
  fecha_pago      DATE,
  estado          TEXT NOT NULL DEFAULT 'pendiente' CHECK (estado IN (
                    'pendiente','pagada','mora'
                  ))
);


-- ══════════════════════════════════════════════════════════
-- MÓDULO 4 · INVERSIONES
-- ══════════════════════════════════════════════════════════

-- ── 4a. Depósitos a plazo fijo digital ───────────────────
CREATE TABLE IF NOT EXISTS public.depositos_plazo (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  cuenta_id       UUID REFERENCES public.cuentas(id) ON DELETE SET NULL,
  monto           NUMERIC(14,2) NOT NULL,
  moneda          TEXT NOT NULL DEFAULT 'PEN' CHECK (moneda IN ('PEN','USD')),
  plazo_dias      INTEGER NOT NULL,
  tasa_anual      NUMERIC(5,2) NOT NULL,
  rendimiento     NUMERIC(12,2),                      -- calculado al vencimiento
  fecha_inicio    DATE NOT NULL DEFAULT CURRENT_DATE,
  fecha_venc      DATE NOT NULL,
  estado          TEXT NOT NULL DEFAULT 'activo' CHECK (estado IN (
                    'activo','vencido','cancelado','renovado'
                  )),
  renovacion_auto BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ DEFAULT now()
);

-- ── 4b. Fondos mutuos ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.fondos_mutuos (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  fondo           TEXT NOT NULL,                      -- nombre del fondo
  tipo_fondo      TEXT NOT NULL CHECK (tipo_fondo IN (
                    'conservador','moderado','agresivo','exterior'
                  )),
  moneda          TEXT NOT NULL DEFAULT 'USD' CHECK (moneda IN ('PEN','USD')),
  monto_invertido NUMERIC(14,2) NOT NULL,
  cuotas          NUMERIC(14,6) NOT NULL DEFAULT 0,
  valor_cuota     NUMERIC(12,6) NOT NULL DEFAULT 1,
  valor_actual    NUMERIC(14,2),                      -- calculado
  rentabilidad    NUMERIC(8,2),                       -- % acumulado
  inversion_min   NUMERIC(10,2) DEFAULT 100,          -- desde $100 para exterior
  estado          TEXT NOT NULL DEFAULT 'activo' CHECK (estado IN (
                    'activo','rescatado','suspendido'
                  )),
  fecha_inicio    DATE DEFAULT CURRENT_DATE,
  created_at      TIMESTAMPTZ DEFAULT now()
);

-- ── 4c. Operaciones en Scotia Bolsa ──────────────────────
CREATE TABLE IF NOT EXISTS public.scotia_bolsa (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  ticker          TEXT NOT NULL,                      -- símbolo bursátil
  operacion       TEXT NOT NULL CHECK (operacion IN ('compra','venta')),
  cantidad        NUMERIC(12,4) NOT NULL,
  precio_unitario NUMERIC(14,4) NOT NULL,
  monto_total     NUMERIC(14,2) NOT NULL,
  moneda          TEXT NOT NULL DEFAULT 'USD',
  comision        NUMERIC(10,2) NOT NULL DEFAULT 0,
  estado          TEXT NOT NULL DEFAULT 'ejecutada' CHECK (estado IN (
                    'pendiente','ejecutada','cancelada'
                  )),
  fecha           TIMESTAMPTZ DEFAULT now()
);


-- ══════════════════════════════════════════════════════════
-- MÓDULO 5 · SEGUROS
-- ══════════════════════════════════════════════════════════

-- ── 5a. Seguros contratados ───────────────────────────────
CREATE TABLE IF NOT EXISTS public.seguros (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tipo            TEXT NOT NULL CHECK (tipo IN (
                    'oncologico_oncomax',      -- Oncomax
                    'oncologico_plus',         -- Oncológico Plus
                    'desgravamen',             -- Desgravamen (vinculado a préstamo)
                    'soat',                    -- SOAT vehicular
                    'vehicular_totalmax',      -- Vehicular TotalMax 2.0
                    'incendio',                -- Seguro contra incendios
                    'hogar_protegido',         -- Seguro Hogar Protegido
                    'proteccion_pagos',        -- Protección de Pagos
                    'tarjeta_segura'           -- Tarjeta Segura (fraude/robo)
                  )),
  prestamo_id     UUID REFERENCES public.prestamos(id) ON DELETE SET NULL,  -- para desgravamen
  tarjeta_id      UUID REFERENCES public.tarjetas(id) ON DELETE SET NULL,   -- para tarjeta segura
  numero_poliza   TEXT NOT NULL UNIQUE,
  prima_mensual   NUMERIC(10,2) NOT NULL,
  suma_asegurada  NUMERIC(14,2),
  moneda          TEXT NOT NULL DEFAULT 'PEN',
  estado          TEXT NOT NULL DEFAULT 'vigente' CHECK (estado IN (
                    'vigente','vencido','cancelado','siniestro'
                  )),
  fecha_inicio    DATE NOT NULL DEFAULT CURRENT_DATE,
  fecha_venc      DATE,
  created_at      TIMESTAMPTZ DEFAULT now()
);

-- ── 5b. Siniestros / Reclamos de seguro ──────────────────
CREATE TABLE IF NOT EXISTS public.siniestros (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  seguro_id       UUID NOT NULL REFERENCES public.seguros(id) ON DELETE CASCADE,
  descripcion     TEXT NOT NULL,
  monto_reclamado NUMERIC(14,2),
  monto_liquidado NUMERIC(14,2),
  estado          TEXT NOT NULL DEFAULT 'en_revision' CHECK (estado IN (
                    'en_revision','aprobado','rechazado','pagado'
                  )),
  fecha_ocurrencia DATE NOT NULL,
  fecha_reporte   TIMESTAMPTZ DEFAULT now()
);


-- ══════════════════════════════════════════════════════════
-- MÓDULO 6 · SOLICITUDES Y ONBOARDING
-- ══════════════════════════════════════════════════════════

-- ── 6a. Solicitudes generales (multi-producto) ────────────
CREATE TABLE IF NOT EXISTS public.solicitudes (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  producto        TEXT NOT NULL CHECK (producto IN (
                    'cuenta_digital','cuenta_sueldo','cuenta_power','cuenta_meta',
                    'cuenta_dolares','cts','afp',
                    'tarjeta_credito','tarjeta_debito',
                    'prestamo_personal','adelanto_sueldo','prestamo_convenio',
                    'credito_vehicular','credito_hipotecario','mi_vivienda','libre_garantia',
                    'deposito_plazo','fondo_mutuo','scotia_bolsa',
                    'seguro_oncologico','seguro_vehicular','seguro_hogar','proteccion_pagos'
                  )),
  datos_solicitud JSONB,                              -- parámetros específicos del producto
  estado          TEXT NOT NULL DEFAULT 'pendiente' CHECK (estado IN (
                    'pendiente','en_revision','aprobada','rechazada','desembolsada'
                  )),
  comentario      TEXT,
  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now()
);

-- ── 6b. Notificaciones al usuario ────────────────────────
CREATE TABLE IF NOT EXISTS public.notificaciones (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tipo            TEXT NOT NULL CHECK (tipo IN (
                    'pago_vencido','cuota_proxima','movimiento','oferta',
                    'seguridad','aprobacion','rechazo','otro'
                  )),
  titulo          TEXT NOT NULL,
  mensaje         TEXT NOT NULL,
  leida           BOOLEAN NOT NULL DEFAULT FALSE,
  fecha           TIMESTAMPTZ DEFAULT now()
);


-- ============================================================
-- ROW LEVEL SECURITY (RLS) — Cada usuario solo ve sus datos
-- ============================================================

ALTER TABLE public.cuentas                ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cuentas_ahorro         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transacciones          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tarjetas               ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scotia_puntos          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meses_sin_intereses    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pagos_servicios        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transferencias         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cambio_divisas         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prestamos              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cuotas_prestamo        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.depositos_plazo        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fondos_mutuos          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scotia_bolsa           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.seguros                ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.siniestros             ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.solicitudes            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notificaciones         ENABLE ROW LEVEL SECURITY;

-- ── Políticas RLS ─────────────────────────────────────────
CREATE POLICY "Usuario ve sus propias cuentas"
  ON public.cuentas FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Usuario ve sus cuentas de ahorro"
  ON public.cuentas_ahorro FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Usuario ve sus transacciones"
  ON public.transacciones FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Usuario ve sus tarjetas"
  ON public.tarjetas FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Usuario ve sus puntos Scotia"
  ON public.scotia_puntos FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Usuario ve sus MSI"
  ON public.meses_sin_intereses FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Usuario ve sus pagos de servicios"
  ON public.pagos_servicios FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Usuario ve sus transferencias"
  ON public.transferencias FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Usuario ve sus cambios de divisa"
  ON public.cambio_divisas FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Usuario ve sus prestamos"
  ON public.prestamos FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Usuario ve sus cuotas"
  ON public.cuotas_prestamo FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Usuario ve sus depositos a plazo"
  ON public.depositos_plazo FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Usuario ve sus fondos mutuos"
  ON public.fondos_mutuos FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Usuario ve sus operaciones bolsa"
  ON public.scotia_bolsa FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Usuario ve sus seguros"
  ON public.seguros FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Usuario ve sus siniestros"
  ON public.siniestros FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Usuario ve sus solicitudes"
  ON public.solicitudes FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Usuario ve sus notificaciones"
  ON public.notificaciones FOR ALL USING (auth.uid() = user_id);


-- ============================================================
-- ÍNDICES — Mejoran el rendimiento en consultas frecuentes
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_cuentas_user          ON public.cuentas(user_id);
CREATE INDEX IF NOT EXISTS idx_transacciones_user     ON public.transacciones(user_id);
CREATE INDEX IF NOT EXISTS idx_transacciones_cuenta   ON public.transacciones(cuenta_id);
CREATE INDEX IF NOT EXISTS idx_transacciones_fecha    ON public.transacciones(fecha DESC);
CREATE INDEX IF NOT EXISTS idx_tarjetas_user          ON public.tarjetas(user_id);
CREATE INDEX IF NOT EXISTS idx_prestamos_user         ON public.prestamos(user_id);
CREATE INDEX IF NOT EXISTS idx_seguros_user           ON public.seguros(user_id);
CREATE INDEX IF NOT EXISTS idx_notificaciones_user    ON public.notificaciones(user_id, leida);


-- ============================================================
-- DATOS DE DEMOSTRACIÓN (opcional)
-- Descomenta el bloque DO $$ ... $$ para insertar datos.
-- Primero regístrate en el portal y ejecuta:
--   SELECT id FROM auth.users;
-- Luego reemplaza el UUID en la variable uid.
-- ============================================================

/*
DO $$
DECLARE
  uid       UUID := 'TU-UUID-AQUI';  -- <-- pegar UUID de tu usuario
  cc_id     UUID;
  ca_id     UUID;
  tc_id     UUID;
  prest_id  UUID;
  seg_id    UUID;
BEGIN

  -- ── Cuentas ──────────────────────────────────────────────
  INSERT INTO public.cuentas (user_id, tipo, numero_cuenta, saldo, moneda, costo_mant)
  VALUES (uid, 'digital',  '019-1100001', 4250.00,   'PEN', 0)
  RETURNING id INTO cc_id;

  INSERT INTO public.cuentas (user_id, tipo, numero_cuenta, saldo, moneda, costo_mant)
  VALUES (uid, 'dolares',  '019-1100002', 850.00,    'USD', 0)
  RETURNING id INTO ca_id;

  -- ── Cuenta ahorro ─────────────────────────────────────────
  INSERT INTO public.cuentas_ahorro (user_id, cuenta_id, saldo, meta_ahorro, tasa_interes, moneda)
  VALUES (uid, ca_id, 850.00, 5000, 2.75, 'USD');

  -- ── Transacciones ─────────────────────────────────────────
  INSERT INTO public.transacciones
    (user_id, cuenta_id, tipo, canal, descripcion, monto, moneda, fecha)
  VALUES
    (uid, cc_id, 'credito', 'app',          'Depósito sueldo',              3500.00, 'PEN', now() - interval '7 days'),
    (uid, cc_id, 'debito',  'plin',         'Pago Plin a Juan Pérez',        200.00, 'PEN', now() - interval '5 days'),
    (uid, cc_id, 'debito',  'app',          'Pago luz ENEL',                 120.00, 'PEN', now() - interval '4 days'),
    (uid, cc_id, 'debito',  'app',          'Pago agua SEDAPAL',              85.00, 'PEN', now() - interval '3 days'),
    (uid, cc_id, 'debito',  'qr',           'Compra supermercado WONG',      230.50, 'PEN', now() - interval '2 days'),
    (uid, cc_id, 'credito', 'transferencia_intl', 'Cobro cheque exterior',   750.00, 'USD', now() - interval '1 day'),
    (uid, ca_id, 'credito', 'app',          'Depósito ahorro USD',           200.00, 'USD', now() - interval '10 days');

  -- ── Tarjeta de crédito ────────────────────────────────────
  INSERT INTO public.tarjetas
    (user_id, cuenta_id, tipo, numero_enmascarado, marca, fecha_vencimiento, linea_credito, saldo_disponible, puntos_acumulados)
  VALUES
    (uid, cc_id, 'credito', '**** **** **** 4521', 'Visa', '2027-09-30', 8000.00, 5320.00, 1250)
  RETURNING id INTO tc_id;

  -- Scotia Puntos
  INSERT INTO public.scotia_puntos (user_id, tarjeta_id, tipo_movimiento, puntos, descripcion)
  VALUES
    (uid, tc_id, 'acumulacion', 1000, 'Compras del mes anterior'),
    (uid, tc_id, 'acumulacion',  250, 'Bono bienvenida');

  -- ── Meses sin intereses ───────────────────────────────────
  INSERT INTO public.meses_sin_intereses
    (user_id, tarjeta_id, comercio, monto_total, plazo_meses, cuota_mensual)
  VALUES
    (uid, tc_id, 'Falabella', 1200.00, 12, 100.00);

  -- ── Pago de servicio ──────────────────────────────────────
  INSERT INTO public.pagos_servicios
    (user_id, cuenta_id, servicio, proveedor, numero_contrato, monto)
  VALUES
    (uid, cc_id, 'luz', 'ENEL', 'ENL-987654', 120.00),
    (uid, cc_id, 'agua', 'SEDAPAL', 'SED-112233', 85.00);

  -- ── Cambio de divisas ─────────────────────────────────────
  INSERT INTO public.cambio_divisas
    (user_id, cuenta_id, operacion, monto_origen, moneda_origen, tipo_cambio, monto_destino, moneda_destino)
  VALUES
    (uid, cc_id, 'compra', 1000.00, 'PEN', 3.72, 268.82, 'USD');

  -- ── Préstamo personal ─────────────────────────────────────
  INSERT INTO public.prestamos
    (user_id, tipo, monto, moneda, plazo_meses, tasa_anual, cuota_mensual, saldo_capital, estado, fecha_desembolso)
  VALUES
    (uid, 'personal', 15000.00, 'PEN', 36, 18.50, 547.30, 14200.00, 'activo', CURRENT_DATE - interval '2 months')
  RETURNING id INTO prest_id;

  -- ── Depósito a plazo fijo digital ─────────────────────────
  INSERT INTO public.depositos_plazo
    (user_id, cuenta_id, monto, moneda, plazo_dias, tasa_anual, fecha_inicio, fecha_venc)
  VALUES
    (uid, ca_id, 500.00, 'USD', 180, 4.25, CURRENT_DATE, CURRENT_DATE + interval '180 days');

  -- ── Fondo mutuo ───────────────────────────────────────────
  INSERT INTO public.fondos_mutuos
    (user_id, fondo, tipo_fondo, moneda, monto_invertido, cuotas, valor_cuota)
  VALUES
    (uid, 'Fondo Global Moderado', 'exterior', 'USD', 300.00, 250.0000, 1.2000);

  -- ── Seguro ────────────────────────────────────────────────
  INSERT INTO public.seguros
    (user_id, tipo, tarjeta_id, numero_poliza, prima_mensual, suma_asegurada, moneda, fecha_inicio, fecha_venc)
  VALUES
    (uid, 'tarjeta_segura', tc_id, 'POL-TS-0099821', 12.90, 5000.00, 'PEN', CURRENT_DATE, CURRENT_DATE + interval '1 year')
  RETURNING id INTO seg_id;

  -- ── Notificaciones ────────────────────────────────────────
  INSERT INTO public.notificaciones (user_id, tipo, titulo, mensaje)
  VALUES
    (uid, 'movimiento',    'Depósito recibido',       'Se acreditó S/ 3,500.00 en tu Cuenta Digital.'),
    (uid, 'cuota_proxima', 'Cuota de préstamo próxima','Tu cuota de S/ 547.30 vence en 5 días.'),
    (uid, 'oferta',        '¡Fondos Mutuos desde $100!','Empieza a invertir en el exterior desde solo $100.');

END $$;
*/