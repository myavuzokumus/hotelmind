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


/** This is an auto generated class representing the RoomControl type in your schema. */
class RoomControl extends amplify_core.Model {
  static const classType = const _RoomControlModelType();
  final String? _roomId;
  final RoomControlControlType? _controlType;
  final String? _controlName;
  final bool? _status;
  final int? _lastUpdated;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => modelIdentifier.serializeAsString();
  
  RoomControlModelIdentifier get modelIdentifier {
    try {
      return RoomControlModelIdentifier(
        roomId: _roomId!,
        controlName: _controlName!
      );
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
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
  
  RoomControlControlType? get controlType {
    return _controlType;
  }
  
  String get controlName {
    try {
      return _controlName!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  bool? get status {
    return _status;
  }
  
  int? get lastUpdated {
    return _lastUpdated;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const RoomControl._internal({required roomId, controlType, required controlName, status, lastUpdated, createdAt, updatedAt}): _roomId = roomId, _controlType = controlType, _controlName = controlName, _status = status, _lastUpdated = lastUpdated, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory RoomControl({required String roomId, RoomControlControlType? controlType, required String controlName, bool? status, int? lastUpdated}) {
    return RoomControl._internal(
      roomId: roomId,
      controlType: controlType,
      controlName: controlName,
      status: status,
      lastUpdated: lastUpdated);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RoomControl &&
      _roomId == other._roomId &&
      _controlType == other._controlType &&
      _controlName == other._controlName &&
      _status == other._status &&
      _lastUpdated == other._lastUpdated;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("RoomControl {");
    buffer.write("roomId=" + "$_roomId" + ", ");
    buffer.write("controlType=" + (_controlType != null ? amplify_core.enumToString(_controlType)! : "null") + ", ");
    buffer.write("controlName=" + "$_controlName" + ", ");
    buffer.write("status=" + (_status != null ? _status!.toString() : "null") + ", ");
    buffer.write("lastUpdated=" + (_lastUpdated != null ? _lastUpdated!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  RoomControl copyWith({RoomControlControlType? controlType, bool? status, int? lastUpdated}) {
    return RoomControl._internal(
      roomId: roomId,
      controlType: controlType ?? this.controlType,
      controlName: controlName,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated);
  }
  
  RoomControl copyWithModelFieldValues({
    ModelFieldValue<RoomControlControlType?>? controlType,
    ModelFieldValue<bool?>? status,
    ModelFieldValue<int?>? lastUpdated
  }) {
    return RoomControl._internal(
      roomId: roomId,
      controlType: controlType == null ? this.controlType : controlType.value,
      controlName: controlName,
      status: status == null ? this.status : status.value,
      lastUpdated: lastUpdated == null ? this.lastUpdated : lastUpdated.value
    );
  }
  
  RoomControl.fromJson(Map<String, dynamic> json)  
    : _roomId = json['roomId'],
      _controlType = amplify_core.enumFromString<RoomControlControlType>(json['controlType'], RoomControlControlType.values),
      _controlName = json['controlName'],
      _status = json['status'],
      _lastUpdated = (json['lastUpdated'] as num?)?.toInt(),
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'roomId': _roomId, 'controlType': amplify_core.enumToString(_controlType), 'controlName': _controlName, 'status': _status, 'lastUpdated': _lastUpdated, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'roomId': _roomId,
    'controlType': _controlType,
    'controlName': _controlName,
    'status': _status,
    'lastUpdated': _lastUpdated,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<RoomControlModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<RoomControlModelIdentifier>();
  static final ROOMID = amplify_core.QueryField(fieldName: "roomId");
  static final CONTROLTYPE = amplify_core.QueryField(fieldName: "controlType");
  static final CONTROLNAME = amplify_core.QueryField(fieldName: "controlName");
  static final STATUS = amplify_core.QueryField(fieldName: "status");
  static final LASTUPDATED = amplify_core.QueryField(fieldName: "lastUpdated");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "RoomControl";
    modelSchemaDefinition.pluralName = "RoomControls";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PUBLIC,
        provider: amplify_core.AuthRuleProvider.APIKEY,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ]),
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PRIVATE,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["roomId", "controlName"], name: null)
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: RoomControl.ROOMID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: RoomControl.CONTROLTYPE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.enumeration)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: RoomControl.CONTROLNAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: RoomControl.STATUS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: RoomControl.LASTUPDATED,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
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

class _RoomControlModelType extends amplify_core.ModelType<RoomControl> {
  const _RoomControlModelType();
  
  @override
  RoomControl fromJson(Map<String, dynamic> jsonData) {
    return RoomControl.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'RoomControl';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [RoomControl] in your schema.
 */
class RoomControlModelIdentifier implements amplify_core.ModelIdentifier<RoomControl> {
  final String roomId;
  final String controlName;

  /**
   * Create an instance of RoomControlModelIdentifier using [roomId] the primary key.
   * And [controlName] the sort key.
   */
  const RoomControlModelIdentifier({
    required this.roomId,
    required this.controlName});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'roomId': roomId,
    'controlName': controlName
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'RoomControlModelIdentifier(roomId: $roomId, controlName: $controlName)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is RoomControlModelIdentifier &&
      roomId == other.roomId &&
      controlName == other.controlName;
  }
  
  @override
  int get hashCode =>
    roomId.hashCode ^
    controlName.hashCode;
}