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


/** This is an auto generated class representing the RoomEvent type in your schema. */
class RoomEvent extends amplify_core.Model {
  static const classType = const _RoomEventModelType();
  final String id;
  final String? _roomId;
  final String? _eventType;
  final int? _timestamp;
  final String? _description;
  final bool? _resolved;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  RoomEventModelIdentifier get modelIdentifier {
      return RoomEventModelIdentifier(
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
  
  String get eventType {
    try {
      return _eventType!;
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
  
  String get description {
    try {
      return _description!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  bool get resolved {
    try {
      return _resolved!;
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
  
  const RoomEvent._internal({required this.id, required roomId, required eventType, required timestamp, required description, required resolved, createdAt, updatedAt}): _roomId = roomId, _eventType = eventType, _timestamp = timestamp, _description = description, _resolved = resolved, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory RoomEvent({String? id, required String roomId, required String eventType, required int timestamp, required String description, required bool resolved}) {
    return RoomEvent._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      roomId: roomId,
      eventType: eventType,
      timestamp: timestamp,
      description: description,
      resolved: resolved);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RoomEvent &&
      id == other.id &&
      _roomId == other._roomId &&
      _eventType == other._eventType &&
      _timestamp == other._timestamp &&
      _description == other._description &&
      _resolved == other._resolved;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("RoomEvent {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("roomId=" + "$_roomId" + ", ");
    buffer.write("eventType=" + "$_eventType" + ", ");
    buffer.write("timestamp=" + (_timestamp != null ? _timestamp!.toString() : "null") + ", ");
    buffer.write("description=" + "$_description" + ", ");
    buffer.write("resolved=" + (_resolved != null ? _resolved!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  RoomEvent copyWith({String? roomId, String? eventType, int? timestamp, String? description, bool? resolved}) {
    return RoomEvent._internal(
      id: id,
      roomId: roomId ?? this.roomId,
      eventType: eventType ?? this.eventType,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
      resolved: resolved ?? this.resolved);
  }
  
  RoomEvent copyWithModelFieldValues({
    ModelFieldValue<String>? roomId,
    ModelFieldValue<String>? eventType,
    ModelFieldValue<int>? timestamp,
    ModelFieldValue<String>? description,
    ModelFieldValue<bool>? resolved
  }) {
    return RoomEvent._internal(
      id: id,
      roomId: roomId == null ? this.roomId : roomId.value,
      eventType: eventType == null ? this.eventType : eventType.value,
      timestamp: timestamp == null ? this.timestamp : timestamp.value,
      description: description == null ? this.description : description.value,
      resolved: resolved == null ? this.resolved : resolved.value
    );
  }
  
  RoomEvent.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _roomId = json['roomId'],
      _eventType = json['eventType'],
      _timestamp = (json['timestamp'] as num?)?.toInt(),
      _description = json['description'],
      _resolved = json['resolved'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'roomId': _roomId, 'eventType': _eventType, 'timestamp': _timestamp, 'description': _description, 'resolved': _resolved, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'roomId': _roomId,
    'eventType': _eventType,
    'timestamp': _timestamp,
    'description': _description,
    'resolved': _resolved,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<RoomEventModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<RoomEventModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final ROOMID = amplify_core.QueryField(fieldName: "roomId");
  static final EVENTTYPE = amplify_core.QueryField(fieldName: "eventType");
  static final TIMESTAMP = amplify_core.QueryField(fieldName: "timestamp");
  static final DESCRIPTION = amplify_core.QueryField(fieldName: "description");
  static final RESOLVED = amplify_core.QueryField(fieldName: "resolved");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "RoomEvent";
    modelSchemaDefinition.pluralName = "RoomEvents";
    
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
      key: RoomEvent.ROOMID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: RoomEvent.EVENTTYPE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: RoomEvent.TIMESTAMP,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: RoomEvent.DESCRIPTION,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: RoomEvent.RESOLVED,
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

class _RoomEventModelType extends amplify_core.ModelType<RoomEvent> {
  const _RoomEventModelType();
  
  @override
  RoomEvent fromJson(Map<String, dynamic> jsonData) {
    return RoomEvent.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'RoomEvent';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [RoomEvent] in your schema.
 */
class RoomEventModelIdentifier implements amplify_core.ModelIdentifier<RoomEvent> {
  final String id;

  /** Create an instance of RoomEventModelIdentifier using [id] the primary key. */
  const RoomEventModelIdentifier({
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
  String toString() => 'RoomEventModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is RoomEventModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}