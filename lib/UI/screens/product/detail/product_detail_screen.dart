import 'package:ecomm_app/UI/screens/cart/cart_screen.dart';
import 'package:ecomm_app/main.dart';
import 'package:ecomm_app/models/cart_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.item});

  final Map<String, dynamic> item;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  void _incrementQuantity(int maxQuantity) {
    if (_quantity < maxQuantity) {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final maxQuantity = item['available_quantity'] ?? 1;
    final price = item['product_price'] ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 5,
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image(
                    image: widget.item['product_image'] != null
                        ? NetworkImage(widget.item['product_image'])
                        : const AssetImage('assets/images/placeholder.png'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.item['product_name'] ?? 'No product name',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.item['product_description'] ??
                    'No product description available.',
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _checkProductAvailability(widget.item),
                    Text(
                      'Price: Rs.${price.toString()}',
                      style: TextStyle(fontSize: 20, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Quantity:',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _decrementQuantity,
                        ),
                        Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _incrementQuantity(maxQuantity),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: Text(
          'Add to Cart',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          // Calculate total price
          final totalPrice = price * _quantity;

          // Add to local cart
          CartModel.addItem(
            CartItem(
              name: item['product_name'] ?? '',
              image: item['product_image'] ?? '',
              quantity: _quantity,
              price: price,
            ),
          );

          // Prepare cart data for Supabase
          final cartJson = CartModel.items
              .map(
                (cartItem) => {
                  'name': cartItem.name,
                  'image': cartItem.image,
                  'quantity': cartItem.quantity,
                  'price': cartItem.price,
                },
              )
              .toList();

          // Update Supabase user metadata
          final user = supabase.auth.currentUser;
          if (user != null) {
            // Update auth metadata (optional, as you already do)
            await supabase.auth.updateUser(
              UserAttributes(data: {...?user.userMetadata, 'cart': cartJson}),
            );

            // Update the "cart" column in the "user" table
            await supabase
                .from('profiles')
                .update({'cart': cartJson})
                .eq('id', user.id);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${item['product_name']} x$_quantity added to cart (Total: Rs.$totalPrice)',
              ),
            ),
          );
        },
      ),
    );
  }

  // Check product availability and return appropriate widget to notify the users.
  Widget _checkProductAvailability(Map<String, dynamic> item) {
    if (item['available_quantity'] == null || item['available_quantity'] <= 0) {
      // Handle out of stock scenario
      //print('Product is out of stock');
      return Text(
        'Out of stock.',
        style: TextStyle(fontSize: 20, color: Colors.black54),
      );
    } else {
      // Handle in stock scenario
      //print('Product is available');
      return Text(
        'In stock.',
        style: TextStyle(fontSize: 20, color: Colors.black54),
      );
    }
  }
}
