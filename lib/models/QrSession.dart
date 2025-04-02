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


/** This is an auto generated class representing the QrSession type in your schema. */
class QrSession extends amplify_core.Model {
  static const classType = const _QrSessionModelType();
  final String? _sessionId;
  final String? _roomId;
  final int? _usedAt;
  final int? _expiry;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => modelIdentifier.serializeAsString();
  
  QrSessionModelIdentifier get modelIdentifier {
    try {
      return QrSessionModelIdentifier(
        sessionId: _sessionId!
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
  
  String get sessionId {
    try {
      return _sessionId!;
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
  
  int get usedAt {
    try {
      return _usedAt!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get expiry {
    try {
      return _expiry!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }

  const QrSession._internal({required sessionId, required roomId, required usedAt, required expiry}): _sessionId = sessionId, _roomId = roomId, _usedAt = usedAt, _expiry = expiry;
  
  factory QrSession({required String sessionId, required String roomId, required int usedAt, required int expiry}) {
    return QrSession._internal(
      sessionId: sessionId,
      roomId: roomId,
      usedAt: usedAt,
      expiry: expiry);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is QrSession &&
      _sessionId == other._sessionId &&
      _roomId == other._roomId &&
      _usedAt == other._usedAt &&
      _expiry == other._expiry;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("QrSession {");
    buffer.write("sessionId=" + "$_sessionId" + ", ");
    buffer.write("roomId=" + "$_roomId" + ", ");
    buffer.write("usedAt=" + (_usedAt != null ? _usedAt!.toString() : "null") + ", ");
    buffer.write("expiry=" + (_expiry != null ? _expiry!.toString() : "null") + ", ");
    buffer.write("}");
    
    return buffer.toString();
  }
  
  QrSession copyWith({String? roomId, int? usedAt, int? expiry}) {
    return QrSession._internal(
      sessionId: sessionId,
      roomId: roomId ?? this.roomId,
      usedAt: usedAt ?? this.usedAt,
      expiry: expiry ?? this.expiry);
  }
  
  QrSession copyWithModelFieldValues({
    ModelFieldValue<String>? roomId,
    ModelFieldValue<int>? usedAt,
    ModelFieldValue<int>? expiry
  }) {
    return QrSession._internal(
      sessionId: sessionId,
      roomId: roomId == null ? this.roomId : roomId.value,
      usedAt: usedAt == null ? this.usedAt : usedAt.value,
      expiry: expiry == null ? this.expiry : expiry.value
    );
  }
  
  QrSession.fromJson(Map<String, dynamic> json)  
    : _sessionId = json['sessionId'],
      _roomId = json['roomId'],
      _usedAt = (json['usedAt'] as num?)?.toInt(),
      _expiry = (json['expiry'] as num?)?.toInt();
  
  Map<String, dynamic> toJson() => {
    'sessionId': _sessionId, 'roomId': _roomId, 'usedAt': _usedAt, 'expiry': _expiry
  };
  
  Map<String, Object?> toMap() => {
    'sessionId': _sessionId,
    'roomId': _roomId,
    'usedAt': _usedAt,
    'expiry': _expiry,
  };

  static final amplify_core.QueryModelIdentifier<QrSessionModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<QrSessionModelIdentifier>();
  static final SESSIONID = amplify_core.QueryField(fieldName: "sessionId");
  static final ROOMID = amplify_core.QueryField(fieldName: "roomId");
  static final USEDAT = amplify_core.QueryField(fieldName: "usedAt");
  static final EXPIRY = amplify_core.QueryField(fieldName: "expiry");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "QrSession";
    modelSchemaDefinition.pluralName = "QrSessions";
    
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
      amplify_core.ModelIndex(fields: const ["sessionId"], name: null)
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: QrSession.SESSIONID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: QrSession.ROOMID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: QrSession.USEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: QrSession.EXPIRY,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));

  });
}

class _QrSessionModelType extends amplify_core.ModelType<QrSession> {
  const _QrSessionModelType();
  
  @override
  QrSession fromJson(Map<String, dynamic> jsonData) {
    return QrSession.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'QrSession';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [QrSession] in your schema.
 */
class QrSessionModelIdentifier implements amplify_core.ModelIdentifier<QrSession> {
  final String sessionId;

  /** Create an instance of QrSessionModelIdentifier using [sessionId] the primary key. */
  const QrSessionModelIdentifier({
    required this.sessionId});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'sessionId': sessionId
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'QrSessionModelIdentifier(sessionId: $sessionId)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is QrSessionModelIdentifier &&
      sessionId == other.sessionId;
  }
  
  @override
  int get hashCode =>
    sessionId.hashCode;
}