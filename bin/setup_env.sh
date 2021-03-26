#!/bin/bash
set -e

module load gcc
###############################################################################
# Environment setup script and package installer for QuantEx + Tequila
# Creates `load_env.sh` which can be sourced for the environment
# Deps:
#   -   Python compiled with "--enable-shared" (i.e non-conda)
#   -   Psi4 (src build, as generally packaged with conda)
#       > Requires: numpy, networkx, pydantic, pint, msgpack-python, deepdiff
#   -   Tequila: required for VQE, and frontend for QuantEx circuit generation
#       > Requires: numpy, jax, qulacs
#   -   PyQX: Python bindings for QuantEx packages
#       Requires: Julia binary on path (installed with jill.py if not found)
#   !   Due to issues with pip, jax was installed from source following:
#       https://jax.readthedocs.io/en/latest/developer.html#building-from-source
#
# LOR: adapted from Python installation procedure from
# https://github.com/ICHEC/QNLP/blob/master/setup_env.sh
###############################################################################

# Pass the required installation directory as an argument
ENV_NAME=$1
export ${ENV_NAME}_ROOT=$2
export MAX_BUILDER_PROCS=$3
export RT=${ENV_NAME}_ROOT
export FULLPATH=$PWD

if [ ! -d "${RT}" ];then
    mkdir -p ${RT}
fi
mkdir -p $RT/downloads ${RT}/install

###############################################################################
# Declare global associative arrays to hold external dependencies
###############################################################################
declare -a GITHUB_REPOS

GITHUB_REPOS=(
    "python/cpython"
    "libffi/libffi"
    "aspuru-guzik-group/tequila"
    "psi4/psi4"
    "google/jax"
    "mlxd/PyQX"
    "xianyi/OpenBLAS"
    "MolSSI/QCElemental"
    "libarchive/bzip2"
    "xz-mirror/xz"
)

PIP_PACKAGES=(
    "numpy"
    "scipy"
    "networkx"
    "pint"
    "pydantic"
    "msgpack-python"
    "deepdiff"
    "wheel"
    "jill"
    "cmake"
    "pybind11"
    "pytest"
)

###############################################################################
# Fetch repos
###############################################################################
function fetchPackagesGithub(){
    echo "### fetchPackages() ###"

    # Loop through arrays and install the packages and repos
    if [ "${#GITHUB_REPOS[@]}" -gt 0 ]; then
        pushd . &> /dev/null
        cd $FULLPATH/$RT/downloads
        for s in $(seq 0 $(( ${#GITHUB_REPOS[@]} -1 )) ); do
            echo ${GITHUB_REPOS[${s}]}
            PC=${GITHUB_REPOS[${s}]} # Package::tag

            if [[ "${GITHUB_REPOS[${s}]}" =~ "::" ]]; then
                git clone https://github.com/${PC%::*}
                PCC=${PC#*/}
                cd ${PCC%::*}
                git checkout ${PC#*::}
                cd -
            else
                git clone https://github.com/${GITHUB_REPOS[${s}]}
            fi

        done
        popd &> /dev/null
    fi
}

###############################################################################
# Build and install Python
###############################################################################

function installPythonDeps(){
    pushd . &> /dev/null
    export LD_LIBRARY_PATH=$FULLPATH/${RT}/install/openssl/lib:${LD_LIBRARY_PATH}
    export LD_LIBRARY_PATH=$FULLPATH/${RT}/install/lib:$FULLPATH/${RT}/install/lib64:$LD_LIBRARY_PATH
    export PATH=$FULLPATH/${RT}/install/bin:$PATH

    #libffi
    cd $FULLPATH/${RT}/downloads/libffi
    ./autogen.sh && ./configure --prefix=$FULLPATH/${RT}/install --disable-docs && make -j${MAX_BUILDER_PROCS} && make install

    #lzma
    cd $FULLPATH/${RT}/downloads/xz && ./autogen.sh && ./configure --prefix=$FULLPATH/${RT}/install && \
    make -j${MAX_BUILDER_PROCS} && make install

    #cmake
    cd $FULLPATH/${RT}/downloads/
    wget https://github.com/Kitware/CMake/releases/download/v3.19.7/cmake-3.19.7-Linux-x86_64.tar.gz
    tar xvf ./cmake-3.19.7-Linux-x86_64.tar.gz --directory $FULLPATH/${RT}/install --strip-components=1
    #mkdir -p build

    #bz2
    cd $FULLPATH/${RT}/downloads/bzip2 && mkdir -p build
    cmake -H. -Bbuild -DCMAKE_INSTALL_PREFIX=$FULLPATH/${RT}/install
    cmake --build ./build/ -j${MAX_BUILDER_PROCS} && cmake --install ./build

    popd &> /dev/null
}

function buildPython(){
    pushd . &> /dev/null
    cd $FULLPATH/${RT}/downloads/cpython
    wget https://github.com/openssl/openssl/archive/refs/tags/OpenSSL_1_1_1j.tar.gz
    tar xvf ./OpenSSL_1_1_1j.tar.gz
    cd openssl-OpenSSL_1_1_1j/
    ./config --prefix=$FULLPATH/${RT}/install/openssl --openssldir=$FULLPATH/${RT}/install/openssl
    make -j${MAX_BUILDER_PROCS} && make install
    cd ..
    export LD_LIBRARY_PATH=$FULLPATH/${RT}/install/openssl/lib:${LD_LIBRARY_PATH}
    export LD_LIBRARY_PATH=$FULLPATH/${RT}/install/lib:$FULLPATH/${RT}/install/lib64:$LD_LIBRARY_PATH
    git checkout v3.7.9
    CFLAGS=-I$FULLPATH/${RT}/install/include \
        LDFLAGS="-L$FULLPATH/${RT}/install/lib -L$FULLPATH/${RT}/install/lib64 -Wl,-rpath=$FULLPATH/${RT}/install/lib -Wl,-rpath=$FULLPATH/${RT}/install/lib64" \
        ./configure --prefix=$FULLPATH/${RT}/install/ \
        --with-openssl=$FULLPATH/${RT}/install/openssl \
        --enable-shared \
#        --enable-optimizations
    
    make -j${MAX_BUILDER_PROCS} && make install;
    popd &> /dev/null
}

###############################################################################
# Create environment
###############################################################################
function envSetup(){
    echo "### envSetup() ###"
    export PATH=${FULLPATH}/${RT}/install/bin:$PATH
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$FULLPATH/${RT}/install/openssl/lib
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$FULLPATH/${RT}/install/lib:$FULLPATH/${RT}/install/lib64
    python3 -m venv $FULLPATH/${RT}/v_env
    source $FULLPATH/${RT}/v_env/bin/activate;
    python3 -c "import ensurepip; ensurepip.bootstrap()";
}


###############################################################################
# Fetch and install packages
###############################################################################
function fetchPackagesPip(){
    echo "### fetchPackages() ###"
    source $FULLPATH/${RT}/v_env/bin/activate;
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$FULLPATH/${RT}/install/openssl/lib
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$FULLPATH/${RT}/install/lib:$FULLPATH/${RT}/install/lib64

    # PIP
    if [ "${#PIP_PACKAGES[@]}" -gt 0 ]; then
        for s in $(seq 0 $(( ${#PIP_PACKAGES[@]} -1 )) ); do
            echo ${PIP_PACKAGES[${s}]}
            python3 -m pip install ${PIP_PACKAGES[${s}]}
        done
    fi
}


###############################################################################
# Build and install OpenBLAS
###############################################################################

function installOpenBLAS(){
    pushd . &> /dev/null
    cd $FULLPATH/${RT}/downloads/OpenBLAS
    git checkout v0.3.13
    source $FULLPATH/${RT}/v_env/bin/activate;
    export LD_LIBRARY_PATH=$FULLPATH/${RT}/install/lib:$LD_LIBRARY_PATH

    mkdir -p build
    CC=gcc FC=gfortran cmake -H. -Bbuild -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=$FULLPATH/${RT}/install 
    cd build && make -j${MAX_BUILDER_PROCS} && make PREFIX=$FULLPATH/${RT}/install install

    popd &> /dev/null
}


###############################################################################
# Build and install Psi4
###############################################################################

function installPsi4(){
    pushd . &> /dev/null
    cd $FULLPATH/${RT}/downloads/psi4
    git checkout v1.3.2
    export PATH=$FULLPATH/${RT}/install/bin:$PATH
    export LD_LIBRARY_PATH=$FULLPATH/${RT}/install/openssl/lib:${LD_LIBRARY_PATH}
    export LD_LIBRARY_PATH=$FULLPATH/${RT}/install/lib:$FULLPATH/${RT}/install/lib64:${LD_LIBRARY_PATH}
    source $FULLPATH/${RT}/v_env/bin/activate;

    mkdir -p build

    cmake -H. -Bbuild \
        -DCMAKE_C_COMPILER=$(which gcc) \
        -DCMAKE_CXX_COMPILER=$(which g++) \
        -DCMAKE_FC_COMPILER=$(which gfortran) \
        -DPYTHON_EXECUTABLE=$(which python3) \
        -DPYTHON_LIBRARY="$(dirname $(which python3))/../lib" \
        -DPYTHON_INCLUDE_DIR="$(dirname $(which python3))/../include" \
        -DCMAKE_INSTALL_PREFIX="$FULLPATH/${RT}/install" \
        -DBLAS_TYPE=OPENBLAS -DLAPACK_TYPE=OPENBLAS \
        -DLAPACK_LIBRARIES="$FULLPATH/${RT}/install/lib64/libopenblas.so" \
        -DLAPACK_INCLUDE_DIRS="$FULLPATH/${RT}/install/include/openblas"

    cd build && make -j${MAX_BUILDER_PROCS} && make install
    psi4 --psiapi-path > $FULLPATH/${RT}/install/bin/psipath.sh

    popd &> /dev/null
}


###############################################################################
# Build and install Jax
###############################################################################

function installJax(){
    pushd . &> /dev/null
    source $FULLPATH/${RT}/v_env/bin/activate;
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$FULLPATH/${RT}/install/openssl/lib
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$FULLPATH/${RT}/install/lib:$FULLPATH/${RT}/install/lib64
    cd $FULLPATH/${RT}/downloads/jax
    #python3 build/build.py && python3 -m pip install dist/*.whl #jaxlib
    #python3 -m pip install -e . #jax
    python3 -m pip install jax jaxlib
    popd &> /dev/null
}

###############################################################################
# Install tequila from src
###############################################################################

function installTequila(){
    pushd . &> /dev/null
    source $FULLPATH/${RT}/v_env/bin/activate;
    cd $FULLPATH/${RT}/downloads/tequila
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$FULLPATH/${RT}/install/openssl/lib
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$FULLPATH/${RT}/install/lib:$FULLPATH/${RT}/install/lib64
    git checkout v1.0.0
    python3 -m pip install -e .
    git apply $FULLPATH/tq.diff
    popd &> /dev/null
}


###############################################################################
# Install Julia via jill.py if not on path
###############################################################################

function checkInstallJulia(){
    export JULIA_DEPOT_PATH=$FULLPATH/${RT}/.julia
    if command -v julia &> /dev/null
    then
        return 0 # if julia on path, exit function
    fi

    pushd . &> /dev/null
    source $FULLPATH/${RT}/v_env/bin/activate;

    jill install latest --upstream Official --confirm \
        --install_dir=$FULLPATH/${RT}/downloads \
        --symlink_dir=$FULLPATH/${RT}/install/bin

   popd &> /dev/null 
}

###############################################################################
# Install PyQX
###############################################################################

function installPyQX(){
    pushd . &> /dev/null
    source $FULLPATH/${RT}/v_env/bin/activate
    export LD_LIBRARY_PATH=$FULLPATH/${RT}/install/lib:$LD_LIBRARY_PATH

    cd $FULLPATH/${RT}/downloads/PyQX
    python3 -m pip install -e .
    popd &> /dev/null
}

###############################################################################
#                                   main
###############################################################################

# Output .sh files with concretised commands of below
mkdir -p $FULLPATH/${RT}/scripts
echo "$(declare -f fetchPackagesGithub)" >> $FULLPATH/${RT}/scripts/fetchPackagesGithub.sh
echo "$(declare -f installPythonDeps)" >> $FULLPATH/${RT}/scripts/installPythonDeps.sh
echo "$(declare -f buildPython)" >> $FULLPATH/${RT}/scripts/buildPython.sh
echo "$(declare -f fetchPackagesPip)" >> $FULLPATH/${RT}/scripts/fetchPackagesPip.sh
echo "$(declare -f installOpenBLAS)" >> $FULLPATH/${RT}/scripts/installOpenBLAS.sh
echo "$(declare -f installPsi4)" >> $FULLPATH/${RT}/scripts/installPsi4.sh
echo "$(declare -f installJax)" >> $FULLPATH/${RT}/scripts/installJax.sh
echo "$(declare -f installTequila)" >> $FULLPATH/${RT}/scripts/installTequila.sh
echo "$(declare -f installJax)" >> $FULLPATH/${RT}/scripts/installJax.sh
echo "$(declare -f installPyQX)" >> $FULLPATH/${RT}/scripts/installPyQX.sh


LOG_NAME="SetupEnv"
fetchPackagesGithub > >(tee -a ${LOG_NAME}_out.log) 2> >(tee -a ${LOG_NAME}_err.log >&2) && \
installPythonDeps > >(tee -a ${LOG_NAME}_out.log) 2> >(tee -a ${LOG_NAME}_err.log >&2) && \
buildPython > >(tee -a ${LOG_NAME}_out.log) 2> >(tee -a ${LOG_NAME}_err.log >&2) && \
envSetup > >(tee -a ${LOG_NAME}_out.log) 2> >(tee -a ${LOG_NAME}_err.log >&2) && \
fetchPackagesPip > >(tee -a ${LOG_NAME}_out.log) 2> >(tee -a ${LOG_NAME}_err.log >&2) && \
installOpenBLAS > >(tee -a ${LOG_NAME}_out.log) 2> >(tee -a ${LOG_NAME}_err.log >&2) && \
installPsi4 > >(tee -a ${LOG_NAME}_out.log) 2> >(tee -a ${LOG_NAME}_err.log >&2) && \
installJax > >(tee -a ${LOG_NAME}_out.log) 2> >(tee -a ${LOG_NAME}_err.log >&2) && \
installTequila > >(tee -a ${LOG_NAME}_out.log) 2> >(tee -a ${LOG_NAME}_err.log >&2) && \
installPyQX > >(tee -a ${LOG_NAME}_out.log) 2> >(tee -a ${LOG_NAME}_err.log >&2) && \
cat > $FULLPATH/load_env.sh << EOL
#!/bin/bash
export PATH="$FULLPATH/${RT}/install/bin":"\${PATH}"
export LD_LIBRARY_PATH="${FULLPATH}/${RT}/install/lib":"${FULLPATH}/${RT}/install/lib64":"\${LD_LIBRARY_PATH}"
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$FULLPATH/${RT}/install/openssl/lib
source $FULLPATH/${RT}/v_env/bin/activate
export RT="$FULLPATH/${RT}"
$($FULLPATH/${RT}/install/bin/psi4 --psiapi-path)
export JULIA_DEPOT_PATH=$FULLPATH/${RT}/.julia
EOL
