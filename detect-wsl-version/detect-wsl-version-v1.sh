#!/bin/bash

# Copyright (C) 2021  thomas.rudolph@gmail.com
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <https://www.gnu.org/licenses/>.


# environment variable "WSL_DISTRO_NAME" exists always if running on WSL
[ -n "${WSL_DISTRO_NAME}" ] || exit

_wsl_version="0"

# Check for WSL 1 with lxfs
if [ $( mount -t lxfs | grep '^rootfs' -c ) -gt 0 ]; then

    _wsl_version="1"

# Check for WSL 1 with wslfs
elif [ $( mount -t wslfs | grep '^rootfs' -c ) -gt 0 ]; then

    _wsl_version="1"

# Check for 
#   -   WSL 1 with other filesystems than checked above
#   -   WSL 2 and newer
else

    # Looking for wsl.exe
    _wsl_exe="/WINDOWS/system32/wsl.exe"

    for _letter in {a..z} 
    do
        [ -e "/mnt/${_letter}${_wsl_exe}" ] || continue;
        break
    done

    _wsl_exe="/mnt/${_letter}${_wsl_exe}" 

    # wsl.exe not found ... exit
    [ ! -e "${_wsl_exe}" ] && exit

    # create tmp file
    _tmp_file="$( realpath ${BASH_SOURCE[0]} )"
    _tmp_file="${_tmp_file##*/}"
    _tmp_file=$( mktemp -t ${_tmp_file%.*}.XXXXXXXXXX )

    # call wsl.exe... write result to tmp file
    ${_wsl_exe} --list --verbose > ${_tmp_file} 

    # check result
    while read _line; do
        if [[ "${_line}" =~ ^${WSL_DISTRO_NAME}.* ]] ; then
            _wsl_version=$( echo ${_line} | awk -F ' ' '{print $3}' )
            break
        fi
    done < ${_tmp_file}

    # remove tmp file
    rm ${_tmp_file}

fi

echo "WSL Version: ${_wsl_version}"
