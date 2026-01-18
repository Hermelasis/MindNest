import 'package:flutter/material.dart';
import '../../services/local_auth.dart';
import '../../services/notification_service.dart';
import '../../services/theme_service.dart';
import '../../services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _username = 'User';
  
  // Toggles
  bool _notifications = true;
  bool _soundEffects = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await LocalAuthService.getUser();
    final name = data['username'];
    if (name != null && name.isNotEmpty) {
      if (mounted) {
        setState(() {
          _username = name;
        });
      }
    }
  }

  Future<void> _handleSignOut() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/sign_in', (route) => false);
    }
  }

  Future<void> _handleDeleteAccount() async {
    // In a real app, delete from DB. Here we just sign out/clear local.
    await LocalAuthService.signOut(); 
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/sign_up', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Helper for dynamic colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      // Global background is set in main.dart (scaffoldBackgroundColor)
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Serif',
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),

                // Profile Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.indigo.shade100,
                        child: Text(
                          _username.isNotEmpty ? _username[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $_username',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () async {
                                await Navigator.of(context).pushNamed('/edit_profile');
                                _loadUserData(); // Refresh on return
                              },
                              child: const Text(
                                'Edit Profile',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                
                // General Settings Section
                Text(
                  'General',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      _buildSwitchTile(
                        icon: Icons.dark_mode_outlined,
                        color: Colors.purple,
                        title: 'Dark Mode',
                        value: ThemeService.isDarkMode,
                        textColor: textColor,
                        onChanged: (v) async {
                          await ThemeService.toggleTheme(v);
                          // No manual setState needed usually if using ValueListener, 
                          // but here we are inside a StatefulWidget NOT listening to theme,
                          // however main.dart listens and rebuilds the whole app.
                          // So the widget will rebuild.
                          // But let's call setState just in case for local switch state reflection?
                          // ThemeService.isDarkMode returns current value.
                          setState(() {}); 
                        },
                      ),
                      const Divider(height: 1),
                      _buildSwitchTile(
                        icon: Icons.notifications_outlined,
                        color: Colors.orange,
                        title: 'Notifications',
                        value: _notifications,
                        textColor: textColor,
                        onChanged: (v) async {
                          setState(() => _notifications = v);
                          if (v) {
                            await NotificationService.requestPermissions();
                            await NotificationService.scheduleDailyNotification();
                          } else {
                            await NotificationService.cancelNotifications();
                          }
                        },
                      ),
                      const Divider(height: 1),
                      _buildSwitchTile(
                        icon: Icons.volume_up_outlined,
                        color: Colors.teal,
                        title: 'Sound Effects',
                        value: _soundEffects,
                        textColor: textColor,
                        onChanged: (v) => setState(() => _soundEffects = v),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Account Section
                Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      _buildActionTile(
                        icon: Icons.logout,
                        color: Colors.redAccent,
                        title: 'Sign Out',
                        textColor: textColor, // Usually sign out is neutral or red? Let's keep logic compatible.
                        onTap: _handleSignOut,
                      ),
                      const Divider(height: 1),
                      _buildActionTile(
                        icon: Icons.delete_outline,
                        color: Colors.red,
                        title: 'Delete Account',
                        textColor: Colors.red,
                        onTap: _handleDeleteAccount,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color color,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    // If textColor explicitly passed (like red), use it. Otherwise use theme text color.
    // Need context access or pass default.
    // Simplifying to assume caller passes correct color or we default to black/white.
    
    final defaultColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87;
    final finalColor = textColor ?? defaultColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: finalColor,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
