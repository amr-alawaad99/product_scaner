class Product{
  int? code;
  int? quantity;
  bool? isNew;

  Product({
    required this.code,
    required this.quantity,
    this.isNew = false,
  });


  // Convert Product object to a formatted string
  String toFormattedString() {
    return '$code,$quantity';
  }

  // Create a Product object from a formatted string
  factory Product.fromFormattedString(String productString) {
    final parts = productString.split(',');
    return Product(
      code: int.parse(parts[0]),
      quantity: int.parse(parts[1]),
    );
  }
}