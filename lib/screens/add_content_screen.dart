import 'package:flutter/material.dart';
import 'package:yajid/theme/app_theme.dart';
import 'package:yajid/l10n/app_localizations.dart';

class AddContentScreen extends StatefulWidget {
  const AddContentScreen({super.key});

  @override
  State<AddContentScreen> createState() => _AddContentScreenState();
}

class _AddContentScreenState extends State<AddContentScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _handleMenuItem(String value) {
    // Close the drawer if it's open
    if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      Navigator.pop(context);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(child: Text('$value feature coming soon')),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildAddDrawer() {
    return Drawer(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40, right: 8),
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.only(left: 8, right: 16),
            leading: const Icon(Icons.business),
            title: Text(AppLocalizations.of(context)!.addYourBusiness),
            onTap: () => _handleMenuItem('business'),
          ),
          ListTile(
            contentPadding: const EdgeInsets.only(left: 8, right: 16),
            leading: const Icon(Icons.event),
            title: Text(AppLocalizations.of(context)!.createEvent),
            onTap: () => _handleMenuItem('event'),
          ),
          ListTile(
            contentPadding: const EdgeInsets.only(left: 8, right: 16),
            leading: const Icon(Icons.flight),
            title: Text(AppLocalizations.of(context)!.newTrip),
            onTap: () => _handleMenuItem('trip'),
          ),
          ListTile(
            contentPadding: const EdgeInsets.only(left: 8, right: 16),
            leading: const Icon(Icons.group),
            title: Text(AppLocalizations.of(context)!.createGroup),
            onTap: () => _handleMenuItem('group'),
          ),
          ListTile(
            contentPadding: const EdgeInsets.only(left: 8, right: 16),
            leading: const Icon(Icons.forum),
            title: Text(AppLocalizations.of(context)!.createThread),
            onTap: () => _handleMenuItem('thread'),
          ),
          ListTile(
            contentPadding: const EdgeInsets.only(left: 8, right: 16),
            leading: const Icon(Icons.restaurant_menu),
            title: Text(AppLocalizations.of(context)!.addRecipe),
            onTap: () => _handleMenuItem('recipe'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      endDrawer: _buildAddDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          elevation: 1,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppTheme.buildLogo(size: 55.0),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      _scaffoldKey.currentState?.openEndDrawer();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 120,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.addNewContent,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.tapPlusToGetStarted,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 32),
            // Quick action buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildQuickActionButton(
                  icon: Icons.business,
                  label: AppLocalizations.of(context)!.business,
                  onTap: () => _handleMenuItem('business'),
                ),
                _buildQuickActionButton(
                  icon: Icons.event,
                  label: AppLocalizations.of(context)!.event,
                  onTap: () => _handleMenuItem('event'),
                ),
                _buildQuickActionButton(
                  icon: Icons.flight,
                  label: AppLocalizations.of(context)!.trip,
                  onTap: () => _handleMenuItem('trip'),
                ),
                _buildQuickActionButton(
                  icon: Icons.group,
                  label: AppLocalizations.of(context)!.group,
                  onTap: () => _handleMenuItem('group'),
                ),
                _buildQuickActionButton(
                  icon: Icons.forum,
                  label: AppLocalizations.of(context)!.thread,
                  onTap: () => _handleMenuItem('thread'),
                ),
                _buildQuickActionButton(
                  icon: Icons.restaurant_menu,
                  label: AppLocalizations.of(context)!.recipe,
                  onTap: () => _handleMenuItem('recipe'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}