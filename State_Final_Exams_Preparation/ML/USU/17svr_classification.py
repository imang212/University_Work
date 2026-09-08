import numpy as np
import matplotlib.pyplot as plt

import random
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

from sklearn.svm import SVC
from sklearn.metrics import accuracy_score

import cvxopt
from cvxopt import matrix, solvers
import numpy as np

def create_model_SVM_softm_primary(X, y, C=1):
    n,dim=X.shape #zjisti si rozmery
    P = np.zeros((dim+1+n,dim+1+n)) # generovani matic a vektoru pro ucelovou funkci, generovani matice P - pro resic vstupuje jako matice prislusne kvadraticke formy
    for i in range(0, dim): P[i,i]=1 # prepis 1 na diagonalu pro hodnoty w
    # generovani vektoru q - vektor s koeficienty pro linearni cast ucelove funkce
    q = C*np.ones(dim+1+n) # linearni clen v ucelove funkci soucet ksi
    q[:dim+1] = 0 #nastav na nulu pozice w a b ve vektoru q

    h = np.concatenate((-1*np.ones((n,1)), np.zeros((n,1)))) # generovani omezujicich podminek

    G = np.zeros((2*n, n+dim+1))
    for i,(x,y) in enumerate(zip(X,y)):
      G[i,:dim] = -y*x # sloupce odpovidajici w
      G[i,dim] = -y  # sloupec odpovidajici b
      G[i,dim+1+i] = -1
      G[i+n,dim+1+i] = -1
    print(f"P:{P.shape}"); print(f"q:{q.shape}"); print(f"G:{G.shape}"); print(f"h:{h.shape}")
    return matrix(P), matrix(q), matrix(G), matrix(h)

X = [ i for i in range(20)]
y = [ i+5*random.random() for i in X]
y[7] = 20; y[12] = 1
plt.scatter(X,y); plt.grid(); plt.title("Body různých tříd v prostoru příznaků"); plt.show()

def line_function(x): return x + 3
threshold = np.mean(y)
y_classes = np.array([1 if val > threshold else -1 for val in y])

X_matrix = np.column_stack((np.array(X), np.zeros(len(X))))

P, q, G, h = create_model_SVM_softm_primary(X_matrix,y, C = 1) # vygeneruj si matice modelu
sol = solvers.qp(P, q, G, h) # volej rešič
w = sol['x']

#vizualizace výsledků
left = np.min(X_matrix, axis = 0); right = np.max(X_matrix, axis = 0)

xgr = np.linspace(left[0], right[0],100)
ygr = -(w[0]*xgr + w[2])/w[1]
ygr_p1 = -(w[0]*xgr + w[2]+1)/w[1]
ygr_m1 = -(w[0]*xgr + w[2]-1)/w[1]

w0 = float(w[0]); w1 = float(w[1]); b = float(w[2])

plt.figure(figsize=(12, 8))
plt.scatter(X, y, c=y_classes, cmap='coolwarm', s=80, edgecolors='k')
margin_width = 1e-5; support_indices = []
for i in range(len(X_matrix)):
    margin = y_classes[i] * (w0*X_matrix[i,0] + w1*X_matrix[i,1] + b)
    if abs(margin - 1) < margin_width: support_indices.append(i)

plt.scatter([X[i] for i in support_indices], [y[i] for i in support_indices], s=100, linewidth=1, facecolors='none', edgecolors='k')
plt.plot(X, [line_function(x) for x in X], 'g--', label='Original separation')

x_range = np.linspace(min(X), max(X), 100)
if w0 != 0:
    y_boundary = [-1 * (w0*x + w1*(x**2) + b) for x in x_range]
    plt.plot(x_range, y_boundary, 'r-', label='SVM decision boundary')

plt.axhline(y=threshold, color='g', linestyle='--', linewidth=1, label=f'Original Threshold (y={threshold:.2f})')

xi_values = [float(w[3+i]) for i in range(len(X_matrix))]
for i, (x_val, y_val, xi) in enumerate(zip(X, y, xi_values)):
    if xi > 0.01:  # Only show significant slack variables
        plt.annotate(f'ξ={xi:.2f}', (x_val, y_val), xytext=(5, 5), textcoords='offset points', fontsize=9, bbox=dict(boxstyle="round,pad=0.3", fc="yellow", alpha=0.7))

plt.grid(True); plt.title("SVM with Soft Margin (C=1) in Original Data Space")
plt.xlabel("X"); plt.ylabel("y"); plt.legend(loc='best'); plt.tight_layout(); plt.show()

