FROM nvidia/cuda:11.4.0-devel-ubuntu18.04
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

WORKDIR /root/
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Santiago

# Install base packages
RUN apt update -y
RUN apt upgrade -y
RUN apt install bc csh flex xorg-dev zlib1g-dev build-essential libbz2-dev patch cmake bison gfortran python3 python3-tk python3-pip wget unzip libjpeg-dev zlib1g-dev -y

# Install AWS CLI v2.0
RUN wget https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
RUN unzip awscli-exe-linux-x86_64.zip
RUN ./aws/install

# Copy and unzip Amber22 and AmberTools22
COPY Amber22.tar.bz2 .
COPY AmberTools22.tar.bz2 .
RUN tar xvfj Amber22.tar.bz2
RUN tar xvfj AmberTools22.tar.bz2

# Install Amber's Python dependencies
RUN pip3 install numpy scipy matplotlib

# Compile and install Amber
WORKDIR /root/amber22_src/build
RUN cmake ../ -DCMAKE_INSTALL_PREFIX=/opt/amber22 -DCOMPILER=GNU -DMPI=FALSE -DCUDA=TRUE -DINSTALL_TESTS=TRUE -DDOWNLOAD_MINICONDA=FALSE
RUN make install -j 4

# Use the fetch and run pattern as entrypoint
COPY fetch_and_run.sh /usr/local/bin/fetch_and_run.sh
ENTRYPOINT ["/usr/local/bin/fetch_and_run.sh"]

# Clean up
WORKDIR /root/
RUN rm -rf /root/*
