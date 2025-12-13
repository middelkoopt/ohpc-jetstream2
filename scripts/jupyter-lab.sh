#!/bin/bash
set -e 

echo "+++ installing jupyter"
python3 -m venv .venv
. .venv/bin/activate

python3 -m pip install pip --upgrade
python3 -m pip install --upgrade jupyterlab
python3 -m pip install --upgrade jupyterlab-spellchecker
python3 -m pip install --upgrade standard-imghdr # Python 3.13
python3 -m pip install --upgrade bash_kernel
python3 -m bash_kernel.install --sys-prefix
python3 -m pip install --upgrade remote-kernel

echo "+++ run jupyter"
jupyter-lab --port=8081
