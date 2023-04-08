import numpy as np
import os
import tensorflow as tf
#import tensorflow.keras as keras
import keras

TEST_EPOCHS = 128
BATCH_SIZE = 32
#THRESHOLD = 0.3
THRESHOLD = 0.5

def predict_and_count_on_batch(image_batch, label_batch):
    predictions = model.predict_on_batch(image_batch)
    #print(predictions)
    
    predictions = predictions.flatten()
    #print(predictions)
    
    # Apply a sigmoid since our model returns logits
    predictions = tf.nn.sigmoid(predictions)
    #print(predictions)
   
    # 片方のクラスの判定をゆるくするときはここを変更する
    predictions = tf.where(predictions < THRESHOLD, 0, 1)
    
    print('Predictions:\n', predictions.numpy())
    print('Labels:\n', label_batch)
    notsulemio_count = np.count_nonzero(predictions.numpy() == 0)
    sulemio_count = np.count_nonzero(predictions.numpy() == 1)
    print('notsulemio count:', notsulemio_count)
    print('sulemio count:', sulemio_count)

    return notsulemio_count, sulemio_count

data_dir = './train_data'

IMG_SIZE = (224, 224)

dataset = tf.keras.utils.image_dataset_from_directory(data_dir,
                                                            shuffle=True,
                                                            batch_size=BATCH_SIZE,
                                                            image_size=IMG_SIZE)

# データセットからクラス0のデータのみを含むデータセットを作成
class_0_dataset = dataset.unbatch().filter(lambda images, labels: tf.equal(labels, 0)).batch(BATCH_SIZE)

# データセットからクラス1のデータのみを含むデータセットを作成
class_1_dataset = dataset.unbatch().filter(lambda images, labels: tf.equal(labels, 1)).batch(BATCH_SIZE)

# データセットの内容を確認（オプション）
for images, labels in class_1_dataset.take(1):
    print("Images shape: ", images.shape)
    print("Labels: ", labels.numpy())

class_names = dataset.class_names

model = keras.models.load_model("./ml/keras_model.h5", compile=False)

epochs = TEST_EPOCHS

sum_for_notsulemio_notsulemio_count = 0
sum_for_notsulemio_sulemio_count = 0

# for notsulemio
for i in range(epochs):
    print('')
    print('epoch:', i)
    image_batch, label_batch = class_0_dataset.as_numpy_iterator().next()
    notsulemio_count, sulemio_count = predict_and_count_on_batch(image_batch, label_batch)
    sum_for_notsulemio_notsulemio_count += notsulemio_count
    sum_for_notsulemio_sulemio_count += sulemio_count

sum_for_sulemio_notsulemio_count = 0
sum_for_sulemio_sulemio_count = 0

# for sulemio
for i in range(epochs):
    print('')
    print('epoch:', i)
    image_batch, label_batch = class_1_dataset.as_numpy_iterator().next()
    notsulemio_count, sulemio_count = predict_and_count_on_batch(image_batch, label_batch)
    sum_for_sulemio_notsulemio_count += notsulemio_count
    sum_for_sulemio_sulemio_count += sulemio_count

print('')
print('sum_for_notsulemio_notsulemio_count:', sum_for_notsulemio_notsulemio_count)
print('sum_for_notsulemio_sulemio_count:', sum_for_notsulemio_sulemio_count)
print('notsulemio accuracy:', sum_for_notsulemio_notsulemio_count / (sum_for_notsulemio_notsulemio_count + sum_for_notsulemio_sulemio_count))

print('')
print('sum_for_sulemio_notsulemio_count:', sum_for_sulemio_notsulemio_count)
print('sum_for_sulemio_sulemio_count:', sum_for_sulemio_sulemio_count)
print('sulemio accuracy:', sum_for_sulemio_sulemio_count / (sum_for_sulemio_notsulemio_count + sum_for_sulemio_sulemio_count))
