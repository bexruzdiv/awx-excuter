FROM quay.io/ansible/awx-ee:latest

USER root
RUN yum install wget -y
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
RUN chmod +x ./kubectl \
    && mv kubectl /usr/local/bin/ \
    && mkdir -p ~/.kube \
    && export PATH=$PATH:$HOME/.kube

RUN wget https://get.helm.sh/helm-v3.13.2-linux-amd64.tar.gz \
    && tar -xzvf helm-v3.13.2-linux-amd64.tar.gz
RUN chmod +x linux-amd64/helm \
    && mv linux-amd64/helm /usr/local/bin/ \
    && rm -rf helm-v3.13.2-linux-amd64.tar.gz

RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq &&\
    chmod +x /usr/local/bin/yq

COPY requirements.txt ./
RUN pip install -r requirements.txt

COPY requirements-kubespray.txt ./

RUN pip install virtualenv
RUN python3 -m venv kubespray-venv
RUN . kubespray-venv/bin/activate && \
    pip install --upgrade pip && \
    pip install -U -r requirements-kubespray.txt

RUN mkdir -p /opt/vault/directory
RUN wget https://releases.hashicorp.com/vault/1.2.3/vault_1.2.3_linux_amd64.zip
RUN unzip vault_1.2.3_linux_amd64.zip
RUN chown root:root vault
RUN mv vault /usr/local/bin/ 


COPY requirements.yml ./
RUN ansible-galaxy collection install -r requirements.yml --collections-path "/usr/share/ansible/collections"

CMD /run.sh
