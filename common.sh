#!/bin/sh

# Copyright (c) 2014-2016 Erick Turnquist <jhujhiti@adjectivism.org>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

log() {
    echo $1
}

errexit() {
    >&2 echo $1
    exit 1
}

exists_in_config() {
    name=$1
    grep "$name[[:space:]]*{" /etc/jail.conf >/dev/null
    return $?
}

jail_running() {
    jls -dnj "$1" >/dev/null 2>&1
    [ $? -eq 0 ] && return 0
    return 1
}

jail_config() {
    cat - <<EOF
$1 {
    host.hostname = "$1";
    path = /jail/$1;
    ip4.addr = $3;
    osrelease = "$(source_osrelease /jail/source/$2)";
    osreldate = "$(source_osreldate /jail/source/$2)";
    mount = "/jail/source/$2 /jail/$1/basejail nullfs ro 0 0";
}
EOF
}

source_osrelease() {
    $1/bin/freebsd-version -u
    return 0
}

source_osreldate() {
    awk '/#define[[:space:]]+__FreeBSD_version/ { print $3; }' $1/usr/include/sys/param.h
    return 0
}

