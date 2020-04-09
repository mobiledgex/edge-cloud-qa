# -*- coding: utf-8 -*-
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: http.proto

import sys
_b=sys.version_info[0]<3 and (lambda x:x) or (lambda x:x.encode('latin1'))
from google.protobuf import descriptor as _descriptor
from google.protobuf import message as _message
from google.protobuf import reflection as _reflection
from google.protobuf import symbol_database as _symbol_database
# @@protoc_insertion_point(imports)

_sym_db = _symbol_database.Default()




DESCRIPTOR = _descriptor.FileDescriptor(
  name='http.proto',
  package='google.api',
  syntax='proto3',
  serialized_options=_b('\n\016com.google.apiB\tHttpProtoP\001ZAgoogle.golang.org/genproto/googleapis/api/annotations;annotations\370\001\001\242\002\004GAPI'),
  serialized_pb=_b('\n\nhttp.proto\x12\ngoogle.api\"T\n\x04Http\x12#\n\x05rules\x18\x01 \x03(\x0b\x32\x14.google.api.HttpRule\x12\'\n\x1f\x66ully_decode_reserved_expansion\x18\x02 \x01(\x08\"\x81\x02\n\x08HttpRule\x12\x10\n\x08selector\x18\x01 \x01(\t\x12\r\n\x03get\x18\x02 \x01(\tH\x00\x12\r\n\x03put\x18\x03 \x01(\tH\x00\x12\x0e\n\x04post\x18\x04 \x01(\tH\x00\x12\x10\n\x06\x64\x65lete\x18\x05 \x01(\tH\x00\x12\x0f\n\x05patch\x18\x06 \x01(\tH\x00\x12/\n\x06\x63ustom\x18\x08 \x01(\x0b\x32\x1d.google.api.CustomHttpPatternH\x00\x12\x0c\n\x04\x62ody\x18\x07 \x01(\t\x12\x15\n\rresponse_body\x18\x0c \x01(\t\x12\x31\n\x13\x61\x64\x64itional_bindings\x18\x0b \x03(\x0b\x32\x14.google.api.HttpRuleB\t\n\x07pattern\"/\n\x11\x43ustomHttpPattern\x12\x0c\n\x04kind\x18\x01 \x01(\t\x12\x0c\n\x04path\x18\x02 \x01(\tBj\n\x0e\x63om.google.apiB\tHttpProtoP\x01ZAgoogle.golang.org/genproto/googleapis/api/annotations;annotations\xf8\x01\x01\xa2\x02\x04GAPIb\x06proto3')
)




_HTTP = _descriptor.Descriptor(
  name='Http',
  full_name='google.api.Http',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='rules', full_name='google.api.Http.rules', index=0,
      number=1, type=11, cpp_type=10, label=3,
      has_default_value=False, default_value=[],
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='fully_decode_reserved_expansion', full_name='google.api.Http.fully_decode_reserved_expansion', index=1,
      number=2, type=8, cpp_type=7, label=1,
      has_default_value=False, default_value=False,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
  ],
  extensions=[
  ],
  nested_types=[],
  enum_types=[
  ],
  serialized_options=None,
  is_extendable=False,
  syntax='proto3',
  extension_ranges=[],
  oneofs=[
  ],
  serialized_start=26,
  serialized_end=110,
)


_HTTPRULE = _descriptor.Descriptor(
  name='HttpRule',
  full_name='google.api.HttpRule',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='selector', full_name='google.api.HttpRule.selector', index=0,
      number=1, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='get', full_name='google.api.HttpRule.get', index=1,
      number=2, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='put', full_name='google.api.HttpRule.put', index=2,
      number=3, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='post', full_name='google.api.HttpRule.post', index=3,
      number=4, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='delete', full_name='google.api.HttpRule.delete', index=4,
      number=5, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='patch', full_name='google.api.HttpRule.patch', index=5,
      number=6, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='custom', full_name='google.api.HttpRule.custom', index=6,
      number=8, type=11, cpp_type=10, label=1,
      has_default_value=False, default_value=None,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='body', full_name='google.api.HttpRule.body', index=7,
      number=7, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='response_body', full_name='google.api.HttpRule.response_body', index=8,
      number=12, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='additional_bindings', full_name='google.api.HttpRule.additional_bindings', index=9,
      number=11, type=11, cpp_type=10, label=3,
      has_default_value=False, default_value=[],
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
  ],
  extensions=[
  ],
  nested_types=[],
  enum_types=[
  ],
  serialized_options=None,
  is_extendable=False,
  syntax='proto3',
  extension_ranges=[],
  oneofs=[
    _descriptor.OneofDescriptor(
      name='pattern', full_name='google.api.HttpRule.pattern',
      index=0, containing_type=None, fields=[]),
  ],
  serialized_start=113,
  serialized_end=370,
)


_CUSTOMHTTPPATTERN = _descriptor.Descriptor(
  name='CustomHttpPattern',
  full_name='google.api.CustomHttpPattern',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='kind', full_name='google.api.CustomHttpPattern.kind', index=0,
      number=1, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='path', full_name='google.api.CustomHttpPattern.path', index=1,
      number=2, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
  ],
  extensions=[
  ],
  nested_types=[],
  enum_types=[
  ],
  serialized_options=None,
  is_extendable=False,
  syntax='proto3',
  extension_ranges=[],
  oneofs=[
  ],
  serialized_start=372,
  serialized_end=419,
)

_HTTP.fields_by_name['rules'].message_type = _HTTPRULE
_HTTPRULE.fields_by_name['custom'].message_type = _CUSTOMHTTPPATTERN
_HTTPRULE.fields_by_name['additional_bindings'].message_type = _HTTPRULE
_HTTPRULE.oneofs_by_name['pattern'].fields.append(
  _HTTPRULE.fields_by_name['get'])
_HTTPRULE.fields_by_name['get'].containing_oneof = _HTTPRULE.oneofs_by_name['pattern']
_HTTPRULE.oneofs_by_name['pattern'].fields.append(
  _HTTPRULE.fields_by_name['put'])
_HTTPRULE.fields_by_name['put'].containing_oneof = _HTTPRULE.oneofs_by_name['pattern']
_HTTPRULE.oneofs_by_name['pattern'].fields.append(
  _HTTPRULE.fields_by_name['post'])
_HTTPRULE.fields_by_name['post'].containing_oneof = _HTTPRULE.oneofs_by_name['pattern']
_HTTPRULE.oneofs_by_name['pattern'].fields.append(
  _HTTPRULE.fields_by_name['delete'])
_HTTPRULE.fields_by_name['delete'].containing_oneof = _HTTPRULE.oneofs_by_name['pattern']
_HTTPRULE.oneofs_by_name['pattern'].fields.append(
  _HTTPRULE.fields_by_name['patch'])
_HTTPRULE.fields_by_name['patch'].containing_oneof = _HTTPRULE.oneofs_by_name['pattern']
_HTTPRULE.oneofs_by_name['pattern'].fields.append(
  _HTTPRULE.fields_by_name['custom'])
_HTTPRULE.fields_by_name['custom'].containing_oneof = _HTTPRULE.oneofs_by_name['pattern']
DESCRIPTOR.message_types_by_name['Http'] = _HTTP
DESCRIPTOR.message_types_by_name['HttpRule'] = _HTTPRULE
DESCRIPTOR.message_types_by_name['CustomHttpPattern'] = _CUSTOMHTTPPATTERN
_sym_db.RegisterFileDescriptor(DESCRIPTOR)

Http = _reflection.GeneratedProtocolMessageType('Http', (_message.Message,), {
  'DESCRIPTOR' : _HTTP,
  '__module__' : 'http_pb2'
  # @@protoc_insertion_point(class_scope:google.api.Http)
  })
_sym_db.RegisterMessage(Http)

HttpRule = _reflection.GeneratedProtocolMessageType('HttpRule', (_message.Message,), {
  'DESCRIPTOR' : _HTTPRULE,
  '__module__' : 'http_pb2'
  # @@protoc_insertion_point(class_scope:google.api.HttpRule)
  })
_sym_db.RegisterMessage(HttpRule)

CustomHttpPattern = _reflection.GeneratedProtocolMessageType('CustomHttpPattern', (_message.Message,), {
  'DESCRIPTOR' : _CUSTOMHTTPPATTERN,
  '__module__' : 'http_pb2'
  # @@protoc_insertion_point(class_scope:google.api.CustomHttpPattern)
  })
_sym_db.RegisterMessage(CustomHttpPattern)


DESCRIPTOR._options = None
# @@protoc_insertion_point(module_scope)
