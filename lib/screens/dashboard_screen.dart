import 'dart:async';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelmind/models/QrSession.dart';
import 'package:hotelmind/screens/settings_screen.dart';
import 'package:hotelmind/services/event_bus.dart';
import 'package:hotelmind/services/navigation_service.dart';

import '../services/debug_log_provider.dart';
import '../services/room_automation_service.dart';
import '../services/sensor_service.dart';
import '../widgets/event_list.dart';
import '../widgets/room_status_card.dart';
import '../widgets/sensor_chart.dart';

part 'dashboard_mixin.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final String roomId;
  final String sessionId;

  const DashboardScreen({
    super.key,
    required this.roomId,
    required this.sessionId,
  });

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with _DashboardMixin, SingleTickerProviderStateMixin {

  // _DashboardScreenState içinde initState metoduna ekle
  @override
  void initState() {
    super.initState();

    // Mixin'deki animasyon başlatma metodunu çağır ve this (TickerProvider) geçir
    initAIAnimation(this);
  }

  Future<void> _showSettingsDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          clipBehavior: Clip.antiAlias, // Köşelerden taşan içeriği kırpmak için
          insetPadding: EdgeInsets.all(16), // Ekrandan uzaklık
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.75, // Genişlik sınırlama
            child: SettingsScreen(roomId: _roomId, sessionId: _currentSessionId),
          ),
        );
      },
    );
  }

  Future<void> _showCleaningRequestDialog() async {
    String note = '';

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Temizlik Talebi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Temizlik ekibine iletilecek talebiniz var mı?'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Ekstra havlu, ekstra çarşaf, vb.',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                note = value;
              },
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                //await _roomService.sendCleaningRequest(_roomId, note);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Temizlik talebiniz iletildi'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Talep gönderilirken hata oluştu'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Talep Gönder'),
          ),
        ],
      ),
    );
  }

  // YENİ: Resepsiyona mesaj gönder
  Future<void> _showReceptionMessageDialog() async {
    String message = '';

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resepsiyona Mesaj'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Mesajınızı yazın:'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Mesajınızı buraya yazın...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              onChanged: (value) {
                message = value;
              },
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (message.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lütfen bir mesaj yazın'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              try {
                //await _roomService.sendMessageToReception(_roomId, message);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Mesajınız resepsiyona iletildi'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Mesaj gönderilirken hata oluştu'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Gönder'),
          ),
        ],
      ),
    );
  }

  // Aktif kullanıcıları görüntüleme diyalogu
  Future<void> _showActiveUsersDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Odadaki Aktif Oturumlar'),
        content: SizedBox(
          width: double.maxFinite, // Dialog genişliğini ayarla
          height: 300, // Yükseklik ekleyelim
          child: FutureBuilder<List<QrSession?>>(
            future: _getActiveUsersForRoom(_roomId),
            builder: (context, snapshot) {
              // Yüklenirken
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Aktif kullanıcılar yükleniyor...')
                    ],
                  ),
                );
              }

              // Hata durumu
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      SizedBox(height: 16),
                      Text('Hata oluştu: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                );
              }

              // Veri boşsa
              final activeUsers = snapshot.data;
              if (activeUsers == null || activeUsers.isEmpty) {
                return Center(child: Text('Aktif oturum bulunamadı.'));
              }

              // Veri varsa
              return ListView.builder(
                shrinkWrap: true,
                itemCount: activeUsers.length,
                itemBuilder: (context, index) {
                  final userSession = activeUsers[index];
                  if (userSession == null) return SizedBox.shrink(); // Null kontrolü

                  bool isCurrentUser = userSession.sessionId == widget.sessionId;

                  return ListTile(
                    leading: Icon(isCurrentUser ? Icons.person_pin : Icons.person_outline),
                    title: Text(isCurrentUser ? 'Siz (Bu Oturum)' : 'Diğer Kullanıcı'),
                    subtitle: Text('Oturum ID: ...${userSession.sessionId.substring(userSession.sessionId.length - 6)}'),
                    trailing: isCurrentUser
                        ? null
                        : IconButton(
                      icon: Icon(Icons.logout, color: Colors.red),
                      tooltip: 'Oturumu Sonlandır',
                      onPressed: () async {
                        bool confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Oturumu Sonlandır'),
                            content: Text('Bu kullanıcının oturumunu sonlandırmak istediğinizden emin misiniz?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: Text('İptal')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Sonlandır', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        ) ?? false;

                        if (confirm) {
                          Navigator.pop(context);
                          await _terminateUserSession(userSession.sessionId);
                          _showActiveUsersDialog(); // Listeyi yenilemek için tekrar aç
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Kapat'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Oda Yönetim Paneli')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Oda Yönetim Paneli', style: TextStyle(color: Colors.blue)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.people, color: Colors.blue),
            tooltip: 'Mevcut Kullanıcılar',
            onPressed: _showActiveUsersDialog,
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.blue),
            tooltip: 'Ayarlar',
            onPressed: _showSettingsDialog, // NavigationService yerine dialog göster
          ),
          AnimatedBuilder(
            animation: _isLoggingOut,
            builder: (context, child) {
              return IconButton(
                icon: _isLoggingOut.value
                    ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.red,
                  ),
                )
                    : Icon(Icons.exit_to_app, color: Colors.red),
                tooltip: 'Oturumu Sonlandır',
                onPressed: _isLoggingOut.value
                    ? null
                    : () async {
                  _isLoggingOut.value = true;
                  try {
                    // Oturumu sonlandırma işlemi
                    await _terminateUserSession(widget.sessionId);

                    // NavigationService'deki updateAuthState metodunu kullanarak oturum bilgilerini sıfırla
                    ref.read(navigationServiceProvider).updateAuthState(
                        isAuthenticated: false,
                        roomId: null,
                        sessionId: null);

                    if (mounted) {
                      // Ana sayfaya yönlendir
                      ref.read(navigationServiceProvider).navigateToHome();
                    }
                  } finally {
                    if (mounted) {
                      _isLoggingOut.value = false;
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRoomHistory,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Karşılama ve durum alanı - Web için uyarlandı
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
                            'Hoş geldiniz, $_userName',
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
                            'Oda Durumu: ${_isRoomOccupied ? "Dolu" : "Boş"} | Mod: $_roomMode',
                            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Canlı sensör verileri - Web benzeri responsive grid
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width > 1200
                        ? 280 // Geniş ekranlarda sabit genişlik
                        : 218,
                          child: RoomStatusCard(
                            title: 'Sıcaklık',
                            value: '${_currentTemperature.toStringAsFixed(1)}°C',
                            icon: Icons.thermostat,
                            color: _getSensorColor(_currentTemperature, 18, 25),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width > 1200
                              ? 280 // Geniş ekranlarda sabit genişlik
                              : 218,
                          child: RoomStatusCard(
                            title: 'Nem',
                            value: '${_currentHumidity.toStringAsFixed(1)}%',
                            icon: Icons.water_drop,
                            color: _getSensorColor(_currentHumidity, 40, 60),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width > 600
                              ? 280 // Geniş ekranlarda sabit genişlik
                              : 218,
                          child: RoomStatusCard(
                            title: 'Gaz Seviyesi',
                            value: '$_currentGasLevel/10',
                            icon: Icons.cloud,
                            color: _getGasColor(_currentGasLevel),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width > 600
                              ? 280 // Geniş ekranlarda sabit genişlik
                              : 218,
                          child: RoomStatusCard(
                            title: 'Kart Durumu',
                            value: _isCardInserted ? 'Takılı' : 'Takılı Değil',
                            icon: Icons.credit_card,
                            color: _isCardInserted ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Oda Kontrol Bölümü - Web için uyarlandı
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.room_preferences, color: Colors.blue, size: 28),
                                SizedBox(width: 8),
                                Text(
                                  'Oda Kontrolleri',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),

                            // Aydınlatma ve Cihaz Kontrolleri yan yana - Web için responsive
                            LayoutBuilder(
                                builder: (context, constraints) {
                                  if (constraints.maxWidth > 800) {
                                    // Geniş ekran - yan yana
                                    return Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Aydınlatma Kontrolleri
                                        Expanded(
                                          child: _buildLightingControls(),
                                        ),
                                        SizedBox(width: 24),
                                        // Cihaz Kontrolleri
                                        Expanded(
                                          child: _buildDeviceControls(),
                                        ),
                                      ],
                                    );
                                  } else {
                                    // Dar ekran - alt alta
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLightingControls(),
                                        SizedBox(height: 24),
                                        _buildDeviceControls(),
                                      ],
                                    );
                                  }
                                }
                            ),

                            Divider(height: 40, thickness: 1),

                            // Hizmet Butonları - Web için uyarlandı
                            Text(
                              'Hizmetler',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: 16),
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              alignment: WrapAlignment.start,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _showCleaningRequestDialog,
                                  icon: Icon(Icons.cleaning_services),
                                  label: Text('Temizlik Talep Et'),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    textStyle: TextStyle(fontSize: 16),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _showReceptionMessageDialog,
                                  icon: Icon(Icons.message),
                                  label: Text('Resepsiyona Mesaj Gönder'),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    textStyle: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 32),

                    Center(child: _buildAIButton()),

                    SizedBox(height: 32),

                    // Sensör grafikleri - Web için uyarlandı
                    LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 900) {
                            // Geniş ekran - yan yana grafikler
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildTemperatureChart(),
                                ),
                                SizedBox(width: 24),
                                Expanded(
                                  child: _buildHumidityChart(),
                                ),
                              ],
                            );
                          } else {
                            // Dar ekran - alt alta grafikler
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTemperatureChart(),
                                SizedBox(height: 32),
                                _buildHumidityChart(),
                              ],
                            );
                          }
                        }
                    ),

                    SizedBox(height: 32),

                    // Son olaylar - Web için uyarlandı
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.history, color: Colors.blue, size: 28),
                                SizedBox(width: 8),
                                Text(
                                  'Son Olaylar',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            EventList(events: _eventHistory),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Aydınlatma kontrolleri widget'ı
  Widget _buildLightingControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'Aydınlatma',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
        ),
        SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              SwitchListTile(
                title: Text('Ana Aydınlatma'),
                value: _mainLightOn,
                secondary: Icon(Icons.lightbulb, color: _mainLightOn ? Colors.yellow : Colors.grey),
                onChanged: (value) => _toggleLight('main', value),
              ),
              Divider(height: 1),
              SwitchListTile(
                title: Text('Masa Işığı'),
                value: _deskLightOn,
                secondary: Icon(Icons.desk, color: _deskLightOn ? Colors.yellow : Colors.grey),
                onChanged: (value) => _toggleLight('desk', value),
              ),
              Divider(height: 1),
              SwitchListTile(
                title: Text('Yatak Işığı'),
                value: _bedLightOn,
                secondary: Icon(Icons.bed, color: _bedLightOn ? Colors.yellow : Colors.grey),
                onChanged: (value) => _toggleLight('bed', value),
              ),
              Divider(height: 1),
              SwitchListTile(
                title: Text('Banyo Işığı'),
                value: _bathroomLightOn,
                secondary: Icon(Icons.bathroom, color: _bathroomLightOn ? Colors.yellow : Colors.grey),
                onChanged: (value) => _toggleLight('bathroom', value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Cihaz kontrolleri widget'ı
  Widget _buildDeviceControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'Cihazlar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
        ),
        SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              SwitchListTile(
                title: Text('Televizyon'),
                value: _tvOn,
                secondary: Icon(Icons.tv, color: _tvOn ? Colors.blue : Colors.grey),
                onChanged: (value) => _toggleDevice('tv', value),
              ),
              Divider(height: 1),
              SwitchListTile(
                title: Text('Klima'),
                value: _acOn,
                secondary: Icon(Icons.ac_unit, color: _acOn ? Colors.blue : Colors.grey),
                onChanged: (value) => _toggleDevice('ac', value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Sıcaklık grafiği widget'ı
  Widget _buildTemperatureChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sıcaklık Grafiği',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SensorChart(
                data: _temperatureHistory,
                color: Colors.orange,
                label: 'Sıcaklık (°C)',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Nem grafiği widget'ı
  Widget _buildHumidityChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nem Grafiği',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SensorChart(
                data: _humidityHistory,
                color: Colors.blue,
                label: 'Nem (%)',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIButton() {
    return AnimatedBuilder(
      animation: _aiButtonAnimController,
      builder: (context, child) {
        final Color currentColor = _aiAssistantEnabled
            ? _aiButtonColors[(_aiButtonAnimController.value * (_aiButtonColors.length - 1)).round()]
            : Colors.grey.shade600;

        return Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _toggleAI(!_aiAssistantEnabled),
            child: Container(
              width: 240,
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: _aiAssistantEnabled
                    ? LinearGradient(
                  colors: [currentColor.withValues(alpha: 0.7), currentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : LinearGradient(
                  colors: [Colors.grey.shade300, Colors.grey.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.smart_toy,
                    size: 48,
                    color: _aiAssistantEnabled ? Colors.white : Colors.grey.shade800,
                  ),
                  SizedBox(height: 12),
                  Text(
                    _aiAssistantEnabled ? 'AI Asistan Aktif' : 'AI Asistan Devre Dışı',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _aiAssistantEnabled ? Colors.white : Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}