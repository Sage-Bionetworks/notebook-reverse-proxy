# notebook-reverse-proxy
Docker container with Apache reverse proxy for Service Catalog notebook product

### To run:

```
export EC2_INSTANCE_ID=...
export NOTEBOOK_CONTAINER_NAME=jupyter
export NETWORK_NAME=proxy-net

docker network create --driver bridge ${NETWORK_NAME}

docker run --rm -d -p 80:80 --name rp --network ${NETWORK_NAME} \
-e EC2_INSTANCE_ID=${EC2_INSTANCE_ID} \
-e NOTEBOOK_HOST=${NOTEBOOK_CONTAINER_NAME} \
-e AWS_REGION=us-east-1 \
-e SERVICE_CATALOG_PREFIX=service-catalog/synapse/cred \
-e SSM_PARAMETER_SUFFIX=oidc-accesstoken \
notebook-reverse-proxy

```

Then run the notebook on the same network, e.g.:

```
docker run --rm -d --name ${NOTEBOOK_CONTAINER_NAME} \
-e DOCKER_STACKS_JUPYTER_CMD=notebook \
--network ${NETWORK_NAME} quay.io/jupyter/base-notebook \
start-notebook.py --IdentityProvider.token='' --NotebookApp.base_url=/${EC2_INSTANCE_ID}

```