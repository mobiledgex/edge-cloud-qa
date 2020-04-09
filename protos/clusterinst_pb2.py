# -*- coding: utf-8 -*-
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: clusterinst.proto

import sys
_b=sys.version_info[0]<3 and (lambda x:x) or (lambda x:x.encode('latin1'))
from google.protobuf import descriptor as _descriptor
from google.protobuf import message as _message
from google.protobuf import reflection as _reflection
from google.protobuf import symbol_database as _symbol_database
# @@protoc_insertion_point(imports)

_sym_db = _symbol_database.Default()


import annotations_pb2 as annotations__pb2
import protogen_pb2 as protogen__pb2
import result_pb2 as result__pb2
import flavor_pb2 as flavor__pb2
import cluster_pb2 as cluster__pb2
import cloudlet_pb2 as cloudlet__pb2
import common_pb2 as common__pb2
import gogo_pb2 as gogo__pb2


DESCRIPTOR = _descriptor.FileDescriptor(
  name='clusterinst.proto',
  package='edgeproto',
  syntax='proto3',
  serialized_options=None,
  serialized_pb=_b('\n\x11\x63lusterinst.proto\x12\tedgeproto\x1a\x11\x61nnotations.proto\x1a\x0eprotogen.proto\x1a\x0cresult.proto\x1a\x0c\x66lavor.proto\x1a\rcluster.proto\x1a\x0e\x63loudlet.proto\x1a\x0c\x63ommon.proto\x1a\ngogo.proto\"\x97\x01\n\x0e\x43lusterInstKey\x12\x30\n\x0b\x63luster_key\x18\x01 \x01(\x0b\x32\x15.edgeproto.ClusterKeyB\x04\xc8\xde\x1f\x00\x12\x32\n\x0c\x63loudlet_key\x18\x02 \x01(\x0b\x32\x16.edgeproto.CloudletKeyB\x04\xc8\xde\x1f\x00\x12\x11\n\tdeveloper\x18\x03 \x01(\t:\x0c\xe8\xf3\x18\x01\xf8\xf3\x18\x01\xb0\xa0\x1f\x01\"\xfc\x08\n\x0b\x43lusterInst\x12\x0e\n\x06\x66ields\x18\x01 \x03(\t\x12,\n\x03key\x18\x02 \x01(\x0b\x32\x19.edgeproto.ClusterInstKeyB\x04\xc8\xde\x1f\x00\x12.\n\x06\x66lavor\x18\x03 \x01(\x0b\x32\x14.edgeproto.FlavorKeyB\x08\xc8\xde\x1f\x00\xa8\xf4\x18\x01\x12+\n\x08liveness\x18\t \x01(\x0e\x32\x13.edgeproto.LivenessB\x04\xa8\xf4\x18\x01\x12\x12\n\x04\x61uto\x18\n \x01(\x08\x42\x04\xa8\xf4\x18\x01\x12\x35\n\x05state\x18\x04 \x01(\x0e\x32\x17.edgeproto.TrackedStateB\r\xa8\xf4\x18\x01\x92\xb2\x19\x05nocmp\x12\x1d\n\x06\x65rrors\x18\x05 \x03(\tB\r\xa8\xf4\x18\x01\x92\xb2\x19\x05nocmp\x12\x37\n\x0c\x63rm_override\x18\x06 \x01(\x0e\x32\x16.edgeproto.CRMOverrideB\t\x92\xb2\x19\x05nocmp\x12,\n\tip_access\x18\x07 \x01(\x0e\x32\x13.edgeproto.IpAccessB\x04\xa8\xf4\x18\x01\x12#\n\x0c\x61llocated_ip\x18\x08 \x01(\tB\r\xa8\xf4\x18\x01\x92\xb2\x19\x05nocmp\x12\"\n\x0bnode_flavor\x18\x0b \x01(\tB\r\xa8\xf4\x18\x01\x92\xb2\x19\x05nocmp\x12\x18\n\ndeployment\x18\x0f \x01(\tB\x04\xa8\xf4\x18\x01\x12\x13\n\x0bnum_masters\x18\r \x01(\r\x12\x11\n\tnum_nodes\x18\x0e \x01(\r\x12/\n\x06status\x18\x10 \x01(\x0b\x32\x15.edgeproto.StatusInfoB\x08\xa8\xf4\x18\x01\xc8\xde\x1f\x00\x12+\n\x14\x65xternal_volume_size\x18\x11 \x01(\x04\x42\r\xa8\xf4\x18\x01\x92\xb2\x19\x05nocmp\x12\x19\n\x11\x61uto_scale_policy\x18\x12 \x01(\t\x12\x19\n\x11\x61vailability_zone\x18\x13 \x01(\t\x12!\n\nimage_name\x18\x14 \x01(\tB\r\xa8\xf4\x18\x01\x92\xb2\x19\x05nocmp\x12\x12\n\nreservable\x18\x15 \x01(\x08\x12\x19\n\x0breserved_by\x18\x16 \x01(\tB\x04\xa8\xf4\x18\x01\x12\x1a\n\x12shared_volume_size\x18\x17 \x01(\x04\x12\x16\n\x0eprivacy_policy\x18\x18 \x01(\t\x12)\n\x12master_node_flavor\x18\x19 \x01(\tB\r\xa8\xf4\x18\x01\x92\xb2\x19\x05nocmp:\xb0\x02\xe8\xf3\x18\x01\xf0\xf3\x18\x01\x98\xf4\x18\x01\xb0\xf4\x18\x01\x80\xf4\x18\x01\x90\xf4\x18\x01\xc8\xf4\x18\x01\xd8\xf4\x18\x01\x92\xf5\x18VLiveness,Auto,MasterFlavor,NodeFlavor,ExternalVolumeSize,AllocatedIp,Status,ReservedBy\xba\xf4\x18\x0cTrackedState\x9a\xf5\x18\x8e\x01\x63luster=Key.ClusterKey.Name,cloudlet=Key.CloudletKey.Name,operator=Key.CloudletKey.OperatorKey.Name,developer=Key.Developer,flavor=Flavor.Name\xda\xf5\x18\x0fKey.CloudletKey\"\xf0\x01\n\x0f\x43lusterInstInfo\x12\x0e\n\x06\x66ields\x18\x01 \x03(\t\x12,\n\x03key\x18\x02 \x01(\x0b\x32\x19.edgeproto.ClusterInstKeyB\x04\xc8\xde\x1f\x00\x12\x1c\n\tnotify_id\x18\x03 \x01(\x03\x42\t\x92\xb2\x19\x05nocmp\x12&\n\x05state\x18\x04 \x01(\x0e\x32\x17.edgeproto.TrackedState\x12\x0e\n\x06\x65rrors\x18\x05 \x03(\t\x12/\n\x06status\x18\x06 \x01(\x0b\x32\x15.edgeproto.StatusInfoB\x08\xa8\xf4\x18\x01\xc8\xde\x1f\x00:\x18\xe8\xf3\x18\x01\xf0\xf3\x18\x01\x80\xf4\x18\x01\xa0\xf4\x18\x01\x90\xf4\x18\x01\xe0\xf4\x18\x01\x32\x83\x05\n\x0e\x43lusterInstApi\x12\x9f\x01\n\x11\x43reateClusterInst\x12\x16.edgeproto.ClusterInst\x1a\x11.edgeproto.Result\"]\x82\xd3\xe4\x93\x02\x18\"\x13/create/clusterinst:\x01*\xa8\xf5\x18\x01\xea\xf4\x18/ResourceClusterInsts,ActionManage,Key.Developer\xd0\xf5\x18\x01\x88\xf6\x18\x01\x30\x01\x12\x9b\x01\n\x11\x44\x65leteClusterInst\x12\x16.edgeproto.ClusterInst\x1a\x11.edgeproto.Result\"Y\x82\xd3\xe4\x93\x02\x18\"\x13/delete/clusterinst:\x01*\xa8\xf5\x18\x01\xea\xf4\x18/ResourceClusterInsts,ActionManage,Key.Developer\x88\xf6\x18\x01\x30\x01\x12\x9b\x01\n\x11UpdateClusterInst\x12\x16.edgeproto.ClusterInst\x1a\x11.edgeproto.Result\"Y\x82\xd3\xe4\x93\x02\x18\"\x13/update/clusterinst:\x01*\xa8\xf5\x18\x01\xea\xf4\x18/ResourceClusterInsts,ActionManage,Key.Developer\x88\xf6\x18\x01\x30\x01\x12\x92\x01\n\x0fShowClusterInst\x12\x16.edgeproto.ClusterInst\x1a\x16.edgeproto.ClusterInst\"M\x82\xd3\xe4\x93\x02\x16\"\x11/show/clusterinst:\x01*\xea\xf4\x18-ResourceClusterInsts,ActionView,Key.Developer0\x01\x32\x87\x01\n\x12\x43lusterInstInfoApi\x12q\n\x13ShowClusterInstInfo\x12\x1a.edgeproto.ClusterInstInfo\x1a\x1a.edgeproto.ClusterInstInfo\" \x82\xd3\xe4\x93\x02\x1a\"\x15/show/clusterinstinfo:\x01*0\x01\x62\x06proto3')
  ,
  dependencies=[annotations__pb2.DESCRIPTOR,protogen__pb2.DESCRIPTOR,result__pb2.DESCRIPTOR,flavor__pb2.DESCRIPTOR,cluster__pb2.DESCRIPTOR,cloudlet__pb2.DESCRIPTOR,common__pb2.DESCRIPTOR,gogo__pb2.DESCRIPTOR,])




_CLUSTERINSTKEY = _descriptor.Descriptor(
  name='ClusterInstKey',
  full_name='edgeproto.ClusterInstKey',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='cluster_key', full_name='edgeproto.ClusterInstKey.cluster_key', index=0,
      number=1, type=11, cpp_type=10, label=1,
      has_default_value=False, default_value=None,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\310\336\037\000'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='cloudlet_key', full_name='edgeproto.ClusterInstKey.cloudlet_key', index=1,
      number=2, type=11, cpp_type=10, label=1,
      has_default_value=False, default_value=None,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\310\336\037\000'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='developer', full_name='edgeproto.ClusterInstKey.developer', index=2,
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
  serialized_start=153,
  serialized_end=304,
)


_CLUSTERINST = _descriptor.Descriptor(
  name='ClusterInst',
  full_name='edgeproto.ClusterInst',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='fields', full_name='edgeproto.ClusterInst.fields', index=0,
      number=1, type=9, cpp_type=9, label=3,
      has_default_value=False, default_value=[],
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='key', full_name='edgeproto.ClusterInst.key', index=1,
      number=2, type=11, cpp_type=10, label=1,
      has_default_value=False, default_value=None,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\310\336\037\000'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='flavor', full_name='edgeproto.ClusterInst.flavor', index=2,
      number=3, type=11, cpp_type=10, label=1,
      has_default_value=False, default_value=None,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\310\336\037\000\250\364\030\001'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='liveness', full_name='edgeproto.ClusterInst.liveness', index=3,
      number=9, type=14, cpp_type=8, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\250\364\030\001'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='auto', full_name='edgeproto.ClusterInst.auto', index=4,
      number=10, type=8, cpp_type=7, label=1,
      has_default_value=False, default_value=False,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\250\364\030\001'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='state', full_name='edgeproto.ClusterInst.state', index=5,
      number=4, type=14, cpp_type=8, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\250\364\030\001\222\262\031\005nocmp'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='errors', full_name='edgeproto.ClusterInst.errors', index=6,
      number=5, type=9, cpp_type=9, label=3,
      has_default_value=False, default_value=[],
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\250\364\030\001\222\262\031\005nocmp'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='crm_override', full_name='edgeproto.ClusterInst.crm_override', index=7,
      number=6, type=14, cpp_type=8, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\222\262\031\005nocmp'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='ip_access', full_name='edgeproto.ClusterInst.ip_access', index=8,
      number=7, type=14, cpp_type=8, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\250\364\030\001'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='allocated_ip', full_name='edgeproto.ClusterInst.allocated_ip', index=9,
      number=8, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\250\364\030\001\222\262\031\005nocmp'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='node_flavor', full_name='edgeproto.ClusterInst.node_flavor', index=10,
      number=11, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\250\364\030\001\222\262\031\005nocmp'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='deployment', full_name='edgeproto.ClusterInst.deployment', index=11,
      number=15, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\250\364\030\001'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='num_masters', full_name='edgeproto.ClusterInst.num_masters', index=12,
      number=13, type=13, cpp_type=3, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='num_nodes', full_name='edgeproto.ClusterInst.num_nodes', index=13,
      number=14, type=13, cpp_type=3, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='status', full_name='edgeproto.ClusterInst.status', index=14,
      number=16, type=11, cpp_type=10, label=1,
      has_default_value=False, default_value=None,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\250\364\030\001\310\336\037\000'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='external_volume_size', full_name='edgeproto.ClusterInst.external_volume_size', index=15,
      number=17, type=4, cpp_type=4, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\250\364\030\001\222\262\031\005nocmp'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='auto_scale_policy', full_name='edgeproto.ClusterInst.auto_scale_policy', index=16,
      number=18, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='availability_zone', full_name='edgeproto.ClusterInst.availability_zone', index=17,
      number=19, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='image_name', full_name='edgeproto.ClusterInst.image_name', index=18,
      number=20, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\250\364\030\001\222\262\031\005nocmp'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='reservable', full_name='edgeproto.ClusterInst.reservable', index=19,
      number=21, type=8, cpp_type=7, label=1,
      has_default_value=False, default_value=False,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='reserved_by', full_name='edgeproto.ClusterInst.reserved_by', index=20,
      number=22, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\250\364\030\001'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='shared_volume_size', full_name='edgeproto.ClusterInst.shared_volume_size', index=21,
      number=23, type=4, cpp_type=4, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='privacy_policy', full_name='edgeproto.ClusterInst.privacy_policy', index=22,
      number=24, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='master_node_flavor', full_name='edgeproto.ClusterInst.master_node_flavor', index=23,
      number=25, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\250\364\030\001\222\262\031\005nocmp'), file=DESCRIPTOR),
  ],
  extensions=[
  ],
  nested_types=[],
  enum_types=[
  ],
  serialized_options=_b('\350\363\030\001\360\363\030\001\230\364\030\001\260\364\030\001\200\364\030\001\220\364\030\001\310\364\030\001\330\364\030\001\222\365\030VLiveness,Auto,MasterFlavor,NodeFlavor,ExternalVolumeSize,AllocatedIp,Status,ReservedBy\272\364\030\014TrackedState\232\365\030\216\001cluster=Key.ClusterKey.Name,cloudlet=Key.CloudletKey.Name,operator=Key.CloudletKey.OperatorKey.Name,developer=Key.Developer,flavor=Flavor.Name\332\365\030\017Key.CloudletKey'),
  is_extendable=False,
  syntax='proto3',
  extension_ranges=[],
  oneofs=[
  ],
  serialized_start=307,
  serialized_end=1455,
)


_CLUSTERINSTINFO = _descriptor.Descriptor(
  name='ClusterInstInfo',
  full_name='edgeproto.ClusterInstInfo',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='fields', full_name='edgeproto.ClusterInstInfo.fields', index=0,
      number=1, type=9, cpp_type=9, label=3,
      has_default_value=False, default_value=[],
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='key', full_name='edgeproto.ClusterInstInfo.key', index=1,
      number=2, type=11, cpp_type=10, label=1,
      has_default_value=False, default_value=None,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\310\336\037\000'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='notify_id', full_name='edgeproto.ClusterInstInfo.notify_id', index=2,
      number=3, type=3, cpp_type=2, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\222\262\031\005nocmp'), file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='state', full_name='edgeproto.ClusterInstInfo.state', index=3,
      number=4, type=14, cpp_type=8, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='errors', full_name='edgeproto.ClusterInstInfo.errors', index=4,
      number=5, type=9, cpp_type=9, label=3,
      has_default_value=False, default_value=[],
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='status', full_name='edgeproto.ClusterInstInfo.status', index=5,
      number=6, type=11, cpp_type=10, label=1,
      has_default_value=False, default_value=None,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      serialized_options=_b('\250\364\030\001\310\336\037\000'), file=DESCRIPTOR),
  ],
  extensions=[
  ],
  nested_types=[],
  enum_types=[
  ],
  serialized_options=_b('\350\363\030\001\360\363\030\001\200\364\030\001\240\364\030\001\220\364\030\001\340\364\030\001'),
  is_extendable=False,
  syntax='proto3',
  extension_ranges=[],
  oneofs=[
  ],
  serialized_start=1458,
  serialized_end=1698,
)

_CLUSTERINSTKEY.fields_by_name['cluster_key'].message_type = cluster__pb2._CLUSTERKEY
_CLUSTERINSTKEY.fields_by_name['cloudlet_key'].message_type = cloudlet__pb2._CLOUDLETKEY
_CLUSTERINST.fields_by_name['key'].message_type = _CLUSTERINSTKEY
_CLUSTERINST.fields_by_name['flavor'].message_type = flavor__pb2._FLAVORKEY
_CLUSTERINST.fields_by_name['liveness'].enum_type = common__pb2._LIVENESS
_CLUSTERINST.fields_by_name['state'].enum_type = common__pb2._TRACKEDSTATE
_CLUSTERINST.fields_by_name['crm_override'].enum_type = common__pb2._CRMOVERRIDE
_CLUSTERINST.fields_by_name['ip_access'].enum_type = common__pb2._IPACCESS
_CLUSTERINST.fields_by_name['status'].message_type = common__pb2._STATUSINFO
_CLUSTERINSTINFO.fields_by_name['key'].message_type = _CLUSTERINSTKEY
_CLUSTERINSTINFO.fields_by_name['state'].enum_type = common__pb2._TRACKEDSTATE
_CLUSTERINSTINFO.fields_by_name['status'].message_type = common__pb2._STATUSINFO
DESCRIPTOR.message_types_by_name['ClusterInstKey'] = _CLUSTERINSTKEY
DESCRIPTOR.message_types_by_name['ClusterInst'] = _CLUSTERINST
DESCRIPTOR.message_types_by_name['ClusterInstInfo'] = _CLUSTERINSTINFO
_sym_db.RegisterFileDescriptor(DESCRIPTOR)

ClusterInstKey = _reflection.GeneratedProtocolMessageType('ClusterInstKey', (_message.Message,), {
  'DESCRIPTOR' : _CLUSTERINSTKEY,
  '__module__' : 'clusterinst_pb2'
  # @@protoc_insertion_point(class_scope:edgeproto.ClusterInstKey)
  })
_sym_db.RegisterMessage(ClusterInstKey)

ClusterInst = _reflection.GeneratedProtocolMessageType('ClusterInst', (_message.Message,), {
  'DESCRIPTOR' : _CLUSTERINST,
  '__module__' : 'clusterinst_pb2'
  # @@protoc_insertion_point(class_scope:edgeproto.ClusterInst)
  })
_sym_db.RegisterMessage(ClusterInst)

ClusterInstInfo = _reflection.GeneratedProtocolMessageType('ClusterInstInfo', (_message.Message,), {
  'DESCRIPTOR' : _CLUSTERINSTINFO,
  '__module__' : 'clusterinst_pb2'
  # @@protoc_insertion_point(class_scope:edgeproto.ClusterInstInfo)
  })
_sym_db.RegisterMessage(ClusterInstInfo)


_CLUSTERINSTKEY.fields_by_name['cluster_key']._options = None
_CLUSTERINSTKEY.fields_by_name['cloudlet_key']._options = None
_CLUSTERINSTKEY._options = None
_CLUSTERINST.fields_by_name['key']._options = None
_CLUSTERINST.fields_by_name['flavor']._options = None
_CLUSTERINST.fields_by_name['liveness']._options = None
_CLUSTERINST.fields_by_name['auto']._options = None
_CLUSTERINST.fields_by_name['state']._options = None
_CLUSTERINST.fields_by_name['errors']._options = None
_CLUSTERINST.fields_by_name['crm_override']._options = None
_CLUSTERINST.fields_by_name['ip_access']._options = None
_CLUSTERINST.fields_by_name['allocated_ip']._options = None
_CLUSTERINST.fields_by_name['node_flavor']._options = None
_CLUSTERINST.fields_by_name['deployment']._options = None
_CLUSTERINST.fields_by_name['status']._options = None
_CLUSTERINST.fields_by_name['external_volume_size']._options = None
_CLUSTERINST.fields_by_name['image_name']._options = None
_CLUSTERINST.fields_by_name['reserved_by']._options = None
_CLUSTERINST.fields_by_name['master_node_flavor']._options = None
_CLUSTERINST._options = None
_CLUSTERINSTINFO.fields_by_name['key']._options = None
_CLUSTERINSTINFO.fields_by_name['notify_id']._options = None
_CLUSTERINSTINFO.fields_by_name['status']._options = None
_CLUSTERINSTINFO._options = None

_CLUSTERINSTAPI = _descriptor.ServiceDescriptor(
  name='ClusterInstApi',
  full_name='edgeproto.ClusterInstApi',
  file=DESCRIPTOR,
  index=0,
  serialized_options=None,
  serialized_start=1701,
  serialized_end=2344,
  methods=[
  _descriptor.MethodDescriptor(
    name='CreateClusterInst',
    full_name='edgeproto.ClusterInstApi.CreateClusterInst',
    index=0,
    containing_service=None,
    input_type=_CLUSTERINST,
    output_type=result__pb2._RESULT,
    serialized_options=_b('\202\323\344\223\002\030\"\023/create/clusterinst:\001*\250\365\030\001\352\364\030/ResourceClusterInsts,ActionManage,Key.Developer\320\365\030\001\210\366\030\001'),
  ),
  _descriptor.MethodDescriptor(
    name='DeleteClusterInst',
    full_name='edgeproto.ClusterInstApi.DeleteClusterInst',
    index=1,
    containing_service=None,
    input_type=_CLUSTERINST,
    output_type=result__pb2._RESULT,
    serialized_options=_b('\202\323\344\223\002\030\"\023/delete/clusterinst:\001*\250\365\030\001\352\364\030/ResourceClusterInsts,ActionManage,Key.Developer\210\366\030\001'),
  ),
  _descriptor.MethodDescriptor(
    name='UpdateClusterInst',
    full_name='edgeproto.ClusterInstApi.UpdateClusterInst',
    index=2,
    containing_service=None,
    input_type=_CLUSTERINST,
    output_type=result__pb2._RESULT,
    serialized_options=_b('\202\323\344\223\002\030\"\023/update/clusterinst:\001*\250\365\030\001\352\364\030/ResourceClusterInsts,ActionManage,Key.Developer\210\366\030\001'),
  ),
  _descriptor.MethodDescriptor(
    name='ShowClusterInst',
    full_name='edgeproto.ClusterInstApi.ShowClusterInst',
    index=3,
    containing_service=None,
    input_type=_CLUSTERINST,
    output_type=_CLUSTERINST,
    serialized_options=_b('\202\323\344\223\002\026\"\021/show/clusterinst:\001*\352\364\030-ResourceClusterInsts,ActionView,Key.Developer'),
  ),
])
_sym_db.RegisterServiceDescriptor(_CLUSTERINSTAPI)

DESCRIPTOR.services_by_name['ClusterInstApi'] = _CLUSTERINSTAPI


_CLUSTERINSTINFOAPI = _descriptor.ServiceDescriptor(
  name='ClusterInstInfoApi',
  full_name='edgeproto.ClusterInstInfoApi',
  file=DESCRIPTOR,
  index=1,
  serialized_options=None,
  serialized_start=2347,
  serialized_end=2482,
  methods=[
  _descriptor.MethodDescriptor(
    name='ShowClusterInstInfo',
    full_name='edgeproto.ClusterInstInfoApi.ShowClusterInstInfo',
    index=0,
    containing_service=None,
    input_type=_CLUSTERINSTINFO,
    output_type=_CLUSTERINSTINFO,
    serialized_options=_b('\202\323\344\223\002\032\"\025/show/clusterinstinfo:\001*'),
  ),
])
_sym_db.RegisterServiceDescriptor(_CLUSTERINSTINFOAPI)

DESCRIPTOR.services_by_name['ClusterInstInfoApi'] = _CLUSTERINSTINFOAPI

# @@protoc_insertion_point(module_scope)
