source ./hi.sh

# cat ../examples/input.txt | highlight cyan "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | highlight green Connected | highlight red 'timed out' | highlight yellow refused | tail
# cat ../examples/input.txt | tail | highlight yellow refused | highlight green Connected | highlight cyan "([0-9]{1,3}\.){3}[0-9]{1,3}" | highlight magenta ":[0-9]+" | highlight blue "[0-9]+" | cat -A
cat ../examples/input.txt | hi from Con[a-z]+ result sul [0-9]+ "([0-9]{1,3}\\\\.){3}[0-9]{1,3}" 
# cat ../examples/input.txt | hi [0-9]+
