# oracle-linux-sync

## Table of contents
* [Description](#description)
* [Dependencies](#dependencies)
* [Setup](#setup)
* [Usage](#usage)

## Description
This bash script syncs the *.rpm packages of one or more OracleLinux repositories based on the index URI. Optionally it provides the possibility to create the YUM meta information based on the createrepo_c program. It can be run in a non-root user context.

The Project is written as a GNU bash shell script.

## Dependencies
* mandatory : GNU bash          >= 5
* optional : createrepo_c      >= 0.18.0 (https://github.com/rpm-software-management/createrepo_c)

## Setup
To run this project, you need to clone it to your local computer and run it as a shell script.

```
$ cd /tmp
$ git clone https://github.com/initd3v/oracle-linux-sync.git
$ nano -w /tmp/oracle-linux-sync/oracle-linux-sync.sh
```
## Usage

### Running the script

To run this project, you must add the execution flag for the user context to the bash file. Afterwards execute it in a bash shell. 
After every successful execution the current option configuration will be saved in the download directory.
The log file is located in the download directory.

```
$ chmod u+x /tmp/oracle-linux-sync/oracle-linux-sync.sh
$ /tmp/oracle-linux-sync/oracle-linux-sync.sh -d=[download path] -u=[download url]
```

### Supported Options

#### Overview

* oracle-linux-sync.sh -d=[download path] -u=[download url] [-m=[createrepo_c binary path] -v=[verbosity]]
* oracle-linux-sync.sh -c=[configuration file path]
* oracle-linux-sync.sh -h

#### Option Description

The folowing configuration options are valid. Every parameter is followed by a "=":

| Option syntax        | Description                                                         | Necessity | Supported value(s)  | Default |
|:---------------------|:--------------------------------------------------------------------|:---------:|:-------------------:|:-------:|
| -h \| --help         | display help page                                                   | optional  | -                   | -       |
| -v \| --verbosity    | adjust level of verbosity (0 = no logging \| 1 = systemctl and log file logging \| 2 = systemctl, log file logging and terminal output | optional  | INT from 0 to 2 | 2      |
| -c \| --configuration| set path to configuration file (parameters will be overwritten)     | optional  | STRING              | -       |
| -d \| --directory    | set path to repository folder where RPM packages and meta information should be saved | mandatory | STRING | -  |
| -u \| --url          | pass URL to Oracle Linux index page (for multiple URL, pass the argument multiple times; the character = will be escaped to %3D) | mandatory | STRING | - |
| -m \| --metadata     | set path to createrepo_c binary - if passed, the meta information will be generated | optional | STRING | -     |
