from sklearn.datasets import make_blobs
import matplotlib.pyplot as plt
# generování bodů
X, y = make_blobs(n_samples=500, centers=5, n_features=2, random_state=0)
print(y)
plt.scatter(X[:,0],X[:,1], c = y)
plt.grid(); plt.title("Body různých tříd v prostoru příznaků"); plt.show()

import numpy as np
def L2(x,y): return np.sqrt((x-y) @ (x-y))
def L1(x,y): return np.sum(np.abs(x-y))

x=np.array([1,2,3]); y=np.array([0,1,4])

print(f"L2: {L2(x,y)}"); print(f"L1: {L1(x,y)}")

def shlukuj(X,k,vzdalenost=L2, TOL=1e-3, MAXITER=50):
  # inicializace
  dim = X.shape[1] # dimenze ulohy
  teziste = np.random.rand(k,dim) #minima+(maxima-minima)*np.random.rand(k,dim) # prenes si to do meritka
  teziste_nove=np.zeros((k,dim))#pomocne pole pro ulozeni tezist
  kampatri = [0 for i in range(X.shape[0])]
  # iteruj
  for iterace in range(MAXITER):
    # ------prirad body tezisti------------
    for index, bod in enumerate(X):
      nejblizsi = 0
      rnejblizsi = vzdalenost(bod, teziste[nejblizsi,:]) # spocti vzdalenost od prvniho teziste
      for i in range(1,k): #pocitej pro vsechny dalsi
        r = vzdalenost(bod,teziste[i,:])
        if rnejblizsi > r :
          rnejblizsi = r
          nejblizsi = i
      kampatri[index] = nejblizsi  # zapamatuj si nejblizsi teziste k danemu bodu
    # ------------ spocti nova teziste ------------------
    teziste_nove = np.zeros((k,dim))
    for i in range(k): # pro kazde teziste delej
      n = 0
      for index, bod in enumerate(X): # prochazej body
        if kampatri[index] == i: # kdyz to patri danemu tezisti
            teziste_nove[i,:]+=bod
            n+=1
      if n > 0:
        teziste_nove[i,:]=teziste_nove[i,:]/n

    # vypocet posunu:
    posun = np.array([vzdalenost(teziste[i], teziste_nove[i]) for i in range(k)]).sum()
    print(f"Posun v iteraci {iterace}::{posun}")
    if posun < TOL :
      break
    teziste=teziste_nove
  # konec iteraci
  print("HOTOVO ")
  return kampatri

#X[:,1] = X[:,1]*100
print(X.shape)
clustery=shlukuj(X,k=5, vzdalenost=L1)
plt.scatter(X[:,0],X[:,1], c = clustery)

"""# KMEANS vs obrazek"""
from sklearn.cluster import KMeans
from PIL import Image
import numpy as np
image = Image.open('P9010058.JPG')

data=np.array(image)/255
height=data.shape[0]
width=data.shape[1]
print(data.shape)
X=data.reshape(height*width,3)
print(X.shape)
print(X[0])

index  = np.random.randint(X.shape[0], size=10000)

kmeans = KMeans(n_clusters=64, random_state=0, n_init="auto").fit(X[index])

cluster_ids=kmeans.predict(X)

centers = kmeans.cluster_centers_
XX=np.zeros(X.shape)
for i in range(XX.shape[0]):
  XX[i]=centers[cluster_ids[i]]

print(XX[:10]); print(X[:10])

import matplotlib.pyplot as plt
plt.imshow(XX.reshape(height,width,3))
plt.imshow(X.reshape(height,width,3))