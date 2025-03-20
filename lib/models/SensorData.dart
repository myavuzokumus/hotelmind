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

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'package:amplify_core/amplify_core.dart';
import 'package:flutter/foundation.dart';


/** This is an auto generated class representing the SensorData type in your schema. */
@immutable
class SensorData extends Model {
  static const classType = const _SensorDataModelType();
  final String id;
  final String? _deviceId;
  final int? _timestamp;
  final double? _temperature;
  final double? _humidity;
  final int? _gasLevel;
  final double? _distance;
  final bool? _occupied;
  final bool? _cardInserted;
  final TemporalDateTime? _createdAt;
  final TemporalDateTime? _updatedAt;

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

  String get deviceId {
    try {
      return _deviceId!;
    } catch(e) {
      throw new AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
      );
    }
  }

  int get timestamp {
    try {
      return _timestamp!;
    } catch(e) {
      throw new AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
      );
    }
  }

  double get temperature {
    try {
      return _temperature!;
    } catch(e) {
      throw new AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
      );
    }
  }

  double get humidity {
    try {
      return _humidity!;
    } catch(e) {
      throw new AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
      );
    }
  }

  int get gasLevel {
    try {
      return _gasLevel!;
    } catch(e) {
      throw new AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
      );
    }
  }

  double get distance {
    try {
      return _distance!;
    } catch(e) {
      throw new AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
      );
    }
  }

  bool get occupied {
    try {
      return _occupied!;
    } catch(e) {
      throw new AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
      );
    }
  }

  bool? get cardInserted {
    return _cardInserted;
  }

  TemporalDateTime? get createdAt {
    return _createdAt;
  }

  TemporalDateTime? get updatedAt {
    return _updatedAt;
  }

  const SensorData._internal({required this.id, required deviceId, required timestamp, required temperature, required humidity, required gasLevel, required distance, required occupied, cardInserted, createdAt, updatedAt}): _deviceId = deviceId, _timestamp = timestamp, _temperature = temperature, _humidity = humidity, _gasLevel = gasLevel, _distance = distance, _occupied = occupied, _cardInserted = cardInserted, _createdAt = createdAt, _updatedAt = updatedAt;

  factory SensorData({String? id, required String deviceId, required int timestamp, required double temperature, required double humidity, required int gasLevel, required double distance, required bool occupied, bool? cardInserted}) {
    return SensorData._internal(
        id: id == null ? UUID.getUUID() : id,
        deviceId: deviceId,
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
        _deviceId == other._deviceId &&
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
    buffer.write("deviceId=" + "$_deviceId" + ", ");
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

  SensorData copyWith({String? deviceId, int? timestamp, double? temperature, double? humidity, int? gasLevel, double? distance, bool? occupied, bool? cardInserted}) {
    return SensorData._internal(
        id: id,
        deviceId: deviceId ?? this.deviceId,
        timestamp: timestamp ?? this.timestamp,
        temperature: temperature ?? this.temperature,
        humidity: humidity ?? this.humidity,
        gasLevel: gasLevel ?? this.gasLevel,
        distance: distance ?? this.distance,
        occupied: occupied ?? this.occupied,
        cardInserted: cardInserted ?? this.cardInserted);
  }

  SensorData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        _deviceId = json['deviceId'],
        _timestamp = (json['timestamp'] as num?)?.toInt(),
        _temperature = (json['temperature'] as num?)?.toDouble(),
        _humidity = (json['humidity'] as num?)?.toDouble(),
        _gasLevel = (json['gasLevel'] as num?)?.toInt(),
        _distance = (json['distance'] as num?)?.toDouble(),
        _occupied = json['occupied'],
        _cardInserted = json['cardInserted'],
        _createdAt = json['createdAt'] != null ? TemporalDateTime.fromString(json['createdAt']) : null,
        _updatedAt = json['updatedAt'] != null ? TemporalDateTime.fromString(json['updatedAt']) : null;

  Map<String, dynamic> toJson() => {
    'id': id, 'deviceId': _deviceId, 'timestamp': _timestamp, 'temperature': _temperature, 'humidity': _humidity, 'gasLevel': _gasLevel, 'distance': _distance, 'occupied': _occupied, 'cardInserted': _cardInserted, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };

  Map<String, Object?> toMap() => {
    'id': id, 'deviceId': _deviceId, 'timestamp': _timestamp, 'temperature': _temperature, 'humidity': _humidity, 'gasLevel': _gasLevel, 'distance': _distance, 'occupied': _occupied, 'cardInserted': _cardInserted, 'createdAt': _createdAt, 'updatedAt': _updatedAt
  };

  static final QueryModelIdentifier<SensorDataModelIdentifier> MODEL_IDENTIFIER = QueryModelIdentifier<SensorDataModelIdentifier>();
  static final QueryField ID = QueryField(fieldName: "id");
  static final QueryField DEVICEID = QueryField(fieldName: "deviceId");
  static final QueryField TIMESTAMP = QueryField(fieldName: "timestamp");
  static final QueryField TEMPERATURE = QueryField(fieldName: "temperature");
  static final QueryField HUMIDITY = QueryField(fieldName: "humidity");
  static final QueryField GASLEVEL = QueryField(fieldName: "gasLevel");
  static final QueryField DISTANCE = QueryField(fieldName: "distance");
  static final QueryField OCCUPIED = QueryField(fieldName: "occupied");
  static final QueryField CARDINSERTED = QueryField(fieldName: "cardInserted");
  static var schema = Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "SensorData";
    modelSchemaDefinition.pluralName = "SensorData";

    modelSchemaDefinition.authRules = [
      AuthRule(
          authStrategy: AuthStrategy.PUBLIC,
          operations: [
            ModelOperation.CREATE,
            ModelOperation.UPDATE,
            ModelOperation.DELETE,
            ModelOperation.READ
          ])
    ];

    modelSchemaDefinition.addField(ModelFieldDefinition.id());

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: SensorData.DEVICEID,
        isRequired: true,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: SensorData.TIMESTAMP,
        isRequired: true,
        ofType: ModelFieldType(ModelFieldTypeEnum.int)
    ));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: SensorData.TEMPERATURE,
        isRequired: true,
        ofType: ModelFieldType(ModelFieldTypeEnum.double)
    ));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: SensorData.HUMIDITY,
        isRequired: true,
        ofType: ModelFieldType(ModelFieldTypeEnum.double)
    ));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: SensorData.GASLEVEL,
        isRequired: true,
        ofType: ModelFieldType(ModelFieldTypeEnum.int)
    ));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: SensorData.DISTANCE,
        isRequired: true,
        ofType: ModelFieldType(ModelFieldTypeEnum.double)
    ));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: SensorData.OCCUPIED,
        isRequired: true,
        ofType: ModelFieldType(ModelFieldTypeEnum.bool)
    ));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: SensorData.CARDINSERTED,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.bool)
    ));

    modelSchemaDefinition.addField(ModelFieldDefinition.nonQueryField(
        fieldName: 'createdAt',
        isRequired: false,
        isReadOnly: true,
        ofType: ModelFieldType(ModelFieldTypeEnum.dateTime)
    ));

    modelSchemaDefinition.addField(ModelFieldDefinition.nonQueryField(
        fieldName: 'updatedAt',
        isRequired: false,
        isReadOnly: true,
        ofType: ModelFieldType(ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _SensorDataModelType extends ModelType<SensorData> {
  const _SensorDataModelType();

  @override
  SensorData fromJson(Map<String, dynamic> jsonData) {
    return SensorData.fromJson(jsonData);
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [SensorData] in your schema.
 */
@immutable
class SensorDataModelIdentifier implements ModelIdentifier<SensorData> {
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