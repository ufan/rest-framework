#!/bin/bash

ROOT_VERSION=6.24.02
if [ $(root-config --version | grep $ROOT_VERSION) ];then

echo "ROOT of version $ROOT_VERSION has already been installed"
echo prefix:
echo $(root-config --prefix)
echo cflags:
echo $(root-config --cflags)

else

set -e
CURRENT_DIR=$PWD

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

ROOT_DIR=$HOME/apps/root-$ROOT_VERSION

mkdir -p ${ROOT_DIR}
cd ${ROOT_DIR}

f=root_v$ROOT_VERSION.source.tar.gz

if [ -f $f ]; then
    echo use cache build/$f
else
	if [ $machine == "Mac" ]; then
	    curl https://root.cern.ch/download/$f -o $f
	else
	    wget https://root.cern.ch/download/$f
	fi
fi
tar -xvzf $f

rm -rf source
mv root-$ROOT_VERSION source

mkdir -p ${ROOT_DIR}/build
cd ${ROOT_DIR}/build

cmake -DCMAKE_CXX_STANDARD=17 -Dgdml=ON -DCMAKE_INSTALL_PREFIX=${ROOT_DIR}/install  ../source
make -j30
make install

cd ${CURRENT_DIR}

echo ""
echo "The following line has been added to your .bashrc to setup the ROOT environment"
echo ""
echo "source ${ROOT_DIR}/install/bin/thisroot.sh"
echo " " >> ~/.bashrc
echo "#Added by REST installROOT.sh script to setup ROOT environment" >> ~/.bashrc
echo "source ${ROOT_DIR}/install/bin/thisroot.sh" >> ~/.bashrc
echo ""

if [ -f $HOME/.zshrc ]; then
echo ""
echo "The following line has been added to your .zshrc to setup the ROOT environment"
echo ""
echo "source ${ROOT_DIR}/install/bin/thisroot.sh"
echo " " >> ~/.zshrc
echo "#Added by REST installROOT.sh script to setup ROOT environment" >> ~/.zshrc
echo "source ${ROOT_DIR}/install/bin/thisroot.sh" >> ~/.zshrc
echo ""
fi

fi
