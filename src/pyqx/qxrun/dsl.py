from multimethod import multimethod
from abc import ABC
import numpy as np

from julia.QXRun import DSL as jl_DSL
from typing import List

class ADSL(ABC):
    "This class is the abstract base for DSL commands found in QXRun.jl. Given the inoperability between Julia abstract types and Python, we define out own base class here, from which all DSL methods will derive."
    pass

class LoadCommand(ADSL):
    def __init__(self, name, label):
        self._jl = jl_DSL.LoadCommand(name, label)

class SaveCommand(ADSL):
    def __init__(self, name, label):
        self._jl = jl_DSL.SaveCommand(name, label)

class DeleteCommand(ADSL):
    def __init__(self, name):
        self._jl = jl_DSL.DeleteCommand(name)

class ReshapeCommand(ADSL):
    def __init__(self, name, dims):
        self._jl = jl_DSL.ReshapeCommand(name, dims)

class PermuteCommand(ADSL):
    def __init__(self, name, dims):
        self._jl = jl_DSL.PermuteCommand(name, label)

class NconCommand(ADSL):
    def __init__(self, output_name, output_idxs, left_name, left_idxs, right_name, right_idxs):
        self._jl = jl_DSL.NconCommand(output_name, output_idxs, left_name, left_idxs, right_name, right_idxs)

class ViewCommand(ADSL):
    def __init__(self, name, target, bond_index, bond_range):
        self._jl = jl_DSL.ViewCommand(name, target, bond_index, bond_range)

class OutputsCommand(ADSL):
    def __init__(self, num_outputs):
        self._jl = jl_DSL.OutputsCommand(num_outputs)

class ParametricCommand(ADSL):
    def __init__(self, args: str):
        self.args = args

@multimethod
def parse_dsl(filename: str):
    return jl_DSL.parse_dsl(filename)

    buffer=[] 
    with open(filename) as f:
        for line in f:
            buffer.append(line)
    
    return parse_dsl(buffer)

"""

@multimethod
def parse_dsl(buffer: List[str]):
    cmd_types = {
        "load"      : LoadCommand,
        "save"      : SaveCommand,
        "del"       : DeleteCommand,
        "reshape"   : ReshapeCommand,
        "permute"   : PermuteCommand,
        "ncon"      : NconCommand,
        "view"      : ViewCommand,
        "outputs"   : OutputsCommand,
    }

    is_compatible, version_dsl = jl_DSL.check_compatible_version_dsl(buffer[0])
    if not is_compatible:
        raise(f"DSL version not compatible:\n\t'{version_dsl}', expected '{jl_DSL.VERSION_DSL}'")
    end

    for line in buffer:
        line_command = line.split('#')
        if ~isempty(line_command[0])
            command = parse_command(line_command, command_types)
            append!(commands, command)
        end
    end

    return jl_DSL.parse_dsl(buffer)


def parse_command(line: str, command_types)

    type, args = string.(split(strip(line), " "; limit = 2))

    if "\$" in line:
        command = ParametricCommand{command_types[type]}(args)
    else
        args = string.(split(args, " "))
        command = command_types[type](args...)
    end

    return command

"""