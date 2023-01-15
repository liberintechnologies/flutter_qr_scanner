// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class BarcodeModel {
  final String displayValue;
  final String format;
  final String type;

  BarcodeModel(
    this.displayValue,
    this.format,
    this.type,
  );

  BarcodeModel copyWith({
    String? displayValue,
    String? format,
    String? type,
  }) {
    return BarcodeModel(
      displayValue ?? this.displayValue,
      format ?? this.format,
      type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'displayValue': displayValue,
      'format': format,
      'type': type,
    };
  }

  factory BarcodeModel.fromMap(Map<String, dynamic> map) {
    return BarcodeModel(
      map['displayValue'] as String,
      map['format'] as String,
      map['type'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory BarcodeModel.fromJson(String source) => BarcodeModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'BarcodeModel(displayValue: $displayValue, format: $format, type: $type)';

  @override
  bool operator ==(covariant BarcodeModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.displayValue == displayValue &&
      other.format == format &&
      other.type == type;
  }

  @override
  int get hashCode => displayValue.hashCode ^ format.hashCode ^ type.hashCode;
}
