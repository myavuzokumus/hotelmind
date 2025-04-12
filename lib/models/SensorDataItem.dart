/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, override_on_non_overriding_member, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;


/** This is an auto generated class representing the SensorDataItem type in your schema. */
class SensorDataItem {
  final int? _timestamp;
  final double? _temperature;
  final double? _pressure;
  final double? _humidity;
  final int? _gasLevel;
  final double? _distance;
  final bool? _occupied;
  final bool? _cardInserted;

  int? get timestamp {
    return _timestamp;
  }
  
  double? get temperature {
    return _temperature;
  }
  
  double? get pressure {
    return _pressure;
  }
  
  double? get humidity {
    return _humidity;
  }
  
  int? get gasLevel {
    return _gasLevel;
  }
  
  double? get distance {
    return _distance;
  }
  
  bool? get occupied {
    return _occupied;
  }
  
  bool? get cardInserted {
    return _cardInserted;
  }
  
  const SensorDataItem._internal({timestamp, temperature, pressure, humidity, gasLevel, distance, occupied, cardInserted}): _timestamp = timestamp, _temperature = temperature, _pressure = pressure, _humidity = humidity, _gasLevel = gasLevel, _distance = distance, _occupied = occupied, _cardInserted = cardInserted;
  
  factory SensorDataItem({int? timestamp, double? temperature, double? pressure, double? humidity, int? gasLevel, double? distance, bool? occupied, bool? cardInserted}) {
    return SensorDataItem._internal(
      timestamp: timestamp,
      temperature: temperature,
      pressure: pressure,
      humidity: humidity,
      gasLevel: gasLevel,
      distance: distance,
      occupied: occupied,
      cardInserted: cardInserted);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SensorDataItem &&
      _timestamp == other._timestamp &&
      _temperature == other._temperature &&
      _pressure == other._pressure &&
      _humidity == other._humidity &&
      _gasLevel == other._gasLevel &&
      _distance == other._distance &&
      _occupied == other._occupied &&
      _cardInserted == other._cardInserted;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("SensorDataItem {");
    buffer.write("timestamp=" + (_timestamp != null ? _timestamp!.toString() : "null") + ", ");
    buffer.write("temperature=" + (_temperature != null ? _temperature!.toString() : "null") + ", ");
    buffer.write("pressure=" + (_pressure != null ? _pressure!.toString() : "null") + ", ");
    buffer.write("humidity=" + (_humidity != null ? _humidity!.toString() : "null") + ", ");
    buffer.write("gasLevel=" + (_gasLevel != null ? _gasLevel!.toString() : "null") + ", ");
    buffer.write("distance=" + (_distance != null ? _distance!.toString() : "null") + ", ");
    buffer.write("occupied=" + (_occupied != null ? _occupied!.toString() : "null") + ", ");
    buffer.write("cardInserted=" + (_cardInserted != null ? _cardInserted!.toString() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  SensorDataItem copyWith({int? timestamp, double? temperature, double? pressure, double? humidity, int? gasLevel, double? distance, bool? occupied, bool? cardInserted}) {
    return SensorDataItem._internal(
      timestamp: timestamp ?? this.timestamp,
      temperature: temperature ?? this.temperature,
      pressure: pressure ?? this.pressure,
      humidity: humidity ?? this.humidity,
      gasLevel: gasLevel ?? this.gasLevel,
      distance: distance ?? this.distance,
      occupied: occupied ?? this.occupied,
      cardInserted: cardInserted ?? this.cardInserted);
  }
  
  SensorDataItem copyWithModelFieldValues({
    ModelFieldValue<int?>? timestamp,
    ModelFieldValue<double?>? temperature,
    ModelFieldValue<double?>? pressure,
    ModelFieldValue<double?>? humidity,
    ModelFieldValue<int?>? gasLevel,
    ModelFieldValue<double?>? distance,
    ModelFieldValue<bool?>? occupied,
    ModelFieldValue<bool?>? cardInserted
  }) {
    return SensorDataItem._internal(
      timestamp: timestamp == null ? this.timestamp : timestamp.value,
      temperature: temperature == null ? this.temperature : temperature.value,
      pressure: pressure == null ? this.pressure : pressure.value,
      humidity: humidity == null ? this.humidity : humidity.value,
      gasLevel: gasLevel == null ? this.gasLevel : gasLevel.value,
      distance: distance == null ? this.distance : distance.value,
      occupied: occupied == null ? this.occupied : occupied.value,
      cardInserted: cardInserted == null ? this.cardInserted : cardInserted.value
    );
  }
  
  SensorDataItem.fromJson(Map<String, dynamic> json)  
    : _timestamp = (json['timestamp'] as num?)?.toInt(),
      _temperature = (json['temperature'] as num?)?.toDouble(),
      _pressure = (json['pressure'] as num?)?.toDouble(),
      _humidity = (json['humidity'] as num?)?.toDouble(),
      _gasLevel = (json['gasLevel'] as num?)?.toInt(),
      _distance = (json['distance'] as num?)?.toDouble(),
      _occupied = json['occupied'],
      _cardInserted = json['cardInserted'];
  
  Map<String, dynamic> toJson() => {
    'timestamp': _timestamp, 'temperature': _temperature, 'pressure': _pressure, 'humidity': _humidity, 'gasLevel': _gasLevel, 'distance': _distance, 'occupied': _occupied, 'cardInserted': _cardInserted
  };
  
  Map<String, Object?> toMap() => {
    'timestamp': _timestamp,
    'temperature': _temperature,
    'pressure': _pressure,
    'humidity': _humidity,
    'gasLevel': _gasLevel,
    'distance': _distance,
    'occupied': _occupied,
    'cardInserted': _cardInserted
  };

  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "SensorDataItem";
    modelSchemaDefinition.pluralName = "SensorDataItems";
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'timestamp',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'temperature',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'pressure',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'humidity',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'gasLevel',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'distance',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'occupied',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'cardInserted',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
  });
}