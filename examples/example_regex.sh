#!/bin/bash

source ./hi.sh

cat example_input.txt | hi b...s [0-9]+ "([0-9]{1,3}\\\\.){3}[0-9]{1,3}" "[a-z.]+\\\\.com" "[0-9]+\\\\.[0-9]+ ms" time
