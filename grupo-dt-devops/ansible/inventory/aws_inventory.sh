#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-eu-south-2}"
PROFILE_A="${AWS_PROFILE_A:-AlejandroA}"
PROFILE_B="${AWS_PROFILE_B:-NicolasB}"
PROFILE_C="${AWS_PROFILE_C:-MarioC}"
PROFILE_D="${AWS_PROFILE_D:-GonzaloD}"
PROFILE_E="${AWS_PROFILE_E:-JesusE}"
LINUX_USER="${ANSIBLE_SSH_USER:-ansible}"
LINUX_PASSWORD="${ANSIBLE_SSH_PASSWORD:-}"
LINUX_KEY_PERSONAL="${ANSIBLE_SSH_PRIVATE_KEY_FILE_PERSONAL:-${ANSIBLE_SSH_PRIVATE_KEY_FILE:-}}"
LINUX_KEY_UFV="${ANSIBLE_SSH_PRIVATE_KEY_FILE_UFV:-${ANSIBLE_SSH_PRIVATE_KEY_FILE:-}}"
WINDOWS_USER="${ANSIBLE_WIN_USER:-ansible}"
WINDOWS_PASSWORD="${ANSIBLE_WIN_PASSWORD:-}"

AVAILABLE_PROFILES=$(aws configure list-profiles 2>/dev/null || true)

profile_available() {
    local profile="$1"
    if [ -z "$profile" ]; then
        return 1
    fi
    echo "$AVAILABLE_PROFILES" | tr -d '\r' | grep -qx "$profile"
}

build_hosts() {
  local profile="$1"
  aws ec2 describe-instances \
    --profile "$profile" \
    --region "$AWS_REGION" \
    --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[].Instances[].{name:Tags[?Key==`Name`]|[0].Value,public_ip:PublicIpAddress,private_ip:PrivateIpAddress,platform:Platform}' \
    --output json
}

PROFILE_A_JSON=""
PROFILE_B_JSON=""
PROFILE_C_JSON=""
PROFILE_D_JSON=""
PROFILE_E_JSON=""

if profile_available "$PROFILE_A"; then PROFILE_A_JSON=$(build_hosts "$PROFILE_A"); fi
if profile_available "$PROFILE_B"; then PROFILE_B_JSON=$(build_hosts "$PROFILE_B"); fi
if profile_available "$PROFILE_C"; then PROFILE_C_JSON=$(build_hosts "$PROFILE_C"); fi
if profile_available "$PROFILE_D"; then PROFILE_D_JSON=$(build_hosts "$PROFILE_D"); fi
if profile_available "$PROFILE_E"; then PROFILE_E_JSON=$(build_hosts "$PROFILE_E"); fi

PROFILE_A_JSON="$PROFILE_A_JSON" PROFILE_B_JSON="$PROFILE_B_JSON" PROFILE_C_JSON="$PROFILE_C_JSON" PROFILE_D_JSON="$PROFILE_D_JSON" PROFILE_E_JSON="$PROFILE_E_JSON" LINUX_USER="$LINUX_USER" LINUX_PASSWORD="$LINUX_PASSWORD" LINUX_KEY_PERSONAL="$LINUX_KEY_PERSONAL" LINUX_KEY_UFV="$LINUX_KEY_UFV" WINDOWS_USER="$WINDOWS_USER" WINDOWS_PASSWORD="$WINDOWS_PASSWORD" python3 - <<'PY'
import json, os

all_hosts = []
for key in ('PROFILE_A_JSON', 'PROFILE_B_JSON', 'PROFILE_C_JSON', 'PROFILE_D_JSON', 'PROFILE_E_JSON'):
    raw = os.environ.get(key)
    if not raw:
        continue
    all_hosts.extend(json.loads(raw))

inv = {
    '_meta': {'hostvars': {}},
    'linux_personal': {'hosts': []},
    'linux_ufv': {'hosts': []},
    'windows_personal': {'hosts': []},
    'windows_clients': {'hosts': []},
    'windows': {'children': ['windows_personal', 'windows_clients']},
    'nginx': {'hosts': []},
    'postgres': {'hosts': []},
    'linux': {'children': ['linux_personal', 'linux_ufv']},
}

def add_host(group, host_key, ip, private_ip, user, password, is_windows=False, private_key=None):
    inv[group]['hosts'].append(host_key)
    inv['_meta']['hostvars'][host_key] = {
        'ansible_host': ip,
        'public_ip': ip,
        'private_ip': private_ip,
        'ansible_user': user,
    }
    if password:
        inv['_meta']['hostvars'][host_key]['ansible_password'] = password
    if is_windows:
        inv['_meta']['hostvars'][host_key].update({
            'ansible_connection': 'winrm',
            'ansible_winrm_transport': 'basic',
            'ansible_port': 5985,
            'ansible_winrm_server_cert_validation': 'ignore'
        })
    else:
        inv['_meta']['hostvars'][host_key].update({
            'ansible_connection': 'ssh',
            'ansible_become': True,
            'ansible_become_method': 'sudo'
        })
        if private_key:
            inv['_meta']['hostvars'][host_key]['ansible_ssh_private_key_file'] = private_key

linux_key_personal = os.environ.get('LINUX_KEY_PERSONAL')
linux_key_ufv = os.environ.get('LINUX_KEY_UFV')

for item in all_hosts:
    name = item.get('name') or ''
    ip = item.get('public_ip')
    private_ip = item.get('private_ip')
    if not ip:
        continue
    if 'WIN-CLIENT' in name:
        add_host('windows_clients', name or ip, ip, private_ip, os.environ['WINDOWS_USER'], os.environ['WINDOWS_PASSWORD'], is_windows=True)
    elif 'DC' in name or 'AD' in name or item.get('platform') == 'windows':
        add_host('windows_personal', name or ip, ip, private_ip, os.environ['WINDOWS_USER'], os.environ['WINDOWS_PASSWORD'], is_windows=True)
    else:
        if 'UFV' in name or 'Web' in name:
            add_host('linux_ufv', name or ip, ip, private_ip, os.environ['LINUX_USER'], os.environ['LINUX_PASSWORD'], private_key=linux_key_ufv)
        else:
            add_host('linux_personal', name or ip, ip, private_ip, os.environ['LINUX_USER'], os.environ['LINUX_PASSWORD'], private_key=linux_key_personal)
        if 'LB' in name or 'Nginx' in name:
            inv['nginx']['hosts'].append(name or ip)
        if 'Postgre' in name or 'DB' in name:
            inv['postgres']['hosts'].append(name or ip)

print(json.dumps(inv, indent=2))
PY
