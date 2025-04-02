import 'package:flutter/material.dart';
import 'package:hotelmind/widgets/developer_drawer.dart';

import '../services/room_automation_service.dart';

class SettingsScreen extends StatefulWidget {
  final String roomId;
  final String sessionId;

  const SettingsScreen({super.key, required this.roomId, required this.sessionId});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final RoomAutomationService _roomService = RoomAutomationService();
  late final String _roomId;

  // Ayarlar
  double _preferredTemperature = 22.0;
  double _preferredHumidity = 50.0;
  bool _autoClimate = true;
  bool _automaticLights = true;
  bool _voiceReports = true;
  String _roomMode = 'comfort'; // comfort, eco, away
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _roomId = widget.roomId;

    _loadPreferences();
  }

  void _showDeveloperConsole() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DeveloperConsoleSheet(),
    );
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final preferences = await _roomService.getUserPreferences(_roomId);

      setState(() {
        if (preferences != null) {
          _preferredTemperature = preferences['preferredTemperature'] ?? 22.0;
          _preferredHumidity = preferences['preferredHumidity'] ?? 50.0;
          _autoClimate = preferences['autoClimate'] ?? true;
          _automaticLights = preferences['automaticLights'] ?? true;
          _voiceReports = preferences['voiceReports'] ?? true;
          _roomMode = preferences['roomMode'] ?? 'comfort';
        }
        _isLoading = false;
      });
    } catch (e) {
      print("Tercihler yüklenirken hata: $e");
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Tercihler yüklenirken hata oluştu"))
      );
    }
  }

  Future<void> _savePreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final preferences = {
        'preferredTemperature': _preferredTemperature,
        'preferredHumidity': _preferredHumidity,
        'autoClimate': _autoClimate,
        'automaticLights': _automaticLights,
        'voiceReports': _voiceReports,
        'roomMode': _roomMode
      };

      final success = await _roomService.saveUserPreferences(_roomId, preferences);

      if (success) {
        // Aynı zamanda oda modunu da ayarla
        await _roomService.setRoomMode(_roomId, _roomMode);
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? "Ayarlar başarıyla kaydedildi"
                : "Ayarlar kaydedilirken hata oluştu"
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          )
      );
    } catch (e) {
      print("Tercihler kaydedilirken hata: $e");
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ayarlar kaydedilirken hata oluştu"),
            backgroundColor: Colors.red,
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: CircleAvatar(
          radius: 6,
          backgroundColor: Colors.grey.shade800.withValues(alpha: 0.7),
          child: IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Başlık ve açıklama alanı
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Kişisel Oda Tercihleri',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: 60,
                          height: 4,
                          color: Colors.blue,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Oda ayarlarınızı kişiselleştirerek konforunuzu en üst düzeye çıkarın',
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Konfor Ayarları kartı
                  _buildSettingsCard(
                    title: 'Konfor Ayarları',
                    icon: Icons.thermostat,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tercih edilen sıcaklık
                        Row(
                          children: [
                            Icon(Icons.thermostat_outlined, color: Colors.orange),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tercih Edilen Sıcaklık: ${_preferredTemperature.toStringAsFixed(1)}°C',
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 8),
                                  Slider(
                                    value: _preferredTemperature,
                                    min: 18,
                                    max: 28,
                                    divisions: 20,
                                    label: '${_preferredTemperature.toStringAsFixed(1)}°C',
                                    activeColor: Colors.orange,
                                    onChanged: (value) {
                                      setState(() {
                                        _preferredTemperature = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // Tercih edilen nem
                        Row(
                          children: [
                            Icon(Icons.water_drop_outlined, color: Colors.blue),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tercih Edilen Nem: ${_preferredHumidity.toStringAsFixed(0)}%',
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 8),
                                  Slider(
                                    value: _preferredHumidity,
                                    min: 30,
                                    max: 70,
                                    divisions: 40,
                                    label: '${_preferredHumidity.toStringAsFixed(0)}%',
                                    activeColor: Colors.blue,
                                    onChanged: (value) {
                                      setState(() {
                                        _preferredHumidity = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Oda Modu kartı
                  _buildSettingsCard(
                    title: 'Oda Modu',
                    icon: Icons.home,
                    content: Column(
                      children: [
                        // Oda modu seçimi
                        _buildModeOption(
                          title: 'Konfor Modu',
                          subtitle: 'En rahat ortam sağlanır, enerji tüketimi daha yüksektir',
                          icon: Icons.weekend,
                          iconColor: Colors.purple,
                          value: 'comfort',
                          groupValue: _roomMode,
                        ),
                        Divider(),
                        _buildModeOption(
                          title: 'Ekonomi Modu',
                          subtitle: 'Enerji tasarrufu yapılır, konfor biraz azalır',
                          icon: Icons.eco,
                          iconColor: Colors.green,
                          value: 'eco',
                          groupValue: _roomMode,
                        ),
                        Divider(),
                        _buildModeOption(
                          title: 'Dışarıda Modu',
                          subtitle: 'Maksimum enerji tasarrufu, minimum sistemler aktif',
                          icon: Icons.directions_walk,
                          iconColor: Colors.orange,
                          value: 'away',
                          groupValue: _roomMode,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Genel Ayarlar kartı
                  _buildSettingsCard(
                    title: 'Genel Ayarlar',
                    icon: Icons.settings,
                    content: Column(
                      children: [
                        // Otomatik iklimlendirme
                        _buildSwitchOption(
                          title: 'Otomatik İklimlendirme',
                          subtitle: 'Oda sıcaklığını otomatik ayarlar',
                          icon: Icons.ac_unit,
                          iconColor: Colors.lightBlue,
                          value: _autoClimate,
                          onChanged: (value) => setState(() => _autoClimate = value),
                        ),
                        Divider(),

                        // Otomatik aydınlatma
                        _buildSwitchOption(
                          title: 'Otomatik Aydınlatma',
                          subtitle: 'Oda ışıklarını otomatik kontrol eder',
                          icon: Icons.lightbulb_outline,
                          iconColor: Colors.amber,
                          value: _automaticLights,
                          onChanged: (value) => setState(() => _automaticLights = value),
                        ),
                        Divider(),

                        // Sesli bildirimler
                        _buildSwitchOption(
                          title: 'Sesli Bildirimler',
                          subtitle: 'Odaya girişte durum özeti sunar',
                          icon: Icons.volume_up,
                          iconColor: Colors.green,
                          value: _voiceReports,
                          onChanged: (value) => setState(() => _voiceReports = value),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),

                  // Kaydet butonu
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _savePreferences,
                      icon: Icon(Icons.save),
                      label: Text('Ayarları Kaydet'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),

                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
      // Geliştirici konsolu tetikleyici butonu
      bottomNavigationBar: Container(
        height: 40,
        color: Colors.grey[200],
        child: InkWell(
          onTap: _showDeveloperConsole,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.code, size: 16),
              SizedBox(width: 8),
              Text(
                'Geliştirici Konsolu',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Ayar kartı oluşturan yardımcı metod
  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 28),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
            SizedBox(height: 4),
            Container(
              width: 40,
              height: 3,
              color: Colors.blue.shade200,
            ),
            SizedBox(height: 20),
            content,
          ],
        ),
      ),
    );
  }

  // Mod seçim widgetı
  Widget _buildModeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String groupValue,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _roomMode = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              activeColor: Colors.blue,
              onChanged: (val) {
                setState(() {
                  _roomMode = val!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // Switch seçim widgetı
  Widget _buildSwitchOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: Colors.blue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}