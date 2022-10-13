import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_2/providers/auth.dart';

import '../screens/product_detail_screen.dart';

import '../providers/cart.dart';
import '../providers/product.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);
    final authToken = Provider.of<Auth>(context, listen: false);
    return Consumer<Product>(
      builder: (ctx, product, child) => ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          footer: GridTileBar(
            leading: IconButton(
              highlightColor: Colors.white,
              splashColor: product.isFavorite
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).primaryColor,
              splashRadius: 2000,
              iconSize: 18,
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: product.isFavorite
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () {
                product.toggleFavoriteStatus(
                    authToken.token!, authToken.userId);
              },
            ),
            title: FittedBox(
              child: Text(
                product.title,
                textAlign: TextAlign.center,
              ),
            ),
            trailing: IconButton(
              iconSize: 18,
              icon: Icon(
                Icons.shopping_cart,
                color: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () {
                cart.addItem(product.id, product.price, product.title);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Added Item to cart!',
                    ),
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          cart.removeSingleItem(product.id);
                        }),
                  ),
                );
              },
            ),
            backgroundColor: Colors.black87,
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                ProductDetailScreen.routeName,
                arguments: product.id,
              );
            },
            child: Container(
              color: Colors.white,
              child: FittedBox(
                  fit: BoxFit.cover,
                  child: Hero(
                    tag: product.id,
                    child: FadeInImage(
                      placeholder: const AssetImage(
                        'assets/images/product-placeholder.png',
                      ),
                      image: NetworkImage(product.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
