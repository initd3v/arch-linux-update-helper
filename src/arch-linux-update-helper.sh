#!/bin/bash

# Author: Martin Manegold
# Description: Arch Linux upgrade script for updating community based packeges / official packages and cleaning up the pacman cache.
# VersioN: 2.0

function f_quit() {
    if [ "${SCRIPT_ERRORLOCK}x" == "0x" ] ; then
        /usr/bin/rmdir "${SCRIPT_LOCK}" > /dev/null 2>&1
    fi

    exit 0
}

function f_out(){
    if [ "${1}x" != "x" ] ; then
        if [ -f "${SCRIPT_LOG}" ] ; then
            ${CMD_ECHO} "${1}" >> "${SCRIPT_LOG}"
        fi
        ${CMD_ECHO} -e "${1}"
    fi
}

function f_init() {

    # set script relevant variables
	SCRIPT_NAME=$( /usr/bin/realpath "$0" )
	SCRIPT_PATH=$( /usr/bin/dirname "$SCRIPT_NAME" )
	SCRIPT_LOCK="/tmp/.updater.lck"
	SCRIPT_ERRORLOCK=0

	# set exit codes
	/usr/bin/true
	TMP_TRUE=$?
	/usr/bin/false
	TMP_FALSE=$?

	# set output format variables
	TMP_OUTPUT_COLOR_RED="\033[31m"
    TMP_OUTPUT_COLOR_GREEN="\033[32m"
    TMP_OUTPUT_COLOR_YELLOW="\033[33m"
    TMP_OUTPUT_COLOR_RESET="\033[0m"
    TMP_OUTPUT_CHECK="✓"
    TMP_OUTPUT_CROSS="✗"

	# set command binary paths
	CMD_ECHO="/bin/echo"
	CMD_AWK="/usr/bin/awk"
	CMD_WHEREIS="/usr/bin/whereis"
    CMD_CURL=$( ${CMD_WHEREIS} curl | ${CMD_AWK} '{ print $2 }' )
	CMD_CURL=${CMD_CURL:-/usr/bin/curl}
	CMD_DATE=$( ${CMD_WHEREIS} date | ${CMD_AWK} '{ print $2 }' )
	CMD_DATE=${CMD_DATE:-/usr/bin/date}
    CMD_GIT=$( ${CMD_WHEREIS} git | ${CMD_AWK} '{ print $2 }' )
	CMD_GIT=${CMD_GIT:-/usr/bin/git}
	CMD_GREP=$( ${CMD_WHEREIS} grep | ${CMD_AWK} '{ print $2 }' )
	CMD_GREP=${CMD_GREP:-/usr/bin/grep}
    CMD_ID=$( ${CMD_WHEREIS} id | ${CMD_AWK} '{ print $2 }' )
	CMD_ID=${CMD_ID:-/usr/bin/id}
    CMD_MAKEPKG=$( ${CMD_WHEREIS} makepkg | ${CMD_AWK} '{ print $2 }' )
	CMD_MAKEPKG=${CMD_MAKEPKG:-/usr/bin/makepkg}
	CMD_MKDIR=$( ${CMD_WHEREIS} mkdir | ${CMD_AWK} '{ print $2 }' )
	CMD_MKDIR=${CMD_MKDIR:-/usr/bin/mkdir}
	CMD_PACMAN=$( ${CMD_WHEREIS} pacman | ${CMD_AWK} '{ print $2 }' )
	CMD_PACMAN=${CMD_PACMAN:-/usr/bin/pacman}
	CMD_RM=$( ${CMD_WHEREIS} rm | ${CMD_AWK} '{ print $2 }' )
	CMD_RM=${CMD_RM:-/usr/bin/rm}
    CMD_SUDO=$( ${CMD_WHEREIS} sudo | ${CMD_AWK} '{ print $2 }' )
	CMD_SUDO=${CMD_SUDO:-/usr/bin/sudo}
	CMD_YES=$( ${CMD_WHEREIS} yes | ${CMD_AWK} '{ print $2 }' )
	CMD_YES=${CMD_YES:-/usr/bin/yes}

	for TMP in "${CMD_ECHO}" "${CMD_AWK}" "${CMD_WHEREIS}" "${CMD_DATE}" "${CMD_GIT}" "${CMD_GREP}" "${CMD_ID}" "${CMD_MAKEPKG}" "${CMD_MKDIR}" "${CMD_PACMAN}" "${CMD_RM}" "${CMD_SUDO}" "${CMD_YES}" ; do
		if [ "${TMP}x" == "x" ] && [ -f "${TMP}" ] ; then
			TMP_NAME=(${!TMP@})
            f_out "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [The bash variable '${TMP_NAME}' with value '${TMP}' does not reference to a valid command binary path or is empty.]${TMP_OUTPUT_COLOR_RESET}"
            f_quit
		fi
	done

    # set log file
    SCRIPT_LOG="/tmp/updater.log"
    ${CMD_ECHO} "[STARTING]" > "${SCRIPT_LOG}"

    # check / set script lock
    if [ -d "${SCRIPT_LOCK}" ] ; then
        SCRIPT_ERRORLOCK=1
        f_out "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [There is already a instance of the script running due to the lock folder '${SCRIPT_LOCK}'.]${TMP_OUTPUT_COLOR_RESET}"
        f_quit
    else
        ${CMD_MKDIR} "${SCRIPT_LOCK}" > /dev/null 2>&1
        if [ $? -eq ${TMP_FALSE} ] ; then
            f_out "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [The lock folder '${SCRIPT_LOCK}' could not be created.]${TMP_OUTPUT_COLOR_RESET}"
            f_quit
        fi
    fi
    UPDATE_ID=$( ${CMD_ID} -u )
    UPDATE_SUDO_CHECK=$( ${CMD_SUDO} --non-interactive --list | ${CMD_GREP} --ignore-case "pacman" )
    if [ "${UPDATE_ID}" != "0" ] && [ "${UPDATE_SUDO_CHECK}x" == "x" ] ; then
        f_out "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [No sudo rights for the current user on command 'pacman' could be identified. This is needed for installing packages.]${TMP_OUTPUT_COLOR_RESET}"
        f_quit
    fi

    f_update
}

function f_update() {
    UPDATE_AUR_PACKAGE_LIST=$( ${CMD_PACMAN} --query --foreign --explicit )
    if [ "${UPDATE_ID}" != "0" ] ; then
        if [ "${UPDATE_AUR_PACKAGE_LIST}x" != "x" ] ; then
            UPDATE_AUR_BASE_LINK="https://aur.archlinux.org"
            f_out "${TMP_OUTPUT_COLOR_GREEN}[${TMP_OUTPUT_CHECK}] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [Starting to update community based packages at '${UPDATE_AUR_BASE_LINK}'.]${TMP_OUTPUT_COLOR_RESET}"
            TMP_IFS=$IFS
            IFS=$'\n'
            for i in ${UPDATE_AUR_PACKAGE_LIST} ; do
                UPDATE_AUR_PACKAGE_NAME=$( ${CMD_AWK} '{ print $1 }' <<< "${i}" )
                UPDATE_AUR_PACKAGE_VERSION=$( ${CMD_AWK} '{ print $2 }' <<< "${i}" )
                if [ "${UPDATE_AUR_PACKAGE_NAME}x" == "x" ] ; then
                    f_out "${TMP_OUTPUT_COLOR_YELLOW}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [The package name is empty. Skipping it...]${TMP_OUTPUT_COLOR_RESET}"
                    continue
                fi

                if [ "${UPDATE_AUR_PACKAGE_VERSION}x" == "x" ] ; then
                    f_out "${TMP_OUTPUT_COLOR_YELLOW}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [The package version for package '${UPDATE_AUR_PACKAGE_NAME}' is empty. Skipping it...]${TMP_OUTPUT_COLOR_RESET}"
                    continue
                fi

                TMP_AUR_PACKAGE_URI_CHECK=$( ${CMD_CURL} --connect-timeout 5 --write-out "%{http_code}\n" --output /dev/null --silent "${UPDATE_AUR_BASE_LINK}/packages/${UPDATE_AUR_PACKAGE_NAME}" )
                if [ "${TMP_AUR_PACKAGE_URI_CHECK}" != "200" ] ; then
                    f_out "${TMP_OUTPUT_COLOR_YELLOW}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [The URI '${UPDATE_AUR_BASE_LINK}/packages/${UPDATE_AUR_PACKAGE_NAME}' for package '${UPDATE_AUR_PACKAGE_NAME}' could not be reached.]${TMP_OUTPUT_COLOR_RESET}"
                    read -p "[?] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [As the package '${UPDATE_AUR_PACKAGE_NAME}' could not be found anymore, would you like to uninstall it? Type 'y' and press [ENTER] for removing it:] " TMP_ANSWER
                    if [ "${TMP_ANSWER}x" == "yx" ] ; then
                        if [ "${UPDATE_ID}" == "0" ] ;  then
                            ${CMD_YES} | ${CMD_PACMAN} --remove --noconfirm "${UPDATE_AUR_PACKAGE_NAME}" > /dev/null 2>&1
                        else
                            ${CMD_YES} | ${CMD_SUDO} ${CMD_PACMAN} --remove --noconfirm "${UPDATE_AUR_PACKAGE_NAME}" > /dev/null 2>&1
                        fi
                    fi
                    TMP_ANSWER=""
                    continue
                fi

                TMP_AUR_PACKAGE_VERSION=$( ${CMD_CURL} --connect-timeout 5 --silent "${UPDATE_AUR_BASE_LINK}/packages/${UPDATE_AUR_PACKAGE_NAME}" | ${CMD_GREP} --ignore-case "Package Details: " | ${CMD_AWK} '{ print $NF }' | ${CMD_AWK} -F '<' '{print $1}' )

                if [ "${TMP_AUR_PACKAGE_VERSION}" == "${UPDATE_AUR_PACKAGE_VERSION}" ] ; then
                    f_out "${TMP_OUTPUT_COLOR_YELLOW}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [The package version for package '${UPDATE_AUR_PACKAGE_NAME}' is already on the newest version '${UPDATE_AUR_PACKAGE_VERSION}'. Skipping it...]${TMP_OUTPUT_COLOR_RESET}"
                    continue
                fi

                TMP_AUR_PACKAGE_GIT=$( ${CMD_CURL} --connect-timeout 5 --silent "${UPDATE_AUR_BASE_LINK}/packages/${UPDATE_AUR_PACKAGE_NAME}" | ${CMD_GREP} --ignore-case 'class="copy" href="'| ${CMD_AWK} -F 'class="copy" href="' '{print $2}' | ${CMD_AWK} -F '"' '{print $1}' )
                if [ "${TMP_AUR_PACKAGE_GIT}x" == "x" ] ; then
                    f_out "${TMP_OUTPUT_COLOR_YELLOW}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [The GIT URI for package '${UPDATE_AUR_PACKAGE_NAME}' could not be extracted. Skipping it...]${TMP_OUTPUT_COLOR_RESET}"
                    continue
                fi

                ${CMD_GIT} clone --quiet "${TMP_AUR_PACKAGE_GIT}" "/tmp/${UPDATE_AUR_PACKAGE_NAME}" > /dev/null 2>&1
                if [ $? -ne ${TMP_TRUE} ] ;  then
                    f_out "${TMP_OUTPUT_COLOR_YELLOW}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [The package '${UPDATE_AUR_PACKAGE_NAME}' could not be downloaded from URI '${TMP_AUR_PACKAGE_GIT}' to local path '/tmp/${UPDATE_AUR_PACKAGE_NAME}'. Skipping it...]${TMP_OUTPUT_COLOR_RESET}"
                    ${CMD_RM} --recursive --force "/tmp/${UPDATE_AUR_PACKAGE_NAME}" 2> /dev/null
                    continue
                fi

                ${CMD_MAKEPKG} --dir "/tmp/${UPDATE_AUR_PACKAGE_NAME}" --syncdeps --install --needed --noconfirm > /dev/null 2>&1
                if [ $? -ne ${TMP_TRUE} ] ;  then
                    f_out "${TMP_OUTPUT_COLOR_YELLOW}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [The package '${UPDATE_AUR_PACKAGE_NAME}' could not be installed from local path '/tmp/${UPDATE_AUR_PACKAGE_NAME}'. Skipping it...]${TMP_OUTPUT_COLOR_RESET}"
                    ${CMD_RM} --recursive --force "/tmp/${UPDATE_AUR_PACKAGE_NAME}" 2> /dev/null
                    continue
                fi

                f_out "${TMP_OUTPUT_COLOR_GREEN}[${TMP_OUTPUT_CHECK}] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [The package '${UPDATE_AUR_PACKAGE_NAME}' was successully updated to version '${UPDATE_AUR_PACKAGE_VERSION}'.]${TMP_OUTPUT_COLOR_RESET}"
                ${CMD_RM} --recursive --force "/tmp/${UPDATE_AUR_PACKAGE_NAME}" 2> /dev/null
            done
            IFS=$TMP_IFS
        else
            f_out "${TMP_OUTPUT_COLOR_YELLOW}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [The community packages found. Skipping it...]${TMP_OUTPUT_COLOR_RESET}"
        fi
    else
        f_out "${TMP_OUTPUT_COLOR_YELLOW}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [The community package update can not be run as 'root' because of the 'makepkg' routine. Skipping it...]${TMP_OUTPUT_COLOR_RESET}"
    fi

    f_out "${TMP_OUTPUT_COLOR_GREEN}[${TMP_OUTPUT_CHECK}] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [Finished the update of community based packages at '${UPDATE_AUR_BASE_LINK}'.]${TMP_OUTPUT_COLOR_RESET}"

    f_out "${TMP_OUTPUT_COLOR_GREEN}[${TMP_OUTPUT_CHECK}] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [Starting full upgrade of official packages.]${TMP_OUTPUT_COLOR_RESET}"

    if [ "${UPDATE_ID}" == "0" ] ;  then
        ${CMD_PACMAN} --sync --refresh > /dev/null 2>&1
    else
        ${CMD_SUDO} ${CMD_PACMAN} --sync --refresh > /dev/null 2>&1
    fi

    TMP_OFFICIAL_UPGRADE_LIST=$( ${CMD_PACMAN} --query --upgrades )

    if [ "${TMP_OFFICIAL_UPGRADE_LIST}x" != "x" ] ; then
        f_out "[${TMP_OUTPUT_CHECK}] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [The following upgrades are available:]"
        ${CMD_ECHO}
        TMP_IFS=$IFS
        IFS=$'\n'
        for i in ${TMP_OFFICIAL_UPGRADE_LIST} ; do
            ${CMD_ECHO} -e "\t${i}"
        done
        IFS=$TMP_IFS
        ${CMD_ECHO}
        read -p "[?] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [Would you like to like to upgrade those packages? Type 'y' and press [ENTER] for updating them:] " TMP_ANSWER

        if [ "${TMP_ANSWER}x" == "yx" ] ; then
            if [ "${UPDATE_ID}" == "0" ] ;  then
                ${CMD_YES} | ${CMD_PACMAN} --sync --refresh --sysupgrade --noconfirm --quiet > /dev/null 2>&1
            else
                ${CMD_YES} | ${CMD_SUDO} ${CMD_PACMAN} --sync --refresh --sysupgrade --noconfirm --quiet > /dev/null 2>&1
            fi

            if [ $? -eq 0 ] ;  then
                f_out "${TMP_OUTPUT_COLOR_GREEN}[${TMP_OUTPUT_CHECK}] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [Finished full upgrade of official packages successfully.]${TMP_OUTPUT_COLOR_RESET}"
            else
                f_out "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [Could not finish full upgrade of official packages successfully.]${TMP_OUTPUT_COLOR_RESET}"
            fi
        else
            f_out "${TMP_OUTPUT_COLOR_YELLOW}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [You have chosen to skip the official upgrades by not pressing 'y'. Skipping it...]${TMP_OUTPUT_COLOR_RESET}"
        fi
    else
        f_out "${TMP_OUTPUT_COLOR_YELLOW}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [There are no official packages to upgrade. Skipping it...]${TMP_OUTPUT_COLOR_RESET}"
    fi
    TMP_ANSWER=""
    read -p "[?] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [Would you like to clean up the pacman cache? Type 'y' and press [ENTER] for updating them:] " TMP_ANSWER

    if [ "${TMP_ANSWER}x" == "yx" ] ; then
        if [ "${UPDATE_ID}" == "0" ] ;  then
            ${CMD_YES} | ${CMD_PACMAN} --sync --clean --noconfirm --quiet > /dev/null 2>&1
        else
            ${CMD_YES} | ${CMD_SUDO} ${CMD_PACMAN} --sync --clean --noconfirm --quiet > /dev/null 2>&1
        fi

        if [ $? -eq 0 ] ;  then
            f_out "${TMP_OUTPUT_COLOR_GREEN}[${TMP_OUTPUT_CHECK}] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [Finished the cleanup of the pacman cache successfully.]${TMP_OUTPUT_COLOR_RESET}"
        else
            f_out "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [Could not finish the cleanup of the pacman cache successfully.]${TMP_OUTPUT_COLOR_RESET}"
        fi
    else
        f_out "${TMP_OUTPUT_COLOR_YELLOW}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} +"%d%m%Y_%H%M%S" )] [You have chosen to skip the pacman cache cleanup by not pressing 'y'. Skipping it...]${TMP_OUTPUT_COLOR_RESET}"
    fi

    f_quit
}

f_init
