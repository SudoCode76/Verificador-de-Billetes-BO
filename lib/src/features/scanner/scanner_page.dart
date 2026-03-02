import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'camera_handler.dart';
import 'scanner_controller.dart';

// ── Paleta de colores (replica el HTML) ──────────────────────────────────────

const _colorPrimary = Color(0xFF13EC5B);
const _colorBgDark = Color(0xFF102216);
const _colorSurface = Color(0xFF1C2E22);

// ── Página principal ─────────────────────────────────────────────────────────

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> with WidgetsBindingObserver {
  late final ScannerController _scannerCtrl;
  late final CameraHandler _cameraHandler;

  bool _cameraReady = false;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scannerCtrl = context.read<ScannerController>();
    _cameraHandler = CameraHandler(controller: _scannerCtrl);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      await _cameraHandler.initialize();
      if (mounted) setState(() => _cameraReady = true);
    } catch (e) {
      if (mounted) {
        setState(() => _cameraError = e.toString());
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ctrl = _cameraHandler.cameraController;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _cameraHandler.pausarStream();
    } else if (state == AppLifecycleState.resumed) {
      _cameraHandler.reanudarStream();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraHandler.dispose();
    super.dispose();
  }

  // ── Acciones ────────────────────────────────────────────────────────────

  void _onCorteChanged(int corte) {
    _scannerCtrl.seleccionarCorte(corte);
    _cameraHandler.reanudarStream();
  }

  Future<void> _abrirWhatsApp() async {
    const phone = '59162994685';
    final encodedMsg = Uri.encodeComponent(
      'Hola Miguel, necesito información sobre la app Verificador Billetes.',
    );

    // Intentar abrir la app nativa primero
    final appUri = Uri.parse('whatsapp://send?phone=$phone&text=$encodedMsg');
    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri);
      return;
    }

    // Fallback: abrir wa.me en el navegador/WebView
    final webUri = Uri.parse('https://wa.me/$phone?text=$encodedMsg');
    try {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp.')),
        );
      }
    }
  }

  void _mostrarDialogoManual() {
    final textCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _colorSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Ingresar serie manualmente',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: textCtrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.inter(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Ej. 96500000',
            hintStyle: GoogleFonts.inter(color: Colors.white38),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: _colorPrimary),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _colorPrimary,
              foregroundColor: _colorBgDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _scannerCtrl.verificarManual(textCtrl.text);
            },
            child: Text(
              'Verificar',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarInfo() {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2B1F),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícono ⓘ verde circular
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _colorPrimary, width: 2),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: _colorPrimary,
                  size: 26,
                ),
              ),
              const SizedBox(height: 14),

              // Título
              Text(
                'Acerca de',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),

              // Descripción
              Text(
                'Diseñado y desarrollado por Miguel Angel Zenteno Orellana.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Fila de iconos sociales
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SocialIconButton(
                    icon: FontAwesomeIcons.github,
                    label: 'GitHub',
                    bgColor: const Color(0xFF2D2D2D),
                    iconColor: Colors.white,
                    onTap: () => _launchUrl(
                      'https://github.com/SudoCode76',
                      ctx,
                    ),
                  ),
                  _SocialIconButton(
                    icon: FontAwesomeIcons.linkedin,
                    label: 'LinkedIn',
                    bgColor: const Color(0xFF0A66C2),
                    iconColor: Colors.white,
                    onTap: () => _launchUrl(
                      'https://www.linkedin.com/in/miguel-zenteno/',
                      ctx,
                    ),
                  ),
                  _SocialIconButton(
                    icon: FontAwesomeIcons.whatsapp,
                    label: 'WhatsApp',
                    bgColor: const Color(0xFF25D366),
                    iconColor: Colors.white,
                    onTap: () {
                      Navigator.pop(ctx);
                      _abrirWhatsApp();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Botón CERRAR
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'CERRAR',
                    style: GoogleFonts.inter(
                      color: _colorPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Lanza una URL HTTPS directamente sin guard de canLaunchUrl
  /// (Android 11+ requiere queries en el manifest para que canLaunchUrl
  /// devuelva true; launchUrl directamente siempre funciona si el SO tiene
  /// un browser o handler instalado).
  Future<void> _launchUrl(String url, BuildContext dialogCtx) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (dialogCtx.mounted) {
        ScaffoldMessenger.of(dialogCtx).showSnackBar(
          SnackBar(content: Text('No se pudo abrir $url')),
        );
      }
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _colorBgDark,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Capa 0 – fondo oscuro sólido (visible mientras la cámara carga
            //          o si el usuario deniega el permiso)
            const ColoredBox(color: _colorBgDark),

            // Capa 1 – preview de cámara a pantalla completa
            if (_cameraReady)
              _CameraPreviewLayer(controller: _cameraHandler.cameraController!),

            // Capa 2 – UI principal
            SafeArea(
              child: Column(
                children: [
                  _TopBar(
                    corte: context.watch<ScannerController>().corteSeleccionado,
                    onCorteChanged: _onCorteChanged,
                    onInfoTap: _mostrarInfo,
                  ),
                  Expanded(child: _ScanArea(cameraError: _cameraError)),
                  _BottomPanel(
                    onTecladoTap: _mostrarDialogoManual,
                    onWhatsAppTap: _abrirWhatsApp,
                  ),
                ],
              ),
            ),

            // Capa 4 – resultado de verificación (overlay superpuesto)
            Consumer<ScannerController>(
              builder: (context, ctrl, child) {
                if (ctrl.status == VerificationStatus.anulado ||
                    ctrl.status == VerificationStatus.valido ||
                    ctrl.status == VerificationStatus.error) {
                  // Pausa el stream al mostrar resultado
                  _cameraHandler.pausarStream();
                  return _ResultOverlay(
                    status: ctrl.status,
                    serie: ctrl.serieDetectada,
                    corte: ctrl.corteSeleccionado,
                    onReset: () {
                      ctrl.resetear();
                      _cameraHandler.reanudarStream();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widget auxiliar: icono social circular con label (diálogo Acerca de) ─────

class _SocialIconButton extends StatelessWidget {
  const _SocialIconButton({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FaIcon(icon, color: iconColor, size: 26),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Preview de la cámara como fondo ──────────────────────────────────────────

class _CameraPreviewLayer extends StatelessWidget {
  const _CameraPreviewLayer({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize?.height ?? 1,
          height: controller.value.previewSize?.width ?? 1,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

// ── Barra superior (selector de corte + botón info) ───────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.corte,
    required this.onCorteChanged,
    required this.onInfoTap,
  });

  final int corte;
  final ValueChanged<int> onCorteChanged;
  final VoidCallback onInfoTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          const SizedBox(width: 40),
          Expanded(
            child: Center(
              child: _CorteSelectorPill(
                corte: corte,
                onChanged: onCorteChanged,
              ),
            ),
          ),
          _InfoButton(onTap: onInfoTap),
        ],
      ),
    );
  }
}

class _CorteSelectorPill extends StatelessWidget {
  const _CorteSelectorPill({required this.corte, required this.onChanged});

  final int corte;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _colorSurface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [10, 20, 50]
            .map(
              (c) => _CorteChip(
                value: c,
                selected: corte == c,
                onTap: () => onChanged(c),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CorteChip extends StatelessWidget {
  const _CorteChip({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _colorPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          'Bs $value',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: selected
                ? _colorBgDark
                : Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

class _InfoButton extends StatelessWidget {
  const _InfoButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _colorSurface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: const Icon(Icons.info_outline, color: Colors.white, size: 20),
      ),
    );
  }
}

// ── Zona de escaneo central (marco del billete) ───────────────────────────────

class _ScanArea extends StatelessWidget {
  const _ScanArea({this.cameraError});

  final String? cameraError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Marco con bordes estilo escáner
          AspectRatio(
            aspectRatio: 1.8,
            child: Stack(
              children: [
                // Fondo semitransparente
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _colorPrimary.withValues(alpha: 0.15),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),

                // Línea central de escaneo animada
                const _ScanLine(),

                // Esquinas del marco
                ..._buildCorners(),

                // Texto central
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      cameraError != null
                          ? 'Sin acceso a cámara'
                          : 'Alinea la serie aquí',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        shadows: [
                          const Shadow(color: Colors.black54, blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Text(
            'Mantén el billete estable\ny con buena iluminación',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCorners() {
    const size = 32.0;
    const thickness = 4.0;
    const radius = 14.0;

    Widget corner({
      required AlignmentGeometry alignment,
      required BorderRadius borderRadius,
    }) {
      return Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: size,
            height: size,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top:
                      borderRadius ==
                          const BorderRadius.only(
                            topLeft: Radius.circular(radius),
                          )
                      ? const BorderSide(color: _colorPrimary, width: thickness)
                      : borderRadius ==
                            const BorderRadius.only(
                              topRight: Radius.circular(radius),
                            )
                      ? const BorderSide(color: _colorPrimary, width: thickness)
                      : BorderSide.none,
                  bottom:
                      borderRadius ==
                          const BorderRadius.only(
                            bottomLeft: Radius.circular(radius),
                          )
                      ? const BorderSide(color: _colorPrimary, width: thickness)
                      : borderRadius ==
                            const BorderRadius.only(
                              bottomRight: Radius.circular(radius),
                            )
                      ? const BorderSide(color: _colorPrimary, width: thickness)
                      : BorderSide.none,
                  left:
                      (borderRadius ==
                              const BorderRadius.only(
                                topLeft: Radius.circular(radius),
                              ) ||
                          borderRadius ==
                              const BorderRadius.only(
                                bottomLeft: Radius.circular(radius),
                              ))
                      ? const BorderSide(color: _colorPrimary, width: thickness)
                      : BorderSide.none,
                  right:
                      (borderRadius ==
                              const BorderRadius.only(
                                topRight: Radius.circular(radius),
                              ) ||
                          borderRadius ==
                              const BorderRadius.only(
                                bottomRight: Radius.circular(radius),
                              ))
                      ? const BorderSide(color: _colorPrimary, width: thickness)
                      : BorderSide.none,
                ),
                borderRadius: borderRadius,
              ),
            ),
          ),
        ),
      );
    }

    return [
      corner(
        alignment: Alignment.topLeft,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(radius)),
      ),
      corner(
        alignment: Alignment.topRight,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(radius),
        ),
      ),
      corner(
        alignment: Alignment.bottomLeft,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(radius),
        ),
      ),
      corner(
        alignment: Alignment.bottomRight,
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(radius),
        ),
      ),
    ];
  }
}

// ── Línea de escaneo animada ──────────────────────────────────────────────────

class _ScanLine extends StatefulWidget {
  const _ScanLine();

  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return Align(
          alignment: Alignment(0, (_anim.value * 2) - 1),
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: _colorPrimary.withValues(alpha: 0.6),
              boxShadow: [
                BoxShadow(
                  color: _colorPrimary.withValues(alpha: 0.8),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Panel inferior (teclado + tarjeta WhatsApp) ───────────────────────────────

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({required this.onTecladoTap, required this.onWhatsAppTap});

  final VoidCallback onTecladoTap;
  final VoidCallback onWhatsAppTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón de teclado (entrada manual) alineado a la derecha
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 12),
              child: _KeyboardButton(onTap: onTecladoTap),
            ),
          ),

          // Tarjeta de publicidad / contacto
          _ContactCard(onWhatsAppTap: onWhatsAppTap),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _KeyboardButton extends StatelessWidget {
  const _KeyboardButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: _colorSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.keyboard, color: _colorPrimary, size: 28),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.onWhatsAppTap});

  final VoidCallback onWhatsAppTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _colorSurface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Necesitas una app como esta?',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '¡Contáctame!',
                  style: GoogleFonts.inter(
                    color: _colorPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onWhatsAppTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF25D366).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'WhatsApp',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Overlay de resultado de verificación ─────────────────────────────────────

class _ResultOverlay extends StatelessWidget {
  const _ResultOverlay({
    required this.status,
    required this.serie,
    required this.corte,
    required this.onReset,
  });

  final VerificationStatus status;
  final String? serie;
  final int corte;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final isAnulado = status == VerificationStatus.anulado;
    final isError = status == VerificationStatus.error;

    final color = isError
        ? Colors.orange
        : isAnulado
        ? const Color(0xFFFF4444)
        : _colorPrimary;

    final icon = isError
        ? Icons.error_outline
        : isAnulado
        ? Icons.cancel_outlined
        : Icons.check_circle_outline;

    final titulo = isError
        ? 'Error de verificación'
        : isAnulado
        ? 'Billete SIN valor legal'
        : 'Billete VÁLIDO';

    final subtitulo = isError
        ? 'No se pudo verificar la serie. Intenta de nuevo.'
        : isAnulado
        ? 'La serie ${serie ?? ''} (Bs $corte) figura en la\nlista de billetes inhabilitados del BCB.'
        : 'La serie ${serie ?? ''} (Bs $corte) NO figura en\nla lista de billetes inhabilitados del BCB.';

    return GestureDetector(
      onTap: onReset,
      child: Container(
        color: Colors.black.withValues(alpha: 0.75),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: _colorSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 64),
                const SizedBox(height: 16),
                Text(
                  titulo,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitulo,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: isAnulado || isError
                        ? Colors.white
                        : _colorBgDark,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onReset,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(
                    'Escanear otro billete',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
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
