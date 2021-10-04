#
# Copyright 2015 gRPC authors.
# Copyright 2018 Mobiledgex, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

HOST_SYSTEM = $(shell uname | cut -f 1 -d_)
SYSTEM ?= $(HOST_SYSTEM)
CXX = g++
CPPFLAGS += `pkg-config --cflags protobuf grpc`
CPPFLAGS += -I.
CPPFLAGS += -I../common
CPPFLAGS += -I../jwt-cpp
CPPFLAGS += -I/usr/local/Cellar/openssl/1.0.2s/include/
CPPFLAGS += -I/usr/include/
CXXFLAGS += -std=c++17
CXXFLAGS += -fPIC
ifeq ($(SYSTEM),Darwin)
LDFLAGS += -L/usr/local/lib `pkg-config --libs protobuf grpc++ grpc`\
           -lgrpc++_reflection\
           -ldl\
           -lcurl
else
LDFLAGS += -L/usr/local/lib `pkg-config --libs protobuf grpc++ grpc`\
           -Wl,--no-as-needed -lgrpc++_reflection -Wl,--as-needed\
           -ldl\
           -lcurl
endif
PROTOC = protoc
GRPC_CPP_PLUGIN = grpc_cpp_plugin
GRPC_CPP_PLUGIN_PATH ?= `which $(GRPC_CPP_PLUGIN)`

# Run "brew install coreutils" to get "grealpath" for protoc's requirement of absolute paths
#ABSOLUTEPATH := $(shell grealpath ../../../../)
ABSOLUTEPATH := $(shell realpath ~/workspace/runEdgecloud/go/src/github.com/mobiledgex/)
DME_PROTO_PATH = $(ABSOLUTEPATH)/edge-proto/dme
THIRD_PARTY_PROTOS_PATH = $(ABSOLUTEPATH)/edge-proto/third_party
EDGEPROTOGEN_PATH = $(ABSOLUTEPATH)/edge-proto/edgeprotogen

PROTO_INCLUDE_DIRECTORIES := $(DME_PROTO_PATH) $(THIRD_PARTY_PROTOS_PATH)/googleapis $(EDGEPROTOGEN_PATH)

vpath %.proto $(PROTO_INCLUDE_DIRECTORIES)
PROTO_INCLUDE_FLAGS += $(addprefix --proto_path ,$(PROTO_INCLUDE_DIRECTORIES))

all: system-check libmexgrpc.so verifyLocationBadCarrier

verifyLocationBadCarrier: ../common/test_credentials.o verifyLocationBadCarrier.o
	$(CXX) $^ $(LDFLAGS) -I. -L. -lmexgrpc -Wl,-rpath,. -o $@

libmexgrpc.so: google/api/http.pb.o google/api/http.grpc.pb.o google/api/annotations.pb.o google/api/annotations.grpc.pb.o appcommon.pb.o appcommon.grpc.pb.o loc.pb.o loc.grpc.pb.o app-client.pb.o app-client.grpc.pb.o dynamic-location-group.pb.o dynamic-location-group.grpc.pb.o
	$(CXX) $^ $(LDFLAGS) -I. -L. --shared -o $@

.PRECIOUS: %.grpc.pb.cc
%.grpc.pb.cc: %.proto
	$(PROTOC) $(PROTO_INCLUDE_FLAGS) --grpc_out=. --plugin=protoc-gen-grpc=$(GRPC_CPP_PLUGIN_PATH) $<

.PRECIOUS: %.pb.cc
%.pb.cc: %.proto
	$(PROTOC) $(PROTO_INCLUDE_FLAGS) --cpp_out=. $<

clean:
	rm -rf *.o *.pb.cc *.pb.h google ../common/*.o libmexgrpc.so verifyLocationBadCarrier


# The following is to test your system and ensure a smoother experience.
# They are by no means necessary to actually compile a grpc-enabled software.

PROTOC_CMD = which $(PROTOC)
PROTOC_CHECK_CMD = $(PROTOC) --version | grep -q libprotoc.3
PLUGIN_CHECK_CMD = which $(GRPC_CPP_PLUGIN)
HAS_PROTOC = $(shell $(PROTOC_CMD) > /dev/null && echo true || echo false)
ifeq ($(HAS_PROTOC),true)
HAS_VALID_PROTOC = $(shell $(PROTOC_CHECK_CMD) 2> /dev/null && echo true || echo false)
endif
HAS_PLUGIN = $(shell $(PLUGIN_CHECK_CMD) > /dev/null && echo true || echo false)

SYSTEM_OK = false
ifeq ($(HAS_VALID_PROTOC),true)
ifeq ($(HAS_PLUGIN),true)
SYSTEM_OK = true
endif
endif

system-check:
ifneq ($(HAS_VALID_PROTOC),true)
	@echo " DEPENDENCY ERROR"
	@echo
	@echo "You don't have protoc 3.0.0 installed in your path."
	@echo "Please install Google protocol buffers 3.0.0 and its compiler."
	@echo "You can find it here:"
	@echo
	@echo "   https://github.com/google/protobuf/releases/tag/v3.0.0"
	@echo
	@echo "Here is what I get when trying to evaluate your version of protoc:"
	@echo
	-$(PROTOC) --version
	@echo
	@echo
endif
ifneq ($(HAS_PLUGIN),true)
	@echo " DEPENDENCY ERROR"
	@echo
	@echo "You don't have the grpc c++ protobuf plugin installed in your path."
	@echo "Please install grpc. You can find it here:"
	@echo
	@echo "   https://github.com/grpc/grpc"
	@echo
	@echo "Here is what I get when trying to detect if you have the plugin:"
	@echo
	-which $(GRPC_CPP_PLUGIN)
	@echo
	@echo
endif
ifneq ($(SYSTEM_OK),true)
	@false
endif

edge-proto-check:
ifneq ("$(wildcard $(DME_PROTO_PATH)/app-client.proto)", "")
	@echo "Found a proto in the proto path. Good."
else
	@echo "Sanity check: Missing edge-proto repository file!"
	@echo "Expected edge-proto.git repo clone at DME_PROTO_PATH outside at the same directory level this git repo here: $(DME_PROTO_PATH)"
endif

test: sample_client
	@echo "Basic test"
	echo y | ./sample_client
