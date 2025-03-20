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


/** This is an auto generated class representing the UserPreference type in your schema. */
@immutable
class UserPreference extends Model {
  static const classType = const _UserPreferenceModelType();
  final String id;
  final String? _roomId;
  final String? _userId;
  final Map<String, dynamic>? _preferences;
  final String? _roomMode;
  final TemporalDateTime? _createdAt;
  final TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;

  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;

  UserPreferenceModelIdentifier get modelIdentifier {
    return UserPreferenceModelIdentifier(
        id: id
    );
  }

  String get roomId {
    try {
      return _roomId!;
    } catch(e) {
      throw new AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
      );
    }
  }

  String? get userId {
    return _userId;
  }

  Map<String, dynamic>? get preferences {
    return _preferences;
  }

  String? get roomMode {
    return _roomMode;
  }

  TemporalDateTime? get createdAt {
    return _createdAt;
  }

  TemporalDateTime? get updatedAt {
    return _updatedAt;
  }

  const UserPreference._internal({required this.id, required roomId, userId, preferences, roomMode, createdAt, updatedAt}): _roomId = roomId, _userId = userId, _preferences = preferences, _roomMode = roomMode, _createdAt = createdAt, _updatedAt = updatedAt;

  factory UserPreference({String? id, required String roomId, String? userId, Map<String, dynamic>? preferences, String? roomMode}) {
    return UserPreference._internal(
        id: id == null ? UUID.getUUID() : id,
        roomId: roomId,
        userId: userId,
        preferences: preferences,
        roomMode: roomMode);
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserPreference &&
        id == other.id &&
        _roomId == other._roomId &&
        _userId == other._userId &&
        _preferences == other._preferences &&
        _roomMode == other._roomMode;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("UserPreference {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("roomId=" + "$_roomId" + ", ");
    buffer.write("userId=" + "$_userId" + ", ");
    buffer.write("preferences=" + (_preferences != null ? _preferences!.toString() : "null") + ", ");
    buffer.write("roomMode=" + "$_roomMode" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");

    return buffer.toString();
  }

  UserPreference copyWith({String? roomId, String? userId, Map<String, dynamic>? preferences, String? roomMode}) {
    return UserPreference._internal(
        id: id,
        roomId: roomId ?? this.roomId,
        userId: userId ?? this.userId,
        preferences: preferences ?? this.preferences,
        roomMode: roomMode ?? this.roomMode);
  }

  UserPreference.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        _roomId = json['roomId'],
        _userId = json['userId'],
        _preferences = json['preferences']?.cast<String, dynamic>(),
        _roomMode = json['roomMode'],
        _createdAt = json['createdAt'] != null ? TemporalDateTime.fromString(json['createdAt']) : null,
        _updatedAt = json['updatedAt'] != null ? TemporalDateTime.fromString(json['updatedAt']) : null;

  Map<String, dynamic> toJson() => {
    'id': id, 'roomId': _roomId, 'userId': _userId, 'preferences': _preferences, 'roomMode': _roomMode, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };

  Map<String, Object?> toMap() => {
    'id': id, 'roomId': _roomId, 'userId': _userId, 'preferences': _preferences, 'roomMode': _roomMode, 'createdAt': _createdAt, 'updatedAt': _updatedAt
  };

  static final QueryModelIdentifier<UserPreferenceModelIdentifier> MODEL_IDENTIFIER = QueryModelIdentifier<UserPreferenceModelIdentifier>();
  static final QueryField ID = QueryField(fieldName: "id");
  static final QueryField ROOMID = QueryField(fieldName: "roomId");
  static final QueryField USERID = QueryField(fieldName: "userId");
  static final QueryField PREFERENCES = QueryField(fieldName: "preferences");
  static final QueryField ROOMMODE = QueryField(fieldName: "roomMode");
  static var schema = Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "UserPreference";
    modelSchemaDefinition.pluralName = "UserPreferences";

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
        key: UserPreference.ROOMID,
        isRequired: true,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: UserPreference.USERID,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: UserPreference.PREFERENCES,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.embedded, ofCustomTypeName: 'JSON')
    ));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: UserPreference.ROOMMODE,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)
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

class _UserPreferenceModelType extends ModelType<UserPreference> {
  const _UserPreferenceModelType();

  @override
  UserPreference fromJson(Map<String, dynamic> jsonData) {
    return UserPreference.fromJson(jsonData);
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [UserPreference] in your schema.
 */
@immutable
class UserPreferenceModelIdentifier implements ModelIdentifier<UserPreference> {
  final String id;

  /** Create an instance of UserPreferenceModelIdentifier using [id] the primary key. */
  const UserPreferenceModelIdentifier({
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
  String toString() => 'UserPreferenceModelIdentifier(id: $id)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is UserPreferenceModelIdentifier &&
        id == other.id;
  }

  @override
  int get hashCode =>
      id.hashCode;
}