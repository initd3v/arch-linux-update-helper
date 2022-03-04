#!/bin/sh

processOutput(){
	case $1 in
		"error")
			if [ ${VERBOSITY_LEVEL} -ne 0 ] ; then
				TMP_TIME=`${CMD_DATE} +"%d%m%Y_%H%M%S"`
				if [ -d "${AUR_DOWNLOAD_FOLDER}" ] ; then
					${CMD_ECHO} -e "${TMP_TIME}$2" >> "${AUR_DOWNLOAD_FOLDER}/arch-linux-update-helper.log"
				fi
				if [ "${CMD_SYSTEMDCAT}" != "x" ] && [ -f ${CMD_SYSTEMDCAT} ] ; then
					${CMD_ECHO} -e "$2" | ${CMD_SYSTEMDCAT} -t ArchLinuxUpdateHelper >/dev/null 2>&1
				fi
				if  [ ${VERBOSITY_LEVEL} -ne 1 ] ; then
					${CMD_ECHO} -e "$2"
				fi
				exit ${TMP_FALSE}
			fi
			;;
		"message")
			if [ ${VERBOSITY_LEVEL} -ne 0 ]; then
				TMP_TIME=`${CMD_DATE} +"%d%m%Y_%H%M%S"`
				if [ -d "${AUR_DOWNLOAD_FOLDER}" ] ; then
					${CMD_ECHO} -e "${TMP_TIME}$2" >> "${AUR_DOWNLOAD_FOLDER}/arch-linux-update-helper.log"
				fi
				if [ "${CMD_SYSTEMDCAT}" != "x" ] && [ -f ${CMD_SYSTEMDCAT} ] ; then
					${CMD_ECHO} "$2" | ${CMD_SYSTEMDCAT} -t ArchLinuxUpdateHelper >/dev/null 2>&1
				fi
				if [ ${VERBOSITY_LEVEL} -ne 1 ] ; then
					${CMD_ECHO} -e "$2"
				fi
			fi
			;;
		*)
			if [ ${VERBOSITY_LEVEL} -ne 0 ] ; then
				TMP_TIME=`${CMD_DATE} +"%d%m%Y_%H%M%S"`
				${CMD_ECHO} -e "${TMP_TIME}ERROR: No valid event can be prosecessed. Possibly script error exists for subroutine call precessOutput().\n" >> "${LOG_PATH}/cgroupmount.log"
			fi
			;;
	esac
}

processInitialization(){

    # set version information
	VERSION="1.0"

	# set script execution path
	SCRIPT_NAME=`/usr/bin/realpath "$0"`
	SCRIPT_PATH=`/usr/bin/dirname "$SCRIPT_NAME"`

	# set exit codes
	/usr/bin/true
	TMP_TRUE=$?
	/usr/bin/false
	TMP_FALSE=$?

	# set command binary paths
	CMD_ECHO="/bin/echo"
	CMD_AWK="/usr/bin/awk"
	CMD_WHEREIS="/usr/bin/whereis"
	CMD_DATE=`${CMD_WHEREIS} date | ${CMD_AWK} '{ print $2 }'`
	CMD_GREP=`${CMD_WHEREIS} grep | ${CMD_AWK} '{ print $2 }'`
	CMD_CURL=`${CMD_WHEREIS} curl | ${CMD_AWK} '{ print $2 }'`
	CMD_GIT=`${CMD_WHEREIS} git | ${CMD_AWK} '{ print $2 }'`
	CMD_PACMAN=`${CMD_WHEREIS} pacman | ${CMD_AWK} '{ print $2 }'`
	CMD_MAKEPKG=`${CMD_WHEREIS} makepkg | ${CMD_AWK} '{ print $2 }'`
	CMD_SUDO=`${CMD_WHEREIS} sudo | ${CMD_AWK} '{ print $2 }'`
	CMD_ID=`${CMD_WHEREIS} id | ${CMD_AWK} '{ print $2 }'`

	for TMP in "${CMD_ECHO}" "${CMD_AWK}" "${CMD_WHEREIS}" "${CMD_DATE}" "${CMD_GREP}" "${CMD_CURL}" "${CMD_GIT}" "${CMD_PACMAN}" "${CMD_MAKEPKG}" "${CMD_SUDO}" "${CMD_ID}" ; do
		if [ "${TMP}x" == "x" ] || [ ! -f "${TMP}" ] ; then
			TMP_NAME=(${!TMP@})
			ERROR="${ERROR}ERROR: The bash variable '${TMP_NAME}' with value '${TMP}' does not reference to a valid command binary path or is empty.\n"
		fi
	done

    AUR_DOWNLOAD_FOLDER="/tmp"

	# processParameters
	processParameters

	# check on write permission for current user
	if [ ! -w "${AUR_DOWNLOAD_FOLDER}" ] ; then
        /bin/echo -e "ERROR: The defined download folder '${AUR_DOWNLOAD_FOLDER}' is not writable for the current user '${USER}' or does not exist."
        exit ${TMP_FALSE}
	fi

	# initialize log
	if [ "${VERBOSITY_LEVEL}x" == "x" ] ; then
		/bin/echo -e  "WARNING: The verbosity level variable is not set. Assuming verbosity level 2."
		VERBOSITY_LEVEL=2
	fi

	if [ ${VERBOSITY_LEVEL} -ne 0 ] && [ ! -f "${AUR_DOWNLOAD_FOLDER}/arch-linux-update-helper.log" ] ; then
		/bin/echo "" > "${AUR_DOWNLOAD_FOLDER}/arch-linux-update-helper.log"
	fi

	# check configuration
	if [ ! -d "${AUR_DOWNLOAD_FOLDER}" ] ; then
		ERROR="${ERROR}ERROR: The download directory '${AUR_DOWNLOAD_FOLDER}' does not exist. It is used as download directory.\n"
	fi

	if [ "${ERROR}x" != "x" ] ; then
		processOutput "error" "${ERROR}"
	fi

	processOutput "message" "INFO: The command binary paths and the parameters were successfully set."
}

processParameters() {
	TMP_COUNTER=1
	while [ ${TMP_COUNTER} -lt ${PARAMETERS_COUNT} ] ; do
		TMP_INDEX=`${CMD_ECHO} "${PARAMETERS}" | ${CMD_AWK}  -F " --|^--| -|^-" '{ print $(1+'"${TMP_COUNTER}"') }' | ${CMD_AWK}  -F "=" '{ print $1 }'`
		TMP_VALUE=`${CMD_ECHO} "${PARAMETERS}" | ${CMD_AWK}  -F " --|^--| -|^-" '{ print $(1+'"${TMP_COUNTER}"') }' | ${CMD_AWK}  -F "=" '{ print $2 }'`
		case "${TMP_INDEX}" in
		"--directory" | "directory" | "-d" | "d")
			AUR_DOWNLOAD_FOLDER="${TMP_VALUE}"
			;;
		"--verbosity" | "verbosity" | "-v" | "v")
			if [ ${TMP_VALUE} -eq 0 ] || [ ${TMP_VALUE} -lt 3 ] ; then
				VERBOSITY_LEVEL="${TMP_VALUE}"
			else
				ERROR="${ERROR}ERROR: The verbosity level must be a number between 0 and 2 but is '${TMP_VALUE}'."
			fi
			;;
		"--help" | "help" | "-h" | "h")
			${CMD_ECHO}
			${CMD_ECHO} -e "This bash script initiates Arch Linux AUR packages and the normal system update at once.\nIt can be run in a non-root user context."
			${CMD_ECHO}
			${CMD_ECHO} -e "Syntax\n"
			${CMD_ECHO} -e "\tCommand\t\t: arch-linux-update-helper.sh [OPTIONAL OPTION]"
			${CMD_ECHO}
			${CMD_ECHO} -e "Optional arguments\n"
			${CMD_ECHO} -e "\t-d, --directory\t: set path to download directory for AUR packages and the log file (must be writable by executing user)"
			${CMD_ECHO} -e "\t-v, --verbosity\t: adjust level of verbosity (0 = no logging | 1 = systemctl and log file logging | 2 = systemctl, log file logging and terminal output"
			${CMD_ECHO} -e "\t-h, --help\t: display help page"
			${CMD_ECHO}
			${CMD_ECHO} -e "Information\n"
			${CMD_ECHO} -e "\tGIT repository\t: <https://github.com/initd3v/arch-linux-update-helper>"
			${CMD_ECHO} -e "\tVersion\t\t: ${VERSION}"
			${CMD_ECHO}

			exit ${TMP_TRUE}
			;;
        " ")
            ;;
		*)
			ERROR="${ERROR}ERROR: The parameter '${TMP_INDEX}' with value '${TMP_VALUE}' is not a valid pair of parameter and value."
			;;
		esac
		TMP_COUNTER=$(( TMP_COUNTER + 1 ))
	done
}

processUpdate() {

    AUR_PACKAGES=`${CMD_PACMAN} -Qm`
    if [ "${AUR_PACKAGES}x" != "x" ] ; then
        AUR_BASE_LINK_CHECK="https://aur.archlinux.org/packages"
        AUR_BASE_LINK_GIT="https://aur.archlinux.org"
        TMP_ID=`${CMD_ID} -u`
        if [ ${TMP_ID} -ne 0 ] ;  then
            while IFS= read -r line; do
                AUR_PACKAGE_NAME=`${CMD_ECHO} "${line}" | ${CMD_AWK} '{print $1}'`
                AUR_PACKAGE_VERSION=`${CMD_ECHO} "${line}" | ${CMD_AWK} '{print $2}'`
                TMP_HTTPCODE=`${CMD_CURL} --write-out "%{http_code}\n" -o /dev/null -s "${AUR_BASE_LINK_CHECK}/${AUR_PACKAGE_NAME}"`
                if [ "${TMP_HTTPCODE}" -eq 200 ] ; then
                    TMP=`${CMD_CURL} -s "${AUR_BASE_LINK_CHECK}/${AUR_PACKAGE_NAME}" | ${CMD_GREP} 'Package Details: '"${AUR_PACKAGE_NAME}"' '"${AUR_PACKAGE_VERSION}"`
                    if [ "${TMP}x" == "x" ] ; then
                        TMP_VERSION=`${CMD_CURL} -s "${AUR_BASE_LINK_CHECK}/${AUR_PACKAGE_NAME}" | ${CMD_GREP} 'Package Details: '"${AUR_PACKAGE_NAME}" | ${CMD_AWK} '{print $4}' | ${CMD_AWK} -F '<' '{print $1}'`
                        read -p "There exist a different package verion for package '${AUR_PACKAGE_NAME}' (current: '${AUR_PACKAGE_VERSION}' | new: '${TMP_VERSION}'). Do you want to update to version: ${TMP_VERSION} (y)?" ANSWER </dev/tty
                        if [[ $ANSWER =~ ^[Yy]$ ]] ; then
                            ${CMD_GIT} clone "${AUR_BASE_LINK_GIT}/${AUR_PACKAGE_NAME}.git" "${AUR_DOWNLOAD_FOLDER}/${AUR_PACKAGE_NAME}" > /dev/null 2>&1
                            if [ $? -ne 0 ] ;  then
                                processOutput "message" "WARNING: The package repository '${AUR_BASE_LINK_GIT}/${AUR_PACKAGE_NAME}.git' could not be cloned. Skipping it."
                                continue
                            fi
                            cd "${AUR_DOWNLOAD_FOLDER}/${AUR_PACKAGE_NAME}"
                            ${CMD_MAKEPKG} -si --needed --noconfirm > /dev/null 2>&1
                            if [ $? -eq 0 ] ;  then
                                processOutput "message" "INFO: The package '${AUR_PACKAGE_NAME}' was successfully updatet to version '${TMP_VERSION}'."
                            else
                                processOutput "message" "WARNING: The URI file '${REPO_DOWNLOAD_BASE_URI}${TMP_RETURN_RPM}' could not be downloaded."
                            fi
                        fi
                    else
                        processOutput "message" "WARNING: The package '${AUR_PACKAGE_NAME}' was not updated as it is already on version ${AUR_PACKAGE_VERSION}."
                    fi
                else
                    processOutput "message" "WARNING: The download URL '${AUR_BASE_LINK_CHECK}/${AUR_PACKAGE_NAME}' could not be contacted successfully. It will be skipped."
                fi
            done <<< $AUR_PACKAGES
        else
            processOutput "message" "WARNING: The current user is root. The command 'makepkg' requires executing in a non-root context. AUR package updates will be skipped."
        fi
    fi
    if [ ${TMP_ID} -eq 0 ] ;  then
        ${CMD_PACMAN} -Syu
    else
        ${CMD_SUDO} ${CMD_PACMAN} -Syu
    fi
    if [ $? -eq 0 ] ;  then
        processOutput "message" "INFO: The system update finished successfully."
    else
        processOutput "message" "INFO: The system update did not finish successfully."
    fi
}

PARAMETERS="$*"
PARAMETERS_COUNT=$(( $# + 1 ))

processInitialization
processUpdate
