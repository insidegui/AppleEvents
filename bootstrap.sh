#!/bin/bash

git submodule update --init --recursive
cd ChromeCastCore
./bootstrap.sh
cd ..