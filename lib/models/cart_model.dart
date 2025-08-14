class CartItem {
  final String name;
  final String image;
  int quantity;
  final int price;

  CartItem({
    required this.name,
    required this.image,
    required this.quantity,
    required this.price,
  });
}

class CartModel {
  static final List<CartItem> items = [];

  static void addItem(CartItem item) {
    // If item exists, update quantity
    final index = items.indexWhere((e) => e.name == item.name);
    if (index != -1) {
      items[index] = CartItem(
        name: item.name,
        image: item.image,
        quantity: items[index].quantity + item.quantity,
        price: item.price,
      );
    } else {
      items.add(item);
    }
  }

  static void removeItem(int index) {
    items.removeAt(index);
  }
}
