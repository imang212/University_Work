#Skript pro normalizaci a výpočet posteriorních pravděpodobností
from bayes_netw_calc import calculate_probabilities

def normalize_probabilities(P0, P1, P2):
    Z = P0 + P1 + P2  #vytvoření normalizační konstanty
    if Z == 0: return 0, 0, 0  #Ochrana proti dělení nulou
    #podle vzorce vydělíme vypočítané pravděpodobnosti normalizační konstantou
    P_T0 = P0 / Z
    P_T1 = P1 / Z
    P_T2 = P2 / Z
    return P_T0, P_T1, P_T2

P0, P1, P2 = calculate_probabilities() #výpočet pravděpodobností
P_T0, P_T1, P_T2 = normalize_probabilities(P0, P1, P2) #normalizace pravděpodobností

print(f"Posteriorní pravděpodobnosti:")
print(f"P(Treasure = 0 | Guest = 0, Host = 2) = {P_T0}")
print(f"P(Treasure = 1 | Guest = 0, Host = 2) = {P_T1}")
print(f"P(Treasure = 2 | Guest = 0, Host = 2) = {P_T2}")
