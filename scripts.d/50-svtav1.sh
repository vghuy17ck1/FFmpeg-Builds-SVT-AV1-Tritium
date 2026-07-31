#!/bin/bash

SCRIPT_REPO="https://github.com/vghuy17ck1/svt-av1-tritium.git"
SCRIPT_COMMIT="f8691f04c4dc10b6f271756ae9526abf819ed1e3"

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

ffbuild_ldflags() {
    # libdovi.a, libhdr10plus-rs.a and librav1e.a are each --crt-static Rust
    # staticlibs, so each bakes in its own copy of the Rust runtime. Now that
    # SvtAv1Enc genuinely references dovi_*/hdr10plus_*, the linker pulls std
    # members out of more than one of them and trips over duplicate
    # rust_eh_personality, GLOBAL_PANIC_COUNT, driftsort_main, etc. All three
    # are built by the same rustc in the same image, so the definitions are
    # identical and keeping the first one is safe.
    #
    # Confining this to the Rust archives instead (ld -r --whole-archive, then
    # objcopy --keep-global-symbol to hide the runtime) is not possible on
    # Windows: mingw ld cannot do a relocatable link of these archives, it
    # fails with "unable to fill in DataDirectory[9]: _tls_used not defined
    # correctly". So the link-wide flag it is.
    echo "-Wl,--allow-multiple-definition"
}

ffbuild_configure() {
    echo --enable-libsvtav1
}

ffbuild_unconfigure() {
    (( $(ffbuild_ffver) >= 404 )) || return 0
    echo --disable-libsvtav1
}
