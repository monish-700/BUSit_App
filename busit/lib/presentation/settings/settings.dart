import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/language_selector_widget.dart';
import './widgets/settings_item_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/settings_toggle_widget.dart';
import './widgets/user_profile_widget.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // Mock user data
  final Map<String, dynamic> userData = {
    "id": 1,
    "name": "Rajesh Kumar",
    "phone": "+91 98765 43210",
    "email": "rajesh.kumar@example.com",
    "avatar":
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
  };

  // Settings state variables
  bool _busArrivalAlerts = true;
  bool _delayNotifications = true;
  bool _promotionalOffers = false;
  bool _emergencyAnnouncements = true;
  bool _largeText = false;
  bool _highContrast = false;
  bool _voiceGuidance = true;
  bool _reducedMotion = false;
  bool _locationServices = true;
  bool _backgroundLocation = true;
  bool _dataSharing = false;
  bool _analytics = true;
  bool _biometricAuth = false;
  String _selectedLanguage = "en";
  String _mapStyle = "standard";
  String _distanceUnit = "km";

  // Mock payment methods
  final List<Map<String, dynamic>> paymentMethods = [
    {
      "id": 1,
      "type": "UPI",
      "name": "rajesh@paytm",
      "isDefault": true,
      "icon": "account_balance_wallet",
    },
    {
      "id": 2,
      "type": "Card",
      "name": "**** **** **** 1234",
      "isDefault": false,
      "icon": "credit_card",
    },
    {
      "id": 3,
      "type": "Wallet",
      "name": "Paytm Wallet",
      "isDefault": false,
      "icon": "account_balance_wallet",
    },
  ];

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Logout",
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            "Are you sure you want to logout? Your data will be synced before logging out.",
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login-screen',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
                foregroundColor: AppTheme.lightTheme.colorScheme.onError,
              ),
              child: Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Delete Account",
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
            ),
          ),
          content: Text(
            "This action cannot be undone. All your data will be permanently deleted. Are you sure you want to delete your account?",
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        "Account deletion request submitted. You will receive a confirmation email."),
                    backgroundColor: AppTheme.lightTheme.colorScheme.error,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
                foregroundColor: AppTheme.lightTheme.colorScheme.onError,
              ),
              child: Text("Delete Account"),
            ),
          ],
        );
      },
    );
  }

  void _showMapStyleSelector() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Map Style",
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              SizedBox(height: 2.h),
              ...["standard", "satellite", "terrain"].map((style) {
                return ListTile(
                  title: Text(
                    style.substring(0, 1).toUpperCase() + style.substring(1),
                    style: AppTheme.lightTheme.textTheme.bodyLarge,
                  ),
                  leading: Radio<String>(
                    value: style,
                    groupValue: _mapStyle,
                    onChanged: (value) {
                      setState(() {
                        _mapStyle = value!;
                      });
                      Navigator.pop(context);
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showDistanceUnitSelector() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Distance Unit",
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              SizedBox(height: 2.h),
              ...["km", "miles"].map((unit) {
                return ListTile(
                  title: Text(
                    unit == "km" ? "Kilometers (km)" : "Miles",
                    style: AppTheme.lightTheme.textTheme.bodyLarge,
                  ),
                  leading: Radio<String>(
                    value: unit,
                    groupValue: _distanceUnit,
                    onChanged: (value) {
                      setState(() {
                        _distanceUnit = value!;
                      });
                      Navigator.pop(context);
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showPaymentMethods() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          height: 60.h,
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Payment Methods",
                    style: AppTheme.lightTheme.textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "Add payment method feature coming soon!")),
                      );
                    },
                    child: Text("Add New"),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: ListView.builder(
                  itemCount: paymentMethods.length,
                  itemBuilder: (context, index) {
                    final method = paymentMethods[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 2.h),
                      child: ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(
                            iconName: method["icon"] as String,
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 5.w,
                          ),
                        ),
                        title: Text(
                          method["name"] as String,
                          style:
                              AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          method["type"] as String,
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                        trailing: method["isDefault"] as bool
                            ? Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "Default",
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Set as default payment method")),
                                  );
                                },
                                child: Text("Set Default"),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Settings",
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            UserProfileWidget(
              userData: userData,
              onEditProfile: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Edit profile feature coming soon!")),
                );
              },
            ),

            SizedBox(height: 3.h),

            // Notification Settings
            SettingsSectionWidget(
              title: "Notifications",
              children: [
                SettingsToggleWidget(
                  title: "Bus Arrival Alerts",
                  subtitle: "Get notified when your bus is approaching",
                  iconName: 'notifications',
                  value: _busArrivalAlerts,
                  onChanged: (value) {
                    setState(() {
                      _busArrivalAlerts = value;
                    });
                    HapticFeedback.lightImpact();
                  },
                ),
                Divider(
                    height: 1,
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2)),
                SettingsToggleWidget(
                  title: "Delay Notifications",
                  subtitle: "Receive updates about bus delays",
                  iconName: 'schedule',
                  value: _delayNotifications,
                  onChanged: (value) {
                    setState(() {
                      _delayNotifications = value;
                    });
                    HapticFeedback.lightImpact();
                  },
                  iconColor: AppTheme.lightTheme.colorScheme.secondary,
                ),
                Divider(
                    height: 1,
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2)),
                SettingsToggleWidget(
                  title: "Promotional Offers",
                  subtitle: "Get notified about discounts and offers",
                  iconName: 'local_offer',
                  value: _promotionalOffers,
                  onChanged: (value) {
                    setState(() {
                      _promotionalOffers = value;
                    });
                    HapticFeedback.lightImpact();
                  },
                  iconColor: Colors.orange,
                ),
                Divider(
                    height: 1,
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2)),
                SettingsToggleWidget(
                  title: "Emergency Announcements",
                  subtitle: "Important safety and service alerts",
                  iconName: 'warning',
                  value: _emergencyAnnouncements,
                  onChanged: (value) {
                    setState(() {
                      _emergencyAnnouncements = value;
                    });
                    HapticFeedback.lightImpact();
                  },
                  iconColor: AppTheme.lightTheme.colorScheme.error,
                ),
              ],
            ),

            // Language Settings
            SettingsSectionWidget(
              title: "Language & Region",
              children: [
                LanguageSelectorWidget(
                  selectedLanguage: _selectedLanguage,
                  onLanguageChanged: (language) {
                    setState(() {
                      _selectedLanguage = language;
                    });
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              "Language changed. Restart app to apply changes.")),
                    );
                  },
                ),
              ],
            ),

            // Payment Settings
            SettingsSectionWidget(
              title: "Payment & Billing",
              children: [
                SettingsItemWidget(
                  title: "Payment Methods",
                  subtitle: "Manage cards, UPI, and wallets",
                  iconName: 'payment',
                  onTap: _showPaymentMethods,
                ),
                Divider(
                    height: 1,
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2)),
                SettingsItemWidget(
                  title: "Transaction History",
                  subtitle: "View your payment history",
                  iconName: 'history',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text("Transaction history feature coming soon!")),
                    );
                  },
                ),
                Divider(
                    height: 1,
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2)),
                SettingsItemWidget(
                  title: "Auto-Recharge",
                  subtitle: "Automatically recharge your wallet",
                  iconName: 'autorenew',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Auto-recharge settings coming soon!")),
                    );
                  },
                ),
              ],
            ),

            // Accessibility Settings
            SettingsSectionWidget(
              title: "Accessibility",
              children: [
                SettingsToggleWidget(
                  title: "Large Text",
                  subtitle: "Increase text size for better readability",
                  iconName: 'text_fields',
                  value: _largeText,
                  onChanged: (value) {
                    setState(() {
                      _largeText = value;
                    });
                    HapticFeedback.lightImpact();
                  },
                ),
                Divider(
                    height: 1,
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2)),
                SettingsToggleWidget(
                  title: "High Contrast Mode",
                  subtitle: "Improve visibility with high contrast colors",
                  iconName: 'contrast',
                  value: _highContrast,
                  onChanged: (value) {
                    setState(() {
                      _highContrast = value;
                    });
                    HapticFeedback.lightImpact();
                  },
                ),
                Divider(
                    height: 1,
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2)),
                SettingsToggleWidget(
                  title: "Voice Guidance",
                  subtitle: "Enable voice assistance for navigation",
                  iconName: 'record_voice_over',
                  value: _voiceGuidance,
                  onChanged: (value) {
                    setState(() {
                      _voiceGuidance = value;
                    });
                    HapticFeedback.lightImpact();
                  },
                ),
                Divider(
                    height: 1,
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2)),
                SettingsToggleWidget(
                  title: "Reduced Motion",
                  subtitle: "Minimize animations and transitions",
                  iconName: 'motion_photos_off',
                  value: _reducedMotion,
                  onChanged: (value) {
                    setState(() {
                      _reducedMotion = value;
                    });
                    HapticFeedback.lightImpact();
                  },
                ),
              ],
            ),

            // Location Settings
            SettingsSectionWidget(
              title: "Location Services",
              children: [
                SettingsToggleWidget(
                  title: "Location Services",
                  subtitle: "Allow app to access your location",
                  iconName: 'location_on',
                  value: _locationServices,
                  onChanged: (value) {
                    setState(() {
                      _locationServices = value;
                      if (!value) {
                        _backgroundLocation = false;
                      }
                    });
                    HapticFeedback.lightImpact();
                  },
                ),
                Divider(
                    height: 1,
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2)),
                SettingsToggleWidget(
                  title: "Background Location",
                  subtitle: "Track location for real-time updates",
                  iconName: 'my_location',
                  value: _backgroundLocation,
                  onChanged: _locationServices
                      ? (value) {
                          setState(() {
                            _backgroundLocation = value;
                          });
                          HapticFeedback.lightImpact();
                        }
                      : (value) {},
                ),
              ],
            ),

            // Privacy Settings
            SettingsSectionWidget(
              title: "Privacy & Security",
              children: [
                SettingsToggleWidget(
                  title: "Biometric Authentication",
                  subtitle: "Use fingerprint or face unlock",
                  iconName: 'fingerprint',
                  value: _biometricAuth,
                  onChanged: (value) {
                    setState(() {
                      _biometricAuth = value;
                    });
                    HapticFeedback.lightImpact();
                  },
                ),
                Divider(
                    height: 1,
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2)),
                SettingsToggleWidget(
                  title: "Data Sharing",
                  subtitle: "Share usage data to improve service",
                  iconName: 'share',
                  value: _dataSharing,
                  onChanged: (value) {
                    setState(() {
                      _dataSharing = value;
                    });
                    HapticFeedback.lightImpact();
                  },
                ),
                Divider(
                    height: 1,
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2)),
                SettingsToggleWidget(
                  title: "Analytics",
                  subtitle: "Help improve app performance",
                  iconName: 'analytics',
                  value: _analytics,
                  onChanged: (value) {
                    setState(() {
                      _analytics = value;
                    });
                    HapticFeedback.lightImpact();
                  },
                ),
                Divider(
                    height: 1,
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2)),
                SettingsItemWidget(
                  title: "Delete Account",
                  subtitle: "Permanently delete your account",
                  iconName: 'delete_forever',
                  onTap: _showDeleteAccountDialog,
                  iconColor: AppTheme.lightTheme.colorScheme.error,
                ),
              ],
            ),

            // App Preferences
            SettingsSectionWidget(
              title: "App Preferences",
              children: [
                SettingsItemWidget(
                  title: "Map Style",
                  subtitle: _mapStyle.substring(0, 1).toUpperCase() +
                      _mapStyle.substring(1),
                  iconName: 'map',
                  onTap: _showMapStyleSelector,
                ),
                Divider(
                    height: 1,
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2)),
                SettingsItemWidget(
                  title: "Distance Unit",
                  subtitle: _distanceUnit == "km" ? "Kilometers" : "Miles",
                  iconName: 'straighten',
                  onTap: _showDistanceUnitSelector,
                ),
                Divider(
                    height: 1,
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2)),
                SettingsItemWidget(
                  title: "Offline Data",
                  subtitle: "Manage cached data (45 MB)",
                  iconName: 'offline_pin',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Clear Offline Data"),
                        content: Text(
                            "This will clear 45 MB of cached data. You may experience slower loading times until data is re-cached."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "Offline data cleared successfully")),
                              );
                            },
                            child: Text("Clear"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),

            // Support Section
            SettingsSectionWidget(
              title: "Support & Feedback",
              children: [
                SettingsItemWidget(
                  title: "Help & FAQ",
                  subtitle: "Get answers to common questions",
                  iconName: 'help',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Help & FAQ feature coming soon!")),
                    );
                  },
                ),
                Divider(
                    height: 1,
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2)),
                SettingsItemWidget(
                  title: "Contact Support",
                  subtitle: "Get help from our support team",
                  iconName: 'support_agent',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Contact support: support@busit.com")),
                    );
                  },
                ),
                Divider(
                    height: 1,
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2)),
                SettingsItemWidget(
                  title: "Report Issue",
                  subtitle: "Report bugs or problems",
                  iconName: 'bug_report',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Report issue feature coming soon!")),
                    );
                  },
                ),
                Divider(
                    height: 1,
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2)),
                SettingsItemWidget(
                  title: "Send Feedback",
                  subtitle: "Share your thoughts about the app",
                  iconName: 'feedback',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Feedback feature coming soon!")),
                    );
                  },
                ),
              ],
            ),

            // About Section
            SettingsSectionWidget(
              title: "About",
              children: [
                SettingsItemWidget(
                  title: "App Version",
                  subtitle: "BUSit v2.1.0 (Build 210)",
                  iconName: 'info',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("About BUSit"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Version: 2.1.0 (Build 210)"),
                            SizedBox(height: 1.h),
                            Text("Last Updated: December 2024"),
                            SizedBox(height: 1.h),
                            Text("© 2024 BUSit Technologies"),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("OK"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Divider(
                    height: 1,
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2)),
                SettingsItemWidget(
                  title: "Terms of Service",
                  subtitle: "Read our terms and conditions",
                  iconName: 'description',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text("Terms of Service will open in browser")),
                    );
                  },
                ),
                Divider(
                    height: 1,
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2)),
                SettingsItemWidget(
                  title: "Privacy Policy",
                  subtitle: "Learn how we protect your data",
                  iconName: 'privacy_tip',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Privacy Policy will open in browser")),
                    );
                  },
                ),
              ],
            ),

            SizedBox(height: 4.h),

            // Logout Button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showLogoutDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.error,
                  foregroundColor: AppTheme.lightTheme.colorScheme.onError,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'logout',
                      color: AppTheme.lightTheme.colorScheme.onError,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      "Logout",
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onError,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }
}