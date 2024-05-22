import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../model/product.dart';
import '../../controller/product_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CreateProductScreen extends StatefulWidget {
  @override
  _CreateProductScreenState createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _productInfoController = TextEditingController();
  final _sizeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _categoryController = TextEditingController();
  File? _imageFile;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

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

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create Product",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
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
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo,
                                size: 50, color: Colors.grey),
                            SizedBox(height: 8.0),
                            Text("Add Image",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 16)),
                          ],
                        ),
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
              buildLabeledTextFormField(
                'Quantity',
                _quantityController,
              ),
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
                            String imageUrl = '';
                            if (_imageFile != null) {
                              imageUrl = await _uploadImage(_imageFile!);
                            }
                            final category = _categoryController.text.trim();
                            await _addCategoryIfNotExists(category);
                            final product = Product(
                              id: DateTime.now().toString(),
                              name: _nameController.text,
                              price: double.parse(_priceController.text),
                              productInfo: _productInfoController.text,
                              size: _sizeController.text,
                              quantity: int.parse(_quantityController.text),
                              category: category,
                              imageUrl: imageUrl.isEmpty
                                  ? 'https://via.placeholder.com/150'
                                  : imageUrl,
                            );
                            await productService.addProduct(product);
                            Navigator.of(context)
                                .pop(); // Optionally pop back after saving
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Failed to add product: $e'),
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
