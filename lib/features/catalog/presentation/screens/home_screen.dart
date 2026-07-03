// lib/features/catalog/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../comercios/domain/models/comercio.dart';
import '../../../../core/theme/app_colors.dart';
import 'catalog_screen.dart';
import '../../../precios/presentation/screens/lista_comparacion_screen.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _confirmarCerrarSesion(
      BuildContext context, WidgetRef ref) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres salir de tu cuenta?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar sesión',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Íconos grandes y translúcidos de fondo (no fotos) ──────
          Positioned(
            top: 130,
            right: -30,
            child: Transform.rotate(
              angle: -0.3,
              child: Icon(
                TipoComercio.supermercado.icon,
                size: 150,
                color: TipoComercio.supermercado.color.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            top: 350,
            left: -40,
            child: Transform.rotate(
              angle: 0.2,
              child: Icon(
                TipoComercio.farmacia.icon,
                size: 130,
                color: TipoComercio.farmacia.color.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: -20,
            child: Transform.rotate(
              angle: 0.15,
              child: Icon(
                TipoComercio.ferreteria.icon,
                size: 120,
                color: TipoComercio.ferreteria.color.withValues(alpha: 0.08),
              ),
            ),
          ),

          Positioned(
            bottom: 60,
            right: 20,
            child: Transform.rotate(
              angle: 0.30,
              child: Icon(
                TipoComercio.ferreteria.icon,
                size: 120,
                color: TipoComercio.ferreteria.color.withValues(alpha: 0.08),
              ),
            ),
          ),

          Positioned(
            top: 175,
            left: 40,
            child: Transform.rotate(
              angle: 0.4,
              child: Icon(
                TipoComercio.farmacia.icon,
                size: 130,
                color: TipoComercio.farmacia.color.withValues(alpha: 0.08),
              ),
            ),
          ),

          Positioned(
            top: 75,
            right: 30,
            child: Transform.rotate(
              angle: -0.6,
              child: Icon(
                TipoComercio.supermercado.icon,
                size: 150,
                color: TipoComercio.supermercado.color.withValues(alpha: 0.08),
              ),
            ),
          ),

          // ── Contenido real ──────────────────────────────────────
          Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 223, 131, 3),
                      Color.fromARGB(255, 48, 51, 251)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Kache',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.list_alt, color: Colors.white),
                          tooltip: 'Mi lista de compras',
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const ListaComparacionScreen()),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          onPressed: () => _confirmarCerrarSesion(context, ref),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '¡Hola, ${user?.username ?? ''}! 👋',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ahorra comparando antes de comprar',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _AnuncioVideo(),
                        const SizedBox(height: 24),
                        const Text(
                          '¿Qué quieres comparar hoy?',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        const SizedBox(height: 14),
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.85,
                          children: TipoComercio.values
                              .map((tipo) => _CategoriaTile(tipo: tipo))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnuncioVideo extends StatefulWidget {
  const _AnuncioVideo();

  @override
  State<_AnuncioVideo> createState() => _AnuncioVideoState();
}

class _AnuncioVideoState extends State<_AnuncioVideo> {
  late VideoPlayerController _controller;
  bool _listo = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
          'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'),
    );
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() => _listo = true);
      _controller.setLooping(true);
      _controller.setVolume(0);
      _controller.play();
    }).catchError((e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'No se pudo cargar el video:\n$_error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error, fontSize: 11),
                ),
              ),
            )
          : _listo
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Publicidad',
                            style:
                                TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ),
                  ],
                )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}

class _CategoriaTile extends StatelessWidget {
  final TipoComercio tipo;
  const _CategoriaTile({required this.tipo});

  @override
  Widget build(BuildContext context) {
    final colorOscuro = Color.lerp(tipo.color, Colors.black, 0.25)!;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => CatalogScreen(tipo: tipo)));
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [tipo.color, colorOscuro],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
                color: tipo.color.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.50),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(tipo.emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(height: 8),
            Text(
              tipo.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
