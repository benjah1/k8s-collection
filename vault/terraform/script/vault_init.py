import hvac
import json
import subprocess
import os
import consul
import time
import sys

consul_token = sys.argv[1]
print(consul_token)

pf = subprocess.Popen(["whoami"])
def get_vault_pf():
    ready = False
    pf = None
    client = None
    while (not ready):
        print('try vault')
        ready = True
        pf = subprocess.Popen(["kubectl", "-n", "vault", "port-forward", "vault-0", "8200:8200"], stdout=subprocess.PIPE)
        time.sleep(5)
        client = hvac.Client(url='http://127.0.0.1:8200')
        try:
            vstatus = client.sys.read_health_status(method='GET')
            print(client.sys.is_initialized()) # => False
            print(vstatus)
        except:
            ready = False
            pf.kill()
            time.sleep(5)

    return pf, client
    

def get_consul_pf(consul_token):
    ready = False
    pf = None
    client = None
    while(not ready):
        print('try consul')
        ready = True
        pf = subprocess.Popen(["kubectl", "-n", "vault", "port-forward", "consul-0", "8500:8500"], stdout=subprocess.PIPE)
        time.sleep(5)
        client = consul.Consul(host='127.0.0.1', token=consul_token)
        try:
            cstatus = client.status.leader()
            print(cstatus)
        except:
            ready = False
            pf.kill()
            time.sleep(5)

    return pf, client



print('init consul pf')
consul_pf, consul = get_consul_pf(consul_token)
print('init vault pf')
vault_pf, vault = get_vault_pf()

try:
    if (not vault.sys.is_initialized()):
    # if (vault.sys.is_initialized()):
        shares = 1
        threshold = 1

        print('init vault')
        result = vault.sys.initialize(shares, threshold)
        # result = {'root_token': 'abc', 'keys': ['def']}
        vault_token = result['root_token']
        keys = result['keys']
        vault.sys.submit_unseal_key(keys[0])

        time.sleep(5)
        rules = """
            key_prefix "secret/" {
                policy = "read"
            }
        """
        print('create consul policy')
        policy = consul.acl.policy.create(
            name='anonymous',
            rules=rules)

        payload = {
          "Description": "anonymous",
          "Policies": [
            {
              "Name": "anonymous"
            }
          ],
          "Local": False
        }
        print('update consul token')
        consul.acl.tokens.update(payload, '00000000-0000-0000-0000-000000000002')

        print('set consul token')
        consul.kv.put('secret/consul_token', consul_token)
        consul.kv.put('secret/vault_token', vault_token)
        consul.kv.put('secret/vault_unseal_key', keys[0])
        print('init success')
    print('already init')
except Exception as e:
    print('fail to init')
    print(e)
finally:
    print('clean up')
    vault_pf.kill()
    consul_pf.kill()
