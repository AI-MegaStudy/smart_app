import 'package:flutter/material.dart';

class ProductRecord {
  final String name;
  final String packageUnit;
  final String summary;
  final String status;
  final Color color;

  const ProductRecord(
    this.name,
    this.packageUnit,
    this.summary,
    this.status,
    this.color,
  );
}
