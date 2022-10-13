import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_2/widgets/app_drawer.dart';
import 'package:shop_app_2/widgets/user_product_item.dart';

import '../providers/products.dart';
import 'edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  const UserProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName,
                    arguments: 'newProduct');
              },
              icon: const Icon(Icons.add))
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: ((context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<Products>(
                      builder: (context, productsData, _) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: productsData.items.length,
                          itemBuilder: (context, index) => Column(
                            children: [
                              UserProductItem(
                                  id: productsData.items[index].id,
                                  title: productsData.items[index].title,
                                  imageUrl: productsData.items[index].imageUrl),
                              const Divider(
                                thickness: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
      ),
    );
  }
}
