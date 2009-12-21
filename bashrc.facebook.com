#!/bin/bash

if [ ${BASH_VERSINFO[0]} -eq 3 ] &&
    [ -x "${HOME}/software/${MACHTYPE}-${OSTYPE}/bash-4.0/bin/bash" ]; then
    ${HOME}/software/${MACHTYPE}-${OSTYPE}/bash-4.0/bin/bash
fi
