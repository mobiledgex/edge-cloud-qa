# Copyright 2022 MobiledgeX, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Codec for quoted-printable encoding.

This codec de/encodes from bytes to bytes.
"""

import codecs
import quopri
from io import BytesIO

def quopri_encode(input, errors='strict'):
    assert errors == 'strict'
    f = BytesIO(input)
    g = BytesIO()
    quopri.encode(f, g, quotetabs=True)
    return (g.getvalue(), len(input))

def quopri_decode(input, errors='strict'):
    assert errors == 'strict'
    f = BytesIO(input)
    g = BytesIO()
    quopri.decode(f, g)
    return (g.getvalue(), len(input))

class Codec(codecs.Codec):
    def encode(self, input, errors='strict'):
        return quopri_encode(input, errors)
    def decode(self, input, errors='strict'):
        return quopri_decode(input, errors)

class IncrementalEncoder(codecs.IncrementalEncoder):
    def encode(self, input, final=False):
        return quopri_encode(input, self.errors)[0]

class IncrementalDecoder(codecs.IncrementalDecoder):
    def decode(self, input, final=False):
        return quopri_decode(input, self.errors)[0]

class StreamWriter(Codec, codecs.StreamWriter):
    charbuffertype = bytes

class StreamReader(Codec, codecs.StreamReader):
    charbuffertype = bytes

# encodings module API

def getregentry():
    return codecs.CodecInfo(
        name='quopri',
        encode=quopri_encode,
        decode=quopri_decode,
        incrementalencoder=IncrementalEncoder,
        incrementaldecoder=IncrementalDecoder,
        streamwriter=StreamWriter,
        streamreader=StreamReader,
        _is_text_encoding=False,
    )
