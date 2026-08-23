import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

// ============================================================
// COLORS & THEME
// ============================================================

class AppColors {
  static const deepIndigo = Color(0xFF4B2AAD);
  static const vividViolet = Color(0xFF7B4DFF);
  static const electricCyan = Color(0xFF00D2C6);
  static const sunnyAmber = Color(0xFFFFB020);
  static const coralPink = Color(0xFFFF5D7A);
  static const lavenderMist = Color(0xFFF3F0FF);
  static const inkNavy = Color(0xFF1B1730);

  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [vividViolet, deepIndigo],
  );

  static const buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [electricCyan, vividViolet],
  );
}

class AppTheme {
  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.vividViolet,
        primary: AppColors.vividViolet,
        secondary: AppColors.electricCyan,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color.fromRGBO(104, 174, 250, 1),
    );

    final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
      headlineSmall: GoogleFonts.poppins(
        fontSize: 50,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: AppColors.inkNavy,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.inkNavy,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.inkNavy.withValues(alpha: 0.8),
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.vividViolet.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.vividViolet.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.vividViolet, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.coralPink, width: 1.5),
        ),
        labelStyle: TextStyle(
          color: AppColors.inkNavy.withValues(alpha: 0.6),
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ============================================================
// MODELS
// ============================================================

enum QuestionType { single, multiple }

class Question {
  final String questionText;
  final List<String> options;
  final QuestionType type;
  final List<int> correctIndexes;

  Question({
    required this.questionText,
    required this.options,
    required this.type,
    required this.correctIndexes,
  });
}

class Attempt {
  final String name;
  final String email;
  final DateTime startTime;
  final DateTime endTime;
  final int marks;
  final int totalMarks;

  Attempt({
    required this.name,
    required this.email,
    required this.startTime,
    required this.endTime,
    required this.marks,
    required this.totalMarks,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'marks': marks,
    'totalMarks': totalMarks,
  };

  factory Attempt.fromJson(Map<String, dynamic> json) => Attempt(
    name: json['name'] as String,
    email: json['email'] as String,
    startTime: DateTime.parse(json['startTime'] as String),
    endTime: DateTime.parse(json['endTime'] as String),
    marks: json['marks'] as int,
    totalMarks: json['totalMarks'] as int,
  );
}

// ============================================================
// LOCAL STORAGE SERVICE
// ============================================================

class StorageService {
  static const _key = 'exam_attempts';

  static Future<List<Attempt>> getAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((e) => Attempt.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveAttempt(Attempt attempt) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.add(jsonEncode(attempt.toJson()));
    await prefs.setStringList(_key, raw);
  }
}

// ============================================================
// AUTO-WIDTH TEXT FIELD (used by HomeScreen for Name & Email)
// ============================================================

class AutoWidthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final Color accentColor;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final double minWidth;
  final double maxWidth;
  final TextStyle? labelStyle;

  const AutoWidthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.accentColor = AppColors.vividViolet,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.minWidth = 200,
    this.maxWidth = 320,
    this.labelStyle,
  });

  @override
  State<AutoWidthTextField> createState() => _AutoWidthTextFieldState();
}

class _AutoWidthTextFieldState extends State<AutoWidthTextField> {
  late double _width;

  @override
  void initState() {
    super.initState();
    _width = widget.minWidth;
    widget.controller.addListener(_updateWidth);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateWidth());
  }

  void _updateWidth() {
    final textToMeasure = widget.controller.text.isEmpty
        ? widget.hintText
        : widget.controller.text;

    final textPainter = TextPainter(
      text: TextSpan(text: textToMeasure, style: const TextStyle(fontSize: 16)),
      textDirection: TextDirection.ltr,
    )..layout();

    double newWidth = textPainter.width + 100;
    newWidth = newWidth.clamp(widget.minWidth, widget.maxWidth);

    if ((newWidth - _width).abs() > 0.5) {
      setState(() => _width = newWidth);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateWidth);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        width: _width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.accentColor.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          textAlign: TextAlign.center,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          cursorColor: widget.accentColor,
          decoration: InputDecoration(
            labelText: widget.label,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 8,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: widget.accentColor.withValues(alpha: 0.15),
                child: Icon(widget.icon, size: 16, color: widget.accentColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// APP ENTRY POINT
// ============================================================

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCQ Exam App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomeScreen(),
    );
  }
}
