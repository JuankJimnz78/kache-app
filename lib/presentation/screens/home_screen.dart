import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:kache/presentation/screens/catalog/subcategoria_screen.dart';
import 'package:kache/presentation/providers/auth_provider.dart';
import 'package:kache/domain/model/comercio.dart';
import 'package:kache/theme/app_colors.dart';
import 'package:kache/presentation/widgets/fondo_patron.dart';
import 'package:kache/presentation/widgets/fondo_patron.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final username = user?.username ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const FondoPatron(),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 10,
                      child: SizedBox(
                        height: 50,
                        width: 180,
                        child: CustomPaint(
                          painter: TiraRombosCentradoPainter(),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text('PreciosEC',
                              style: const TextStyle(
                                  color: Color(0xFF1A237E),
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '¡Hola, $username! 👋',
                          style: const TextStyle(
                              color: Color(0xFF1A237E),
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Ahorra comparando antes de comprar',
                          style:
                              TextStyle(color: Color(0xFF666666), fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
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
                              fontSize: 22),
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
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
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
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.campaign_outlined,
                      color: AppColors.textFaint, size: 24),
                  SizedBox(height: 6),
                  Text('Espacio para anuncio publicitario',
                      style:
                          TextStyle(color: AppColors.textFaint, fontSize: 12)),
                ],
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
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => SubcategoriaScreen(tipo: tipo)));
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
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(tipo.emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(height: 8),
            Text(
              tipo.label,
              textAlign: TextAlign.left,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
