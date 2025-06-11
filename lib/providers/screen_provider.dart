import 'package:flutter/material.dart';

class ScreenProvider extends ChangeNotifier {
  // Contains info about the screen size, orientation, etc.
  MediaQueryData? _screenData;
  bool _useMobileLayout = true;

  MediaQueryData get screenData => _screenData!;
  bool get useMobileLayout => _useMobileLayout;

  set screenData(MediaQueryData mqd) {
    _screenData = mqd;
    _useMobileLayout = screenData.size.width < 600;
  }
}
