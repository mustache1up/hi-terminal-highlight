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

      for i in $(seq $start $end)
      do 
        # echo "CURRENT i: ${i}"


        charColors[$i]="${r[ri]}"
      done

      # echo "CURRENT charColors: $(declare -p charColors)"


      let ri++
    done

    ############## TODO: iterar as paradas por char, array sparse, se mudar, aplicar os codes.

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
cat ~/Desktop/validation_tratado_copy.txt | tail -2 | hi ref..ed result

#cat ~/Desktop/validation_tratado_copy.txt | tail | 