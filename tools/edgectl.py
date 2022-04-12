#!/usr/bin/env python3
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


import argparse
from datetime import datetime
import os
import re
import requests
import subprocess
import sys

REGION_REGEX = re.compile(r'-([a-z]+)\.ctrl\.mobiledgex\.net')
CERT_DIR = os.path.expanduser("~/.edgectl-certs")

def get_vault_token(args):
    r = requests.post("{0}/v1/auth/userpass/login/{1}".format(
                        args.vault, args.vault_user),
                      json={"password": args.vault_pass})
    return r.json()["auth"]["client_token"]

def gen_certs(region, cert_dir, args):
    crt_file = os.path.join(cert_dir, "ec.crt")
    key_file = os.path.join(cert_dir, "ec.key")

    cert_gen_file = os.path.join(cert_dir, "certgen.txt")
    cert_gen = ""
    if os.path.exists(cert_gen_file):
        with open(cert_gen_file) as f:
            cert_gen = f.read().strip()

    datestamp = datetime.now().strftime("%Y-%m-%d")
    if datestamp != cert_gen:
        # Refresh certs

        # Fetch CA cert
        r = requests.get("{0}/v1/{1}/ca/pem".format(args.vault, args.pki))
        with open(os.path.join(cert_dir, "mex-ca.crt"), "w") as f:
            f.write(r.text)

        token = get_vault_token(args)

        # Generate certificate
        r = requests.post("{0}/v1/{1}/issue/{2}".format(
                            args.vault, args.pki, region),
                          headers={"X-Vault-Token": token},
                          json={
                              "common_name": args.common_name,
                              "uri_sans": "region://{0}".format(region),
                          }).json()
        cert = r["data"]["certificate"]
        key = r["data"]["private_key"]

        with open(crt_file, "w") as f:
            f.write(cert)

        with open(key_file, "w") as f:
            f.write(key)

        with open(cert_gen_file, "w") as f:
            f.write(datestamp)

    return crt_file

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("--addr", help="Controller address")
    parser.add_argument("--tls", help="This argument is ignored")
    parser.add_argument("--vault", help="Vault to use to generate certs",
                        default="https://vault-qa.mobiledgex.net")
    parser.add_argument("--pki", help="PKI endpoint in vault",
                        default="pki-regional")
    parser.add_argument("--real-edgectl", help="Path to real edgectl command",
                        default=os.path.expanduser( "~/go/bin/edgectl.real"))
    parser.add_argument("--vault-user", help="Vault username",
                        default="edgectl")
    parser.add_argument("--vault-pass", help="Vault password",
                        default="***REMOVED***")
    parser.add_argument("--common-name", help="Common name for the generated cert",
                        default="local.mobiledgex.net")

    args, unknown = parser.parse_known_args()

    m = re.search(REGION_REGEX, args.addr)
    if not m:
        sys.exit("Failed to identify region from address: {0}".format(args.addr))

    region = m.group(1).upper()

    if not os.path.exists(CERT_DIR):
        os.mkdir(CERT_DIR)

    region_cert_dir = os.path.join(CERT_DIR, region)
    if not os.path.exists(region_cert_dir):
        os.mkdir(region_cert_dir)

    crt_file = gen_certs(region, region_cert_dir, args)

    command = [ args.real_edgectl,
                "--addr", args.addr,
               "--tls", crt_file ] + unknown
    subprocess.call(command)

