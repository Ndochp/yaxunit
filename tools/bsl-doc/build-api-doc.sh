#!/bin/bash

export SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

rm -rf ${SCRIPTPATH}/../../documentation/api

java -jar ${SCRIPTPATH}/bsldoc-0.1.0.jar ${SCRIPTPATH}/../../exts/yaxunit ${SCRIPTPATH}/../../documentation/api -f Docusaurus -s ЮТДвижок