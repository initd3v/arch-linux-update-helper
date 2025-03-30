# arch-linux-update-helper

## Table of contents
* [Description](#description)
* [Dependencies](#dependencies)
* [Setup](#setup)
* [Usage](#usage)

## Description
The script 'arch-linux-update-helper.sh' is used for updating community driven (AUR) and official package upgrades. Additionally it can clear the pacman cache for non-existent packages.

To run the script you need to cmake it executable for a user with at least sudo rights. Further information can be obtained from the 'Usage' part.

Supported functions:

* identify and update AUR driven packages which are manually installed
* uninstall not existent AUR packages by user interaction
* update world update packages from official repositories
* clean up pacman cache for non-existent packages

The Project is written as a GNU bash shell script.

## Dependencies
| Dependency            | Version                               | Necessity     | Used Command Binary                                                                               |
|:----------------------|:--------------------------------------|:-------------:|:-------------------------------------------------------------------------------------------------:|
| curl                  | >= 8.12.1                             | necessary     | curl                                                                                              |
| GNU bash              | >= 5.1.4(1)                           | necessary     | bash                                                                                              |
| GNU Awk               | >= 5.1.0                              | necessary     | awk                                                                                               |
| GNU Coreutils         | >= 8.32c                              | necessary     | clear & date & dirname & echo & false & id & mkdir & realpath & rm & test & true & yes            |
| git                   | >= 2.30.2                             | necessary     | git                                                                                               |
| grep                  | >= 3.6                                | necessary     | grep                                                                                              |
| pacman                | >= 7.0.0                              | necessary     | pacman & makepkg                                                                                  |
| sudo                  | >= 1.9.16p2                           | necessary     | sudo                                                                                              |
| whereis               | >= 2.36.1                             | necessary     | whereis                                                                                           |

## Setup
To run this project, you need to clone it to your local computer and run it as a shell script.

```
$ cd /tmp
$ git clone https://github.com/initd3v/arch-linux-update-helper.git
```
## Usage

### Running the script

To run this project, you must add the execution flag for the user context to the bash file. Afterwards execute it in a bash shell. 
After every successful execution the current option configuration will be saved in the download directory.
The log file is located in the download directory.

```
$ chmod u+x /tmp/arch-linux-update-helper/src/arch-linux-update-helper.sh
$ /tmp/oracle-linux-sync/src/arch-linux-update-helper.sh
```

### Syntax

* arch-linux-update-helper.sh
