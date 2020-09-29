FROM alpine:3.12.0

RUN apk add curl

RUN curl -sLO https://releases.hashicorp.com/terraform/0.13.3/terraform_0.13.3_linux_amd64.zip && \
    unzip terraform_0.13.3_linux_amd64.zip && \
	  chmod +x ./terraform && \
		mv ./terraform /usr/local/bin/terraform

RUN curl -sLO "https://storage.googleapis.com/kubernetes-release/release/v1.19.2/bin/linux/amd64/kubectl" && \
	  chmod +x ./kubectl && \
		mv ./kubectl /usr/local/bin/kubectl
