hi() { 


  usage() {
      >&2 echo "# usage: SOME_COMMAND | hi regex1 [regexN...]" 
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

  if [[ "$#" -gt ${#r[@]} ]]; then
    >&2 echo "More regex patterns received than available colors."
    return 1
  fi

  IFS=$'\n'

  for line in $(cat)
  do
    # >&2 echo "# CURRENT line: $line" 

    local ri=0
    unset charColors
    declare -a charColors

    for regex in "$@"
    do

      local lineIndex=0
      local se=0-0

      # >&2 echo "# CURRENT regex: $regex" 
      while true
      do
        [ $lineIndex -ge ${#line} ] && break

        local subLine=${line:${lineIndex}}
        >&2 echo "* lineIndex: ${lineIndex} => ${subLine}"
        local se=$(echo "${subLine}" | awk -v "regex=$regex" ' match($0, regex) { print RSTART+1"-"RSTART+RLENGTH}')
        # >&2 echo "# CURRENT se: $se" 
        [ -z "$se" ] && break

        let start=${se%-*}+$lineIndex
        let end=${se#*-}+$lineIndex
        let lineIndex=$end-1
        # >&2 echo "$start -> $end"

        for i in $(seq $start $end)
        do 
          # >&2 echo "# CURRENT i: ${i}" 
          charColors[$i]="${r[ri]}"
        done
      done

      # >&2 echo "# CURRENT start: $start" 
      # >&2 echo "# CURRENT end: $end" 

      # >&2 echo "# CURRENT ri: $ri" 
      # >&2 echo "# CURRENT r[ri]: ${r[ri]}" 
      # >&2 echo "# CURRENT ${#r}: ${#r}" 

      # if [ -z "$start" ] || [ -z "$end" ]
      # then 
      #   let ri++
      #   continue
      # fi



      # >&2 declare -p charColors 

      let ri++
    done

    local outputLine=""
    
    >&2 declare -p charColors 

    local firstKey=("${!charColors[@]}")
    # >&2 echo "# firstKey=${firstKey}" 

    local lastLineIndex=0

    local color=${charColors[firstKey]}
    local colorStart=${firstKey}
    local colorEnd=${firstKey}

    # >&2 echo "# INI color=${color}" 

    for charColorIndex in "${!charColors[@]}"
    do
      charColor=${charColors[charColorIndex]}
      let diff=charColorIndex-colorEnd
      if [[ "$color" != "$charColor" ]] || [ $diff -gt 1 ]
      then
        >&2 echo '** "$color" != "$charColor"' 

        >&2 echo "# color=${color}" 
        >&2 echo "# colorStart=${colorStart}" 
        >&2 echo "# colorEnd=${colorEnd}" 

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
      # >&2 echo "# colorEnd=${colorEnd}" 
    done


    >&2 echo "# color=${color}" 
    >&2 echo "# colorStart=${colorStart}" 
    >&2 echo "# colorEnd=${colorEnd}" 

    outputLine="${outputLine}${line:lastLineIndex:colorStart-2-lastLineIndex}"
    outputLine="${outputLine}$(echo -e "\e[1;${color}m")"
    outputLine="${outputLine}${line:colorStart-2:colorEnd-colorStart+1}"
    outputLine="${outputLine}$(echo -e "\e[0m")"

    lastLineIndex=${colorEnd}-1
    outputLine="${outputLine}${line:lastLineIndex}"

    # >&2 echo "# INPUT $line" 
    echo "$outputLine"
  done

}
