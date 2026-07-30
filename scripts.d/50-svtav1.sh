#!/bin/bash

SCRIPT_REPO="https://github.com/vghuy17ck1/svt-av1-tritium.git"
SCRIPT_COMMIT="67f0e42c8b958ca7cc6cfe19fd37e5fdd752eda2"

ffbuild_depends() {
    echo libdovi
    echo hdr10plus-rs
}

ffbuild_enabled() {
    [[ $TARGET == win32 ]] && return -1
    (( $(ffbuild_ffver) > 700 )) || return -1
    return 0
}

ffbuild_dockerdl() {
    echo "git clone \"$SCRIPT_REPO\" . && git checkout \"$SCRIPT_COMMIT\""
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF -DBUILD_TESTING=OFF -DBUILD_APPS=OFF -DENABLE_AVX512=ON -DSVT_AV1_LTO=OFF \
        -DEXT_LIB_STATIC=ON -DLIBDOVI_FOUND=ON -DLIBHDR10PLUS_RS_FOUND=ON ..
    make -j$(nproc)
    make install DESTDIR="$FFBUILD_DESTDIR"
}

ffbuild_configure() {
    echo --enable-libsvtav1
}

ffbuild_unconfigure() {
    (( $(ffbuild_ffver) >= 404 )) || return 0
    echo --disable-libsvtav1
}
