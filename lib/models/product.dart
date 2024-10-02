class Product{
  int? code;
  int? quantity;

  Product({
    required this.code,
    required this.quantity
  });


  Product.fromJson(Map<String,dynamic> json){
    code = json['code'];
    quantity = json['quantity'];

  }

  Map<String, dynamic> toMap(){
    return{
      'code' : code,
      'quantity' : quantity,
    };
  }
}