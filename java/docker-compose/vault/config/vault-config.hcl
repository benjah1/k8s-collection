disable_mlock = true
ui = true
listener "tcp" {
	tls_disable = 1
	address = "[::]:8200"
	cluster_address = "[::]:8201"
}
storage "consul" {
	path = "vault/"
	address = "consul:8500"
	token = "7b52b70e-3cb3-2e0d-baa4-4b58659336d6"
}
