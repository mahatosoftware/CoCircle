import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../core/theme/app_pallete.dart';

class PdfPreviewScreen extends StatelessWidget {
  final String title;
  final Uint8List pdfBytes;
  final String fileName;

  const PdfPreviewScreen({
    super.key,
    required this.title,
    required this.pdfBytes,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppPallete.backgroundDark : AppPallete.background,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: isDark ? AppPallete.surfaceDark : Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        minimum: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        child: PdfPreview(
          build: (format) => pdfBytes,
          canChangeOrientation: false,
          canChangePageFormat: false,
          canDebug: false,
          pdfFileName: fileName,
          loadingWidget: const Center(
            child: CircularProgressIndicator(),
          ),
          actionBarTheme: PdfActionBarTheme(
            backgroundColor: isDark ? AppPallete.surfaceDark : Colors.white,
            iconColor: isDark ? Colors.white : AppPallete.navy,
          ),
        ),
      ),
    );
  }
}
