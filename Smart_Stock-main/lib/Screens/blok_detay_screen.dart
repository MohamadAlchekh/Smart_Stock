import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/statik_provider.dart';

class BlockDetailScreen extends StatefulWidget {
  final String blockName;
  final int blockIndex;
  final List<dynamic> products;
  final Function(String, String, String, String) onAddProduct;
  final Function(int, String, String, String, String) onEditProduct;
  final Function(int) onDeleteProduct;
  final bool isAdmin;
  final String userName;
  final String? role;
  final String warehouseName;

  const BlockDetailScreen({
    Key? key,
    required this.blockName,
    required this.blockIndex,
    required this.products,
    required this.onAddProduct,
    required this.onEditProduct,
    required this.onDeleteProduct,
    required this.isAdmin,
    required this.userName,
    required this.warehouseName,
    this.role,
  }) : super(key: key);

  @override
  State<BlockDetailScreen> createState() => _BlockDetailScreenState();
}

class _BlockDetailScreenState extends State<BlockDetailScreen> {
  final TextEditingController searchController = TextEditingController();
  late List<dynamic> filteredProducts;

  @override
  void initState() {
    super.initState();
    filteredProducts = List.from(widget.products);
  }

  String get _displayName => widget.isAdmin ? 'Yönetici' : widget.userName;

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredProducts = List.from(widget.products);
      } else {
        filteredProducts = widget.products.where((product) {
          final name = (product['name'] ?? '').toString().toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _showAddProductDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController weightController = TextEditingController();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
        title: Text(
          'Ürün Ekle',
          style: TextStyle(
            color: isDarkMode ? Colors.white : const Color(0xFF1A237E),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Ürün Adı',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : const Color(0xFF1A237E),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priceController,
              decoration: InputDecoration(
                labelText: 'Fiyat (₺)',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : const Color(0xFF1A237E),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Adet',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : const Color(0xFF1A237E),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: weightController,
              decoration: InputDecoration(
                labelText: 'Kilo (kg)',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : const Color(0xFF1A237E),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: TextStyle(
                color: isDarkMode ? Colors.white : const Color(0xFF1A237E),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final price = priceController.text.trim();
              final quantity = quantityController.text.trim();
              final weight = weightController.text.trim();

              if (name.isNotEmpty && price.isNotEmpty && quantity.isNotEmpty && weight.isNotEmpty) {
                // İstatistik kaydı ekle
                final statistics = Provider.of<StatisticsProvider>(context, listen: false);
                statistics.addLog(
                  _displayName,
                  widget.warehouseName,
                  widget.blockName,
                  name,
                  int.parse(quantity),
                  true, // ekleme işlemi
                  role: widget.role,
                );

                widget.onAddProduct(name, price, quantity, weight);
                Navigator.pop(context);
                setState(() {
                  filteredProducts = List.from(widget.products);
                });
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Uyarı'),
                    content: const Text('Lütfen tüm alanları doldurunuz.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tamam'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: Text(
              'Ekle',
              style: TextStyle(
                color: isDarkMode ? Colors.white : const Color(0xFF1A237E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(int index) {
    final product = filteredProducts[index];
    final TextEditingController nameController = TextEditingController(text: product['name']);
    final TextEditingController priceController = TextEditingController(text: product['price']);
    final TextEditingController quantityController = TextEditingController(text: product['quantity']);
    final TextEditingController weightController = TextEditingController(text: product['weight']);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final oldQuantity = int.parse(product['quantity']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
        title: Text(
          'Ürün Düzenle',
          style: TextStyle(
            color: isDarkMode ? Colors.white : const Color(0xFF1A237E),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Ürün Adı',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : const Color(0xFF1A237E),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priceController,
              decoration: InputDecoration(
                labelText: 'Fiyat (₺)',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : const Color(0xFF1A237E),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Adet',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : const Color(0xFF1A237E),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: weightController,
              decoration: InputDecoration(
                labelText: 'Kilo (kg)',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : const Color(0xFF1A237E),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: TextStyle(
                color: isDarkMode ? Colors.white : const Color(0xFF1A237E),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final price = priceController.text.trim();
              final quantity = quantityController.text.trim();
              final weight = weightController.text.trim();

              if (name.isNotEmpty && price.isNotEmpty && quantity.isNotEmpty && weight.isNotEmpty) {
                final newQuantity = int.parse(quantity);
                final statistics = Provider.of<StatisticsProvider>(context, listen: false);

                // Adet sayısı değişmişse log kaydı ekle
                if (newQuantity != oldQuantity) {
                  if (newQuantity < oldQuantity) {
                    // Adet azaltıldıysa silme kaydı ekle
                    final removedQuantity = oldQuantity - newQuantity;
                    statistics.addLog(
                      _displayName,
                      widget.warehouseName,
                      widget.blockName,
                      name,
                      removedQuantity,
                      false, // silme işlemi
                      role: widget.role,
                    );
                  } else {
                    // Adet artırıldıysa ekleme kaydı ekle
                    final addedQuantity = newQuantity - oldQuantity;
                    statistics.addLog(
                      _displayName,
                      widget.warehouseName,
                      widget.blockName,
                      name,
                      addedQuantity,
                      true, // ekleme işlemi
                      role: widget.role,
                    );
                  }
                }

                widget.onEditProduct(index, name, price, quantity, weight);
                Navigator.pop(context);
                setState(() {
                  filteredProducts = List.from(widget.products);
                });
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Uyarı'),
                    content: const Text('Lütfen tüm alanları doldurunuz.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tamam'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: Text(
              'Kaydet',
              style: TextStyle(
                color: isDarkMode ? Colors.white : const Color(0xFF1A237E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.blockName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF1A237E),
                Color(0xFF3949AB),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A237E),
              Color(0xFF3949AB),
            ],
          ),
        ),
        child: Column(
          children: [
            // Arama çubuğu
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ürün Ara...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () {
                          searchController.clear();
                          _filterProducts('');
                        },
                      )
                    : null,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.white, width: 1),
                  ),
                ),
                onChanged: _filterProducts,
              ),
            ),
            // Ürün listesi
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _showAddProductDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Yeni Ürün Ekle'),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                product['name'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Fiyat: ${product['price']}₺\nAdet: ${product['quantity']}\nKilo: ${product['weight']} kg',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _showEditProductDialog(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Ürün Sil'),
                                          content: const Text('Bu ürünü silmek istediğinizden emin misiniz?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('İptal'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                // İstatistik kaydı ekle
                                                final statistics = Provider.of<StatisticsProvider>(context, listen: false);
                                                statistics.addLog(
                                                  _displayName,
                                                  widget.warehouseName,
                                                  widget.blockName,
                                                  product['name'],
                                                  int.parse(product['quantity']),
                                                  false, // silme işlemi
                                                  role: widget.role,
                                                );

                                                widget.onDeleteProduct(index);
                                                setState(() {
                                                  filteredProducts = List.from(widget.products);
                                                });
                                              },
                                              child: const Text('Sil'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 