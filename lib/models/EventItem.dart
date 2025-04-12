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


/** This is an auto generated class representing the EventItem type in your schema. */
class EventItem {
  final String? _eventType;
  final int? _timestamp;
  final String? _description;
  final bool? _resolved;

  String? get eventType {
    return _eventType;
  }
  
  int? get timestamp {
    return _timestamp;
  }
  
  String? get description {
    return _description;
  }
  
  bool? get resolved {
    return _resolved;
  }
  
  const EventItem._internal({eventType, timestamp, description, resolved}): _eventType = eventType, _timestamp = timestamp, _description = description, _resolved = resolved;
  
  factory EventItem({String? eventType, int? timestamp, String? description, bool? resolved}) {
    return EventItem._internal(
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
    return other is EventItem &&
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
    
    buffer.write("EventItem {");
    buffer.write("eventType=" + "$_eventType" + ", ");
    buffer.write("timestamp=" + (_timestamp != null ? _timestamp!.toString() : "null") + ", ");
    buffer.write("description=" + "$_description" + ", ");
    buffer.write("resolved=" + (_resolved != null ? _resolved!.toString() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  EventItem copyWith({String? eventType, int? timestamp, String? description, bool? resolved}) {
    return EventItem._internal(
      eventType: eventType ?? this.eventType,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
      resolved: resolved ?? this.resolved);
  }
  
  EventItem copyWithModelFieldValues({
    ModelFieldValue<String?>? eventType,
    ModelFieldValue<int?>? timestamp,
    ModelFieldValue<String?>? description,
    ModelFieldValue<bool?>? resolved
  }) {
    return EventItem._internal(
      eventType: eventType == null ? this.eventType : eventType.value,
      timestamp: timestamp == null ? this.timestamp : timestamp.value,
      description: description == null ? this.description : description.value,
      resolved: resolved == null ? this.resolved : resolved.value
    );
  }
  
  EventItem.fromJson(Map<String, dynamic> json)  
    : _eventType = json['eventType'],
      _timestamp = (json['timestamp'] as num?)?.toInt(),
      _description = json['description'],
      _resolved = json['resolved'];
  
  Map<String, dynamic> toJson() => {
    'eventType': _eventType, 'timestamp': _timestamp, 'description': _description, 'resolved': _resolved
  };
  
  Map<String, Object?> toMap() => {
    'eventType': _eventType,
    'timestamp': _timestamp,
    'description': _description,
    'resolved': _resolved
  };

  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "EventItem";
    modelSchemaDefinition.pluralName = "EventItems";
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'eventType',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'timestamp',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'description',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'resolved',
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
  });
}