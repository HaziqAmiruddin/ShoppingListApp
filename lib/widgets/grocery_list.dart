import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
//import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  //use for backend get request
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadItem();
  }

  //use for backend get request
  void _loadItem() async {
    final url = Uri.https(
        'flutter-prep-f3d37-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list.json');
    //code potential to fail put into try
    // final response = await http.get(url);

    //throw Exception('Error Detected!');

    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to get data, Try again later.';
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;
        loadedItems.add(
          GroceryItem(
              id: item.key,
              name: item.value['name'],
              quantity: item.value['quantity'],
              category: category),
        );
      }

      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Something went wrong, Try again later.';
      });
    }

    // put into try
    // if (response.statusCode >= 400) {
    //   setState(() {
    //     _error = 'Failed to get data, Try again later.';
    //   });
    // }

    // put into try
    // if (response.body == 'null') {
    //   setState(() {
    //     _isLoading == false;
    //   });
    //   return;
    // }

    // put into try
    // final Map<String, dynamic> listData = json.decode(response.body);
    // final List<GroceryItem> loadedItems = [];
    // for (final item in listData.entries) {
    //   final category = categories.entries
    //       .firstWhere(
    //           (catItem) => catItem.value.title == item.value['category'])
    //       .value;
    //   loadedItems.add(
    //     GroceryItem(
    //         id: item.key,
    //         name: item.value['name'],
    //         quantity: item.value['quantity'],
    //         category: category),
    //   );
    // }

    // put into try
    // setState(() {
    //   _groceryItems = loadedItems;
    //   _isLoading = false;
    // });
  }

  void _addItem() async {
    //final newItem =
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    //use for backend get request
    //_loadItem();

    //use back on 288
    //we will get the data from backend
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
        'flutter-prep-f3d37-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list/${item.id}.json');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      // Optional: Show Error Message Write the code here
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('Empty List'),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (directin) {
            _removeItem(_groceryItems[index]);
          },
          key: ValueKey(_groceryItems[index].id),
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(
              _groceryItems[index].quantity.toString(),
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: content,
    );
  }
}
