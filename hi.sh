hi() { 


  usage() {
      echo "usage: SOME_COMMAND | hi regex1 [regexN...]" >&2
  }

  # detect pipe or tty
  if [[ -t 0 ]]; then
      usage
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
    echo "CURRENT line: $line" >&2

    local ri=0
    unset charColors
    declare -a charColors

    for regex in "$@"
    do
      echo "CURRENT regex: $regex" >&2
      local se=$(echo "$line" | awk -v "regex=$regex" ' match($0, regex) { print RSTART+1"-"RSTART+RLENGTH}')
      echo "CURRENT se: $se" >&2

      start=${se%-*}
      echo "CURRENT start: $start" >&2
      end=${se#*-}
      echo "CURRENT end: $end" >&2

      echo "CURRENT ri: $ri" >&2
      echo "CURRENT r[ri]: ${r[ri]}" >&2
      echo "CURRENT ${#r}: ${#r}" >&2

      for i in $(seq $start $end)
      do 
        echo "CURRENT i: ${i}" >&2


        charColors[$i]="${r[ri]}"
      done

      declare -p charColors >&2

      let ri++
      # if [ $ri -eq ${#r} ]
      # then
      #   ri=0
      # fi
    done

    local outputLine=""
    
    declare -p charColors >&2

    local firstKey=("${!charColors[@]}")
    echo "firstKey=${firstKey}" >&2

    local lastLineIndex=0

    local color=${charColors[firstKey]}
    local colorStart=${firstKey}
    local colorEnd=${firstKey}

    echo "INI color=${color}" >&2

    for charColorIndex in "${!charColors[@]}"
    do
      charColor=${charColors[charColorIndex]}
      if [[ "$color" != "$charColor" ]]
      then
        echo '** "$color" != "$charColor"' >&2

        echo "# color=${color}" >&2
        echo "# colorStart=${colorStart}" >&2
        echo "# colorEnd=${colorEnd}" >&2

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
      echo "colorEnd=${colorEnd}" >&2
    done


    echo "# color=${color}" >&2
    echo "# colorStart=${colorStart}" >&2
    echo "# colorEnd=${colorEnd}" >&2

    outputLine="${outputLine}${line:lastLineIndex:colorStart-2-lastLineIndex}"
    outputLine="${outputLine}$(echo -e "\e[1;${color}m")"
    outputLine="${outputLine}${line:colorStart-2:colorEnd-colorStart+1}"
    outputLine="${outputLine}$(echo -e "\e[0m")"

    echo "$line"
    echo "$outputLine"
  done

}

# cat ~/Desktop/validation_tratado_copy.txt | highlight cyan "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | highlight green Connected | highlight red 'timed out' | highlight yellow refused | tail
# cat ~/Desktop/validation_tratado_copy.txt | tail | highlight yellow refused | highlight green Connected | highlight cyan "([0-9]{1,3}\.){3}[0-9]{1,3}" | highlight magenta ":[0-9]+" | highlight blue "[0-9]+" | cat -A
cat ~/Desktop/validation_tratado_copy.txt | hi from ref..ed result sul [0-9]+ "([0-9]{1,3}\.){3}[0-9]{1,3}"
