import io
import requests
from keras.models import load_model  # TensorFlow is required for Keras to work
from PIL import Image, ImageOps  # Install pillow instead of PIL
import numpy as np
from flask import Flask, jsonify, request

# メモリリーク検証用
#import sys
#import tracemalloc

# メモリリーク検証用
#tracemalloc.start()

def predict(model, image):
    # Disable scientific notation for clarity
    np.set_printoptions(suppress=True)

    # Create the array of the right shape to feed into the keras model
    # The 'length' or number of images you can put into the array is
    # determined by the first position in the shape tuple, in this case 1
    data = np.ndarray(shape=(1, 224, 224, 3), dtype=np.float32)

    # resizing the image to be at least 224x224 and then cropping from the center
    size = (224, 224)
    image = ImageOps.fit(image, size, Image.Resampling.LANCZOS)

    # turn the image into a numpy array
    image_array = np.asarray(image)

    # Normalize the image
    normalized_image_array = (image_array.astype(np.float32) / 127.5) - 1

    # Load the image into the array
    data[0] = normalized_image_array

    # Predicts the model
    # FIXME: model.predict() だとメモリリークする. 対策したが完全ではない
    #prediction = model.predict(data)
    prediction = model(data)
    index = np.argmax(prediction)
    confidence_score = prediction[0][index]

    return index, confidence_score

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
        #image = Image.open(io.BytesIO(requests.get(image_url).content)).convert("RGB")
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
