#!/bin/bash

set -e

SUPPORTED_TYPES=('cli' 'fullnode' 'lightnode')
SUPPORTED_NETWORKS=('prod' 'testnet')

FORCE=0

function exec_name {
    local node_type=$1
    local network=$2

    case ${TYPE} in
        lightnode)
            echo "lightd"
            ;;
        fullnode)
            echo "bnbchaind"
            ;;
        cli)
            echo "bnbcli"
            ;;
        *)
            echo "Invalid node type selected"
            exit 1
            ;;
    esac
}

function run_build {
    local TYPE=$1
    local NETWORK=$2
    local VERSION=$3
    local EXEC_NAME=$(exec_name ${TYPE} ${NETWORK})
    local DEST_EXEC_NAME=${EXEC_NAME}

    if [[ ${NETWORK} == "testnet"  ]] && [[ ${EXEC_NAME} == "bnbcli" ]]; then
        EXEC_NAME="tbnbcli"
    fi

    IMAGE="chainup/binance-${TYPE}-${NETWORK}:${VERSION}"

    echo "Running build step for ${IMAGE}"

    rm -rf build && mkdir build

    cp binaries/${TYPE}/${NETWORK}/${VERSION}/linux/${EXEC_NAME} build/${DEST_EXEC_NAME}

    if [[ ${EXEC_NAME} == "bnbchaind" ]]; then
        cp -R binaries/${TYPE}/${NETWORK}/${VERSION}/config build/config
    fi

    cp Dockerfile.${TYPE} build/Dockerfile

    if [[ ${FORCE} -eq 1 ]]; then
        echo "Forcing rebuild..."
    fi

    if [[ "$(docker images -q ${IMAGE} 2> /dev/null)" == "" ]] || [[ ${FORCE} -eq 1 ]]; then
        echo "Building docker image..."
        docker build -t ${IMAGE} ./build
    else
      echo "Image already exists"
    fi

#    set +e; docker pull ${IMAGE} 1> /dev/null; set -e
#    if [[ $? -ne 0 ]] || [[ ${FORCE} -eq 1 ]]; then
#        echo "Pushing image to Docker Hub..."
#
#        docker push ${IMAGE}
#    else
#        echo "Image already pushed to Docker Hub"
#    fi
}

TYPE=$1
NETWORK=$2
VERSION=$3

if [[ ${TYPE} != "" ]] && [[ ${NETWORK} ]] && [[ ${VERSION} ]]; then
    FORCE=1

    run_build ${TYPE} ${NETWORK} ${VERSION}
    exit 0
fi

for TYPE in ${SUPPORTED_TYPES[@]}; do
    for NETWORK in ${SUPPORTED_NETWORKS[@]}; do
        for VERSION in binaries/${TYPE}/${NETWORK}/*; do
            VERSION=${VERSION##*/}

            run_build ${TYPE} ${NETWORK} ${VERSION}
        done
    done
done
