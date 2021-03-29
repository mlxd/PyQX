from typing import List
from abc import ABC
from multimethod import multimethod

from julia.QXRun.Execution import QXContext as jl_QXContext

class QXContext:
    def __init__(self, cmds, params, input_file, output_file, data=None):
        self._ctx = jl_QXContext(cmds, params, input_file, output_file, data)

    def get_cmds(self):
        return self._ctx.cmds

    def get_params(self):
        return self._ctx.params

    def get_input_file(self):
        return self._ctx.input_file

    def get_output_file(self):
        return self._ctx.output_file

    def get_data(self):
        return self._ctx.data


    #def __repr__(self):
    #    out_str = f"{self.label}("
    #    if hasattr(self.gate_call, "ctrl"):
    #        out_str += f"ctrl={self.gate_call.ctrl}, "
    #    out_str += f"tgt={self.gate_call.target}"
    #    if hasattr(self.gate_call.gate_symbol, "param"):
    #        out_str += f", param={self.gate_call.gate_symbol.param}"
    #    return out_str + ")"


