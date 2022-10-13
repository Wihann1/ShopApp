import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_2/providers/products.dart';
import '../providers/cart.dart';
import '../screens/cart_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/badge.dart';
import '../widgets/products_grid.dart';

enum FilterOptions {
  favorites,
  all,
}

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isLoading = false;

  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });

    Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts()
        .then((value) => setState(() {
              _isLoading = false;
            }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyShop'),
        actions: [
          PopupMenuButton(
              onSelected: (selecteValue) {
                setState(() {
                  if (selecteValue == FilterOptions.favorites) {
                    _showOnlyFavorites = true;
                  } else {
                    _showOnlyFavorites = false;
                  }
                });
              },
              icon: const Icon(Icons.more_vert),
              itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: FilterOptions.favorites,
                      child: Text('Only Favorites'),
                    ),
                    const PopupMenuItem(
                      value: FilterOptions.all,
                      child: Text('Show All'),
                    )
                  ]),
          Consumer<Cart>(
            builder: (_, cartData, ch) => Badge(
              value: cartData.itemCount.toString(),
              child: ch!,
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.pushNamed(context, CartScreen.routeName);
              },
            ),
          )
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ProductsGrid(showFavs: _showOnlyFavorites),
    );
  }
}
