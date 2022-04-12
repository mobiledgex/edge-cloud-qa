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

#
# export these commands
# export VAULT_SECRET_ID=***REMOVED***
# export VAULT_ROLE_ID=0870a629-4634-7f0c-ffd1-b235232abc32
#
# this will create a file called signed-key in the local directory
# then ssh using this key
#

#!/bin/bash
export VAULT_ADDR="https://vault-qa.mobiledgex.net"
export VAULT_SECRET_ID=***REMOVED***
export VAULT_ROLE_ID=0870a629-4634-7f0c-ffd1-b235232abc32

SSH_KEY="$HOME/.ssh/id_rsa"
[[ -z "$VAULT_ROLE_ID" ]] && read -p "Vault Role ID: " VAULT_ROLE_ID
[[ -z "$VAULT_SECRET_ID" ]] && read -p "Vault Secret ID: " VAULT_SECRET_ID
die() {
    echo "ERROR: $*" >&2
    exit 2
}
echo "Generating token"
TOKEN=$( vault write -field=token auth/approle/login role_id="$VAULT_ROLE_ID" secret_id="$VAULT_SECRET_ID" )
[[ -n "$TOKEN" ]] || die "Unable to generate vault token"
echo "Logging in"
vault login "$TOKEN" >/dev/null || die "Unable to log in to vault"
echo "Signing key"
vault write -field signed_key ssh/sign/machine public_key=@${SSH_KEY}.pub > ~/.ssh/signed-key \
    || die "Unable to sign SSH key: ${SSH_KEY}.pub"
echo "Wrote signed-key to ~/.ssh/signed-key"
echo
echo -e "Examine key using:\n  ssh-keygen -L -f signed-key"
echo
echo -e "Log in using:\n  ssh -i signed-key -i $SSH_KEY ..."

