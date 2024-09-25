# Base image for cmpt 373 projects.
# Build with:
#    docker buildx build -t nsumner/cmpt373:fall2024 .
FROM ubuntu:noble AS build

RUN apt-get update -y \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
    software-properties-common \
    && add-apt-repository ppa:ubuntu-toolchain-r/ppa -y \
    && apt-get update -y \
    \
    && `# Start with all normal ubuntu packages` \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
    apt-utils \
    ca-certificates \
    lsb-release \
    gnupg2 \
    wget \
    git \
    make \
    ninja-build \
    cmake \
    valgrind \
    heaptrack \
    cppcheck \
    libncurses5-dev \
    libsqlite3-dev \
    zlib1g-dev \
    xz-utils \
    bzip2 \
    googletest \
    nlohmann-json3-dev \
    libfmt-dev \
    python3 \
    python3-pip \
    gcc-14 \
    g++-14 \
    gdb \
    gcovr \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 1000 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-14 1000 \
    \
    && `# Install boost` \
    && `# Can also use ubuntu packages, but they depend on old GCC versions` \
    && wget http://downloads.sourceforge.net/project/boost/boost/1.83.0/boost_1_83_0.tar.gz \
    && tar xfz boost_1_83_0.tar.gz \
    && rm boost_1_83_0.tar.gz \
    && cd boost_1_83_0 \
    && ./bootstrap.sh --with-libraries=system,filesystem,container,locale,log,program_options,serialization,stacktrace,test \
    && ./b2 cxxstd=23 install \
    && cd ../ && rm -rf boost_1_83_0 \
    \
    && `# Install the latest version of LLVM` \
    && wget https://apt.llvm.org/llvm.sh \
    && chmod +x llvm.sh \
    && ./llvm.sh 18 \
    && rm llvm.sh \
    && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-18 1000 \
    && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-18 1000 \
    && update-alternatives --install /usr/bin/llvm-profdata llvm-profdata /usr/bin/llvm-profdata-18 1000 \
    && update-alternatives --install /usr/bin/llvm-cov llvm-cov /usr/bin/llvm-cov-18 1000 \
    \
    `# Install emscripten` \
    && cd /opt \
    && git clone https://github.com/emscripten-core/emsdk.git \
    && cd emsdk \
    && ./emsdk install latest \
    && ./emsdk activate latest \
    && ./emsdk construct_env \
    && echo "/opt/emsdk/emsdk activate latest" >> /etc/profile \
    && echo ". /opt/emsdk/emsdk_env.sh" >> /etc/profile \
    \
    && `# Install spdlog` \
    && git clone https://github.com/gabime/spdlog.git \
    && cd spdlog && mkdir build && cd build \
    && cmake .. && make -j && make install \
    && cd ../.. && rm -rf ./spdlog \
    \
    && `# Late stage ubuntu packages` \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
    heaptrack \
    \
    && `# Final cleanup` \
    && rm -rf /var/lib/apt/lists/*

