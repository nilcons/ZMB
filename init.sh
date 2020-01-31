#!/bin/bash

rm -rf venv
/usr/bin/python3 -m virtualenv -p /usr/bin/python3 venv

venv/bin/pip install untangle jsonpickle
