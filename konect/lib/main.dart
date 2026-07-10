import 'package:flutter/material.dart';
import 'app.dart';
import 'data/services/preferences_service.dart';
import 'data/repositories/discussion_room_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Preload SharedPreferences supaya PreferencesService.instance bisa
  // diakses synchronous dari mana saja.
  await PreferencesService.bootstrap();
  // Bootstrap repository room — load data dari local storage ke cache.
  await DiscussionRoomRepository.bootstrap();
  runApp(const KonectApp());
}
