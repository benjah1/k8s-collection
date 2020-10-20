import hvac
import socket
import json
import consul

from kubernetes import client, config
from kubernetes.client.api import core_v1_api
from kubernetes.stream import portforward


config.load_kube_config()
print("%-40s %s" %("core", ",".join(client.CoreApi().get_api_versions().versions)))
api = core_v1_api.CoreV1Api()

socket_create_connection = socket.create_connection
socket_getaddrinfo = socket.getaddrinfo

def kubernetes_create_connection(address, *args, **kwargs):
    dns_name = address[0]
    if isinstance(dns_name, bytes):
        dns_name = dns_name.decode()
    dns_name = dns_name.split(".")

    print("{} {}".format(dns_name, address[1] ))
    if len(dns_name) != 3 or dns_name[2] != "kubernetes":
        return socket_create_connection(address, *args, **kwargs)

    pf = portforward(
        api.connect_get_namespaced_pod_portforward,
        dns_name[0], dns_name[1],
        ports=str(address[1]),
    )

    return pf.socket(address[1])
    

def kubernetes_getaddrinfo(host, port, family=0, type=0, proto=0, flags=0):
    dns_name = host
    if isinstance(dns_name, bytes):
        dns_name = dns_name.decode()
    dns_name = dns_name.split(".")

    print("{} {}".format(dns_name, port))
    print("{} {}".format(family, proto))
    if len(dns_name) != 3 or dns_name[2] != "kubernetes":
        return socket_getaddrinfo(host, port, family, type, proto, flags)

    return socket_getaddrinfo('127.0.0.1', port)


socket.create_connection = kubernetes_create_connection
socket.getaddrinfo = kubernetes_getaddrinfo

client = hvac.Client(url='http://vault-0.vault.kubernetes:8200')

print(client.sys.is_initialized()) # => False

shares = 1
threshold = 1

# result = client.sys.initialize(shares, threshold)

result = {'root_token': 'abc', 'keys': ['def']}
root_token = result['root_token']
keys = result['keys']

# print("token: {}".format(root_token))
# print("key: {}".format(keys))

# print(client.sys.is_initialized()) # => True
# print(client.sys.is_sealed()) # => True

# unseal with individual keys
# client.sys.submit_unseal_key(keys[0])



consul = consul.Consul(host='consul-0.vault.kubernetes',
        token='95b4472e-7e1f-e052-b02f-ad0d2d89759a')
consul.kv.put('the/key', 'the_value')

# print(client.sys.is_sealed()) # => False



# connect to consul 
# push key to consul

print(json.dumps(result))
