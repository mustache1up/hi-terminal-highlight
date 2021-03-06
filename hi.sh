hi() { 


  _usage() {
      echo "usage: YOUR_COMMAND | hi args..."
  }

  # detect pipe or tty
  if [[ -t 0 ]]; then
      _usage
      return
  fi
  
  declare -a r;
  r[0]=30 #black
  r[1]=31 #red
  # m[green]=32
  # m[yellow]=33
  # m[blue]=34
  # m[magenta]=35
  # m[cyan]=36

  # declare -a r;

  IFS=$'\n'

  for line in $(cat)
  do
    echo "CURRENT line: $line"

    local ri=0

    for regex in "$@"
    do
      echo "CURRENT regex: $regex"
      local se=$(echo "$line" | awk -v "regex=$regex" ' match($0, regex) { print ";"RSTART+1"-"RSTART+RLENGTH}')
      echo "CURRENT se: $se"
      r[ri]+=$se
      echo "CURRENT ri: $ri"
      echo "CURRENT r[ri]: ${r[ri]}"

      let ri=$_mIndex+1
    done


    for item in "${r[@]}"
    do
      # echo "CURRENT item: $item"

      IFS=';'
      for subItem in $item
      do
        if ! [[ $subItem =~ - ]]
        then
          code=$subItem
          continue
        fi
        echo "CURRENT code: $code"
        # echo "CURRENT subItem: $subItem"
        start=${subItem%-*}
        echo "CURRENT start: $start"
        end=${subItem#*-}
        echo "CURRENT end: $end"
      done
    done

    echo "*** OUTPUT: $line"
  done

}
# cat ~/Desktop/validation_tratado_copy.txt | highlight cyan "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | highlight green Connected | highlight red 'timed out' | highlight yellow refused | tail
# cat ~/Desktop/validation_tratado_copy.txt | tail | highlight yellow refused | highlight green Connected | highlight cyan "([0-9]{1,3}\.){3}[0-9]{1,3}" | highlight magenta ":[0-9]+" | highlight blue "[0-9]+" | cat -A
cat ~/Desktop/validation_tratado_copy.txt | tail -2 | hi re..lt ref..ed

#cat ~/Desktop/validation_tratado_copy.txt | tail | 