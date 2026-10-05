import 'package:flutter/material.dart';

/// The app's root Navigator, so code without a BuildContext (notification
/// taps, for example) can open screens.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
