hi() { 

  usage() {
    log_info "# usage: SOME_COMMAND | hi regex1 [regexN...]"
  }

  log_info() {
    echo "$@" >&2
  }

  log_debug() {
    [ ! -z $DEBUG ] && log_info "# DEBUG - $@"
  }

  # detect pipe or tty
  if [[ -t 0 ]]; then
      usage
      return
  fi
  
  declare -a color_map;
  color_map[0]=30 #black
  color_map[1]=31 #red
  color_map[2]=32 #green
  color_map[3]=33 #yellow
  color_map[4]=34 #blue
  color_map[5]=35 #magenta
  color_map[6]=36 #cyan

  if [[ "$#" -gt ${#color_map[@]} ]]; then
    log_debug "#More regex patterns received than available colors."
    return 1
  fi

  IFS=$'\n'
  for line in $(cat)
  do
    log_debug "line: $line" 

    local ri=0
    unset charColors
    declare -a charColors

    for regex in "$@"
    do

      local lineIndex=0
      local se=0-0

      log_debug "regex: $regex" 
      while true
      do
        [ $lineIndex -ge ${#line} ] && break

        local subLine=${line:${lineIndex}}
        log_debug "lineIndex: ${lineIndex} => ${subLine}"
        local se=$(echo "${subLine}" | awk -v "regex=$regex" ' match($0, regex) { print RSTART+1"-"RSTART+RLENGTH}')
        log_debug "se: $se" 
        [ -z "$se" ] && break

        let start=${se%-*}+$lineIndex
        let end=${se#*-}+$lineIndex
        let lineIndex=$end-1
        log_debug "$start -> $end"

        for i in $(seq $start $end)
        do 
          log_debug "i: ${i}" 
          charColors[$i]="${color_map[ri]}"
        done
      done

      log_debug "start: $start" 
      log_debug "end: $end" 

      log_debug "ri: $ri" 
      log_debug "color_map[ri]: ${color_map[ri]}" 
      log_debug "${#r}: ${#r}" 

      let ri++
    done

    local outputLine=""
    
    log_debug "$(declare -p charColors)"

    local firstKey=("${!charColors[@]}")
    log_debug "firstKey: ${firstKey}" 

    local lastLineIndex=0

    local color=${charColors[firstKey]}
    local colorStart=${firstKey}
    local colorEnd=${firstKey}

    log_debug "color: ${color}" 

    for charColorIndex in "${!charColors[@]}"
    do
      charColor=${charColors[charColorIndex]}
      let diff=charColorIndex-colorEnd
      if [[ "$color" != "$charColor" ]] || [ $diff -gt 1 ]
      then
        log_debug "color=${color}" 
        log_debug "colorStart=${colorStart}" 
        log_debug "colorEnd=${colorEnd}" 

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
      log_debug "colorEnd: ${colorEnd}" 
    done


    log_debug "color: ${color}" 
    log_debug "colorStart: ${colorStart}" 
    log_debug "colorEnd: ${colorEnd}" 

    outputLine="${outputLine}${line:lastLineIndex:colorStart-2-lastLineIndex}"
    outputLine="${outputLine}$(echo -e "\e[1;${color}m")"
    outputLine="${outputLine}${line:colorStart-2:colorEnd-colorStart+1}"
    outputLine="${outputLine}$(echo -e "\e[0m")"

    lastLineIndex=${colorEnd}-1
    outputLine="${outputLine}${line:lastLineIndex}"

    log_debug "line: $line" 
    echo "$outputLine"
  done

}
