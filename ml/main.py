import io
import requests
from keras.models import load_model
from PIL import Image, ImageOps
import numpy as np
import tensorflow as tf
from flask import Flask, jsonify, request

THRESHOLD = 0.5

# メモリリーク検証用
#import sys
#import tracemalloc

# メモリリーク検証用
#tracemalloc.start()

def preprocess_image(img, target_size=(224, 224)):
    # 画像を読み込む
    img = img.resize(target_size)
    img_array = np.array(img)

    # 画像を前処理する
    img_array = img_array[np.newaxis, ...]

    return img_array

def predict(model, image):
    image_array = preprocess_image(image)

    # 予測を行う
    predictions = model.predict(image_array)
    predictions = predictions.flatten()
    predictions = tf.nn.sigmoid(predictions)

    score = predictions.numpy()[0]

    # 予測結果を0または1に変換
    predictions = tf.where(predictions < THRESHOLD, 0, 1)

    index = predictions.numpy()[0]

    return index, score

# Load the model
model = load_model("./ml/keras_model.h5", compile=False)

# Load the labels
class_names = open("./ml/labels.txt", "r").readlines()

app = Flask(__name__)

@app.route('/')
def index():
    image_url = request.args.get("image_url")
    response = requests.get(image_url)
    if response.status_code == 200:
        image = Image.open(io.BytesIO(response.content)).convert("RGB")
        index, score = predict(model, image)
        class_name = class_names[index][2:].strip()
        data = {
                "status": "ok",
                "class_name": class_name,
                "score": float(score)
                }
        return jsonify(data), 200
    elif response.status_code == 404:
        data = {
                "status": "error",
                "message": "image not found"
                }
        return jsonify(data), 422
    else:
        data = {
                "status": "error",
                "message": "invalid image url"
                }
        return jsonify(data), 422

# メモリリーク検証用
#@app.route('/tm')
#def tm():
#    snapshot = tracemalloc.take_snapshot()
#    top_stats = snapshot.statistics('lineno')
#    for stat in top_stats[:10]:
#        print(stat)
#    print("")
#    sys.stdout.flush()
#    return "ok"
