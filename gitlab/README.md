# GitLab

inspire by https://gitlab.com/gitlab-org/gitlab/-/issues/23911#note_215199418


## CI/CD jobs

| Name 										| Description 			|
|---|---|
| 91_vagrant_image 				| create image for create VM |
| 92_kind_image						| create image of kind node |
| 93_devops_image					| create image for create k8s and exec terraform | 
| 01_vagrant_up						| create VM |
|	02_kind_up							| create k8s cluster | 
| 11_terraform_monitoring	| exec terraform monitoring workspace |


## Start up GitLab environment
```
docker-compose up -d
```

Get the registration token from: http://localhost:8080/root/${project}/settings/

```
bash .scripts/gitlab-runner-register.sh REGISTRATION_TOKEN
```

## Initial GitLab

After create account and login, Push this k8s-collection repo to GitLab. GitLab will pickup the .gitlab-ci.yaml

Also, configure the CI/CD Variables in the k8s-collection repo. see the Variables session


## Variables

| Type | Key         				| Description |
|---|---|---|
| FILE | K8S_BEN_CRT 				| Cert for k8s user signup with private key |
| FILE | K8S_BEN_KEY 				| Same as private key |
| FILE | K8S_CA_KEY 				| K8s CA for creating k8s |
| FILE | K8S_CA_CRT 				| K8s CA cert |
| FILE | PRI_KEY 						| Private key for ssh |
| FILE | PUB_KEY 						| Public Key |
| FILE | REMOTE_SERVER_HOST | Remote Server Host for creating VM |
| FILE | REMOTE_SERVER_USER | Remote Server User |
| FILE | REMOTE_VM_HOST 		| VM host for kind k8s |
| FILE | REMOTE_VM_USER 		| VM user |
