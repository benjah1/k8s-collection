import hvac
import json

client = hvac.Client(url='http://localhost:8200')

# print(client.sys.is_initialized()) # => False

shares = 1
threshold = 1

result = client.sys.initialize(shares, threshold)

root_token = result['root_token']
keys = result['keys']

# print("token: {}".format(root_token))
# print("key: {}".format(keys))

# print(client.sys.is_initialized()) # => True
# print(client.sys.is_sealed()) # => True

# unseal with individual keys
# client.sys.unseal(keys[0])
client.sys.submit_unseal_key(keys[0])

# print(client.sys.is_sealed()) # => False

print(json.dumps(result))
