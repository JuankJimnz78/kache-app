// lib/presentation/screens/admin/admin_home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache/presentation/providers/auth_provider.dart';
import 'package:kache/presentation/screens/admin/categorias_admin_screen.dart';
import 'package:kache/presentation/screens/admin/comercios_admin_screen.dart';
import 'package:kache/presentation/screens/admin/precios_admin_screen.dart';
import 'package:kache/presentation/screens/admin/productos_admin_screen.dart';
import 'package:kache/presentation/screens/admin/sucursales_admin_screen.dart';
import 'package:kache/theme/app_colors.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authProvider).user;
    final esAdmin = usuario?.esAdmin ?? false;

    // Comercios, Sucursales y Categorías son estructurales: solo ADMIN.
    // Productos y Precios son operativos: ADMIN y OPERADOR.
    final tabs = <Tab>[
      if (esAdmin)
        const Tab(icon: Icon(Icons.storefront_outlined, size: 20), text: 'Comercios'),
      if (esAdmin)
        const Tab(icon: Icon(Icons.location_on_outlined, size: 20), text: 'Sucursales'),
      if (esAdmin)
        const Tab(icon: Icon(Icons.category_outlined, size: 20), text: 'Categorías'),
      const Tab(icon: Icon(Icons.inventory_2_outlined, size: 20), text: 'Productos'),
      const Tab(icon: Icon(Icons.attach_money, size: 20), text: 'Precios'),
    ];

    final vistas = <Widget>[
      if (esAdmin) const ComerciosAdminScreen(),
      if (esAdmin) const SucursalesAdminScreen(),
      if (esAdmin) const CategoriasAdminScreen(),
      const ProductosAdminScreen(),
      const PreciosAdminScreen(),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Panel de administración',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              Text(
                esAdmin ? 'Rol: Administrador' : 'Rol: Operador',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
          bottom: TabBar(
            isScrollable: true,
            labelColor: AppColors.accentDark,
            unselectedLabelColor: AppColors.textFaint,
            indicatorColor: AppColors.accent,
            labelStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            tabs: tabs,
          ),
        ),
        body: TabBarView(children: vistas),
      ),
    );
  }
}
