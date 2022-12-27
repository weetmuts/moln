#!/bin/bash

# This test script can be run when credentials are configured.

echo "Testing with credentials..."

./moln aws whoami
./moln aws list-vms
