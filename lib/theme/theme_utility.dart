import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme createTextTheme(BuildContext context, String fontFamily) {
  return GoogleFonts.getTextTheme(fontFamily, Theme.of(context).textTheme);
}
