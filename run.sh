#!/bin/bash

git clone "$@" repo
cd repo
../lang-stats.sh
