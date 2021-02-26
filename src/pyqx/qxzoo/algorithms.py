from pyqx.qxzoo.circuit import Circuit

from typing import List
from julia import QXZoo as jl_QXZoo
from multimethod import multimethod

class Algorithms:
    def __init__(self):
        pass
    
    @staticmethod
    @multimethod
    def apply_ncu(cct, gate, ctrl_indices, target):
        pass

    @staticmethod
    @multimethod
    def apply_ncu(cct, gate, ctrl_indices, aux_indices, target):
        pass

    @staticmethod
    def apply_pauli_string(cct: Circuit, pauli_str: str, angle: float, targets: List[int]):
        ops = [cct.gate_set_1q_static[i](j) for i,j in zip(pauli_str, targets)]
        jl_QXZoo.Evolution.apply_pauli_string_b(cct._jl_cct, angle, ops)