import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MyHiveHomePage extends StatefulWidget {
  const MyHiveHomePage({super.key});

  @override
  State<MyHiveHomePage> createState() => _MyHiveHomePageState();
}

class _MyHiveHomePageState extends State<MyHiveHomePage> {
  List<Map<String, dynamic>> _items = [];
  final _shoppingBox = Hive.box('shopping_box');

  void _refreshItems() {
    final data = _shoppingBox.keys.map((e) {
      final value = _shoppingBox.get(e);

      return {
        "key": e,
        "name": value["name"],
        "quantity": value["quantity"],
      };
    }).toList();

    setState(() {
      _items = data.reversed.toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  Future<void> _createItem(Map<String, dynamic> myItems) async {
    await _shoppingBox.add(myItems);
    _refreshItems();
  }

  Map<String, dynamic> _readItem(int _key) {
    final item = _shoppingBox.get(_key);
    return item;
  }

  Future<void> _deleteItem(int itemKey) async {
    await _shoppingBox.delete(itemKey);
    _refreshItems();

   ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Data Has Been Deleted',
        ),
      ),
    );
  }

  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await _shoppingBox.put(itemKey, item);
    _refreshItems();
  }

  var _nameController = TextEditingController();
  var _quantityController = TextEditingController();

  void _showForm(BuildContext ctx, int? itemKey) async {
    if (itemKey != null) {
      final existingItem =
          _items.firstWhere((element) => element['key'] == itemKey);

      _nameController.text = existingItem['name'];
      _quantityController.text = existingItem['quantity'];
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => SingleChildScrollView(
        child: Container(
          height: 300,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                top: 15,
                left: 15,
                right: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(hintText: 'Item Name'),
                ),
                TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Item Quantity',
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (itemKey == null) {
                      _createItem({
                        'name': _nameController.text,
                        'quantity': _quantityController.text
                      });
                    }
                    if (itemKey != null) {
                      _updateItem(itemKey, {
                        'name': _nameController.text,
                        'quantity': _quantityController.text,
                      });
                    }

                    _nameController.text = '';
                    _quantityController.text = '';
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    itemKey == null ? 'Add Data' : 'Update Data',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive Home Page'),
      ),
      body: _items.isEmpty
          ? Center(
              child: Text('No Data'),
            )
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final currentItem = _items[index];
                return ListTile(
                  minVerticalPadding: 5,
                  tileColor: Colors.amber.shade100,
                  title: Text(currentItem['name']),
                  subtitle: Text(currentItem['quantity']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          _showForm(context, currentItem['key']);
                        },
                        icon: Icon(
                          Icons.edit,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _deleteItem(currentItem['key']);
                        },
                        icon: Icon(
                          Icons.delete,
                        ),
                      ),
                    ],
                  ),
                );
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: Icon(Icons.add),
      ),
    );
  }
}
