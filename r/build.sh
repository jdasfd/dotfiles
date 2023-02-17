#!/bin/bash

BASE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# source URI
sudo cp /etc/apt/sources.list /etc/apt/sources.list~
sudo sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list
sudo sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

sudo apt -y update

# This command will install texlive
# sudo apt -y build-dep r-base

sudo apt -y install build-essential
sudo apt -y install gfortran

# sudo apt install apt-rdepends
# apt-rdepends --build-depends --print-state --follow=DEPENDS r-base

sudo apt -y install groff-base libxml2-dev gettext
sudo apt -y install libblas-dev liblapack-dev
sudo apt -y install libcurl4-openssl-dev libncurses5-dev libreadline-dev
sudo apt -y install libcairo2-dev libjpeg-dev libpango1.0-dev libpng-dev libtiff5-dev
sudo apt -y install libbz2-dev liblzma-dev zlib1g-dev

sudo apt -y install ghostscript libfreetype-dev fontconfig

# udunit2, gdal
sudo apt -y install cmake
sudo apt -y install udunits-bin libudunits2-dev
sudo apt -y install gdal-bin libgdal-dev

mkdir -p $HOME/share/R

cd
curl -L https://mirrors.tuna.tsinghua.edu.cn/CRAN/src/base/R-4/R-4.2.1.tar.gz |
    tar xvz
cd R-4.2.1

# brewed binaries confuse configure
hash brew 2>/dev/null && {
    brew unlink pkg-config
}

CC=gcc CXX=g++ FC=gfortran ./configure \
    --prefix="$HOME/share/R" \
    --enable-memory-profiling \
    --disable-java \
    --with-pcre1 \
    --with-blas \
    --with-lapack \
    --without-x \
    --without-tcltk \
    --without-ICU \
    --with-cairo \
    --with-libpng \
    --with-jpeglib \
    --with-libtiff \
    --with-gnu-ld

make -j 8

bin/Rscript -e '
    capabilities();
    png("test.png");
    plot(rnorm(4000),rnorm(4000),col="#ff000018",pch=19,cex=2);
    dev.off();
    '

make install

cd
rm -fr ~/R-4.2.1

if grep -q -i R_42_PATH $HOME/.bashrc; then
    echo "==> .bashrc already contains R_42_PATH"
else
    echo "==> Updating .bashrc with R_42_PATH..."
    R_42_PATH="export PATH=\"$HOME/share/R/bin:\$PATH\""
    echo '# R_42_PATH' >> $HOME/.bashrc
    echo $R_42_PATH    >> $HOME/.bashrc
    echo >> $HOME/.bashrc
fi

source ~/.bashrc
