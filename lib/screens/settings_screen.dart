import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/room_automation_service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final RoomAutomationService _roomService = RoomAutomationService();

  // Ayarlar
  String _roomId = 'room_001';
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
    _loadPreferences();
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
      appBar: AppBar(
        title: Text('Oda Ayarları'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPreferences,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Konfor Ayarları',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Tercih edilen sıcaklık
            Text('Tercih Edilen Sıcaklık: ${_preferredTemperature.toStringAsFixed(1)}°C'),
            Slider(
              value: _preferredTemperature,
              min: 18,
              max: 28,
              divisions: 20,
              label: '${_preferredTemperature.toStringAsFixed(1)}°C',
              onChanged: (value) {
                setState(() {
                  _preferredTemperature = value;
                });
              },
            ),

            // Tercih edilen nem
            Text('Tercih Edilen Nem: ${_preferredHumidity.toStringAsFixed(0)}%'),
            Slider(
              value: _preferredHumidity,
              min: 30,
              max: 70,
              divisions: 40,
              label: '${_preferredHumidity.toStringAsFixed(0)}%',
              onChanged: (value) {
                setState(() {
                  _preferredHumidity = value;
                });
              },
            ),

            Divider(height: 32),

            Text(
              'Oda Modu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Oda modu seçimi
            RadioListTile<String>(
              title: Text('Konfor Modu'),
              subtitle: Text('En rahat ortam sağlanır, enerji tüketimi daha yüksektir'),
              value: 'comfort',
              groupValue: _roomMode,
              onChanged: (value) {
                setState(() {
                  _roomMode = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: Text('Ekonomi Modu'),
              subtitle: Text('Enerji tasarrufu yapılır, konfor biraz azalır'),
              value: 'eco',
              groupValue: _roomMode,
              onChanged: (value) {
                setState(() {
                  _roomMode = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: Text('Dışarıda Modu'),
              subtitle: Text('Maksimum enerji tasarrufu, minimum sistemler aktif'),
              value: 'away',
              groupValue: _roomMode,
              onChanged: (value) {
                setState(() {
                  _roomMode = value!;
                });
              },
            ),

            Divider(height: 32),

            Text(
              'Genel Ayarlar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Otomatik iklimlendirme
            SwitchListTile(
              title: Text('Otomatik İklimlendirme'),
              subtitle: Text('Oda sıcaklığını otomatik ayarlar'),
              value: _autoClimate,
              onChanged: (value) {
                setState(() {
                  _autoClimate = value;
                });
              },
            ),

            // Otomatik aydınlatma
            SwitchListTile(
              title: Text('Otomatik Aydınlatma'),
              subtitle: Text('Oda ışıklarını otomatik kontrol eder'),
              value: _automaticLights,
              onChanged: (value) {
                setState(() {
                  _automaticLights = value;
                });
              },
            ),

            // Sesli bildirimler
            SwitchListTile(
              title: Text('Sesli Bildirimler'),
              subtitle: Text('Odaya girişte durum özeti sunar'),
              value: _voiceReports,
              onChanged: (value) {
                setState(() {
                  _voiceReports = value;
                });
              },
            ),

            SizedBox(height: 24),

            // Kaydet butonu
            Center(
              child: ElevatedButton.icon(
                onPressed: _savePreferences,
                icon: Icon(Icons.save),
                label: Text('Ayarları Kaydet'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}