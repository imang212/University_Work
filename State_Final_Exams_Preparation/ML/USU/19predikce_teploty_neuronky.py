import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error


import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.Layers import Dense, Dropout
from tensorflow.keras.optimisers import Adam

train_data, test_data = tf.keras.datasets.mnist.load_data()
X_tr,y_tr = train_data
X_test,y_test = test_data
print(f'{X_tr.shape}')
print(f'{y_tr.shape}')
print(f'{X_test.shape}')
print(f'{y_test.shape}')
fig, axs = plt.subplots(1, 9, figsize=(15, 3))
for index, ax in enumerate(axs):
  ax.imshow(X_tr[index],cmap='gray')
plt.show()



def get_model():
  model = models.Sequential()
  model.add(layers.Dense(units = 32, input_shape = (784,) , activation = 'relu'))
  model.add(layers.Dropout(0.1))
  model.add(layers.Dense(units = 32, activation='relu'))
  model.add(layers.Dense(CATEGORIES, activation='softmax'))
  model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])
  return model


EPOCHS = 20
model = get_model()
history = model.fit(X_tr_vec, y_tr_cat, epochs=EPOCHS, validation_split=0.1)

plt.rcParams["figure.figsize"] = [12,4]
figure, axis = plt.subplots(1, 2)

axis[0].plot(history.history['loss'], label='loss - training data')
axis[0].plot(history.history['val_loss'], label='loss - validating data')
axis[0].grid()
axis[0].set_title('Loss')
axis[0].legend()



axis[1].plot(history.history['accuracy'], label='accuracy - training data')
axis[1].plot(history.history['val_accuracy'], label='accuracy - validating data')
axis[1].grid()
axis[1].set_title('Accuracy')
axis[1].legend()
