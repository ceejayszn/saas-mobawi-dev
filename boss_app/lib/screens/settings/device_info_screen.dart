import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../theme/app_colors.dart';

class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  Map<String, String> _deviceInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    final info = <String, String>{};
    try {
      // Package info
      final packageInfo = await PackageInfo.fromPlatform();
      info['App Name'] = packageInfo.appName;
      info['App Version'] = packageInfo.version;
      info['Build Number'] = packageInfo.buildNumber;
      info['Package Name'] = packageInfo.packageName;

      // Device info
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      info['Device Model'] = androidInfo.model;
      info['Manufacturer'] = androidInfo.manufacturer;
      info['Brand'] = androidInfo.brand;
      info['Android Version'] = 'Android ${androidInfo.version.release}';
      info['SDK Version'] = androidInfo.version.sdkInt.toString();
      info['Device ID'] = androidInfo.id;
      info['Board'] = androidInfo.board;
      info['Hardware'] = androidInfo.hardware;
      info['Is Physical Device'] = androidInfo.isPhysicalDevice ? 'Yes' : 'No (Emulator)';
    } catch (e) {
      info['Error'] = 'Could not load device info on this platform';
    }

    // Battery
    try {
      final battery = Battery();
      final level = await battery.batteryLevel;
      final state = await battery.batteryState;
      info['Battery Level'] = '$level%';
      info['Battery Status'] = state.name.capitalizeFirst();
    } catch (_) {
      info['Battery Level'] = 'N/A';
    }

    if (mounted) {
      setState(() {
        _deviceInfo = info;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: const Text('Device Information'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadDeviceInfo();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Icon header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryGreen, AppColors.primaryGreenAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.phone_android_rounded, color: Colors.white, size: 44),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _deviceInfo['Device Model'] ?? 'Unknown Device',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              _deviceInfo['Manufacturer'] ?? '',
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _deviceInfo['Android Version'] ?? '',
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Info cards grouped
                  _buildGroup('Application', isDark, [
                    'App Name', 'App Version', 'Build Number', 'Package Name',
                  ]),
                  const SizedBox(height: 12),
                  _buildGroup('Device Hardware', isDark, [
                    'Device Model', 'Manufacturer', 'Brand', 'Board', 'Hardware', 'Is Physical Device',
                  ]),
                  const SizedBox(height: 12),
                  _buildGroup('Software', isDark, [
                    'Android Version', 'SDK Version', 'Device ID',
                  ]),
                  const SizedBox(height: 12),
                  _buildGroup('Battery', isDark, [
                    'Battery Level', 'Battery Status',
                  ]),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock_rounded, color: AppColors.info, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'This information is read-only and is used to help diagnose issues. It is never transmitted.',
                            style: TextStyle(color: AppColors.info, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildGroup(String title, bool isDark, List<String> keys) {
    final entries = keys.where((k) => _deviceInfo.containsKey(k)).toList();
    if (entries.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title.toUpperCase(),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1.2)),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
          ),
          child: Column(
            children: entries.asMap().entries.map((entry) {
              final i = entry.key;
              final key = entry.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(key, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            _deviceInfo[key] ?? '—',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < entries.length - 1) const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

extension _StringExt on String {
  String capitalizeFirst() => isEmpty ? this : this[0].toUpperCase() + substring(1);
}
