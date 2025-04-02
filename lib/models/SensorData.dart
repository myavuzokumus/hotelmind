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


/** This is an auto generated class representing the SensorData type in your schema. */
class SensorData extends amplify_core.Model {
  static const classType = const _SensorDataModelType();
  final String id;
  final String? _roomId;
  final int? _timestamp;
  final double? _temperature;
  final double? _humidity;
  final int? _gasLevel;
  final double? _distance;
  final bool? _occupied;
  final bool? _cardInserted;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  SensorDataModelIdentifier get modelIdentifier {
      return SensorDataModelIdentifier(
        id: id
      );
  }
  
  String get roomId {
    try {
      return _roomId!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get timestamp {
    try {
      return _timestamp!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  double get temperature {
    try {
      return _temperature!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  double get humidity {
    try {
      return _humidity!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get gasLevel {
    try {
      return _gasLevel!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  double get distance {
    try {
      return _distance!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  bool get occupied {
    try {
      return _occupied!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  bool get cardInserted {
    try {
      return _cardInserted!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const SensorData._internal({required this.id, required roomId, required timestamp, required temperature, required humidity, required gasLevel, required distance, required occupied, required cardInserted, createdAt, updatedAt}): _roomId = roomId, _timestamp = timestamp, _temperature = temperature, _humidity = humidity, _gasLevel = gasLevel, _distance = distance, _occupied = occupied, _cardInserted = cardInserted, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory SensorData({String? id, required String roomId, required int timestamp, required double temperature, required double humidity, required int gasLevel, required double distance, required bool occupied, required bool cardInserted}) {
    return SensorData._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      roomId: roomId,
      timestamp: timestamp,
      temperature: temperature,
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
    return other is SensorData &&
      id == other.id &&
      _roomId == other._roomId &&
      _timestamp == other._timestamp &&
      _temperature == other._temperature &&
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
    
    buffer.write("SensorData {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("roomId=" + "$_roomId" + ", ");
    buffer.write("timestamp=" + (_timestamp != null ? _timestamp!.toString() : "null") + ", ");
    buffer.write("temperature=" + (_temperature != null ? _temperature!.toString() : "null") + ", ");
    buffer.write("humidity=" + (_humidity != null ? _humidity!.toString() : "null") + ", ");
    buffer.write("gasLevel=" + (_gasLevel != null ? _gasLevel!.toString() : "null") + ", ");
    buffer.write("distance=" + (_distance != null ? _distance!.toString() : "null") + ", ");
    buffer.write("occupied=" + (_occupied != null ? _occupied!.toString() : "null") + ", ");
    buffer.write("cardInserted=" + (_cardInserted != null ? _cardInserted!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  SensorData copyWith({String? roomId, int? timestamp, double? temperature, double? humidity, int? gasLevel, double? distance, bool? occupied, bool? cardInserted}) {
    return SensorData._internal(
      id: id,
      roomId: roomId ?? this.roomId,
      timestamp: timestamp ?? this.timestamp,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      gasLevel: gasLevel ?? this.gasLevel,
      distance: distance ?? this.distance,
      occupied: occupied ?? this.occupied,
      cardInserted: cardInserted ?? this.cardInserted);
  }
  
  SensorData copyWithModelFieldValues({
    ModelFieldValue<String>? roomId,
    ModelFieldValue<int>? timestamp,
    ModelFieldValue<double>? temperature,
    ModelFieldValue<double>? humidity,
    ModelFieldValue<int>? gasLevel,
    ModelFieldValue<double>? distance,
    ModelFieldValue<bool>? occupied,
    ModelFieldValue<bool>? cardInserted
  }) {
    return SensorData._internal(
      id: id,
      roomId: roomId == null ? this.roomId : roomId.value,
      timestamp: timestamp == null ? this.timestamp : timestamp.value,
      temperature: temperature == null ? this.temperature : temperature.value,
      humidity: humidity == null ? this.humidity : humidity.value,
      gasLevel: gasLevel == null ? this.gasLevel : gasLevel.value,
      distance: distance == null ? this.distance : distance.value,
      occupied: occupied == null ? this.occupied : occupied.value,
      cardInserted: cardInserted == null ? this.cardInserted : cardInserted.value
    );
  }
  
  SensorData.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _roomId = json['roomId'],
      _timestamp = (json['timestamp'] as num?)?.toInt(),
      _temperature = (json['temperature'] as num?)?.toDouble(),
      _humidity = (json['humidity'] as num?)?.toDouble(),
      _gasLevel = (json['gasLevel'] as num?)?.toInt(),
      _distance = (json['distance'] as num?)?.toDouble(),
      _occupied = json['occupied'],
      _cardInserted = json['cardInserted'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'roomId': _roomId, 'timestamp': _timestamp, 'temperature': _temperature, 'humidity': _humidity, 'gasLevel': _gasLevel, 'distance': _distance, 'occupied': _occupied, 'cardInserted': _cardInserted, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'roomId': _roomId,
    'timestamp': _timestamp,
    'temperature': _temperature,
    'humidity': _humidity,
    'gasLevel': _gasLevel,
    'distance': _distance,
    'occupied': _occupied,
    'cardInserted': _cardInserted,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<SensorDataModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<SensorDataModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final ROOMID = amplify_core.QueryField(fieldName: "roomId");
  static final TIMESTAMP = amplify_core.QueryField(fieldName: "timestamp");
  static final TEMPERATURE = amplify_core.QueryField(fieldName: "temperature");
  static final HUMIDITY = amplify_core.QueryField(fieldName: "humidity");
  static final GASLEVEL = amplify_core.QueryField(fieldName: "gasLevel");
  static final DISTANCE = amplify_core.QueryField(fieldName: "distance");
  static final OCCUPIED = amplify_core.QueryField(fieldName: "occupied");
  static final CARDINSERTED = amplify_core.QueryField(fieldName: "cardInserted");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "SensorData";
    modelSchemaDefinition.pluralName = "SensorData";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PRIVATE,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SensorData.ROOMID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SensorData.TIMESTAMP,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SensorData.TEMPERATURE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SensorData.HUMIDITY,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SensorData.GASLEVEL,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SensorData.DISTANCE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SensorData.OCCUPIED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SensorData.CARDINSERTED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _SensorDataModelType extends amplify_core.ModelType<SensorData> {
  const _SensorDataModelType();
  
  @override
  SensorData fromJson(Map<String, dynamic> jsonData) {
    return SensorData.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'SensorData';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [SensorData] in your schema.
 */
class SensorDataModelIdentifier implements amplify_core.ModelIdentifier<SensorData> {
  final String id;

  /** Create an instance of SensorDataModelIdentifier using [id] the primary key. */
  const SensorDataModelIdentifier({
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'SensorDataModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is SensorDataModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}