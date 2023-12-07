#!/usr/bin/env python3

##
## Expects these environmen variables:
## SYNAPSE_TOKEN_AWS_SSM_PARAMETER_NAME
## KMS_KEY_ALIAS
## AWS_REGION
## EC2_INSTANCE_ID
##

import jwt
import requests
import base64
import json
import boto3
import time
import functools
import os
from access_helpers import approved_user, store_to_ssm, jwt_payload
from mod_python import apache

AMZN_OIDC_HEADER_NAME = 'x-amzn-oidc-data'

SSM_PARAMETER_NAME = os.environ.get('SYNAPSE_TOKEN_AWS_SSM_PARAMETER_NAME')
SSM_KMS_KEY_ALIAS = os.environ.get('KMS_KEY_ALIAS')
AWS_REGION = os.environ.get('AWS_REGION')
EC2_INSTANCE_ID = os.environ.get('EC2_INSTANCE_ID')

def headerparserhandler(req):
  req.log_error("Entering handler")

  try:
    if not AMZN_OIDC_HEADER_NAME in req.headers_in:
        raise RuntimeError(f"Request lacks {AMZN_OIDC_HEADER_NAME} header.")
    jwt_str = req.headers_in[AMZN_OIDC_HEADER_NAME] # proxy.conf ensures this header exists
    req.log_error(f"jwt_str: {jwt_str}")
    payload = jwt_payload(jwt_str, req)
    req.log_error(f"userid: {payload['userid']}")

    if payload['userid'] == approved_user(req) and payload['exp'] > time.time():
      store_to_ssm(req.headers_in['x-amzn-oidc-accesstoken'])
      req.log_error("Saved access token")
      return apache.OK
    else:
      # the userid claim does not match the userid tag or the JWT is expired
      req.content_type = "text/plain"
      req.write("You are not permitted to access this resource.")
      req.status = apache.HTTP_FORBIDDEN
      return apache.DONE
  except Exception as e:
    # if the JWT is missing or payload is invalid
    if len(e.args)>0:
      req.content_type = "text/plain"
      req.write(f"{e.args[0]}\n")
      req.status = apache.HTTP_UNAUTHORIZED
    return apache.DONE
