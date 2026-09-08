
import numpy as np
from cvxopt import matrix, solvers
import matplotlib.pyplot as plt

def create_model_SVR_primary(X, y, C=10.0, eps=1):
    """generuje matice pro knihovnu CVXOPT pro reseni SVR problemu"""
    m, n = X.shape  # zjisti si rozmery
    # m - pocet bodu
    # n - dimenze
    # generovani matic a vektoru pro ucelovou funkci
    # generovani matice P - pro resic vstupuje jako matice prislusne kvadraticke formy
    P = np.zeros((n + 1 + 2 * m, n + 1 + 2 * m))
    for i in range(0, n):
        P[i, i] = 1  # prepis 1 na diagonalu pro hodnoty w
    # generovani vektoru q - vektor s koeficienty pro linearni cast ucelove funkce
    q = C * np.ones(n + 1 + 2 * m)  # linearni clen v ucelove funkci soucet ksi
    q[:n + 1] = 0  # nastav na nulu pozice w a b ve vektoru q
    # generovani omezujicich podminek
    h = np.concatenate((np.zeros((2 * m, 1)), np.zeros((2 * m, 1))))
    G = np.zeros((4 * m, n + 1 + 2 * m))
    for i, (x, y) in enumerate(zip(X, y)):  # pres vsechny datove body
        # prvni omezeni
        G[i, :n] = x  # sloupce odpovidajici w
        G[i, n] = 1.  # sloupec odpovidajici b
        G[i, n + 1 + i] = -1.  # sloupec ksi+
        h[i] = y + eps
        # druhe omezeni
        G[i + m, :n] = -x  # sloupce odpovidajici w
        G[i + m, n] = -1.  # sloupec odpovidajici b
        G[i + m, n + 1 + i + m] = -1.  # sloupec ksi-
        h[i + m] = -y + eps
        # podminky nezapornosti ksi+
        G[i + 2 * m, n + 1 + i] = -1.
        # podminky nezapornosti ksi-
        G[i + 3 * m, n + 1 + i + m] = -1.

    print(f"P:{P.shape}"); print(f"q:{q.shape}"); print(f"G:{G.shape}"); print(f"h:{h.shape}")
    return matrix(P), matrix(q), matrix(G), matrix(h)

def get_points(n, f=lambda x: 4 * x + 2, a=0, b=10, noise=2):
    x = a + (b - a) * np.random.rand(n)
    y = f(x) + np.random.rand(n) * noise
    return np.array(x).reshape((n, 1)), np.array(y)

"""# Ukazka pro linearni data"""
X, y = get_points(100, noise=10)
P, q, G, h = create_model_SVR_primary(X, y); print(np.array(P).shape)
sol = solvers.qp(P, q, G, h)  # zavolani resice
w = np.array([sol['x'][0]])
b = np.array([sol['x'][1]])
y_hat = (X @ w + b)
plt.scatter(X, y,label="Data")
plt.scatter(X, y_hat, label="Model")
plt.legend(); plt.grid(); plt.show()

"""#Úloha obsahující nelineární data
Protože používám primární formulaci SVR, tak nepoužívám jádrový trik, ale přímo nelineární transformaci.
"""
X, y = get_points(200, f=lambda x: x * np.cos(2 * x + 5))  # nelinearni data
# toto je nelinearni transformace - nekernelova, pomoci polynomu
X_tr = np.array([X, X ** 2, X ** 3, X ** 4, X ** 5, X ** 6, X ** 7, X ** 8, X ** 9]).squeeze(axis=2).transpose()
dim = X_tr.shape[1]; print(X_tr.shape)
P, q, G, h = create_model_SVR_primary(X_tr, y, C=1e3)
sol = solvers.qp(P, q, G, h)  # zavolani resice
result = np.array(sol["x"])
w = result[:dim].flatten() # vezmi si vahy z reseni
b = result[dim]
y_hat = (X_tr @ w + b) # spocti linearni kombinaci vah a hodnot X

plt.scatter(X, y, label="Data")
plt.scatter(X, y_hat, label="Model")
plt.legend(); plt.grid(); plt.show()