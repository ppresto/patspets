# Start a server on a port
# Take in a number and picture type and return the picture 
import os
import glob
import random
from flask import Flask
from flask import send_file

# Defaults
NAME='dogs'
VERSION='1' 
PORT=8080
PIC_PATH='assets/pictures'
BIND_HOST='0.0.0.0'
BIND_PORT=8080

app = Flask(__name__)

@app.route('/healthz')
def healthz():
    return 'OK'

@app.route('/')
def index():
    path=PIC_PATH
    # Build path to service type
    service_type = os.environ.get('NAME', NAME)
    # If the supplied service type isn't found, use the default one
    try:
        os.listdir(os.path.join(PIC_PATH, service_type))
    except:
        print("NOTFOUND: Service Type: {}. Using Default".format(service_type))
        service_type=NAME
    path = os.path.join(path, service_type)

    # Build path to service version
    service_version = os.environ.get('VERSION', VERSION)
    # Check the "version" folder exists
    try:
        os.listdir(os.path.join(path, service_version))
    except:
        print("NOTFOUND: Service Version: {}. Using Default".format(service_version))
        service_version=VERSION
    path=os.path.join(path, service_version)

    # Choose a random image and return it
    image = random.choice(os.listdir(path))
    image_path = os.path.join(path, image)
    return send_file(image_path)

if __name__ == '__main__':
    host = os.environ.get('BIND_HOST', BIND_HOST)
    port = os.environ.get('BIND_PORT', BIND_PORT)
    app.run(host=host, port=port)
