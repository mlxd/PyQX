from pyqx.qxzoo import Circuit, Algorithms
import numpy as np

num_qubits = 8
cct = Circuit(num_qubits)
cct2 = Circuit(num_qubits)

p_str = "zzxy"
q_list = [0,2,3,5]
angle = np.pi/8

p_str = "zzzy"
q_list = [1,2,4,5]
angle = np.pi/4

Algorithms.apply_pauli_string(cct, p_str, angle, q_list)
Algorithms.apply_pauli_string(cct2, p_str, angle, q_list)

cct.print_gates()
cct2.print_gates()

cct << cct2

cct.print_gates()
cct2.print_gates()