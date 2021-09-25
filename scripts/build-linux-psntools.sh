#!/bin/sh -eu
# debug cmake: MY_CMAKE_PARAMETERS='--debug-output' <script>
# build SWIG wrappers: MY_CMAKE_PARAMETERS='-DCUSTOM_BUILD_SWIG=ON' <script>

hr ()
{
  printf -- '============================================================\n'
}

MY_BITNESS="${1:-}"
if [ -z "${MY_BITNESS}" ]; then
  MY_PYTHON_PLATFORM="linux-$(uname -m)"
elif [ "${MY_BITNESS}" = '64' ]; then
  MY_PYTHON_PLATFORM='linux-x86_64'
elif [ "${MY_BITNESS}" = '32' ]; then
  MY_PYTHON_PLATFORM='linux-i686'
fi

MY_CMAKE_PARAMETERS="${MY_CMAKE_PARAMETERS:+${MY_CMAKE_PARAMETERS} }-Wdev ${MY_BITNESS:+-DCMAKE_C_FLAGS=-m${MY_BITNESS} -DCMAKE_CXX_FLAGS=-m${MY_BITNESS}}"
## Passing platform: -DCUSTOM_PLATFORM=${MY_PYTHON_PLATFORM}

hr

## static library
MY_BUILD_DIR="build/${MY_PYTHON_PLATFORM}-static"
[ ! -d "${MY_BUILD_DIR}" ] || rm -rf "${MY_BUILD_DIR}"
cmake -B "${MY_BUILD_DIR}" -DBUILD_SHARED_LIBS=OFF ${MY_CMAKE_PARAMETERS:+${MY_CMAKE_PARAMETERS}}
cmake --build "${MY_BUILD_DIR}"
printf -- '----------\n'
printf -- 'as root: cmake --install "%s"\n' "${PWD}/${MY_BUILD_DIR}"
hr

## shared library
MY_BUILD_DIR="build/${MY_PYTHON_PLATFORM}-shared"
[ ! -d "${MY_BUILD_DIR}" ] || rm -rf "${MY_BUILD_DIR}"
cmake -B "${MY_BUILD_DIR}" -DBUILD_SHARED_LIBS=ON ${MY_CMAKE_PARAMETERS:+${MY_CMAKE_PARAMETERS}}
cmake --build "${MY_BUILD_DIR}"
printf -- '----------\n'
printf -- 'as root: cmake --install "%s"\n' "${PWD}/${MY_BUILD_DIR}"
hr
