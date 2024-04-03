#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")

get_tb_major()
{
    tb_dir=$1
    "$tb_dir/thunderbird" -v  | sed -e 's/^Thunderbird \([0-9]\+\)\..*$/\1/'
}

get_patch_path()
{
    tb_dir=$1
    major=$(get_tb_major "$tb_dir")
    patch="$DIR/patches/${major}.patch"

    if [ ! -f "$patch" ]; then
        echo "Patch not available for version $major"
        exit 1
    fi
    echo "$patch"
}

fix_thunderbird()
{
    tb_dir=$1
    dir=$(mktemp -d)
    ja=$(mktemp)
    patch=$(get_patch_path "$tb_dir")
    (
        cd "${dir}"
        echo "Extracting omni.ja"
        if ! unzip -q "${tb_dir}/omni.ja"; then
            echo "Failed to extract '${tb_dir}/omni.ja'"
            exit 1
        fi
        echo "Checking if patch is already applied"
        if patch -f -s -p0 -R --dry-run < "${patch}"; then
            echo "Patch already applied"
            exit 0
        fi
        echo "Patch is not applied"
        if ! patch -f -s --dry-run -p0 < "${patch}"; then
            echo "Patch does not apply cleanly... Sorry !"
            exit 1
        fi
        echo "Patching TB scripts"
        if ! patch -f -s -p0 < "${patch}"; then
            echo "Failed to patch TB."
            exit 1
        fi
        echo "Recompressing omni.ja"
        rm -f "$ja" && zip -0DXqr "${ja}" ./*
        if [ $? -ne 0 ]; then
            echo "Failed to repack omni.ja"
            exit 1
        fi
        cp "${tb_dir}/omni.ja" "${tb_dir}/omni.ja.bak"
        mv "$ja" "${tb_dir}/omni.ja"
        cd -
        rm -Rf "$dir"

        echo "Restarting temporarly TB to purge JS cache"
        "${tb_dir}/thunderbird" -purgecaches &
        sleep 2
        kill %
        wait && true
    )
    return 0
}

if [ "$1" == "" ]; then
    echo "Usage: $0 /path/to/tb/dir"
    exit 1
fi
if [ ! -d "$1" ]; then
    echo "Could not find thunderbird directory '$1'"
    exit 1
fi

fix_thunderbird "$1"
