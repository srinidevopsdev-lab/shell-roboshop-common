#!/bin/bash

source ./common.sh
app_name=payment

check_root
app_setup
python_setup
systemd_setup
app_restarted
print_total_time