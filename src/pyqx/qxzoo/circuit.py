from typing import List
from julia import QXZoo as jl_QXZoo
from multimethod import multimethod

class Circuit:
    def __init__(self, num_qubits):
        self._jl_cct = jl_QXZoo.Circuit.Circ(num_qubits)
        self.gate_set_1q_static = {
            "x" : jl_QXZoo.DefaultGates.x, 
            "y" : jl_QXZoo.DefaultGates.y, 
            "z" : jl_QXZoo.DefaultGates.z, 
            "h" : jl_QXZoo.DefaultGates.h
        }
        self.gate_set_2q_static = {
            "c_x" : jl_QXZoo.DefaultGates.c_x, 
            "c_y" : jl_QXZoo.DefaultGates.c_y, 
            "c_z" : jl_QXZoo.DefaultGates.c_z, 
        }
        self.gate_set_1q_param = {
            "r_x" : jl_QXZoo.DefaultGates.r_x, 
            "r_y" : jl_QXZoo.DefaultGates.r_y, 
            "r_z" : jl_QXZoo.DefaultGates.r_z, 
            "r_phase" : jl_QXZoo.DefaultGates.r_phase, 
        }
        self.gate_set_2q_param = {
            "c_r_x" : jl_QXZoo.DefaultGates.c_r_x, 
            "c_r_y" : jl_QXZoo.DefaultGates.c_r_y, 
            "c_r_z" : jl_QXZoo.DefaultGates.c_r_z,
            "c_r_phase" : jl_QXZoo.DefaultGates.c_r_phase, 
        }

    def print_gates(self):
        print(self._jl_cct)

    def __lshift__(self, other):
        jl_QXZoo.Circuit.append_b(self._jl_cct, other._jl_cct)

    @multimethod
    def apply_gate(self, gate_label: str, target: int):
        jl_QXZoo.Circuit.append_b(self._jl_cct, self.gate_set_1q_static[gate_label](target+1))

    @multimethod
    def apply_gate(self, gate_label: str, ctrl: int, target: int):
        jl_QXZoo.Circuit.append_b(self._jl_cct, self.gate_set_2q_static[gate_label](target+1, ctrl+1))

    @multimethod
    def apply_gate(self, gate_label: str, target: int, angle: float):
        jl_QXZoo.Circuit.append_b(self._jl_cct, self.gate_set_1q_param[gate_label](target+1, angle))

    @multimethod
    def apply_gate(self, gate_label: str, ctrl: int, target: int, angle: float):
        jl_QXZoo.Circuit.append_b(self._jl_cct, self.gate_set_2q_param[gate_label](target+1, ctrl+1, angle))
