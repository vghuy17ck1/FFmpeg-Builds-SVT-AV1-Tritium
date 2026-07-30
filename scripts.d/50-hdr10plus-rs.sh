#!/bin/bash

SCRIPT_REPO="https://github.com/quietvoid/hdr10plus_tool.git"
SCRIPT_COMMIT="faa437e52b317d08f5d0df43278640623d318479"

ffbuild_enabled() {
    [[ $TARGET == win32 ]] && return -1
    (( $(ffbuild_ffver) > 700 )) || return -1
    return 0
}

ffbuild_dockerbuild() {
    cd hdr10plus

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --destdir="$FFBUILD_DESTDIR"
        --target="$FFBUILD_RUST_TARGET"
        --library-type=staticlib
        --crt-static
        --release
        --features=capi
    )

    export "AR_${FFBUILD_RUST_TARGET//-/_}"="$AR"
    export "RANLIB_${FFBUILD_RUST_TARGET//-/_}"="$RANLIB"
    export "NM_${FFBUILD_RUST_TARGET//-/_}"="$NM"
    export "LD_${FFBUILD_RUST_TARGET//-/_}"="$LD"
    export "CC_${FFBUILD_RUST_TARGET//-/_}"="$CC"
    export "CXX_${FFBUILD_RUST_TARGET//-/_}"="$CXX"
    export "CFLAGS_${FFBUILD_RUST_TARGET//-/_}"="$CFLAGS"
    export "CXXFLAGS_${FFBUILD_RUST_TARGET//-/_}"="$CXXFLAGS"
    export "LDFLAGS_${FFBUILD_RUST_TARGET//-/_}"="$LDFLAGS"
    unset AR RANLIB NM CC CXX LD CFLAGS CXXFLAGS LDFLAGS

    cargo cinstall -v "${myconf[@]}"
}
