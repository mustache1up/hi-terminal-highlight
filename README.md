# TL;DR:

Highlights each word/regex in a diferent color.

```bash
# import hi
source ./hi.sh

# call it over a pipe and pass one or more word/regex
cat examples/input.txt | hi over [0-9]+
```

# Usage:

```
<some_command> | hi REGEX [ REGEX ... ]

REGEX    Bash style regular expression. 
```

# Examples: 

```
ping -c 4 127.0.0.1 | hi from

ping -c 4 127.0.0.1 | hi [0-9]+

ping -c 4 127.0.0.1 | hi from bytes [0-9]+
 
ping -c 4 127.0.0.1 | hi ttl "([0-9]{1,3}\\\\.){3}[0-9]{1,3}"

```

# Running unit tests

```bash
sudo apt-get install shunit2

bash ./unit_test.sh
```