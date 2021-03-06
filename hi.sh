hi() { 

  usage() {
    log_info "# usage: SOME_COMMAND | hi regex1 [regexN...]"
  }

  log_info() {
    echo "# INFO - $@" >&2
  }

  log_debug() {
    [ ! -z $DEBUG ] && echo "# DEBUG - $@" >&2
  }

  # detect pipe or tty
  if [[ -t 0 ]]; then
      usage
      return
  fi

  let ELAPSED_TIME_ACCUMULATOR=0
  
  declare -a color_map;
  color_map[0]=36 #cyan
  color_map[1]=32 #green
  color_map[2]=33 #yellow
  color_map[3]=31 #red
  color_map[4]=34 #blue
  color_map[5]=35 #magenta
  color_map[6]=30 #black

  if [[ "$#" -gt ${#color_map[@]} ]]; then
    # log_debug "#More regex patterns received than available colors."
    return 1
  fi

  IFS=$'\n'
  for line in $(cat)
  do
    # log_debug "line: $line" 

    local ri=0
    unset charColors
    declare -a charColors

    for regex in "$@"
    do

      local subLine="${line}"

      # log_debug "regex: $regex" 
      while [ ! -z ${#subLine} ]
      do
        # log_debug "subLine: ${subLine}"

        STARTTIME=$(date +%s%N) ###################
        [[ "$subLine" =~ $regex ]] || break

        textMatch="${BASH_REMATCH[0]}"
        # log_debug "textMatch: $textMatch"

        textBeforeMatch="${subLine/$textMatch*/''}"

        let relative_start="${#textBeforeMatch}"
        let relative_end=relative_start+"${#textMatch}"
        # log_debug "r: $relative_start -> $relative_end"

        let start=relative_start+"${#line}"-"${#subLine}"
        let end=relative_end+"${#line}"-"${#subLine}"-1
        # log_debug "$start -> $end"
        ENDTIME=$(date +%s%N) ###############
        ELAPSED=$(($ENDTIME-$STARTTIME))
        let ELAPSED_TIME_ACCUMULATOR=$ELAPSED_TIME_ACCUMULATOR+$ELAPSED

        subLine=${subLine:${relative_end}}

        for i in $(seq $start $end)
        do 
          # log_debug "i: ${i}" 
          charColors[$i]="${color_map[ri]}"
        done
      done

      # log_debug "start: $start" 
      # log_debug "end: $end" 

      # log_debug "ri: $ri" 
      # log_debug "color_map[ri]: ${color_map[ri]}" 
      # log_debug "${#r}: ${#r}" 

      let ri++
    done

    local outputLine=""
    
    log_debug "$(declare -p charColors)"

    local firstKey=("${!charColors[@]}")
    # log_debug "firstKey: ${firstKey}" 

    local lastLineIndex=0

    local color=${charColors[firstKey]}
    local colorStart=${firstKey}
    local colorEnd=${firstKey}

    # log_debug "color: ${color}" 

    for charColorIndex in "${!charColors[@]}"
    do
      charColor=${charColors[charColorIndex]}
      let diff=charColorIndex-colorEnd
      if [[ "$color" != "$charColor" ]] || [ $diff -gt 1 ]
      then
        # log_debug "color=${color}" 
        # log_debug "colorStart=${colorStart}" 
        # log_debug "colorEnd=${colorEnd}" 

        outputLine="${outputLine}${line:lastLineIndex:colorStart-lastLineIndex}"
        outputLine="${outputLine}$(echo -e "\e[1;${color}m")"
        outputLine="${outputLine}${line:colorStart:colorEnd-colorStart+1}"
        outputLine="${outputLine}$(echo -e "\e[0m")"
        lastLineIndex=${colorEnd}+1

        color=${charColors[charColorIndex]}
        colorStart=${charColorIndex}
        colorEnd=$charColorIndex
      fi

      colorEnd=$charColorIndex
      # log_debug "colorEnd: ${colorEnd}" 
    done


    # log_debug "color: ${color}" 
    # log_debug "colorStart: ${colorStart}" 
    # log_debug "colorEnd: ${colorEnd}" 

    outputLine="${outputLine}${line:lastLineIndex:colorStart-lastLineIndex}"
    outputLine="${outputLine}$(echo -e "\e[1;${color}m")"
    outputLine="${outputLine}${line:colorStart:colorEnd-colorStart+1}"
    outputLine="${outputLine}$(echo -e "\e[0m")"
    lastLineIndex=${colorEnd}+1

    outputLine="${outputLine}${line:lastLineIndex}"

    # log_debug "line: $line" 
    echo "$outputLine"
  done


  log_info "It takes $((${ELAPSED_TIME_ACCUMULATOR}/1000000)) ticks to complete all computed task..."  ###########

}
