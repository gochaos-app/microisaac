#! /usr/bin/python3

import boto3 
import botocore.session
import sys
import json
from datetime import datetime


# Create a session using the default credentials
bedrock = boto3.client('bedrock-runtime', region_name='us-east-1')

body = {
    "prompt": sys.argv[1],
    "temperature": 0.8,
    "topP": 0.9,
    "maxTokens": 200,
}
filepath = sys.argv[2] + "/data.json"
filetext = sys.argv[2] + "/data.txt"
response_bd = bedrock.invoke_model(body=json.dumps(body), modelId="ai21.j2-ultra-v1")
response_content = response_bd.get('body').read().decode('utf-8')
response_data = json.loads(response_content)
response = response_data["completions"][0]["data"]["text"]

test = [{'prompt' : sys.argv[1], 'response': response}]
with open(filetext, 'a+') as f:
    f.write("Prompt: " + sys.argv[1] + "\n")
    f.write("Response: " + response[1:] + "\n")
    
with open(filepath, 'a+') as f:
    for item in test:
        f.write(json.dumps(item) + "\n")



