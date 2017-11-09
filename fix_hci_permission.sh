#!/bin/bash

setcap 'cap_net_raw,cap_net_admin+eip' `which hciconfig`
setcap 'cap_net_raw,cap_net_admin+eip' `which hcitool`
