#!/bin/bash

apt-install-if-needed python3 python3-pip python3-dev python3-pip python3-venv

function mkvirtualenv-if-needed {

    python3 -m venv .venv --prompt $@

}
