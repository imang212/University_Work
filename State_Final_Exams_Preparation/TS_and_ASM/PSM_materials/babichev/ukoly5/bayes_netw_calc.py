# Skript pro výpočet apriorních a podmíněných pravděpodobností
def calculate_probabilities():
    # Apriorní pravděpodobnosti
    P_Guest = 1/3; P_Treasure = 1/3
    # Podmíněné pravděpodobnosti
    P_Host_given_Treasure = { (0, 0): 0.5, (0, 1): 1.0, (0, 2): 0.0,}
    # Výpočet pravděpodobností - čitatel pro jednotlivé varianty
    P0 = P_Guest * P_Treasure * P_Host_given_Treasure[(0, 0)]
    P1 = P_Guest * P_Treasure * P_Host_given_Treasure[(0, 1)]
    P2 = P_Guest * P_Treasure * P_Host_given_Treasure[(0, 2)]
    return P0, P1, P2

P0, P1, P2 = calculate_probabilities()
print(f"P0 = {P0}, P1 = {P1}, P2 = {P2}")
