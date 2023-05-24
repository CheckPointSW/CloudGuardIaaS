#!/bin/bash

HASHED_PASSWORD="<YOUR_HASHED_PASSWORD>"

# Unlock Database
clish -c "lock database override"
# Set password
clish -c "set user admin password-hash $HASHED_PASSWORD" -s


