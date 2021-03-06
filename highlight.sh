hi() { 


  _usage() {
      echo "usage: YOUR_COMMAND | hi args..."
  }

  # detect pipe or tty
  if [[ -t 0 ]]; then
      _usage
      return
  fi
  
  declare -A m;
  m[black]=30;
  m[red]=31;
  m[green]=32;
  m[yellow]=33;
  m[blue]=34;
  m[magenta]=35;
  m[cyan]=36;

  # sed -u "s/$2/$(echo -e "\e[1;${m[$1]}m\\\\0\e[0m")/g"; 
  # GREP_COLORS="ms=1;${m[$1]}" grep --color=always -E -e "^" -e "$2" 
  # awk 'refused {print "NICE: " $0} {print "MEH: " $potato}'
  # echo oi

  # all="$@"

  # echo "all: $all"

  # doit() {

 
  # }

  echo BEGINNING
  echo "args: $@"


  IFS=$'\n'

  for line in $(cat)
  do
    echo "GEENTE: $line :UIA"
    for regex in "$@"
    do
      if [[ $line =~ $regex ]]
      then
        begin=$(expr index "$str" "${BASH_REMATCH[0]}")
        echo $begin
      fi
    done
  done

  IFS=OLD_IFS
  
  echo THE END
}
# cat ~/Desktop/validation_tratado_copy.txt | highlight cyan "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | highlight green Connected | highlight red 'timed out' | highlight yellow refused | tail
# cat ~/Desktop/validation_tratado_copy.txt | tail | highlight yellow refused | highlight green Connected | highlight cyan "([0-9]{1,3}\.){3}[0-9]{1,3}" | highlight magenta ":[0-9]+" | highlight blue "[0-9]+" | cat -A
cat ~/Desktop/validation_tratado_copy.txt | tail -2 | hi result

#cat ~/Desktop/validation_tratado_copy.txt | tail | 