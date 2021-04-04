#!/bin/bash

# environment variable "WSL_DISTRO_NAME" exists always if running on WSL
[ -n "${WSL_DISTRO_NAME}" ] || exit

_wsl_version="0"

# Check for WSL 1 with lxfs or wslfs
if [ -n "$( cat /proc/self/mounts | grep rootfs | grep -E 'lxfs | wslfs' )" ] ; then

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

    # wsl.exe writes null chars ("\000" or short "\0") to output ... remove with tr
    _result=$( ${_wsl_exe} --list --verbose |  tr -d '\0' | grep  ${WSL_DISTRO_NAME} | awk -F ' ' '{print $3}' )
    [ -n "${_result}" ] && _wsl_version="${_result}"
    
    unset _result
    unset _wsl_exe
 
fi

echo "WSL Version: ${_wsl_version}"
