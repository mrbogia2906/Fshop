import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../model/product.dart';
import '../../controller/product_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateProductScreen extends StatefulWidget {
  final Product product;

  UpdateProductScreen({required this.product});

  @override
  _UpdateProductScreenState createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _productInfoController;
  late TextEditingController _sizeController;
  late TextEditingController _quantityController;
  late TextEditingController _categoryController;
  File? _imageFile;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _productInfoController =
        TextEditingController(text: widget.product.productInfo);
    _sizeController = TextEditingController(text: widget.product.size);
    _quantityController =
        TextEditingController(text: widget.product.quantity.toString());
    _categoryController = TextEditingController(text: widget.product.category);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('product_images/${DateTime.now().toIso8601String()}');
    final uploadTask = storageRef.putFile(image);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _addCategoryIfNotExists(String category) async {
    final categoryRef =
        FirebaseFirestore.instance.collection('categories').doc(category);
    final categoryDoc = await categoryRef.get();
    if (!categoryDoc.exists) {
      await categoryRef.set({'name': category});
    }
  }

  Future<void> _deleteProduct(BuildContext context) async {
    final productService = Provider.of<ProductService>(context, listen: false);
    try {
      await productService.deleteProduct(widget.product.id);
      Navigator.of(context).pop(); // Go back after deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to delete product: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Update Product",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Delete Product'),
                    content:
                        Text('Are you sure you want to delete this product?'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      TextButton(
                        child:
                            Text('Delete', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ],
                  );
                },
              );

              if (confirm) {
                await _deleteProduct(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                      : Image.network(widget.product.imageUrl,
                          fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 16.0),
              buildLabeledTextFormField('Product name', _nameController),
              SizedBox(height: 16.0),
              buildLabeledTextFormField('Price (₫)', _priceController,
                  isNumeric: true),
              SizedBox(height: 16.0),
              buildLabeledTextFormField('Product Info', _productInfoController),
              SizedBox(height: 16.0),
              buildLabeledTextFormField('Size', _sizeController),
              SizedBox(height: 16.0),
              buildLabeledTextFormField('Quantity', _quantityController),
              SizedBox(height: 16.0),
              buildLabeledTextFormField('Category', _categoryController),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _isUploading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isUploading = true;
                          });
                          try {
                            String imageUrl = widget.product.imageUrl;
                            if (_imageFile != null) {
                              imageUrl = await _uploadImage(_imageFile!);
                            }
                            final category = _categoryController.text.trim();
                            await _addCategoryIfNotExists(category);
                            final updatedProduct = Product(
                              id: widget.product.id,
                              name: _nameController.text,
                              price: double.parse(_priceController.text),
                              productInfo: _productInfoController.text,
                              size: _sizeController.text,
                              quantity: int.parse(_quantityController.text),
                              category: category,
                              imageUrl: imageUrl,
                            );
                            await productService.updateProduct(updatedProduct);
                            Navigator.of(context)
                                .pop(); // Optionally pop back after saving
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Failed to update product: $e'),
                            ));
                          } finally {
                            setState(() {
                              _isUploading = false;
                            });
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding:
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: _isUploading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLabeledTextFormField(
      String labelText, TextEditingController controller,
      {bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding:
                EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $labelText';
            }
            return null;
          },
        ),
      ],
    );
  }
}
