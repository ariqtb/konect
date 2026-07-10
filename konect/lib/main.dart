import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  
  await dotenv.load(fileName: ".env");
  
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? 'http://43.157.247.43:8000',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? dotenv.env['ANON_KEY'] ?? 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlLWhhY2thdGhvbiIsImlhdCI6MTc4MzY5OTMzOSwiZXhwIjoxOTQxMzc5MzM5fQ.3DwvawrR3jwVq6-_a-GiO8EMQv1tY8VHkHDT02Scsck',
  );
  
  runApp(const KonectApp());
}
