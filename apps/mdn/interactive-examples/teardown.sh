#!/bin/bash

source ../bin/common.sh
check_neres_env

monitor_id=$(get_newrelic_monitor_id "MDN interactive-examples")
neres delete-monitor $monitor_id

