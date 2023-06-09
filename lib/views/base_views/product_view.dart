import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:products_manager/controllers/product_categories_controller.dart';

import '../../controllers/products_controller.dart';
import '../../models/product_model.dart';

abstract class ProductView<T extends ProductModel> extends StatelessWidget {
  final T? product = null;
  final ProductsController<T>? productsController = null;
  final int? index;
  final ProductsCategoryController productsCategoryController = Get.find();

  ProductView({super.key, this.index});

  List<Widget> getProductElements(BuildContext context);

  T getUpdatedProduct();

  void loadProduct() {
    if (index != null) {
      product!.copyFrom(productsController!.getProduct(index!)!);
    }
  }

  @override
  Widget build(BuildContext context) {
    loadProduct();
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: index == null
                  ? const Text('Add a new item')
                  : const Text('Update item'),
            ),
            body: getBody(context)));
  }

  Widget getBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
      child: SingleChildScrollView(
          child: Column(
        children: getProductElements(context) + getProductButtons(),
      )),
    );
  }

  Align getProductName(TextEditingController nameEditingController) {
    return Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
            width: 250,
            child: TextField(
              controller: nameEditingController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: getInputDecoration("Name"),
              keyboardType: TextInputType.text,
              maxLines: 1,
              onChanged: (value) => product!.name.value = value,
            )));
  }

  SizedBox getSpaceBetweenElements(
      {required bool isVertical, double multiplier = 2}) {
    if (isVertical) {
      return SizedBox(height: 25 * multiplier);
    }
    return SizedBox(width: 25 * multiplier);
  }

  InputDecoration getInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black87),
          borderRadius: BorderRadius.circular(10)),
    );
  }

  Obx getProductCategoryHandler() {
    return Obx(() => Row(
          children: [
            getProductCategory(),
            getSpaceBetweenElements(isVertical: false),
            getProductCategoryAddButton()
          ],
        ));
  }

  Obx getProductCategory() {
    List<DropdownMenuItem<int>> dropdownItems = getCategoryDropdownItems();
    RxInt? currentCategoryIndex = (getCurrentCategoryIndex()).obs;

    return Obx(() => DropdownButton<int>(
          hint: const Text("Select a category"),
          disabledHint: const Text("No categories"),
          value: currentCategoryIndex.value < 0
              ? null
              : currentCategoryIndex.value,
          items: dropdownItems,
          onChanged: dropdownItems.isEmpty
              ? null
              : (categoryIndex) => {
                    currentCategoryIndex.value = categoryIndex!,
                    product!.category.value = productsCategoryController
                        .getCategory(currentCategoryIndex.value)!
                  },
        ));
  }

  int getCurrentCategoryIndex() {
    if (index != null) {
      String currentCategory =
          productsController!.getProduct(index!)!.category.value;
      return productsCategoryController.getIndexOf(currentCategory);
    }
    if (product!.category.value.isNotEmpty) {
      return productsCategoryController.getIndexOf(product!.category.value);
    }
    return -1;
  }

  List<DropdownMenuItem<int>> getCategoryDropdownItems() {
    List<DropdownMenuItem<int>> dropdownItems = List.empty(growable: true);

    for (int index = 0;
        index < productsCategoryController.getListSize();
        index++) {
      dropdownItems.add(DropdownMenuItem<int>(
          value: index,
          child: Text(productsCategoryController.getCategory(index)!)));
    }

    return dropdownItems;
  }

  List<Widget> getProductButtons() {
    return <Widget>[
      const SizedBox(height: 16),
      Row(children: <Widget>[
        getSpaceBetweenElements(isVertical: true, multiplier: 4),
        getCancelButton(),
        getSpaceBetweenElements(isVertical: false, multiplier: 4),
        getSubmitButton()
      ])
    ];
  }

  OutlinedButton getCancelButton() {
    return OutlinedButton(
      onPressed: () {
        Get.back();
      },
      child: const Text('Cancel'),
    );
  }

  ElevatedButton getSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        if (index == null) {
          productsController!.addProduct(product!);
        } else {
          T updatedProduct = getUpdatedProduct();
          productsController!.setIndexWithProduct(index!, updatedProduct);
        }

        Get.back();
      },
      child: index == null ? const Text('Add') : const Text('Update'),
    );
  }

  TextButton getProductCategoryAddButton() {
    return TextButton(
      onPressed: () {
        getProductCategoryDialog();
      },
      child: const Text('Add category'),
    );
  }

  Future<dynamic> getProductCategoryDialog() {
    final TextEditingController categoryTextController =
        TextEditingController();

    return Get.bottomSheet(Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          getProductCategoryDialogTitle(),
          getSpaceBetweenElements(isVertical: true),
          getCategoryInputField(categoryTextController),
          getSpaceBetweenElements(isVertical: true),
          getProductCategorySubmitButton(categoryTextController),
          getSpaceBetweenElements(isVertical: true),
          getProductCategoryCancelButton(),
        ],
      )),
    ));
  }

  Text getProductCategoryDialogTitle() {
    return const Text(
      'Add Category',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  TextField getCategoryInputField(
      TextEditingController categoryTextController) {
    return TextField(
      controller: categoryTextController,
      decoration: const InputDecoration(
        labelText: 'Category',
      ),
    );
  }

  OutlinedButton getProductCategoryCancelButton() {
    return OutlinedButton(
        child: const Text('Cancel'),
        onPressed: () {
          Get.back();
        });
  }

  ElevatedButton getProductCategorySubmitButton(
      TextEditingController categoryController) {
    return ElevatedButton(
      child: const Text('Add'),
      onPressed: () {
        String category = categoryController.text;
        if (category.isNotEmpty) {
          productsCategoryController.addProductCategory(category);
          Get.back();
        }
      },
    );
  }

  Align getProductQuantity(TextEditingController quantityEditingController) {
    int? processedValue;
    return Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
            width: 100,
            child: TextField(
              controller: quantityEditingController,
              decoration: getInputDecoration("Quantity"),
              keyboardType: TextInputType.number,
              maxLines: 1,
              onChanged: (value) => {
                processedValue = getValue(value),
                if (processedValue != null)
                  product!.quantity.value = int.parse(value)
              },
            )));
  }

  int? getValue(value) {
    try {
      int finalValue = int.parse(value);
      return finalValue;
    } catch (exception) {
      return null;
    }
  }
}
