To use PyJulia effectively (or at all) we require a Python environment that is shared rather than statically linked (see https://pyjulia.readthedocs.io/en/latest/troubleshooting.html#ultimate-fix-build-your-own-python). Given that the conda builds are statically linked (despite the availability of libpython.so), PyJulia still complains, requiring use of an additional wrapper `python-jl` to call the env.

This can be problematic as we require psi4 to use the Tequila environment, since psi4's primary distribution method is conda. To overcome this, and avoid any obscures wrappings, we build our own Python distribution from source (3.7.9, as determined by the current psi4 dependency), as well as psi4 and other required packages.

The script `setup_env.sh` attempts to automate this process, acquiring Python, Psi4, Tequila, and additional dependencies to build the stack. PyQX is installed as the final step of the process, for which Tequila is patched to recognise it. The script will create a single `load_env.sh` scripts which can be sourced to sdet all required paths. The only manualy step is ensuring a valid Julia (>=1.5) package is available.

Run the scripts as follows, which takes ~10 minutes to complete on 4 cores:
```bash
./setup_env.sh <name_of_installation_dir> <prefix_install_path> <num_build_threads>
```

As an example, to create a dir called `py_ROOT`, in the current working dir using 4 cores, and load the created environment, run the following:
```bash
./setup_env.sh py $PWD 4
source ./load_env.sh
```
