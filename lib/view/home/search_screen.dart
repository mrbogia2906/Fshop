import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '/controller/product_service.dart';
import '/model/product.dart';
import 'product_details_screen.dart'; // Import the ProductDetailsScreen

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = "";
  List<Product> searchResults = [];
  List<Product> suggestedProducts = [];
  String selectedSort = 'Newest';

  @override
  void initState() {
    super.initState();
    fetchSuggestedProducts();
  }

  void fetchSuggestedProducts() async {
    final productService = Provider.of<ProductService>(context, listen: false);
    var results = await productService.getSuggestedProducts(limit: 5);
    setState(() {
      suggestedProducts = results;
    });
  }

  void searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        searchQuery = query;
        sortSuggestedProducts(); // Sort suggested products
      });
      return;
    }

    final productService = Provider.of<ProductService>(context, listen: false);
    var results = await productService.searchProducts(query);
    setState(() {
      searchResults = results;
      searchQuery = query;
      sortSearchResults(); // Sort search results
    });
  }

  void sortSearchResults() {
    if (selectedSort == 'Price: Low to High') {
      searchResults.sort((a, b) => a.price.compareTo(b.price));
    } else if (selectedSort == 'Price: High to Low') {
      searchResults.sort((a, b) => b.price.compareTo(a.price));
    }
  }

  void sortSuggestedProducts() {
    if (selectedSort == 'Price: Low to High') {
      suggestedProducts.sort((a, b) => a.price.compareTo(b.price));
    } else if (selectedSort == 'Price: High to Low') {
      suggestedProducts.sort((a, b) => b.price.compareTo(a.price));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Search', style: TextStyle(color: Colors.black)),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14.0),
                      ),
                      onChanged: (value) => searchProducts(value),
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () {
                      _showSortOptionsDialog(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Result for "$searchQuery"',
                    style: TextStyle(fontSize: 18)),
                Text('${searchResults.length} found',
                    style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          Expanded(
            child: searchResults.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) =>
                        ProductListItem(product: searchResults[index]),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: suggestedProducts.length,
                          itemBuilder: (context, index) => ProductListItem(
                              product: suggestedProducts[index]),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _showSortOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sort by'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text('Newest'),
                value: 'Newest',
                groupValue: selectedSort,
                onChanged: (value) {
                  setState(() {
                    selectedSort = value!;
                    sortSearchResults();
                    sortSuggestedProducts();
                  });
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                title: Text('Price: Low to High'),
                value: 'Price: Low to High',
                groupValue: selectedSort,
                onChanged: (value) {
                  setState(() {
                    selectedSort = value!;
                    sortSearchResults();
                    sortSuggestedProducts();
                  });
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                title: Text('Price: High to Low'),
                value: 'Price: High to Low',
                groupValue: selectedSort,
                onChanged: (value) {
                  setState(() {
                    selectedSort = value!;
                    sortSearchResults();
                    sortSuggestedProducts();
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProductListItem extends StatelessWidget {
  final Product product;

  ProductListItem({required this.product});

  @override
  Widget build(BuildContext context) {
    final formattedPrice = NumberFormat.currency(
      locale: 'vi',
      symbol: '₫',
      decimalDigits: 0,
    ).format(product.price);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
                product: product), // Navigate to ProductDetailsScreen
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Image.network(
                product.imageUrl,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Size: ${product.size} || Qty: ${product.quantity}',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 4),
                    Text(
                      formattedPrice,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
