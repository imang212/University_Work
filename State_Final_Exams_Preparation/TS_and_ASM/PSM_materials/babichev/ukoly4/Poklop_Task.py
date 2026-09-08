import numpy as np
import skfuzzy as fuzz
from skfuzzy import control as ctrl
import matplotlib.pyplot as plt

#definice proměnných
room_temp = ctrl.Antecedent(np.arange(0,41,1), 'room_temperature')
target_temp = ctrl.Antecedent(np.arange(0,41,1), 'target_temperature')
ac_command = ctrl.Consequent(np.arange(-5,6,1), 'ac_control') #příkaz pro klimatizační systém

#definice gausovských příslušnostních funkcí
#pro teplotu v místnosti
room_temp['very_cold'] = fuzz.gaussmf(room_temp.universe, 0, 3)
room_temp['cold'] = fuzz.gaussmf(room_temp.universe, 10, 3)
room_temp['moderate'] = fuzz.gaussmf(room_temp.universe, 20, 3)
room_temp['hot'] = fuzz.gaussmf(room_temp.universe, 30, 3)
room_temp['very_hot'] = fuzz.gaussmf(room_temp.universe, 40, 3)
room_temp.view()

#pro cílovou teplotu
target_temp['very_cold'] = fuzz.gaussmf(target_temp.universe, 0, 3)
target_temp['cold'] = fuzz.gaussmf(target_temp.universe, 10, 3)
target_temp['moderate'] = fuzz.gaussmf(target_temp.universe, 20, 3)
target_temp['hot'] = fuzz.gaussmf(target_temp.universe, 30, 3)
target_temp['very_hot'] = fuzz.gaussmf(target_temp.universe, 40, 3)
target_temp.view()

# pro příkaz klimatizace
ac_command['cool'] = fuzz.trapmf(ac_command.universe, [-5, -5, -3, -1])
ac_command['no_change'] = fuzz.trimf(ac_command.universe, [0, 0, 1])
ac_command['heat'] = fuzz.trapmf(ac_command.universe, [0, 1, 5, 5])
ac_command.view()

#definovaní fuzzy pravidel pro každý stav teploty a cílové teploty
rules = [
    ctrl.Rule(room_temp['very_cold'] & target_temp['very_hot'], ac_command['heat']),
    ctrl.Rule(room_temp['very_cold'] & target_temp['hot'], ac_command['heat']),
    ctrl.Rule(room_temp['very_cold'] & target_temp['moderate'], ac_command['heat']),
    ctrl.Rule(room_temp['very_cold'] & target_temp['cold'], ac_command['heat']),
    ctrl.Rule(room_temp['very_cold'] & target_temp['very_cold'], ac_command['no_change']),

    ctrl.Rule(room_temp['cold'] & target_temp['very_hot'], ac_command['heat']),
    ctrl.Rule(room_temp['cold'] & target_temp['hot'], ac_command['heat']),
    ctrl.Rule(room_temp['cold'] & target_temp['moderate'], ac_command['heat']),
    ctrl.Rule(room_temp['cold'] & target_temp['cold'], ac_command['no_change']),
    ctrl.Rule(room_temp['cold'] & target_temp['very_cold'], ac_command['cool']),

    ctrl.Rule(room_temp['moderate'] & target_temp['very_hot'], ac_command['cool']),
    ctrl.Rule(room_temp['moderate'] & target_temp['hot'], ac_command['cool']),
    ctrl.Rule(room_temp['moderate'] & target_temp['moderate'], ac_command['no_change']),
    ctrl.Rule(room_temp['moderate'] & target_temp['cold'], ac_command['heat']),
    ctrl.Rule(room_temp['moderate'] & target_temp['very_cold'], ac_command['heat']),

    ctrl.Rule(room_temp['hot'] & target_temp['very_hot'], ac_command['cool']),
    ctrl.Rule(room_temp['hot'] & target_temp['hot'], ac_command['no_change']),
    ctrl.Rule(room_temp['hot'] & target_temp['moderate'], ac_command['heat']),
    ctrl.Rule(room_temp['hot'] & target_temp['cold'], ac_command['heat']),
    ctrl.Rule(room_temp['hot'] & target_temp['very_cold'], ac_command['heat']),

    ctrl.Rule(room_temp['very_hot'] & target_temp['very_hot'], ac_command['no_change']),
    ctrl.Rule(room_temp['very_hot'] & target_temp['hot'], ac_command['cool']),
    ctrl.Rule(room_temp['very_hot'] & target_temp['moderate'], ac_command['cool']),
    ctrl.Rule(room_temp['very_hot'] & target_temp['cold'], ac_command['cool']),
    ctrl.Rule(room_temp['very_hot'] & target_temp['very_cold'], ac_command['cool']),

]

#vytvoření control systému
ac_ctrl = ctrl.ControlSystem(rules)
ac_prediction = ctrl.ControlSystemSimulation(ac_ctrl)

def test_fuzzy_system(ac_prediction, room_temp, target_temp):
    #vyhodnocení pookojové teploty a cílové teploty
    ac_prediction.input['room_temperature'] = room_temp
    ac_prediction.input['target_temperature'] = target_temp
    #výpočet simulace outputu
    ac_prediction.compute()
    #vrácení výstupní hodnoty
    return ac_prediction.output['ac_control']

def plot_3D_visualization(ac_prediction):
    room_temp_values = np.arange(0,41,5)
    target_temp_values = np.arange(0,41,5)
    #příprava mřížky pro 3d graf
    X,Y = np.meshgrid(room_temp_values, target_temp_values) #room_temp grid, target_temp grid
    Z = np.zeros_like(X) #command grid výpoet predikcí

    #výpočet predikcí(výstupních hodnot) pro každý bod v mřížce
    for i, room in enumerate(room_temp_values):
        for j, target in enumerate(target_temp_values):
            Z[i, j] = test_fuzzy_system(ac_prediction, room, target)

    #vykreslení 3D grafu
    fig = plt.figure(figsize=(10, 7))
    ax = fig.add_subplot(111, projection='3d')
    #vybarvení povrchu
    surf = ax.plot_surface(X, Y, Z, cmap='coolwarm', edgecolor='k', linewidth=0, antialiased=False)

    ax.set_xlabel('Room Temperature (°C)')
    ax.set_ylabel('Target Temperature (°C)')
    ax.set_zlabel('AC Control command')
    ax.set_title('Fuzzy logic model of climatisation')

    #přidání barevné stupnice
    fig.colorbar(surf, shrink=0.5, aspect=5)
    #mezery a vykreslení grafu
    plt.tight_layout(); plt.show()

print("Test 1 (horká místnost, chladný cíl): ", test_fuzzy_system(ac_prediction, 30, 10))
print("Test 2 (horká místnost, horký cíl): ", test_fuzzy_system(ac_prediction, 30, 30))
print("Test 3 (studená místnost, teplý cíl): ", test_fuzzy_system(ac_prediction, 10, 25))
print("Test 4 (studená místnost, studený cíl): ", test_fuzzy_system(ac_prediction, 10, 10))
print("Test 5 (střední teplota v místnosti, teplý cíl): ", test_fuzzy_system(ac_prediction, 20, 25))
print("Test 6 (hodně studená místnost, teplý cíl): ", test_fuzzy_system(ac_prediction, 0, 25))
print("Test 7 (střední teplota, horký cíl): ", test_fuzzy_system(ac_prediction, 10, 30))
print("Test 8 (střední teploty):", test_fuzzy_system(ac_prediction, 20, 20))

plot_3D_visualization(ac_prediction)