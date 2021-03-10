from typing import List
from julia import QXZoo as jl_QXZoo
from abc import ABC
from multimethod import multimethod

from julia.QXZoo.GateOps import AGateCall as jl_agc

class Gate:
    def __init__(self, num_qubits):
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

class GateCall:
    def __init__(self, gate_call, label):
        self.gate_call = gate_call
        self.label = label

    def __repr__(self):
        out_str = f"{self.label}("
        if hasattr(self.gate_call, "ctrl"):
            out_str += f"ctrl={self.gate_call.ctrl}, "
        out_str += f"tgt={self.gate_call.target}"
        if hasattr(self.gate_call.gate_symbol, "param"):
            out_str += f", param={self.gate_call.gate_symbol.param}"
        return out_str + ")"


def x(tgt: int):
    return GateCall(jl_QXZoo.DefaultGates.x(tgt), "x")

def y(tgt: int):
    return GateCall(jl_QXZoo.DefaultGates.y(tgt), "y")

def z(tgt: int):
    return GateCall(jl_QXZoo.DefaultGates.z(tgt), "z")

def h(tgt: int):
    return GateCall(jl_QXZoo.DefaultGates.h(tgt), "h")


def r_x(tgt: int, angle: float):
    return GateCall(jl_QXZoo.DefaultGates.r_x(tgt, angle), "r_x")

def r_y(tgt: int, angle: float):
    return GateCall(jl_QXZoo.DefaultGates.r_y(tgt, angle), "r_y")

def r_z(tgt: int, angle: float):
    return GateCall(jl_QXZoo.DefaultGates.r_z(tgt, angle), "r_z")

def r_phase(tgt: int, angle: float):
    return GateCall(jl_QXZoo.DefaultGates.r_phase(tgt, angle), "r_phase")


def c_x(ctrl: int, tgt: int):
    return GateCall(jl_QXZoo.DefaultGates.c_x(tgt, ctrl), "c_x")

def c_y(ctrl: int, tgt: int):
    return GateCall(jl_QXZoo.DefaultGates.c_y(tgt, ctrl), "c_y")

def c_z(ctrl: int, tgt: int):
    return GateCall(jl_QXZoo.DefaultGates.c_z(tgt, ctrl), "c_z")

def c_r_x(ctrl: int, tgt: int, angle: float):
    return GateCall(jl_QXZoo.DefaultGates.c_r_x(tgt, ctrl, angle), "c_r_x")

def c_r_y(ctrl: int, tgt: int, angle: float):
    return GateCall(jl_QXZoo.DefaultGates.c_r_y(tgt, ctrl, angle), "c_r_y")

def c_r_z(ctrl: int, tgt: int, angle: float):
    return GateCall(jl_QXZoo.DefaultGates.c_r_z(tgt, ctrl, angle), "c_r_z")

def c_r_phase(ctrl: int, tgt: int, angle: float):
    return GateCall(jl_QXZoo.DefaultGates.c_r_phase(tgt, ctrl, angle), "c_r_phase")

