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

# this is from Venkys script

import re
import os
from datetime import datetime
import requests
import logging

logger = logging.getLogger(__name__)

def generate_new_cert(controller_address):
    REGION_REGEX = re.compile(r'-([a-z]+)\.ctrl\.mobiledgex\.net')
    CERT_DIR = os.path.expanduser("~/.edgectl-certs")

    vault_address = 'https://vault-qa.mobiledgex.net'
    vault_user = 'edgectl'
    vault_password = 'HZkTmGqN4uKmQWtZbRrn'
    vault_pki = 'pki-regional'
    common_name = 'local.mobiledgex.net'

    logger.info(f'generating cert with vault:{vault_address} {vault_user} {vault_password} {vault_pki} {common_name}')

    m = re.search(REGION_REGEX, controller_address)
    if not m:
        sys.exit("Failed to identify region from address: {0}".format(controller_address))
    region = m.group(1).upper()
    if not os.path.exists(CERT_DIR):
        os.mkdir(CERT_DIR)
    region_cert_dir = os.path.join(CERT_DIR, region)
    if not os.path.exists(region_cert_dir):
        os.mkdir(region_cert_dir)
    crt_file = gen_certs(region=region, cert_dir=region_cert_dir, vault_address=vault_address, vault_user=vault_user, vault_password=vault_password, vault_pki=vault_pki, common_name=common_name)

    certpathlist = os.path.split(crt_file)
    
    key_file = certpathlist[0] + '/' + certpathlist[1].split('.')[0] + '.key'
    rootcert_file = certpathlist[0] + '/rootcert.crt'
    r1 = requests.get("https://vault-qa.mobiledgex.net/v1/pki-global/ca/pem")
    r2 = requests.get("https://vault-qa.mobiledgex.net/v1/pki/ca/pem")
    r3 = requests.get("https://vault-qa.mobiledgex.net/v1/pki-regional/ca/pem")
    #root_cert = str.encode('\n' + r1.text) + str.encode('\n' + r2.text) + str.encode('\n' + r3.text) 
    with open(rootcert_file, 'w') as f:
        f.write(f'{r1.text}\n{r2.text}\n{r3.text}')

    return crt_file, key_file, rootcert_file

def get_vault_token(vault_address, vault_user, vault_password):
    r = requests.post("{0}/v1/auth/userpass/login/{1}".format(
                        vault_address, vault_user),
                      json={"password": vault_password})
    return r.json()["auth"]["client_token"]

def gen_certs(region, cert_dir, vault_address, vault_user, vault_password, vault_pki, common_name):
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
        r = requests.get("{0}/v1/{1}/ca/pem".format(vault_address, vault_pki))
        with open(os.path.join(cert_dir, "mex-ca.crt"), "w") as f:
            f.write(r.text)
        token = get_vault_token(vault_address, vault_user, vault_password)
        # Generate certificate
        r = requests.post("{0}/v1/{1}/issue/{2}".format(
                            vault_address,vault_pki, region),
                          headers={"X-Vault-Token": token},
                          json={
                              "common_name": common_name,
                              "uri_sans": "region://{0}".format(region),
                          }).json()
        cert = r["data"]["certificate"]
        key = r["data"]["private_key"]

        #added by Jons suggestion
        ca = r["data"]["issuing_ca"]    #jon
        print('*WARN*', 'CCCCCCCCCCCCCCCCCCCca', ca)
        with open(os.path.join(cert_dir, "mex-ca.crt"), "w") as f:
            f.write(ca)

        with open(crt_file, "w") as f:
            f.write(cert)
        with open(key_file, "w") as f:
            f.write(key)
        with open(cert_gen_file, "w") as f:
            f.write(datestamp)

    return crt_file

