import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/statik_provider.dart';
import 'blok_detay_screen.dart';

class WarehouseDetailScreen extends StatefulWidget {
  final String title;
  final String products;
  final IconData icon;
  final List<Map<String, dynamic>> blok;
  final Function(List<Map<String, dynamic>>) onBlocksUpdated;
  final bool isAdmin;
  final String userName;
  final String role;

  const WarehouseDetailScreen({
    Key? key,
    required this.title,
    required this.products,
    required this.icon,
    required this.blok,
    required this.onBlocksUpdated,
    required this.isAdmin,
    required this.userName,
    required this.role,
  }) : super(key: key);

  @override
  State<WarehouseDetailScreen> createState() => _WarehouseDetailScreenState();
}

class _WarehouseDetailScreenState extends State<WarehouseDetailScreen> {
  late List<Map<String, dynamic>> _blocks;

  @override
  void initState() {
    super.initState();
    _blocks = List.from(widget.blok.map((block) {
      return {
        ...block,
        'products_list': block['products_list'] ?? [],
      };
    }));
  }

  void _updateBlocks() {
    final updatedBlocks = _blocks.map((block) {
      final totalProducts = (block['products_list'] as List).fold<int>(
        0,
        (sum, product) => sum + int.parse(product['quantity'] ?? '0'),
      );

      return {
        ...block,
        'products': totalProducts.toString(),
      };
    }).toList();

    widget.onBlocksUpdated(List<Map<String, dynamic>>.from(updatedBlocks));
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.locale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(isRTL ? Icons.arrow_forward : Icons.arrow_back,
              color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _blocks.length,
          itemBuilder: (context, index) {
            final block = _blocks[index];
            return _buildBlockCard(context, block, index);
          },
        ),
      ),
    );
  }

  Widget _buildBlockCard(
      BuildContext context, Map<String, dynamic> block, int blockIndex) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlockDetailScreen(
                blockName: block['name'],
                blockIndex: blockIndex,
                products: block['products_list'],
                isAdmin: widget.isAdmin,
                userName: widget.userName,
                role: widget.role,
                warehouseName: widget.title,
                onAddProduct: (name, price, quantity, weight) {
                  setState(() {
                    if (_blocks[blockIndex]['products_list'] == null) {
                      _blocks[blockIndex]['products_list'] = [];
                    }
                    _blocks[blockIndex]['products_list'].add({
                      'name': name,
                      'price': price,
                      'quantity': quantity,
                      'weight': weight,
                    });
                  });
                  _updateBlocks();
                },
                onEditProduct: (index, name, price, quantity, weight) {
                  setState(() {
                    _blocks[blockIndex]['products_list'][index] = {
                      'name': name,
                      'price': price,
                      'quantity': quantity,
                      'weight': weight,
                    };
                  });
                  _updateBlocks();
                },
                onDeleteProduct: (index) {
                  _deleteProduct(blockIndex, index);
                },
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.view_module, size: 40, color: Color(0xFF1A237E)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      block['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'total_products'.tr(args: [block['products'] ?? '0']),
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
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

  void _showAddProductDialog(BuildContext context, int blockIndex) {
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
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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

              if (name.isNotEmpty &&
                  price.isNotEmpty &&
                  quantity.isNotEmpty &&
                  weight.isNotEmpty) {
                setState(() {
                  if (_blocks[blockIndex]['products_list'] == null) {
                    _blocks[blockIndex]['products_list'] = [];
                  }
                  _blocks[blockIndex]['products_list'].add({
                    'name': name,
                    'price': price,
                    'quantity': quantity,
                    'weight': weight,
                  });
                });

                // İstatistik kaydı ekle
                final statistics =
                    Provider.of<StatisticsProvider>(context, listen: false);
                statistics.addLog(
                  'Kullanıcı',
                  widget.title,
                  _blocks[blockIndex]['name'],
                  name,
                  int.parse(quantity),
                  true,
                );

                Navigator.pop(context);
                _updateBlocks();
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

  void _deleteProduct(int blockIndex, int productIndex) {
    final product = _blocks[blockIndex]['products_list'][productIndex];

    // İstatistik kaydı ekle
    final statistics = Provider.of<StatisticsProvider>(context, listen: false);
    statistics.addLog(
      'Kullanıcı',
      widget.title,
      _blocks[blockIndex]['name'],
      product['name'],
      int.parse(product['quantity']),
      false,
    );

    setState(() {
      _blocks[blockIndex]['products_list'].removeAt(productIndex);
    });
    _updateBlocks();
  }
}
