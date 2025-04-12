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


/** This is an auto generated class representing the UserPreference type in your schema. */
class UserPreference extends amplify_core.Model {
  static const classType = const _UserPreferenceModelType();
  final String? _roomId;
  final double? _preferredTemperature;
  final double? _preferredHumidity;
  final bool? _autoClimate;
  final bool? _automaticLights;
  final bool? _voiceReports;
  final UserPreferenceRoomMode? _roomMode;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => modelIdentifier.serializeAsString();
  
  UserPreferenceModelIdentifier get modelIdentifier {
    try {
      return UserPreferenceModelIdentifier(
        roomId: _roomId!
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
  
  double? get preferredTemperature {
    return _preferredTemperature;
  }
  
  double? get preferredHumidity {
    return _preferredHumidity;
  }
  
  bool? get autoClimate {
    return _autoClimate;
  }
  
  bool? get automaticLights {
    return _automaticLights;
  }
  
  bool? get voiceReports {
    return _voiceReports;
  }
  
  UserPreferenceRoomMode? get roomMode {
    return _roomMode;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const UserPreference._internal({required roomId, preferredTemperature, preferredHumidity, autoClimate, automaticLights, voiceReports, roomMode, createdAt, updatedAt}): _roomId = roomId, _preferredTemperature = preferredTemperature, _preferredHumidity = preferredHumidity, _autoClimate = autoClimate, _automaticLights = automaticLights, _voiceReports = voiceReports, _roomMode = roomMode, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory UserPreference({required String roomId, double? preferredTemperature, double? preferredHumidity, bool? autoClimate, bool? automaticLights, bool? voiceReports, UserPreferenceRoomMode? roomMode}) {
    return UserPreference._internal(
      roomId: roomId,
      preferredTemperature: preferredTemperature,
      preferredHumidity: preferredHumidity,
      autoClimate: autoClimate,
      automaticLights: automaticLights,
      voiceReports: voiceReports,
      roomMode: roomMode);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserPreference &&
      _roomId == other._roomId &&
      _preferredTemperature == other._preferredTemperature &&
      _preferredHumidity == other._preferredHumidity &&
      _autoClimate == other._autoClimate &&
      _automaticLights == other._automaticLights &&
      _voiceReports == other._voiceReports &&
      _roomMode == other._roomMode;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("UserPreference {");
    buffer.write("roomId=" + "$_roomId" + ", ");
    buffer.write("preferredTemperature=" + (_preferredTemperature != null ? _preferredTemperature!.toString() : "null") + ", ");
    buffer.write("preferredHumidity=" + (_preferredHumidity != null ? _preferredHumidity!.toString() : "null") + ", ");
    buffer.write("autoClimate=" + (_autoClimate != null ? _autoClimate!.toString() : "null") + ", ");
    buffer.write("automaticLights=" + (_automaticLights != null ? _automaticLights!.toString() : "null") + ", ");
    buffer.write("voiceReports=" + (_voiceReports != null ? _voiceReports!.toString() : "null") + ", ");
    buffer.write("roomMode=" + (_roomMode != null ? amplify_core.enumToString(_roomMode)! : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  UserPreference copyWith({double? preferredTemperature, double? preferredHumidity, bool? autoClimate, bool? automaticLights, bool? voiceReports, UserPreferenceRoomMode? roomMode}) {
    return UserPreference._internal(
      roomId: roomId,
      preferredTemperature: preferredTemperature ?? this.preferredTemperature,
      preferredHumidity: preferredHumidity ?? this.preferredHumidity,
      autoClimate: autoClimate ?? this.autoClimate,
      automaticLights: automaticLights ?? this.automaticLights,
      voiceReports: voiceReports ?? this.voiceReports,
      roomMode: roomMode ?? this.roomMode);
  }
  
  UserPreference copyWithModelFieldValues({
    ModelFieldValue<double?>? preferredTemperature,
    ModelFieldValue<double?>? preferredHumidity,
    ModelFieldValue<bool?>? autoClimate,
    ModelFieldValue<bool?>? automaticLights,
    ModelFieldValue<bool?>? voiceReports,
    ModelFieldValue<UserPreferenceRoomMode?>? roomMode
  }) {
    return UserPreference._internal(
      roomId: roomId,
      preferredTemperature: preferredTemperature == null ? this.preferredTemperature : preferredTemperature.value,
      preferredHumidity: preferredHumidity == null ? this.preferredHumidity : preferredHumidity.value,
      autoClimate: autoClimate == null ? this.autoClimate : autoClimate.value,
      automaticLights: automaticLights == null ? this.automaticLights : automaticLights.value,
      voiceReports: voiceReports == null ? this.voiceReports : voiceReports.value,
      roomMode: roomMode == null ? this.roomMode : roomMode.value
    );
  }
  
  UserPreference.fromJson(Map<String, dynamic> json)  
    : _roomId = json['roomId'],
      _preferredTemperature = (json['preferredTemperature'] as num?)?.toDouble(),
      _preferredHumidity = (json['preferredHumidity'] as num?)?.toDouble(),
      _autoClimate = json['autoClimate'],
      _automaticLights = json['automaticLights'],
      _voiceReports = json['voiceReports'],
      _roomMode = amplify_core.enumFromString<UserPreferenceRoomMode>(json['roomMode'], UserPreferenceRoomMode.values),
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'roomId': _roomId, 'preferredTemperature': _preferredTemperature, 'preferredHumidity': _preferredHumidity, 'autoClimate': _autoClimate, 'automaticLights': _automaticLights, 'voiceReports': _voiceReports, 'roomMode': amplify_core.enumToString(_roomMode), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'roomId': _roomId,
    'preferredTemperature': _preferredTemperature,
    'preferredHumidity': _preferredHumidity,
    'autoClimate': _autoClimate,
    'automaticLights': _automaticLights,
    'voiceReports': _voiceReports,
    'roomMode': _roomMode,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<UserPreferenceModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<UserPreferenceModelIdentifier>();
  static final ROOMID = amplify_core.QueryField(fieldName: "roomId");
  static final PREFERREDTEMPERATURE = amplify_core.QueryField(fieldName: "preferredTemperature");
  static final PREFERREDHUMIDITY = amplify_core.QueryField(fieldName: "preferredHumidity");
  static final AUTOCLIMATE = amplify_core.QueryField(fieldName: "autoClimate");
  static final AUTOMATICLIGHTS = amplify_core.QueryField(fieldName: "automaticLights");
  static final VOICEREPORTS = amplify_core.QueryField(fieldName: "voiceReports");
  static final ROOMMODE = amplify_core.QueryField(fieldName: "roomMode");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "UserPreference";
    modelSchemaDefinition.pluralName = "UserPreferences";
    
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
      amplify_core.ModelIndex(fields: const ["roomId"], name: null)
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: UserPreference.ROOMID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: UserPreference.PREFERREDTEMPERATURE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: UserPreference.PREFERREDHUMIDITY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: UserPreference.AUTOCLIMATE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: UserPreference.AUTOMATICLIGHTS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: UserPreference.VOICEREPORTS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: UserPreference.ROOMMODE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.enumeration)
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

class _UserPreferenceModelType extends amplify_core.ModelType<UserPreference> {
  const _UserPreferenceModelType();
  
  @override
  UserPreference fromJson(Map<String, dynamic> jsonData) {
    return UserPreference.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'UserPreference';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [UserPreference] in your schema.
 */
class UserPreferenceModelIdentifier implements amplify_core.ModelIdentifier<UserPreference> {
  final String roomId;

  /** Create an instance of UserPreferenceModelIdentifier using [roomId] the primary key. */
  const UserPreferenceModelIdentifier({
    required this.roomId});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'roomId': roomId
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'UserPreferenceModelIdentifier(roomId: $roomId)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is UserPreferenceModelIdentifier &&
      roomId == other.roomId;
  }
  
  @override
  int get hashCode =>
    roomId.hashCode;
}