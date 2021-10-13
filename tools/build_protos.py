#!/usr/local/bin/python3

# copy needed proto files into 1 directory
# I originally tried building these from the original path but ran into problems

import os
import shutil
import glob
import subprocess
import os
import argparse
import sys

parser = argparse.ArgumentParser(description='create proto files for testcases')
parser.add_argument('--sourcedir', default=os.environ['HOME'] + '/go/src/github.com/mobiledgex/edge-cloud/', help='dir where go source dir exists')
parser.add_argument('--sourcedir_proto', default=os.environ['HOME'] + '/go/src/github.com/mobiledgex/edge-proto/', help='dir where go source dir exists')
#parser.add_argument('--sourcedir_infra', default=os.environ['HOME'] + '/go/src/github.com/mobiledgex/edge-cloud-infra/', help='dir where go source dir exists')
parser.add_argument('--qadir', default=os.environ['HOME'] + '/go/src/github.com/mobiledgex/edge-cloud-qa/', help='dir where qa is')

args = parser.parse_args()

#home_dir = os.environ['HOME']
edgecloud_dir = args.sourcedir
edgeproto_dir = args.sourcedir_proto
#edgecloud_dir_infra = args.sourcedir_infra
edgecloud_qa_dir = args.qadir
pkg_dir = os.environ['HOME'] + '/go/pkg/mod/github.com/gogo/protobuf@v1.3.1/gogoproto/'
#edgecloud_dir = home_dir + '/go/src/github.com/mobiledgex/edge-cloud/'
#edgecloud_qa_dir = home_dir + '/go/src/github.com/mobiledgex/edge-cloud-qa/'

protos_src_list = (#edgecloud_dir + 'vendor/github.com/gogo/googleapis/google/api/',
                   #edgecloud_dir + 'vendor/github.com/gogo/protobuf/gogoproto/',
                   edgecloud_dir + 'edge-mvp/third_party/googleapis/google/api/',
                   pkg_dir, 
#                   edgecloud_dir_infra + 'vendor/github.com/gogo/protobuf/gogoproto/',
#                   edgecloud_dir_infra + 'vendor/github.com/golang/protobuf/ptypes/timestamp/',
#                   edgecloud_dir_infra + 'vendor/github.com/golang/protobuf/ptypes/any/',
                   #edgecloud_dir + 'vendor/github.com/golang/protobuf/protoc-gen-go/descriptor/',
#                   edgecloud_dir + 'vendor/github.com/golang/protobuf/ptypes/timestamp/',
                   edgecloud_dir + 'd-match-engine/dme-proto/',
                   edgecloud_dir + 'edgeproto/',
                   edgecloud_dir + 'protoc-gen-cmd/protocmd/',
                   edgecloud_dir + 'protogen/',
                   edgeproto_dir + 'dme/',
                   edgeproto_dir + 'edgeprotogen/',
                   edgeproto_dir + 'third_party/googleapis/google/api/',

)
protos_dest = edgecloud_qa_dir + '/protos'

#file_skip_convert_list = ('annotations.proto')
import_proto_skip_convert_list = ['descriptor.proto']  # dont remove path from this since it causes a warning to print
proto_mapping = {'protoc-gen-swagger/options/annotations.proto': 'swagger_annotations.proto'}

generate_proto_cmd = 'python3 -m grpc_tools.protoc -I{} --python_out={} --grpc_python_out={} '.format(protos_dest, protos_dest, protos_dest)

# copy protofiles and change import statement to remove path info
for proto in protos_src_list:
    #flist = os.listdir(proto)
    #print(proto, flist)
    flist = glob.glob(proto + '*.proto')
    #print(flist)
    for file in flist:
        print('copy {} to {}'.format(file, protos_dest))
        filename = os.path.basename(file)
        dest_file_copy = protos_dest + '/' + filename + '.orig'
        dest_file_new = protos_dest + '/' + filename
        shutil.copy2(file, dest_file_copy)
        os.chmod(dest_file_copy, 0o777)

        with open(dest_file_copy) as read_file, open(dest_file_new, 'w') as write_file:
            line = read_file.readline()
            while line:
                if line.startswith('import') and '/' in line: # remove path from import statement
                    #print('found',line)
                    lsplit = line.split('"')
                    #print(os.path.basename(lsplit[1]), import_proto_skip_convert_list)
                    if os.path.basename(lsplit[1]) not in import_proto_skip_convert_list and lsplit[1] not in proto_mapping.keys():
                        line = lsplit[0] + '"' + os.path.basename(lsplit[1]) + '"' + lsplit[2]
                    else:
                        print('skipping convert of', os.path.basename(lsplit[1]))
                    if lsplit[1] in proto_mapping.keys():
                        line = lsplit[0] + '"' + proto_mapping[lsplit[1]] + '"' + lsplit[2]
                write_file.write(line)
                line = read_file.readline()

# convert proto files to python
flist_proto = glob.glob(protos_dest + '/*.proto')
for file in flist_proto:
    new_cmd = generate_proto_cmd + '/' + file
    print('executing', new_cmd)
    return_code = subprocess.call(new_cmd, shell=True)
    if return_code != 0:
        print('error converting proto. returncode=', return_code)

            
                   
