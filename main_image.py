#! /usr/bin/python3

import boto3 
import botocore.session
import base64
import sys
from datetime import datetime
import json
import io
from PIL import Image
from datetime import datetime


# Create a session using the default credentials
bedrock = boto3.client('bedrock-runtime', region_name='us-east-1')


body = json.dumps({
    "taskType": "TEXT_IMAGE",
    "textToImageParams": {
    "text": sys.argv[1],
    },
    "imageGenerationConfig": {
    "numberOfImages": 1,
    "height": 1024,
    "width": 1024,
    "cfgScale": 8.0,
    "seed": 0
    }
})

accept = "application/json"
content_type = "application/json"
name =  datetime.now().strftime('%H%M%S')
response = bedrock.invoke_model(body=body, modelId="amazon.titan-image-generator-v1", accept=accept, contentType=content_type)
response_body = json.loads(response.get("body").read())

base64_image = response_body.get("images")[0]
base64_bytes = base64_image.encode('ascii')
image_bytes = base64.b64decode(base64_bytes)
image = Image.open(io.BytesIO(image_bytes))
image_path = sys.argv[2] + "/" + name+".png"
image.save(image_path)

