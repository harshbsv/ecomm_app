import 'package:flutter/material.dart';
import 'package:ecomm_app/models/cart_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCartFromDatabase();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 10));
      await _loadCartFromDatabase();
      return mounted;
    });
  }

  Future<void> _loadCartFromDatabase() async {
    setState(() {
      _isLoading = true;
    });
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user != null) {
      final response = await supabase
          .from('profiles')
          .select('cart')
          .eq('id', user.id)
          .single();
      final cartData = response['cart'];
      if ((CartModel.items.isEmpty && cartData != null && cartData is List) ||
          (_isCartDifferent(cartData))) {
        CartModel.items.clear();
        if (cartData != null && cartData is List) {
          for (var item in cartData) {
            CartModel.items.add(
              CartItem(
                name: item['name'] ?? '',
                image: item['image'] ?? '',
                quantity: item['quantity'] ?? 1,
                price: item['price'] ?? 0,
              ),
            );
          }
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  bool _isCartDifferent(dynamic cartData) {
    if (cartData == null || cartData is! List) return false;
    if (CartModel.items.length != cartData.length) return true;
    for (int i = 0; i < cartData.length; i++) {
      final local = CartModel.items[i];
      final remote = cartData[i];
      if (local.name != remote['name'] ||
          local.quantity != remote['quantity'] ||
          local.price != remote['price']) {
        return true;
      }
    }
    return false;
  }

  void _incrementQuantity(int index) {
    setState(() {
      CartModel.items[index].quantity++;
    });
    _updateCartInDatabase();
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (CartModel.items[index].quantity > 1) {
        CartModel.items[index].quantity--;
      }
    });
    _updateCartInDatabase();
  }

  Future<void> _updateCartInDatabase() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user != null) {
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
      await supabase
          .from('profiles')
          .update({'cart': cartJson})
          .eq('id', user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Cart',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 5,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 30.0),
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CartModel.items.isEmpty
                  ? Center(
                      child: Text(
                        'Your cart is empty.',
                        style: TextStyle(fontSize: 20, color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: CartModel.items.length,
                      itemBuilder: (context, index) {
                        final cartItem = CartModel.items[index];
                        return ListTile(
                          leading: cartItem.image.isNotEmpty
                              ? Image.network(
                                  cartItem.image,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                )
                              : null,
                          title: Text(cartItem.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () => _decrementQuantity(index),
                                  ),
                                  Text(
                                    '${cartItem.quantity}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () => _incrementQuantity(index),
                                  ),
                                ],
                              ),
                              Text(
                                'Price: Rs.${cartItem.price * cartItem.quantity}',
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle),
                            onPressed: () {
                              setState(() {
                                CartModel.removeItem(index);
                              });
                              _updateCartInDatabase();
                            },
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(Icons.delete_forever, color: Colors.white),
                    label: const Text(
                      'Clear Cart',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    onPressed: () async {
                      setState(() {
                        CartModel.items.clear();
                      });
                      final supabase = Supabase.instance.client;
                      final user = supabase.auth.currentUser;
                      if (user != null) {
                        await supabase
                            .from('profiles')
                            .update({'cart': []})
                            .eq('id', user.id);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cart cleared')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(Icons.payment, color: Colors.white),
                    label: const Text(
                      'Checkout',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Checkout functionality not implemented',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
