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
  r[2]=32 #green
  r[3]=33 #yellow
  r[4]=34 #blue
  r[5]=35 #magenta
  r[6]=36 #cyan

  IFS=$'\n'

  for line in $(cat)
  do
    # echo "CURRENT line: $line"

    local ri=0
    unset charColors
    declare -a charColors

    for regex in "$@"
    do
      # echo "CURRENT regex: $regex"
      local se=$(echo "$line" | awk -v "regex=$regex" ' match($0, regex) { print RSTART+1"-"RSTART+RLENGTH}')
      # echo "CURRENT se: $se"

      start=${se%-*}
      # echo "CURRENT start: $start"
      end=${se#*-}
      # echo "CURRENT end: $end"

      # echo "CURRENT ri: $ri"
      # echo "CURRENT r[ri]: ${r[ri]}"
      # echo "CURRENT ${#r}: ${#r}"

      for i in $(seq $start $end)
      do 
        # echo "CURRENT i: ${i}"


        charColors[$i]="${r[ri]}"
      done

      # echo "CURRENT charColors: $(declare -p charColors)"

      let ri++
      # if [ $ri -eq ${#r} ]
      # then
      #   ri=0
      # fi
    done

    local outputLine=""
    
    declare -p charColors

    local firstKey=("${!charColors[@]}")
    echo "firstKey=${firstKey}"

    local lastLineIndex=0

    local color=${charColors[firstKey]}
    local colorStart=${firstKey}
    local colorEnd=${firstKey}

    echo "INI color=${color}"

    for charColorIndex in "${!charColors[@]}"
    do
      charColor=${charColors[charColorIndex]}
      if [[ "$color" != "$charColor" ]]
      then
        # echo '** "$color" != "$charColor"'

        echo "# color=${color}"
        echo "# colorStart=${colorStart}"
        echo "# colorEnd=${colorEnd}"

        outputLine="${outputLine}${line:lastLineIndex:colorStart-2-lastLineIndex}"
        outputLine="${outputLine}$(echo -e "\e[1;${color}m")"
        outputLine="${outputLine}${line:colorStart-2:colorEnd-colorStart+1}"
        outputLine="${outputLine}$(echo -e "\e[0m")"

        lastLineIndex=${colorEnd}-1

        color=${charColors[charColorIndex]}
        colorStart=${charColorIndex}
        colorEnd=$charColorIndex
      fi

      colorEnd=$charColorIndex
      # echo "colorEnd=${colorEnd}"
    done


    echo "# color=${color}"
    echo "# colorStart=${colorStart}"
    echo "# colorEnd=${colorEnd}"

    outputLine="${outputLine}${line:lastLineIndex:colorStart-2-lastLineIndex}"
    outputLine="${outputLine}$(echo -e "\e[1;${color}m")"
    outputLine="${outputLine}${line:colorStart-2:colorEnd-colorStart+1}"
    outputLine="${outputLine}$(echo -e "\e[0m")"

    echo "*** INPUT : $line"
    echo "*** OUTPUT: $outputLine"
  done

}

# cat ~/Desktop/validation_tratado_copy.txt | highlight cyan "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | highlight green Connected | highlight red 'timed out' | highlight yellow refused | tail
# cat ~/Desktop/validation_tratado_copy.txt | tail | highlight yellow refused | highlight green Connected | highlight cyan "([0-9]{1,3}\.){3}[0-9]{1,3}" | highlight magenta ":[0-9]+" | highlight blue "[0-9]+" | cat -A
cat ~/Desktop/validation_tratado_copy.txt | tail -2 | hi from ref..ed result sul [0-9]+

#cat ~/Desktop/validation_tratado_copy.txt | tail | 