from flask import Flask, jsonify, request, Response, send_file, send_from_directory
from models import db, Employee, Change
from sqlalchemy import select
from typing import Sequence
import json
import urllib.parse
from helpers import Sync
from pathlib import Path
import platform
import os

app = Flask(__name__)
if platform.system() == "Linux":
    UPLOAD_DIR = Path("/home/phyoekyawthan/Documents")
    app.config['UPLOAD_DIR'] = "/home/phyoekyawthan/Documents"
else:
    UPLOAD_DIR = Path("D:/uploads")
    app.config['UPLOAD_DIR'] = "D:/uploads"
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
raw_password = "domak90@"
PASSWORD = urllib.parse.quote_plus(raw_password)
app.config['SQLALCHEMY_DATABASE_URI'] = f"mysql+pymysql://domak:{PASSWORD}@127.0.0.1/employee_records"
db.init_app(app = app)
with app.app_context():
    db.create_all()

def toDictObject(changes: Sequence[Change]) -> list[dict]:
    changes_list: list[dict] = []
    for ch in changes:
        changes_list.append(ch.to_dict())
    return changes_list

@app.route("/")
def home() -> Response:
    return jsonify({
        "status" : True,
        "message": "Hi",
        "platform": platform.system(),
        "acknowledgement" : "open_sesame",
        # "upload_dir": app.config['UPLOAD_DIR'],
        "url": request.host_url.rstrip('/'),
    }), 200
    
@app.route("/make_sync", methods=['POST'])
def make_sync():
    # changes from mysql db
    mysql_changes = db.session.execute(select(Change)).scalars().all()
    if request.method == "POST":
        images = request.files.getlist('files[]')
        json_path = request.files.get('json_data')
        changes_data = json_path.read()
        if json_path and len(changes_data) > 0:
            changes_data = json.loads(changes_data)
            sync = Sync(changes_data, images, app.config['UPLOAD_DIR'])
            sync.apply_changes()
            
            return jsonify({
                "status": True,
                "data_provided_from_android": True,
                "has_changes": len(mysql_changes) > 0,
                "changes": toDictObject(mysql_changes)
            }), 200
        if len(mysql_changes) > 0:
            db.session.query(Change).delete()
            db.session.commit()
            return jsonify({
                "status": True,
                "data_provided_from_android": False,
                "has_changes": len(mysql_changes) > 0,
                "changes": toDictObject(mysql_changes)
            }), 200
        return jsonify({
            "message": "Json file didn't provided",
            "status": False,
            "has_changes": len(mysql_changes) > 0
        }), 400
    return jsonify({
        "message": "Method Not Allowed",
        "status": False
    }), 405
        
@app.route("/sync", methods=['POST'])
def get_employees() -> Response:
    if request.method == 'POST':
        changes = request.get_json()
        sync = Sync(changes)
        sync.apply_changes()
        return jsonify({
            "status" : True,
            "message" : "Synced Successfully!"
        })
    return jsonify({
        "status": False,
        "message": "Wrong request method"
    })
    
@app.route("/uploads/<path:name>")
def download_file(name):
    return send_from_directory(
        app.config['UPLOAD_DIR'], name, as_attachment=True
    )  
    
@app.route("/write", methods=['POST'])
def image_writer():
    if request.method == 'POST':
        if 'image' in request.files:
            image = request.files['image']
            try:
                image.save(os.path.join(app.config['UPLOAD_DIR'], image.filename))
                return jsonify({
                    "status" : True,
                    "message": f"Image {image.filename} uploaded"
                })
            except Exception as e:
                return jsonify({
                    "status" : False,
                    "message": "Somthing wrong while uploading image",
                    "err" : str(e)
                })
        
# @app.route("/image/<filename>")
# def image_serve(filename: str):
#     import os
#     path = os.path.join(app.config['UPLOAD_DIR'] , filename)
#     if Path.exists(path):
#         return send_file(path)