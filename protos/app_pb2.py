# -*- coding: utf-8 -*-
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: app.proto

import sys
_b=sys.version_info[0]<3 and (lambda x:x) or (lambda x:x.encode('latin1'))
from google.protobuf.internal import enum_type_wrapper
from google.protobuf import descriptor as _descriptor
from google.protobuf import message as _message
from google.protobuf import reflection as _reflection
from google.protobuf import symbol_database as _symbol_database
# @@protoc_insertion_point(imports)

_sym_db = _symbol_database.Default()


import annotations_pb2 as annotations__pb2
import result_pb2 as result__pb2
import protogen_pb2 as protogen__pb2
import developer_pb2 as developer__pb2
import flavor_pb2 as flavor__pb2
import gogo_pb2 as gogo__pb2


DESCRIPTOR = _descriptor.FileDescriptor(
  name='app.proto',
  package='edgeproto',
  syntax='proto3',
  serialized_options=None,
  serialized_pb=_b('\n\tapp.proto\x12\tedgeproto\x1a\x11\x61nnotations.proto\x1a\x0cresult.proto\x1a\x0eprotogen.proto\x1a\x0f\x64\x65veloper.proto\x1a\x0c\x66lavor.proto\x1a\ngogo.proto\"k\n\x06\x41ppKey\x12\x34\n\rdeveloper_key\x18\x01 \x01(\x0b\x32\x17.edgeproto.DeveloperKeyB\x04\xc8\xde\x1f\x00\x12\x0c\n\x04name\x18\x02 \x01(\t\x12\x0f\n\x07version\x18\x03 \x01(\t:\x0c\xe8\xf3\x18\x01\xf8\xf3\x18\x01\xb0\xa0\x1f\x01\"*\n\nConfigFile\x12\x0c\n\x04kind\x18\x01 \x01(\t\x12\x0e\n\x06\x63onfig\x18\x02 \x01(\t\"\xfb\x06\n\x03\x41pp\x12\x0e\n\x06\x66ields\x18\x01 \x03(\t\x12$\n\x03key\x18\x02 \x01(\x0b\x32\x11.edgeproto.AppKeyB\x04\xc8\xde\x1f\x00\x12\x18\n\nimage_path\x18\x04 \x01(\tB\x04\xa8\xf4\x18\x01\x12(\n\nimage_type\x18\x05 \x01(\x0e\x32\x14.edgeproto.ImageType\x12\x14\n\x0c\x61\x63\x63\x65ss_ports\x18\x07 \x01(\t\x12\x32\n\x0e\x64\x65\x66\x61ult_flavor\x18\t \x01(\x0b\x32\x14.edgeproto.FlavorKeyB\x04\xc8\xde\x1f\x00\x12\x17\n\x0f\x61uth_public_key\x18\x0c \x01(\t\x12\x0f\n\x07\x63ommand\x18\r \x01(\t\x12\x13\n\x0b\x61nnotations\x18\x0e \x01(\t\x12\x18\n\ndeployment\x18\x0f \x01(\tB\x04\xa8\xf4\x18\x01\x12*\n\x13\x64\x65ployment_manifest\x18\x10 \x01(\tB\r\xa8\xf4\x18\x01\x92\xb2\x19\x05nocmp\x12+\n\x14\x64\x65ployment_generator\x18\x11 \x01(\tB\r\xa8\xf4\x18\x01\x92\xb2\x19\x05nocmp\x12\x1c\n\x14\x61ndroid_package_name\x18\x12 \x01(\t\x12\x31\n\x07\x64\x65l_opt\x18\x14 \x01(\x0e\x32\x15.edgeproto.DeleteTypeB\t\x92\xb2\x19\x05nocmp\x12&\n\x07\x63onfigs\x18\x15 \x03(\x0b\x32\x15.edgeproto.ConfigFile\x12\x1a\n\x12scale_with_cluster\x18\x16 \x01(\x08\x12\x16\n\x0einternal_ports\x18\x17 \x01(\x08\x12\x10\n\x08revision\x18\x18 \x01(\x05\x12\x15\n\rofficial_fqdn\x18\x19 \x01(\t\x12\x0e\n\x06md5sum\x18\x1a \x01(\t\x12\"\n\x1a\x64\x65\x66\x61ult_shared_volume_size\x18\x1b \x01(\x04\x12\x18\n\x10\x61uto_prov_policy\x18\x1c \x01(\t\x12*\n\x0b\x61\x63\x63\x65ss_type\x18\x1d \x01(\x0e\x32\x15.edgeproto.AccessType\x12\x1e\n\x16\x64\x65\x66\x61ult_privacy_policy\x18\x1e \x01(\t:\x8d\x01\xe8\xf3\x18\x01\xf0\xf3\x18\x01\x98\xf4\x18\x01\x80\xf4\x18\x01\x90\xf4\x18\x01\xc8\xf4\x18\x01\x9a\xf5\x18\x65\x61ppname=Key.Name,appvers=Key.Version,developer=Key.DeveloperKey.Name,defaultflavor=DefaultFlavor.Name\x92\xf5\x18\x08Revision*d\n\tImageType\x12\x16\n\x12IMAGE_TYPE_UNKNOWN\x10\x00\x12\x15\n\x11IMAGE_TYPE_DOCKER\x10\x01\x12\x13\n\x0fIMAGE_TYPE_QCOW\x10\x02\x12\x13\n\x0fIMAGE_TYPE_HELM\x10\x03*1\n\nDeleteType\x12\x12\n\x0eNO_AUTO_DELETE\x10\x00\x12\x0f\n\x0b\x41UTO_DELETE\x10\x01*k\n\nAccessType\x12&\n\"ACCESS_TYPE_DEFAULT_FOR_DEPLOYMENT\x10\x00\x12\x16\n\x12\x41\x43\x43\x45SS_TYPE_DIRECT\x10\x01\x12\x1d\n\x19\x41\x43\x43\x45SS_TYPE_LOAD_BALANCER\x10\x02\x32\xf5\x03\n\x06\x41ppApi\x12}\n\tCreateApp\x12\x0e.edgeproto.App\x1a\x11.edgeproto.Result\"M\x82\xd3\xe4\x93\x02\x10\"\x0b/create/app:\x01*\xea\xf4\x18/ResourceApps,ActionManage,Key.DeveloperKey.Name\xd0\xf5\x18\x01\x12y\n\tDeleteApp\x12\x0e.edgeproto.App\x1a\x11.edgeproto.Result\"I\x82\xd3\xe4\x93\x02\x10\"\x0b/delete/app:\x01*\xea\xf4\x18/ResourceApps,ActionManage,Key.DeveloperKey.Name\x12}\n\tUpdateApp\x12\x0e.edgeproto.App\x1a\x11.edgeproto.Result\"M\x82\xd3\xe4\x93\x02\x10\"\x0b/update/app:\x01*\xea\xf4\x18/ResourceApps,ActionManage,Key.DeveloperKey.Name\xd0\xf5\x18\x01\x12r\n\x07ShowApp\x12\x0e.edgeproto.App\x1a\x0e.edgeproto.App\"E\x82\xd3\xe4\x93\x02\x0e\"\t/show/app:\x01*\xea\xf4\x18-ResourceApps,ActionView,Key.DeveloperKey.Name0\x01\x62\x06proto3')
  ,
  dependencies=[annotations__pb2.DESCRIPTOR,result__pb2.DESCRIPTOR,protogen__pb2.DESCRIPTOR,developer__pb2.DESCRIPTOR,flavor__pb2.DESCRIPTOR,gogo__pb2.DESCRIPTOR,])

_IMAGETYPE = _descriptor.EnumDescriptor(
  name='ImageType',
  full_name='edgeproto.ImageType',
  filename=None,
  file=DESCRIPTOR,
  values=[
    _descriptor.EnumValueDescriptor(
      name='IMAGE_TYPE_UNKNOWN', index=0, number=0,
      serialized_options=None,
      type=None),
    _descriptor.EnumValueDescriptor(
      name='IMAGE_TYPE_DOCKER', index=1, number=1,
      serialized_options=None,
      type=None),
    _descriptor.EnumValueDescriptor(
      name='IMAGE_TYPE_QCOW', index=2, number=2,
      serialized_options=None,
      type=None),
    _descriptor.EnumValueDescriptor(
      name='IMAGE_TYPE_HELM', index=3, number=3,
      serialized_options=None,
      type=None),
  ],
  containing_type=None,
  serialized_options=None,
  serialized_start=1163,
  serialized_end=1263,
)
_sym_db.RegisterEnumDescriptor(_IMAGETYPE)

ImageType = enum_type_wrapper.EnumTypeWrapper(_IMAGETYPE)
_DELETETYPE = _descriptor.EnumDescriptor(
  name='DeleteType',
  full_name='edgeproto.DeleteType',
  filename=None,
  file=DESCRIPTOR,
  values=[
    _descriptor.EnumValueDescriptor(
      name='NO_AUTO_DELETE', index=0, number=0,
      serialized_options=None,
      type=None),
    _descriptor.EnumValueDescriptor(
      name='AUTO_DELETE', index=1, number=1,
      serialized_options=None,
      type=None),
  ],
  containing_type=None,
  serialized_options=None,
  serialized_start=1265,
  serialized_end=1314,
)
_sym_db.RegisterEnumDescriptor(_DELETETYPE)

DeleteType = enum_type_wrapper.EnumTypeWrapper(_DELETETYPE)
_ACCESSTYPE = _descriptor.EnumDescriptor(
  name='AccessType',
  full_name='edgeproto.AccessType',
  filename=None,
  file=DESCRIPTOR,
  values=[
    _descriptor.EnumValueDescriptor(
      name='ACCESS_TYPE_DEFAULT_FOR_DEPLOYMENT', index=0, number=0,
      serialized_options=None,
      type=None),
    _descriptor.EnumValueDescriptor(
      name='ACCESS_TYPE_DIRECT', index=1, number=1,
      serialized_options=None,
      type=None),
    _descriptor.EnumValueDescriptor(
      name='ACCESS_TYPE_LOAD_BALANCER', index=2, number=2,
      serialized_options=None,
      type=None),
  ],
  containing_type=None,
  serialized_options=None,
  serialized_start=1316,
  serialized_end=1423,
)
_sym_db.RegisterEnumDescriptor(_ACCESSTYPE)

AccessType = enum_type_wrapper.EnumTypeWrapper(_ACCESSTYPE)
IMAGE_TYPE_UNKNOWN = 0
IMAGE_TYPE_DOCKER = 1
IMAGE_TYPE_QCOW = 2
IMAGE_TYPE_HELM = 3
NO_AUTO_DELETE = 0
AUTO_DELETE = 1
ACCESS_TYPE_DEFAULT_FOR_DEPLOYMENT = 0
ACCESS_TYPE_DIRECT = 1
ACCESS_TYPE_LOAD_BALANCER = 2



_APPKEY = _descriptor.Descriptor(
  name='AppKey',
  full_name='edgeproto.AppKey',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='developer_key', full_name='edgeproto.AppKey.developer_key', index=0,
      number=1, type=11, cpp_type=10, label=1,
      has_default_value=False, default_value=None,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\310\336\037\000'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='name', full_name='edgeproto.AppKey.name', index=1,
      number=2, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='version', full_name='edgeproto.AppKey.version', index=2,
      number=3, type=9, cpp_type=9, label=1,
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
  serialized_options=_b('\350\363\030\001\370\363\030\001\260\240\037\001'),
  is_extendable=False,
  syntax='proto3',
  extension_ranges=[],
  oneofs=[
  ],
  serialized_start=116,
  serialized_end=223,
)


_CONFIGFILE = _descriptor.Descriptor(
  name='ConfigFile',
  full_name='edgeproto.ConfigFile',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='kind', full_name='edgeproto.ConfigFile.kind', index=0,
      number=1, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='config', full_name='edgeproto.ConfigFile.config', index=1,
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
  serialized_start=225,
  serialized_end=267,
)


_APP = _descriptor.Descriptor(
  name='App',
  full_name='edgeproto.App',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='fields', full_name='edgeproto.App.fields', index=0,
      number=1, type=9, cpp_type=9, label=3,
      has_default_value=False, default_value=[],
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='key', full_name='edgeproto.App.key', index=1,
      number=2, type=11, cpp_type=10, label=1,
      has_default_value=False, default_value=None,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\310\336\037\000'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='image_path', full_name='edgeproto.App.image_path', index=2,
      number=4, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\250\364\030\001'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='image_type', full_name='edgeproto.App.image_type', index=3,
      number=5, type=14, cpp_type=8, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='access_ports', full_name='edgeproto.App.access_ports', index=4,
      number=7, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='default_flavor', full_name='edgeproto.App.default_flavor', index=5,
      number=9, type=11, cpp_type=10, label=1,
      has_default_value=False, default_value=None,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\310\336\037\000'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='auth_public_key', full_name='edgeproto.App.auth_public_key', index=6,
      number=12, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='command', full_name='edgeproto.App.command', index=7,
      number=13, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='annotations', full_name='edgeproto.App.annotations', index=8,
      number=14, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='deployment', full_name='edgeproto.App.deployment', index=9,
      number=15, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\250\364\030\001'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='deployment_manifest', full_name='edgeproto.App.deployment_manifest', index=10,
      number=16, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\250\364\030\001\222\262\031\005nocmp'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='deployment_generator', full_name='edgeproto.App.deployment_generator', index=11,
      number=17, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\250\364\030\001\222\262\031\005nocmp'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='android_package_name', full_name='edgeproto.App.android_package_name', index=12,
      number=18, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='del_opt', full_name='edgeproto.App.del_opt', index=13,
      number=20, type=14, cpp_type=8, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\222\262\031\005nocmp'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='configs', full_name='edgeproto.App.configs', index=14,
      number=21, type=11, cpp_type=10, label=3,
      has_default_value=False, default_value=[],
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='scale_with_cluster', full_name='edgeproto.App.scale_with_cluster', index=15,
      number=22, type=8, cpp_type=7, label=1,
      has_default_value=False, default_value=False,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='internal_ports', full_name='edgeproto.App.internal_ports', index=16,
      number=23, type=8, cpp_type=7, label=1,
      has_default_value=False, default_value=False,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='revision', full_name='edgeproto.App.revision', index=17,
      number=24, type=5, cpp_type=1, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='official_fqdn', full_name='edgeproto.App.official_fqdn', index=18,
      number=25, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='md5sum', full_name='edgeproto.App.md5sum', index=19,
      number=26, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='default_shared_volume_size', full_name='edgeproto.App.default_shared_volume_size', index=20,
      number=27, type=4, cpp_type=4, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='auto_prov_policy', full_name='edgeproto.App.auto_prov_policy', index=21,
      number=28, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='access_type', full_name='edgeproto.App.access_type', index=22,
      number=29, type=14, cpp_type=8, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='default_privacy_policy', full_name='edgeproto.App.default_privacy_policy', index=23,
      number=30, type=9, cpp_type=9, label=1,
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
  serialized_options=_b('\350\363\030\001\360\363\030\001\230\364\030\001\200\364\030\001\220\364\030\001\310\364\030\001\232\365\030eappname=Key.Name,appvers=Key.Version,developer=Key.DeveloperKey.Name,defaultflavor=DefaultFlavor.Name\222\365\030\010Revision'),
  is_extendable=False,
  syntax='proto3',
  extension_ranges=[],
  oneofs=[
  ],
  serialized_start=270,
  serialized_end=1161,
)

_APPKEY.fields_by_name['developer_key'].message_type = developer__pb2._DEVELOPERKEY
_APP.fields_by_name['key'].message_type = _APPKEY
_APP.fields_by_name['image_type'].enum_type = _IMAGETYPE
_APP.fields_by_name['default_flavor'].message_type = flavor__pb2._FLAVORKEY
_APP.fields_by_name['del_opt'].enum_type = _DELETETYPE
_APP.fields_by_name['configs'].message_type = _CONFIGFILE
_APP.fields_by_name['access_type'].enum_type = _ACCESSTYPE
DESCRIPTOR.message_types_by_name['AppKey'] = _APPKEY
DESCRIPTOR.message_types_by_name['ConfigFile'] = _CONFIGFILE
DESCRIPTOR.message_types_by_name['App'] = _APP
DESCRIPTOR.enum_types_by_name['ImageType'] = _IMAGETYPE
DESCRIPTOR.enum_types_by_name['DeleteType'] = _DELETETYPE
DESCRIPTOR.enum_types_by_name['AccessType'] = _ACCESSTYPE
_sym_db.RegisterFileDescriptor(DESCRIPTOR)

AppKey = _reflection.GeneratedProtocolMessageType('AppKey', (_message.Message,), {
  'DESCRIPTOR' : _APPKEY,
  '__module__' : 'app_pb2'
  # @@protoc_insertion_point(class_scope:edgeproto.AppKey)
  })
_sym_db.RegisterMessage(AppKey)

ConfigFile = _reflection.GeneratedProtocolMessageType('ConfigFile', (_message.Message,), {
  'DESCRIPTOR' : _CONFIGFILE,
  '__module__' : 'app_pb2'
  # @@protoc_insertion_point(class_scope:edgeproto.ConfigFile)
  })
_sym_db.RegisterMessage(ConfigFile)

App = _reflection.GeneratedProtocolMessageType('App', (_message.Message,), {
  'DESCRIPTOR' : _APP,
  '__module__' : 'app_pb2'
  # @@protoc_insertion_point(class_scope:edgeproto.App)
  })
_sym_db.RegisterMessage(App)


_APPKEY.fields_by_name['developer_key']._options = None
_APPKEY._options = None
_APP.fields_by_name['key']._options = None
_APP.fields_by_name['image_path']._options = None
_APP.fields_by_name['default_flavor']._options = None
_APP.fields_by_name['deployment']._options = None
_APP.fields_by_name['deployment_manifest']._options = None
_APP.fields_by_name['deployment_generator']._options = None
_APP.fields_by_name['del_opt']._options = None
_APP._options = None

_APPAPI = _descriptor.ServiceDescriptor(
  name='AppApi',
  full_name='edgeproto.AppApi',
  file=DESCRIPTOR,
  index=0,
  serialized_options=None,
  serialized_start=1426,
  serialized_end=1927,
  methods=[
  _descriptor.MethodDescriptor(
    name='CreateApp',
    full_name='edgeproto.AppApi.CreateApp',
    index=0,
    containing_service=None,
    input_type=_APP,
    output_type=result__pb2._RESULT,
    serialized_options=_b('\202\323\344\223\002\020\"\013/create/app:\001*\352\364\030/ResourceApps,ActionManage,Key.DeveloperKey.Name\320\365\030\001'),
  ),
  _descriptor.MethodDescriptor(
    name='DeleteApp',
    full_name='edgeproto.AppApi.DeleteApp',
    index=1,
    containing_service=None,
    input_type=_APP,
    output_type=result__pb2._RESULT,
    serialized_options=_b('\202\323\344\223\002\020\"\013/delete/app:\001*\352\364\030/ResourceApps,ActionManage,Key.DeveloperKey.Name'),
  ),
  _descriptor.MethodDescriptor(
    name='UpdateApp',
    full_name='edgeproto.AppApi.UpdateApp',
    index=2,
    containing_service=None,
    input_type=_APP,
    output_type=result__pb2._RESULT,
    serialized_options=_b('\202\323\344\223\002\020\"\013/update/app:\001*\352\364\030/ResourceApps,ActionManage,Key.DeveloperKey.Name\320\365\030\001'),
  ),
  _descriptor.MethodDescriptor(
    name='ShowApp',
    full_name='edgeproto.AppApi.ShowApp',
    index=3,
    containing_service=None,
    input_type=_APP,
    output_type=_APP,
    serialized_options=_b('\202\323\344\223\002\016\"\t/show/app:\001*\352\364\030-ResourceApps,ActionView,Key.DeveloperKey.Name'),
  ),
])
_sym_db.RegisterServiceDescriptor(_APPAPI)

DESCRIPTOR.services_by_name['AppApi'] = _APPAPI

# @@protoc_insertion_point(module_scope)
