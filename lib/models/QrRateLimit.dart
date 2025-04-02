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


/** This is an auto generated class representing the QrRateLimit type in your schema. */
class QrRateLimit extends amplify_core.Model {
  static const classType = const _QrRateLimitModelType();
  final String id;
  final String? _sourceIp;
  final int? _timestamp;
  final int? _ttl;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  QrRateLimitModelIdentifier get modelIdentifier {
      return QrRateLimitModelIdentifier(
        id: id
      );
  }
  
  String get sourceIp {
    try {
      return _sourceIp!;
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
  
  int? get ttl {
    return _ttl;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const QrRateLimit._internal({required this.id, required sourceIp, required timestamp, ttl, createdAt, updatedAt}): _sourceIp = sourceIp, _timestamp = timestamp, _ttl = ttl, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory QrRateLimit({String? id, required String sourceIp, required int timestamp, int? ttl}) {
    return QrRateLimit._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      sourceIp: sourceIp,
      timestamp: timestamp,
      ttl: ttl);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is QrRateLimit &&
      id == other.id &&
      _sourceIp == other._sourceIp &&
      _timestamp == other._timestamp &&
      _ttl == other._ttl;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("QrRateLimit {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("sourceIp=" + "$_sourceIp" + ", ");
    buffer.write("timestamp=" + (_timestamp != null ? _timestamp!.toString() : "null") + ", ");
    buffer.write("ttl=" + (_ttl != null ? _ttl!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  QrRateLimit copyWith({String? sourceIp, int? timestamp, int? ttl}) {
    return QrRateLimit._internal(
      id: id,
      sourceIp: sourceIp ?? this.sourceIp,
      timestamp: timestamp ?? this.timestamp,
      ttl: ttl ?? this.ttl);
  }
  
  QrRateLimit copyWithModelFieldValues({
    ModelFieldValue<String>? sourceIp,
    ModelFieldValue<int>? timestamp,
    ModelFieldValue<int?>? ttl
  }) {
    return QrRateLimit._internal(
      id: id,
      sourceIp: sourceIp == null ? this.sourceIp : sourceIp.value,
      timestamp: timestamp == null ? this.timestamp : timestamp.value,
      ttl: ttl == null ? this.ttl : ttl.value
    );
  }
  
  QrRateLimit.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _sourceIp = json['sourceIp'],
      _timestamp = (json['timestamp'] as num?)?.toInt(),
      _ttl = (json['ttl'] as num?)?.toInt(),
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'sourceIp': _sourceIp, 'timestamp': _timestamp, 'ttl': _ttl, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'sourceIp': _sourceIp,
    'timestamp': _timestamp,
    'ttl': _ttl,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<QrRateLimitModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<QrRateLimitModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final SOURCEIP = amplify_core.QueryField(fieldName: "sourceIp");
  static final TIMESTAMP = amplify_core.QueryField(fieldName: "timestamp");
  static final TTL = amplify_core.QueryField(fieldName: "ttl");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "QrRateLimit";
    modelSchemaDefinition.pluralName = "QrRateLimits";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PUBLIC,
        provider: amplify_core.AuthRuleProvider.APIKEY,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["sourceIp", "timestamp"], name: "qrRateLimitsBySourceIpAndTimestamp")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: QrRateLimit.SOURCEIP,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: QrRateLimit.TIMESTAMP,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: QrRateLimit.TTL,
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

class _QrRateLimitModelType extends amplify_core.ModelType<QrRateLimit> {
  const _QrRateLimitModelType();
  
  @override
  QrRateLimit fromJson(Map<String, dynamic> jsonData) {
    return QrRateLimit.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'QrRateLimit';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [QrRateLimit] in your schema.
 */
class QrRateLimitModelIdentifier implements amplify_core.ModelIdentifier<QrRateLimit> {
  final String id;

  /** Create an instance of QrRateLimitModelIdentifier using [id] the primary key. */
  const QrRateLimitModelIdentifier({
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
  String toString() => 'QrRateLimitModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is QrRateLimitModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}