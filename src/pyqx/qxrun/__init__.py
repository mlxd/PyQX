name = "qxrun"

import mpi4py # used to initialise MPI runtime if needed

from julia import Pkg
Pkg.develop(url="https://github.com/juliaqx/QXRun.jl")

from pyqx.qxrun.dsl import *