import 'package:flutter/material.dart';
import 'package:flutter_task/model/product_model.dart';

class CartScreen extends StatefulWidget {
  final List<Product> cartItems;
  final Map<int, int> quantityMap;

  const CartScreen(
      {Key? key, required this.cartItems, required this.quantityMap})
      : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void removeFromCart(Product product) {
    setState(() {
      widget.cartItems.remove(product);
      widget.quantityMap.remove(product.id);
    });
  }

  double getTotalPrice() {
    double total = 0;
    for (var item in widget.cartItems) {
      final quantity = widget.quantityMap[item.id] ?? 1;
      total += item.price * quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: const Color.fromARGB(255, 45, 56, 182),
      ),
      body: widget.cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      final product = widget.cartItems[index];
                      final quantity = widget.quantityMap[product.id] ?? 1;
                      final itemTotal = product.price * quantity;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: Image.network(
                            product.image,
                            height: 50,
                            width: 50,
                            fit: BoxFit.contain,
                          ),
                          title: Text(
                            product.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '\$${product.price.toStringAsFixed(2)} x $quantity = \$${itemTotal.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.green),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => removeFromCart(product),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: Text(
                    'Total: \$${getTotalPrice().toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
    );
  }
}
