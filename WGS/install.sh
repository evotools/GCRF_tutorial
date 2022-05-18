#!/bin/bash
## Create a variable to find the way back
LOCALDIR=`pwd`

## Create the folder where we will install all the software we need
if [ ! -e BIN ] ; then 
	mkdir BIN && cd BIN
else
	cd BIN && rm -rf ./*
fi

## Install missing Ubuntu dependencies
sudo apt update && \
	sudo DEBIAN_FRONTEND=noninteractive apt install -y automake make gcc g++ perl python3-pip && \
	sudo DEBIAN_FRONTEND=noninteractive apt install -y libz-dev unzip wget curl pkg-config libncurses-dev && \
	sudo DEBIAN_FRONTEND=noninteractive apt install -y libbz2-dev liblzma-dev libcurl4-openssl-dev libssl-dev && \
	sudo DEBIAN_FRONTEND=noninteractive apt install -y openjdk-11-jre git cpanminus && \
	sudo DEBIAN_FRONTEND=noninteractive apt install -y libmodule-build-perl libdbi-perl libdbd-mysql-perl build-essential zlib1g-dev

## Install perl dependencies
cpanm Archive::Zip && \
	cpanm DBD::mysql  && \
	cpanm Module::Build

## Install Fastqc
wget --no-check-certificate https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip \
   && unzip fastqc_v0.11.9.zip
cd FastQC
chmod a+x fastqc
echo 'export PATH=$PATH:'$PWD > $LOCALDIR/source_me.sh
cd ../

## Install BWA-MEM2
curl -L https://github.com/bwa-mem2/bwa-mem2/releases/download/v2.0pre2/bwa-mem2-2.0pre2_x64-linux.tar.bz2 \
   | tar jxf -
cd bwa-mem2-2.0pre2_x64-linux 
echo 'export PATH=$PATH:'$PWD >> $LOCALDIR/source_me.sh
cd ../

## Install samtools
curl -L https://github.com/samtools/samtools/releases/download/1.15.1/samtools-1.15.1.tar.bz2 \
   | tar jxf -
cd samtools-1.15.1 && autoheader && autoconf -Wno-syntax && ./configure && make -j 4
echo 'export PATH=$PATH:'$PWD >> $LOCALDIR/source_me.sh
cd ../

# Install bcftools
curl -L https://github.com/samtools/bcftools/releases/download/1.15.1/bcftools-1.15.1.tar.bz2 \
   | tar jxf -
cd bcftools-1.15.1 && make -j 4
echo 'export BCFTOOLS_PLUGINS='${PWD}/plugins >> $LOCALDIR/source_me.sh
echo 'export PATH=$PATH:'$PWD >> $LOCALDIR/source_me.sh
cd ../

## Install vcftools
wget https://github.com/vcftools/vcftools/releases/download/v0.1.16/vcftools-0.1.16.tar.gz \
   && tar xvfz vcftools-0.1.16.tar.gz 
cd vcftools-0.1.16 
echo 'export PERL5LIB='${PWD}/src/perl/ >> $LOCALDIR/source_me.sh
./configure
make
echo 'export PATH=$PATH:'${PWD}/src/cpp:${PWD}/src/perl >> $LOCALDIR/source_me.sh
cd ..

## Install biobambam2
curl -L https://gitlab.com/german.tischler/biobambam2/uploads/ffbf93e1b4ca3a695bba8f10b131cf44/biobambam2_x86_64-linux-gnu_2.0.180.tar.xz \
   | tar Jxf -
echo 'export PATH=$PATH:'$PWD/biobambam2/x86_64-linux-gnu/2.0.180/bin >> $LOCALDIR/source_me.sh

## Install freebayes
wget https://github.com/freebayes/freebayes/releases/download/v1.3.6/freebayes-1.3.6-linux-amd64-static.gz && \
gunzip -c freebayes-1.3.6-linux-amd64-static.gz > freebayes && chmod a+x freebayes
echo 'export PATH=$PATH:'$PWD >> $LOCALDIR/source_me.sh

## Install cutadapt...
sudo pip install --upgrade cutadapt

## ... and then Trim_Galore!
curl -fsSL https://github.com/FelixKrueger/TrimGalore/archive/0.6.6.tar.gz -o trim_galore.tar.gz
tar xvzf trim_galore.tar.gz
echo 'export PATH=$PATH:'${PWD}/TrimGalore-0.6.6/ >> $LOCALDIR/source_me.sh

# Install tabix
git clone https://github.com/samtools/tabix.git
cd tabix 
make
echo 'export PATH=$PATH:'${PWD} >> $LOCALDIR/source_me.sh
cd ../

## Install MultiQC
sudo pip install multiqc

# Install VEP
git clone https://github.com/Ensembl/ensembl-vep.git
cd ensembl-vep
perl INSTALL.pl -a a
echo 'export PATH=$PATH:'${PWD} >> $LOCALDIR/source_me.sh

# Move back to the initial point
cd $LOCALDIR

# Now make everything accessible
echo "Now run the command:"
echo "    source ./source_me.sh"
