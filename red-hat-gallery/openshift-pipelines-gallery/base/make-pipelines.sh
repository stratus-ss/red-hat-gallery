#!/usr/bin/env bash

# Creates a Tekton pipeline for each demo microservice.

set -euo pipefail
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

while IFS= read -d $'\0' -r dir; do
    # build image
    svcname="$(basename "${dir}")"
    pipeline="${SCRIPTDIR}/${svcname}-pipeline.yaml"
    pipelinerun="${SCRIPTDIR}/${svcname}-pipelinerun.yaml"
    builddir="./src/${svcname}"
    #PR 516 moved cartservice build artifacts one level down to src
    if [ $svcname == "cartservice" ]
    then
        builddir="./src/${svcname}/src"
    fi
    echo Creating pipeline $pipeline
    sed \
      -e "s#@@SVCNAME@@#${svcname}#g" \
      -e "s#@@BUILDDIR@@#${builddir}#g" \
      "${SCRIPTDIR}/template-pipeline.yaml" \
      > "${pipeline}"
    echo Creating pipelinerun $pipelinerun
    sed \
      -e "s#@@SVCNAME@@#${svcname}#g" \
      -e "s#@@BUILDDIR@@#${builddir}#g" \
      "${SCRIPTDIR}/template-pipelinerun.yaml" \
      > "${pipelinerun}"
done < <(find "${SCRIPTDIR}/../../../src" -mindepth 1 -maxdepth 1 -type d -print0)
