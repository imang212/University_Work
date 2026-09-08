import numpy as np
import matplotlib.pyplot as plt
import scipy as sp

noise=10
x=np.linspace(0,20,4)
x=np.sort(x)
y= (4*x + 5) + noise*np.random.normal(size=len(x)) # rovnice y=4*x + noise
plt.scatter(x,y,label="nahodne body")
plt.grid()

#pip install qpsolvers
from qpsolvers import solve_qp
# parametry C a epsilon
C=1
epsilon=1
# generovani matic vektor neznamych v notaci x = [w,b,ksip_1, ksip_2..., ksim_1, ksim_2,...] celkem 2+2*pocet bodu
n = len(x) # pocet datovych bodu
# matice P
P=np.zeros((2+2*n,2+2*n)) #matice pro ucelovou funkci
P[0,0]=1 # zde je jednicka pro w
# vektor q - linearni cast ucelove funkce
q=C*np.ones((2+2*n,1))
q[0]=0
q[1]=0

# matice linearnich omezeni
G = np.zeros((2*n,2+2*n))
G[:n,0]=x
G[n:,1]=-x
G[:n,1]=np.ones(n)
G[n:,1]=-np.ones(n)
G[:n,2:n+2]=-np.eye(n)
G[:n,n+2:]=-np.eye(n)

# prave strany linearnich omezeni
h=np.ones(2*n)
h[:n]=y+epsilon
h[n:]=-y+epsilon

print(f"P>{P.shape}"); print(f"q>{q.shape}"); print(f"G>{G.shape}"); print(f"h>{h.shape}")

sol = solve_qp(P, q, G, h, solver="cvxopt")
print(sol)