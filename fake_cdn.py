from flask import Flask, send_file
from flask import request
from flask_cors import CORS, cross_origin
from werkzeug.utils import secure_filename
from datetime import datetime
import os, json, time, random, io

app = Flask(__name__)
cors = CORS(app)

file_path = os.path.realpath(__file__)
cdn_path = os.path.join(os.path.abspath(os.path.join(file_path, os.pardir)),"fake_cdn")

if not os.path.isdir(cdn_path):
    os.mkdir(cdn_path)

@app.route("/")
@cross_origin()
def home():
    return f"<p>hiya! youve reached the fake cdn server! leave a message after the beep :3"

@app.route("/api/v4/upload", methods=['POST'])
@cross_origin()
def upload():
    auth = request.headers.get("Authorization")
    if not auth or not "Bearer " in auth:
        return {"error":"invalid auth"}
    file = request.files.get("file")
    if not file:
        return {"error":"Missing file parameter"}
    letters = "abcdefgh1234567890"
    file_id = "".join([random.choice(letters) for d in range(10)])
    name = secure_filename(file.filename)
    file.save(os.path.join(cdn_path,file_id+name))
    
    base_url =request.url_root
    response = {
        "id": file_id,
        "filename": name,
        "size": 12345, # the hackvertisements server doesnt use this anyways soo...
        "content_type": file.content_type,
        "url": base_url+"files/"+file_id+"/"+name,
        "created_at": "2026-01-29T12:00:00Z" # this isnt used either so wont bother adding it
    }
    return response


@app.route("/files/<file_id>/<name>")
@cross_origin()
def get(file_id,name):
    path = os.path.join(cdn_path,file_id+name)
    if not os.path.isfile(path):
        return "file not found"
    with open(path,"rb") as f:
        response = send_file(
            io.BytesIO(f.read()),
            mimetype='image/jpg'
        )
    return response


if __name__ == "__main__":
    app.run(host="0.0.0.0",port=5462)
