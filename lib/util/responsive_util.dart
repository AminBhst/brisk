import 'package:flutter/material.dart';


double minimizedSideMenuWidth = 150;

double resolveSideMenuWidth(Size size) {
  if (minimizedSideMenu(size)) {
    return minimizedSideMenuWidth;
  }
  return size.width * 0.2;
}

double resolveWindowWidth(Size size) {
  if (size.width < 1300) {
    return size.width - minimizedSideMenuWidth;
  }
  return size.width * 0.8;
}

bool minimizedSideMenu(Size size) => size.width < 1300;