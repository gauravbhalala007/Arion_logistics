import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  static const double xsValue = 8;
  static const double smValue = 12;
  static const double mdValue = 18;
  static const double lgValue = 24;
  static const double xlValue = 32;
  static const double fullValue = 999;

  static const Radius xs = Radius.circular(xsValue);
  static const Radius sm = Radius.circular(smValue);
  static const Radius md = Radius.circular(mdValue);
  static const Radius lg = Radius.circular(lgValue);
  static const Radius xl = Radius.circular(xlValue);
  static const Radius full = Radius.circular(fullValue);

  static const BorderRadius allXs = BorderRadius.all(xs);
  static const BorderRadius allSm = BorderRadius.all(sm);
  static const BorderRadius allMd = BorderRadius.all(md);
  static const BorderRadius allLg = BorderRadius.all(lg);
  static const BorderRadius allXl = BorderRadius.all(xl);
  static const BorderRadius allFull = BorderRadius.all(full);
}
