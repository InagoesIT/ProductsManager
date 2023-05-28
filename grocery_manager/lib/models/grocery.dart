import 'package:get/get.dart';
import 'package:grocery_manager/models/product.dart';

class Grocery extends Product {
  var isBought = false.obs;

  Grocery({
    String name = "",
    String category = "",
    bool isBought = false,
    int quantity = 1,
  }) : super(name: name, category: category, quantity: quantity) {
    this.isBought.value = isBought;
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    isBought.value = json['isBought'];
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name.value,
      'category': category.value,
      'isBought': isBought.value,
      'quantity': quantity.value
    };
  }
}
