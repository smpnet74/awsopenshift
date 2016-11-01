#!/bin/bash
nohup consul agent -server -datacenter dc2 -data-dir=/tmp -join-wan=${server} --advertise-wan=${myipaddr} -bootstrap-expect=1 &>/dev/null &