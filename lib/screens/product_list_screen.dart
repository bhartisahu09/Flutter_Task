import 'package:flutter/material.dart';
import 'package:flutter_task/model/product_model.dart';
import 'package:flutter_task/screens/card_screen.dart';
import 'package:flutter_task/services/api_service.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final Map<int, bool> _favoriteMap = {};
  final List<Product> _cartItems = [];
  final Map<int, int> _quantityMap = {};

  late Future<List<Product>> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = ApiService.fetchProducts();
  }

  void _addToCart(Product product) {
    setState(() {
      _cartItems.add(product);
      _quantityMap[product.id] = 1;
    });
    _showSnackBar('${product.title} added to cart');
  }

  void _increaseQuantity(Product product) {
    setState(() {
      _quantityMap[product.id] = (_quantityMap[product.id] ?? 0) + 1;
    });
  }

  void _decreaseQuantity(Product product) {
    final currentQty = _quantityMap[product.id] ?? 0;
    if (currentQty > 1) {
      setState(() {
        _quantityMap[product.id] = currentQty - 1;
      });
    } else {
      setState(() {
        _quantityMap.remove(product.id);
        _cartItems.remove(product);
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Widget _buildProductCard(Product product) {
    final isFavorite = _favoriteMap[product.id] ?? false;
    final inCart = _quantityMap.containsKey(product.id);
    final quantity = _quantityMap[product.id] ?? 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  product.image,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _favoriteMap[product.id] = !isFavorite;
                    });
                  },
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                inCart
                    ? _buildQuantityControl(product, quantity)
                    : _buildAddToCartButton(product),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton(Product product) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 39, 54, 223),
        minimumSize: const Size.fromHeight(35),
      ),
      onPressed: () => _addToCart(product),
      icon: const Icon(Icons.shopping_cart_checkout, size: 18),
      label: const Text("Add to Cart"),
    );
  }

  Widget _buildQuantityControl(Product product, int quantity) {
    return SizedBox(
      height: 35,
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 39, 54, 223),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => _decreaseQuantity(product),
              icon: const Icon(Icons.remove, color: Colors.white),
            ),
            Text(
              '$quantity',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => _increaseQuantity(product),
              icon: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopee'),
        backgroundColor: const Color.fromARGB(255, 45, 56, 182),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(
                    cartItems: _cartItems,
                    quantityMap: _quantityMap,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          final products = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) => _buildProductCard(products[index]),
          );
        },
      ),
    );
  }
}
