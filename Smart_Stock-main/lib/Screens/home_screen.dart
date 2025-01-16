import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'warehouse_detail_screen.dart';
import 'login_screen.dart';
import '../providers/personnel_provider.dart';
import 'package:flutter/services.dart';
import '../providers/statistics_provider.dart';
import 'package:intl/intl.dart';
import '../providers/warehouse_provider.dart';

class HomeScreen extends StatefulWidget {
  final bool isAdmin;
  final String userName;
  final String? role;

  const HomeScreen({
    Key? key,
    this.isAdmin = false,
    required this.userName,
    this.role,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      WarehousesPage(
        isAdmin: widget.isAdmin,
        userName: widget.userName,
        role: widget.role,
      ),
      const StatisticsPage(),
      ProfilePage(
        userName: widget.userName,
        isAdmin: widget.isAdmin,
        role: widget.role,
      ),
      SettingsPage(isAdmin: widget.isAdmin),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'app_name'.tr(),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF1A237E),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.warehouse),
            label: 'warehouses'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.analytics),
            label: 'İstatistik',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'profile'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: 'settings'.tr(),
          ),
        ],
      ),
    );
  }
}

// İstatistik Sayfası
class StatisticsPage extends StatelessWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'İşlem Geçmişi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
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
              child: Consumer<StatisticsProvider>(
                builder: (context, statistics, child) {
                  if (statistics.logs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Henüz işlem yapılmadı',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: statistics.logs.length,
                    itemBuilder: (context, index) {
                      final log =
                          statistics.logs[statistics.logs.length - 1 - index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            log['isAddition']
                                ? Icons.add_circle
                                : Icons.remove_circle,
                            color:
                                log['isAddition'] ? Colors.green : Colors.red,
                          ),
                          title: Text(log['message']),
                          subtitle: Text(
                            DateFormat('dd/MM/yyyy HH:mm')
                                .format(log['timestamp']),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Profil Sayfası
class ProfilePage extends StatelessWidget {
  final String userName;
  final bool isAdmin;
  final String? role;

  const ProfilePage({
    Key? key,
    required this.userName,
    required this.isAdmin,
    this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isRTL = context.locale.languageCode == 'ar';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  const Color(0xFF1A237E),
                  const Color(0xFF3949AB),
                ]
              : [
                  theme.primaryColor,
                  theme.primaryColor.withOpacity(0.7),
                ],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Profil Resmi
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFF1A237E),
                width: 3,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                size: 80,
                color: Color(0xFF1A237E),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Kullanıcı Adı
          Text(
            userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // Rol
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isAdmin ? 'Yönetici' : 'Personel',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Çıkış Yap Butonu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A237E),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Çıkış Yap',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Ayarlar Sayfası
class SettingsPage extends StatefulWidget {
  final bool isAdmin;
  const SettingsPage({Key? key, this.isAdmin = false}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final isRTL = context.locale.languageCode == 'ar';
    final personnelProvider = Provider.of<PersonnelProvider>(context);

    return Container(
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
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.isAdmin) // Sadece yönetici için personel yönetimi
            Column(
              children: [
                _buildSettingsSection(
                  context,
                  'settings_page.personnel_management'.tr(),
                  [
                    _buildSettingsTile(
                      context,
                      'settings_page.add_personnel'.tr(),
                      Icons.person_add,
                      onTap: () => _showAddPersonelDialog(context),
                    ),
                    _buildSettingsTile(
                      context,
                      'settings_page.personnel_list'.tr(),
                      Icons.people,
                      onTap: () => _showPersonelList(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          _buildSettingsSection(
            context,
            'settings_page.general_settings'.tr(),
            [
              _buildSettingsTile(
                context,
                'settings_page.theme'.tr(),
                Icons.palette,
                onTap: () => _showThemeDialog(context),
              ),
              _buildSettingsTile(
                context,
                'settings_page.language'.tr(),
                Icons.language,
                onTap: () => _showLanguageDialog(context),
              ),
              _buildSettingsTile(
                context,
                'settings_page.notifications'.tr(),
                Icons.notifications,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsSection(
            context,
            'settings_page.app_settings'.tr(),
            [
              _buildSettingsTile(
                  context, 'settings_page.sync'.tr(), Icons.sync),
              _buildSettingsTile(
                  context, 'settings_page.backup'.tr(), Icons.backup),
              _buildSettingsTile(context, 'settings_page.auto_update'.tr(),
                  Icons.system_update),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsSection(
            context,
            'settings_page.about'.tr(),
            [
              _buildSettingsTile(
                  context, 'settings_page.app_version'.tr(), Icons.info),
              _buildSettingsTile(context, 'settings_page.privacy_policy'.tr(),
                  Icons.privacy_tip),
              _buildSettingsTile(context, 'settings_page.terms_of_use'.tr(),
                  Icons.description),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
      BuildContext context, String title, List<Widget> items) {
    final isRTL = context.locale.languageCode == 'ar';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment:
            isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF1A237E),
              ),
            ),
          ),
          const Divider(),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, String title, IconData icon,
      {VoidCallback? onTap}) {
    final isRTL = context.locale.languageCode == 'ar';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: isRTL
          ? null
          : Icon(
              icon,
              color: isDarkMode ? Colors.white : const Color(0xFF1A237E),
            ),
      trailing: isRTL
          ? Icon(
              icon,
              color: isDarkMode ? Colors.white : const Color(0xFF1A237E),
            )
          : Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDarkMode ? Colors.white : const Color(0xFF1A237E),
            ),
      title: Text(
        title,
        textAlign: isRTL ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          color: isDarkMode ? Colors.white : const Color(0xFF1A237E),
        ),
      ),
      onTap: onTap,
    );
  }

  // Personel Ekleme Dialog'u
  void _showAddPersonelDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController roleController = TextEditingController();
    final isRTL = context.locale.languageCode == 'ar';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final personnelProvider =
        Provider.of<PersonnelProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
        title: Text(
          'Personel Ekle',
          style: TextStyle(
            color: isDarkMode ? Colors.white : const Color(0xFF1A237E),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textAlign: isRTL ? TextAlign.right : TextAlign.left,
                decoration: InputDecoration(
                  labelText: 'Personel Adı',
                  labelStyle: TextStyle(
                    color:
                        isDarkMode ? Colors.white70 : const Color(0xFF1A237E),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                textAlign: isRTL ? TextAlign.right : TextAlign.left,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  labelStyle: TextStyle(
                    color:
                        isDarkMode ? Colors.white70 : const Color(0xFF1A237E),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: roleController.text.isEmpty
                    ? 'personel'
                    : roleController.text,
                decoration: InputDecoration(
                  labelText: 'Personel Rolü',
                  labelStyle: TextStyle(
                    color:
                        isDarkMode ? Colors.white70 : const Color(0xFF1A237E),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Admin'),
                  ),
                  DropdownMenuItem(
                    value: 'personel',
                    child: Text('Personel'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    roleController.text = value;
                  }
                },
              ),
            ],
          ),
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
              final password = passwordController.text.trim();
              final role = roleController.text.trim();

              if (name.isNotEmpty && password.isNotEmpty && role.isNotEmpty) {
                personnelProvider.addPersonnel(
                  name: name,
                  password: password,
                  role: role,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Personel başarıyla eklendi'),
                    backgroundColor: Colors.green,
                  ),
                );

                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lütfen tüm alanları doldurun'),
                    backgroundColor: Colors.red,
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

  // Personel Listesi Dialog'u
  void _showPersonelList(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final personnelProvider =
        Provider.of<PersonnelProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
        title: Text(
          'Personel Listesi',
          style: TextStyle(
            color: isDarkMode ? Colors.white : const Color(0xFF1A237E),
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: personnelProvider.personnel.length,
            itemBuilder: (context, index) {
              final person = personnelProvider.personnel[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(person['name'] ?? ''),
                subtitle: Text(person['role'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Personel Sil'),
                        content: const Text(
                            'Bu personeli silmek istediğinizden emin misiniz?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('İptal'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              personnelProvider.removePersonnel(index);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Personel başarıyla silindi'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            child: const Text('Sil'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Kapat',
              style: TextStyle(
                color: isDarkMode ? Colors.white : const Color(0xFF1A237E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tema Seçimi Dialog'u
  void _showThemeDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
        title: Text(
          'theme_dialog.title'.tr(),
          style: TextStyle(
            color: isDarkMode ? Colors.white : const Color(0xFF1A237E),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(context, 'theme_dialog.blue_theme'.tr(), 'blue',
                Icons.circle, const Color(0xFF1A237E)),
            _buildThemeOption(context, 'theme_dialog.dark_theme'.tr(), 'dark',
                Icons.circle, Colors.black),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'theme_dialog.close'.tr(),
              style: TextStyle(
                color: isDarkMode ? Colors.white : const Color(0xFF1A237E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, String title, String themeKey,
      IconData icon, Color color) {
    final isRTL = context.locale.languageCode == 'ar';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading:
          isRTL ? null : Icon(icon, color: isDarkMode ? Colors.white : color),
      trailing:
          isRTL ? Icon(icon, color: isDarkMode ? Colors.white : color) : null,
      title: Text(
        title,
        textAlign: isRTL ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          color: isDarkMode ? Colors.white : const Color(0xFF1A237E),
        ),
      ),
      onTap: () {
        Provider.of<ThemeProvider>(context, listen: false).setTheme(themeKey);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('theme_dialog.applied'.tr(args: [title])),
            backgroundColor: color,
          ),
        );
      },
    );
  }

  // Dil Seçimi Dialog'u
  void _showLanguageDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
        title: Text(
          'language_dialog.title'.tr(),
          style: TextStyle(
            color: isDarkMode ? Colors.white : const Color(0xFF1A237E),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
                context, 'Türkçe', 'tr', Icons.language, '🇹🇷'),
            _buildLanguageOption(
                context, 'English', 'en', Icons.language, '🇬🇧'),
            _buildLanguageOption(
                context, 'العربية', 'ar', Icons.language, '🇸🇦'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'language_dialog.close'.tr(),
              style: TextStyle(
                color: isDarkMode ? Colors.white : const Color(0xFF1A237E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String title,
      String langCode, IconData icon, String flag) {
    final isRTL = context.locale.languageCode == 'ar';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: isRTL ? null : Text(flag, style: const TextStyle(fontSize: 24)),
      trailing: isRTL ? Text(flag, style: const TextStyle(fontSize: 24)) : null,
      title: Text(
        title,
        textAlign: isRTL ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          color: isDarkMode ? Colors.white : const Color(0xFF1A237E),
        ),
      ),
      onTap: () {
        context.setLocale(Locale(langCode));
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('language_dialog.selected'.tr(args: [title])),
            backgroundColor: const Color(0xFF1A237E),
          ),
        );
      },
    );
  }
}

class WarehousesPage extends StatefulWidget {
  final bool isAdmin;
  final String userName;
  final String? role;

  const WarehousesPage({
    Key? key,
    this.isAdmin = false,
    required this.userName,
    this.role,
  }) : super(key: key);

  @override
  State<WarehousesPage> createState() => _WarehousesPageState();
}

class _WarehousesPageState extends State<WarehousesPage> {
  @override
  void initState() {
    super.initState();
    // Load warehouses from database
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WarehouseProvider>(context, listen: false).loadWarehouses();
    });
  }

  void _addWarehouse(String name, IconData icon, int blockCount) {
    final warehouseProvider =
        Provider.of<WarehouseProvider>(context, listen: false);
    final blockNames =
        List.generate(blockCount, (index) => 'Blok ${index + 1}');

    warehouseProvider.addWarehouse(
      name: name,
      icon: icon.codePoint.toString(), // Store icon as string
      blockNames: blockNames,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.locale.languageCode == 'ar';
    final warehouseProvider = Provider.of<WarehouseProvider>(context);
    final warehouses = warehouseProvider.warehouses;

    return Scaffold(
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
          itemCount: warehouses.length,
          itemBuilder: (context, index) {
            final warehouse = warehouses[index];
            return _buildWarehouseCard(
              context,
              warehouse['name'] as String,
              'total_products'
                  .tr(args: [warehouse['total_products'].toString()]),
              IconData(int.parse(warehouse['icon']),
                  fontFamily: 'MaterialIcons'),
              List<Map<String, dynamic>>.from(warehouse['blocks'] as List),
              false,
              () {},
              warehouse['id'] as int,
            );
          },
        ),
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: () => _showAddWarehouseDialog(context),
              backgroundColor: const Color(0xFF1A237E),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildWarehouseCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    List<Map<String, dynamic>> blocks,
    bool isExpanded,
    VoidCallback onTap,
    int warehouseId,
  ) {
    final isRTL = context.locale.languageCode == 'ar';

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
              builder: (context) => WarehouseDetailScreen(
                title: title,
                products: blocks
                    .fold<int>(
                        0, (sum, block) => sum + (block['products'] as int))
                    .toString(),
                icon: icon,
                blocks: blocks,
                isAdmin: widget.isAdmin,
                userName: widget.userName,
                role: widget.role ?? '',
                onBlocksUpdated: (updatedBlocks) async {
                  final warehouseProvider =
                      Provider.of<WarehouseProvider>(context, listen: false);
                  for (var block in updatedBlocks) {
                    block['warehouse_id'] = warehouseId;
                    await warehouseProvider.updateBlock(block);
                  }
                },
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (!isRTL) Icon(icon, size: 40, color: const Color(0xFF1A237E)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isRTL) ...[
                const SizedBox(width: 16),
                Icon(icon, size: 40, color: const Color(0xFF1A237E)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAddWarehouseDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController blockCountController = TextEditingController();
    final isRTL = context.locale.languageCode == 'ar';
    IconData selectedIcon = Icons.warehouse;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('warehouse_dialog.add_title'.tr(),
              style: const TextStyle(color: Color(0xFF1A237E))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  textAlign: isRTL ? TextAlign.right : TextAlign.left,
                  decoration: InputDecoration(
                    labelText: 'warehouse_dialog.name'.tr(),
                    labelStyle: const TextStyle(color: Color(0xFF1A237E)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: blockCountController,
                  textAlign: isRTL ? TextAlign.right : TextAlign.left,
                  decoration: InputDecoration(
                    labelText: 'warehouse_dialog.block_count'.tr(),
                    labelStyle: const TextStyle(color: Color(0xFF1A237E)),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'warehouse_dialog.select_icon'.tr(),
                  style: const TextStyle(
                    color: Color(0xFF1A237E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildIconOption(Icons.warehouse, selectedIcon, (icon) {
                      setDialogState(() => selectedIcon = icon);
                    }),
                    _buildIconOption(Icons.store, selectedIcon, (icon) {
                      setDialogState(() => selectedIcon = icon);
                    }),
                    _buildIconOption(Icons.home_work, selectedIcon, (icon) {
                      setDialogState(() => selectedIcon = icon);
                    }),
                    _buildIconOption(Icons.business, selectedIcon, (icon) {
                      setDialogState(() => selectedIcon = icon);
                    }),
                    _buildIconOption(Icons.factory, selectedIcon, (icon) {
                      setDialogState(() => selectedIcon = icon);
                    }),
                    _buildIconOption(Icons.storage, selectedIcon, (icon) {
                      setDialogState(() => selectedIcon = icon);
                    }),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('warehouse_dialog.cancel'.tr(),
                  style: const TextStyle(color: Color(0xFF1A237E))),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                final blockCount =
                    int.tryParse(blockCountController.text.trim()) ?? 0;
                if (name.isNotEmpty && blockCount > 0) {
                  _addWarehouse(name, selectedIcon, blockCount);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('warehouse_dialog.success'.tr()),
                      backgroundColor: const Color(0xFF1A237E),
                    ),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('warehouse_dialog.error'.tr()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('warehouse_dialog.add'.tr(),
                  style: const TextStyle(color: Color(0xFF1A237E))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconOption(
      IconData icon, IconData selectedIcon, Function(IconData) onSelect) {
    final isSelected = icon == selectedIcon;

    return InkWell(
      onTap: () => onSelect(icon),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1A237E).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A237E) : Colors.grey,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 32,
          color: isSelected ? const Color(0xFF1A237E) : Colors.grey,
        ),
      ),
    );
  }
}
