import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_2/providers/auth.dart';
import 'package:shop_app_2/screens/auth_screen.dart';
import 'package:shop_app_2/screens/edit_product_screen.dart';
import 'package:shop_app_2/screens/products_overview_screen.dart';
import 'package:shop_app_2/screens/user_products_screen.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './screens/cart_screen.dart';
import './screens/orders_screen.dart';
import './screens/product_detail_screen.dart';

import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'providers/products.dart';
import 'screens/splash_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (_) => Products(null, [], ''),
            update: (ctx, auth, previusProducts) => Products(
                auth.token,
                previusProducts == null ? [] : previusProducts.items,
                auth.userId),
          ),
          ChangeNotifierProvider(
            create: (ctx) => Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (_) => Orders(
              '',
              [],
              '',
            ),
            update: (ctx, auth, previousOrder) => Orders(
              auth.token!,
              previousOrder == null ? [] : previousOrder.orders,
              auth.userId,
            ),
          ),
        ],
        child: Consumer<Auth>(
          builder: ((context, auth, _) => MaterialApp(
                title: 'MyShop',
                theme: FlexThemeData.light(
                  fontFamily: 'Lato',
                  scheme: FlexScheme.mandyRed,
                ),
                darkTheme: FlexThemeData.dark(scheme: FlexScheme.mandyRed),
                themeMode: ThemeMode.system,
                home: auth.isAuth
                    ? const ProductsOverviewScreen()
                    : FutureBuilder(
                        future: auth.tryAutoLogin(),
                        builder: (ctx, authResultSnapshot) =>
                            authResultSnapshot.connectionState ==
                                    ConnectionState.waiting
                                ? const SplashScreen()
                                : const AuthScreen(),
                      ),
                routes: {
                  ProductDetailScreen.routeName: ((context) =>
                      const ProductDetailScreen()),
                  CartScreen.routeName: ((context) => const CartScreen()),
                  OrdersScreen.routeName: (context) => OrdersScreen(),
                  UserProductsScreen.routeName: (context) =>
                      const UserProductsScreen(),
                  EditProductScreen.routeName: (context) =>
                      const EditProductScreen(),
                },
              )),
        ));
  }
}
