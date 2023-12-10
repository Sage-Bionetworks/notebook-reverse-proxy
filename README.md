# notebook-reverse-proxy
Docker container with Apache reverse proxy for Service Catalog notebook product

### To run a Jupyter notebook:

```
export EC2_INSTANCE_ID=...
export NOTEBOOK_CONTAINER_NAME=jupyter
export NETWORK_NAME=proxy-net

docker network create --driver bridge ${NETWORK_NAME}

docker run -d -p 443:443 --name reverse-proxy \
--network ${NETWORK_NAME} \
--restart unless-stopped \
-e EC2_INSTANCE_ID=${EC2_INSTANCE_ID} \
-e NOTEBOOK_HOST=${NOTEBOOK_CONTAINER_NAME} \
-e AWS_REGION=us-east-1 \
-e SERVICE_CATALOG_PREFIX=service-catalog/synapse/cred \
-e SSM_PARAMETER_SUFFIX=oidc-accesstoken \
ghcr.io/sage-bionetworks/notebook-reverse-proxy-jupyter:main

```

Then run the notebook on the same network:

```
mkdir /home/ssm-user/workdir
sudo chmod 777 /home/ssm-user/workdir

sudo docker run -d --name ${NOTEBOOK_CONTAINER_NAME} \
--restart unless-stopped \
-e DOCKER_STACKS_JUPYTER_CMD=notebook \
-v /home/ssm-user/workdir:/home/jovyan/workdir \
--network proxy-net quay.io/jupyter/base-notebook \
start-notebook.py --IdentityProvider.token='' --NotebookApp.base_url=/${EC2_INSTANCE_ID} \
--notebook-dir=/home/jovyan/workdir

```

### To run an RStudio notebook:


```
export EC2_INSTANCE_ID=...
export NOTEBOOK_CONTAINER_NAME=rstudio
export NETWORK_NAME=proxy-net

docker network create --driver bridge ${NETWORK_NAME}

docker run -d -p 443:443 --name reverse-proxy \
--network ${NETWORK_NAME} \
--restart unless-stopped \
-e EC2_INSTANCE_ID=${EC2_INSTANCE_ID} \
-e NOTEBOOK_HOST=${NOTEBOOK_CONTAINER_NAME} \
-e AWS_REGION=us-east-1 \
-e SERVICE_CATALOG_PREFIX=service-catalog/synapse/cred \
-e SSM_PARAMETER_SUFFIX=oidc-accesstoken \
ghcr.io/sage-bionetworks/notebook-reverse-proxy-rstudio:main

```

Then run the notebook on the same network:

```
mkdir /home/ssm-user/workdir
sudo chmod 777 /home/ssm-user/workdir

sudo docker run -d --name ${NOTEBOOK_CONTAINER_NAME} \
--restart unless-stopped \
--network proxy-net \
-e DISABLE_AUTH=true \
-v /home/ssm-user/workdir:/home/rstudio \
rocker/rstudio

```
