import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Handler para mensagens em background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📬 Background message: ${message.messageId}');
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Inicializa o serviço de notificações
  static Future<void> initialize() async {
    try {
      // Configurar handler de background
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Solicitar permissões
      await requestPermission();

      // Configurar notificações locais
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Criar canal de notificação (Android)
      const androidChannel = AndroidNotificationChannel(
        'high_importance_channel',
        'Notificações Importantes',
        description: 'Canal para notificações importantes do EVA',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(androidChannel);

      // Configurar handlers
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      print('✅ NotificationService inicializado');
    } catch (e) {
      print('❌ Erro ao inicializar NotificationService: $e');
    }
  }

  /// Solicita permissões de notificação
  static Future<void> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('📱 Permissão de notificação: ${settings.authorizationStatus}');
  }

  /// Obtém o token FCM
  static Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      print('🔑 FCM Token: $token');
      return token;
    } catch (e) {
      print('❌ Erro ao obter token: $e');
      return null;
    }
  }

  /// Handler para mensagens em foreground
  static void _handleForegroundMessage(RemoteMessage message) {
    print('📨 Foreground message: ${message.notification?.title}');

    if (message.notification != null) {
      showLocalNotification(
        message.notification!.title ?? 'EVA',
        message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// Handler para quando o app é aberto via notificação
  static void _handleMessageOpenedApp(RemoteMessage message) {
    print('📬 App opened from notification: ${message.messageId}');
    // TODO: Navegar para tela específica baseado em message.data
  }

  /// Handler para tap em notificação local
  static void _onNotificationTap(NotificationResponse response) {
    print('👆 Notification tapped: ${response.payload}');
    // TODO: Navegar para tela específica
  }

  /// Exibe notificação local
  static Future<void> showLocalNotification(
    String title,
    String body, {
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'Notificações Importantes',
      channelDescription: 'Canal para notificações importantes do EVA',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Cancela todas as notificações
  static Future<void> cancelAll() async {
    await _localNotifications.cancelAll();
  }

  /// Verifica se notificações estão habilitadas
  static Future<bool> areNotificationsEnabled() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }
}
