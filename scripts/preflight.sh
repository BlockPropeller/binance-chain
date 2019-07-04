#!/bin/sh



git lfs --version &>/dev/null
if [[ $? -ne 0 ]]; then
    echo "git lfs not installed, installing..."

    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        apt-get update
        apt-get install \
            software-properties-common \
            git -y
        add-apt-repository ppa:git-core/ppa -y
        apt-get update
        curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
        apt-get install git-lfs -y
        git lfs install
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew update
        brew install git-lfs
        git lfs install
    else
        echo "Unrecognized OS: $OSTYPE"
        exit 1
    fi
fi

if [[ ! -d binaries ]]; then
    git lfs clone https://github.com/binance-chain/node-binary.git binaries
fi

cd binaries && git pull
