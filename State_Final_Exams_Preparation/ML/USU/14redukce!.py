import pandas as pd
import numpy as np

data_url = "http://lib.stat.cmu.edu/datasets/boston"
raw_df = pd.read_csv(data_url, sep="\s+", skiprows=22)

raw_df.dropna(inplace=True)
raw_df.head()

X = raw_df.iloc[:, :-1]; y = raw_df.iloc[:, -1]

from sklearn.preprocessing import MinMaxScaler
scaler = MinMaxScaler()
Xn = scaler.fit_transform(X)

import numpy as np
beta = np.linalg.solve(Xn.T@Xn, Xn.T@y)
print(beta)

import statsmodels
from statsmodels.regression.linear_model import OLS
print(y.shape)
print(Xn.shape)
model = OLS(y, Xn)
results = model.fit()
print(results.summary())