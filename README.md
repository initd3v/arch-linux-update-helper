# oracle-linux-sync

## Table of contents
* [Description](#description)
* [Dependencies](#dependencies)
* [Setup](#setup)
* [Usage](#usage)

## Description
This bash script updates all external AUR sources by checking their version number and performas an additional world update. 
It can be run in a non-root user context. But be aware to give sudo rights for AUR package updates and system updates.

The Project is written as a GNU bash shell script.

## Dependencies
* mandatory : GNU bash          >= 5

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

### Supported Options

#### Overview

* arch-linux-update-helper.sh [ -d=[download path AUR packages] -v=[verbosity]]
* arch-linux-update-helper.sh -h

#### Option Description

The folowing configuration options are valid. Every parameter is followed by a "=":

| Option syntax        | Description                                                         | Necessity | Supported value(s)  | Default |
|:---------------------|:--------------------------------------------------------------------|:---------:|:-------------------:|:-------:|
| -h \| --help         | display help page                                                   | optional  | -                   | -       |
| -v \| --verbosity    | adjust level of verbosity (0 = no logging \| 1 = systemctl and log file logging \| 2 = systemctl, log file logging and terminal output | optional  | INT from 0 to 2 | 2      |
| -d \| --directory    | set path to download folder where AUR packages should be saved      | optional  | STRING              | -       |
