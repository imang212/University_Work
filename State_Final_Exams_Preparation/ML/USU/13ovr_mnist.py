import numpy as np
import numpy.linalg as la # pro vypocet normy
import scipy.optimize as optimize # pro vypocet minima kriterialni funkce

class naivni_logisticka_regrese_binarni:
  def __init__(self):
    self._w = None
    self._X = None
    self._y = None
    self._regularization=False
    self._c=0.01

  def sigmoida(self, w, X):
    """
    Pomocna metoda pro vypocet sigmoidy
    """
    return 1.0/(1.0+np.exp(-X @ w))

  def kriterialni_funkce_bez_regularizace(self, w):
    """
    Minimalizovana funkce
    """
    #return la.norm(self._y-self.sigmoida(w, self._X))
    return -(self._y.T @ np.log(self.sigmoida(w, self._X)+1e-10) + (1-self._y).T @ np.log(1-self.sigmoida(w, self._X)+1e-10)) # TODO regulariyace

  def kriterialni_funkce_s_regularizaci(self, w):
    """
    Minimalizovana funkce:
    """
    return self.kriterialni_funkce_bez_regularizace(w)+self._c*np.sum(w**2)

  def fit(self, X,y, c = 0.001, regularization=False):
    """
    Nauceni modelu. Pro uceni je vyuzita knihovna scipy a nastroje pro
    optimalizaci v ni obsazene.
    """
    self._regularization=regularization
    self._c=c
    dimenze = X.shape[1]+1
    radky = X.shape[0]
    # priprav si data - pridani sloupce se jednickami, pro bias
    self._X = np.hstack((np.ones((radky,1)), X)) # pridej jednicky
    self._y = y
    # je pouzita iteracni metoda optimalizace, nahodne je zvolena nulta iterace
    w0 = np.random.randn(dimenze) # nahodny bod
    self._w=w0
    print(f"Pocatecni hodnota krit. fce {self.kriterialni_funkce_bez_regularizace(w0)}")
    #print(f"Pocatecni hodnota vah w={w0}")
    if self._regularization:
      res = optimize.minimize(self.kriterialni_funkce_s_regularizaci, w0, method='BFGS', tol=1e-8)
    else:
      res = optimize.minimize(self.kriterialni_funkce_bez_regularizace, w0, method='BFGS', tol=1e-8)
    #res = optimize.minimize(self.kriterialni_funkce, w0, method='BFGS', tol=1e-5)
    self._w = res.x
    print(f"Konecna hodnota krit. fce {self.kriterialni_funkce_bez_regularizace(self._w)}")
    #print(f"Konecna hodnota vah w={self._w}")
    return self._w

  def predict_proba(self, X):
    """
    Vypocet pravdepodobnosti prislusnosti ke tride
    """
    return self.sigmoida(self._w, np.hstack((np.ones((X.shape[0],1)), X)))

  def predict(self, X, hranice=0.5):
    """
    Predikce konkretni tridy na zaklade pravdepodobnosti.
    """
    pravdepodobnost = self.predict_proba( X)
    return  1* (pravdepodobnost > hranice)

class ovr_classifier:
  def __init__(self):
    self._models=[]
    self._classes=[]

  def fit(self, X, y, c=0.01, regularization=True):
    self._classes=np.unique(y)
    for cls in self._classes:
      classifier = naivni_logisticka_regrese_binarni()
      ycls=1*(y==cls)
      classifier.fit(X,ycls,c=c,regularization=regularization)
      self._models.append(classifier)
  def predict(self, X):
    predictions=np.array([ model.predict_proba(X) for model in self._models])
    return self._classes[np.argmax(predictions, axis=0)]

from sklearn import datasets, metrics
from sklearn.model_selection import train_test_split

digits = datasets.load_digits()
n_samples = len(digits.images)
print(f"Pocet vzorku {n_samples}")
data = digits.images.reshape((n_samples, -1))/255 # reshape a normalizuj
X_train, X_test, y_train, y_test = train_test_split(data, digits.target, test_size=0.2, shuffle=False)

ovr = ovr_classifier()
ovr.fit(X_train, y_train, c=0.01, regularization=True)
y_pred = ovr.predict(X_test)

print()
print(f"LOG-REG:{metrics.classification_report(y_test, y_pred)}\n")

from sklearn.metrics import confusion_matrix,  ConfusionMatrixDisplay
disp = metrics.ConfusionMatrixDisplay.from_predictions(y_test, y_pred)
disp.figure_.suptitle("Confusion Matrix LOG REG")
#disp.plot()

def knn_klasifikuj(X,y,x, k=3):
  """
  :param X: vstupni matice prvku, kazdy radek je jeden zaznam - trenovaci data
  :param y: labely trenovacich dat
  :param x: prvek ktery chceme klasifikovat
  :param k: počet sousedů
  :return: cislo tridy
  """
  def vzdalenost(x,y):
    return np.sum((x-y)**2)

   # urceni tabulky vzdalenosti - ulozime vzdalenost od x a label pro kazdy prvek z X
  tabulka = np.array([(vzdalenost(x,radek), label) for radek, label in zip(X[:],y)])
  # nalezeni k-nejblizsich prvku. Podobny algoritmus jako pro selection sort.
  for krok in range(k):
    index = np.argmin(tabulka[krok:,0], axis=0)+krok
    tabulka[[krok, index]]  =  tabulka[[index, krok]]
  # urceni cetnosti labelu pro k nejblizsich sousedu - prvnich k v tabulce
  cetnosti = {}
  for label in tabulka[:k,1]:  # jed jen pres sloupecek labelu
    if label in cetnosti:
      cetnosti[label] += 1
    else:
      cetnosti[label] = 1
  # vrat klic prislusejici nejcetnejsi hodnote
  return int(sorted(cetnosti.items(), key = lambda kv: kv[1])[-1][0])

y_pred_knn = [knn_klasifikuj(X_train,y_train,prvek) for prvek in X_test]
print(f"KNN:{metrics.classification_report(y_test, y_pred_knn)}\n")

from sklearn.metrics import confusion_matrix,  ConfusionMatrixDisplay
disp = metrics.ConfusionMatrixDisplay.from_predictions(y_test, y_pred_knn)
disp.figure_.suptitle("Confusion Matrix KNN")