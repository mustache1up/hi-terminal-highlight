hi() { 

  usage() {
    log_info "usage: SOME_COMMAND | hi REGEX [REGEX...]"
    log_info "currently supports up to 6 REGEXes"
  }

  log_info() {
    echo "INFO - $@" >&2
  }

  log_debug() {
    [ ! -z $DEBUG ] && echo "DEBUG - $@" >&2
  }

  if [[ -t 0 ]]
  then
      usage
      return
  fi

  ESCAPED_E=$'\e'

  declare -a color_map;
  color_map[0]=36 #cyan
  color_map[1]=32 #green
  color_map[2]=33 #yellow
  color_map[3]=31 #red
  color_map[4]=34 #blue
  color_map[5]=35 #magenta

  if [[ "$#" -gt ${#color_map[@]} ]]; then
    return 1
  fi

  declare -a char_colors

  while read line
  do
    firstKey=-1

    color_map_index=0
    char_colors=()
    for regex in "$@"
    do
      current_color="${color_map[color_map_index]}"
      sub_line="${line}"
      while [ ! -z ${#sub_line} ] && [[ "$sub_line" =~ $regex ]]
      do
        text_before_match="${sub_line/${BASH_REMATCH[0]}*/''}"
        ((relative_start="${#text_before_match}"))
        ((relative_end=${relative_start}+"${#BASH_REMATCH[0]}"))
        ((start=${relative_start}+"${#line}"-"${#sub_line}"))
        ((end=${relative_end}+"${#line}"-"${#sub_line}"-1))
        sub_line=${sub_line:${relative_end}}
        [ ${start} -lt ${firstKey} ] || [ ${firstKey} -lt 0 ] && firstKey=${start}
        for (( i=$start; i<=$end; i++ ))
        do 
          char_colors[$i]=${current_color}
        done
      done
      ((color_map_index++))
    done
    
    [ ${firstKey} -lt 0 ] && continue

    current_line_index=0
    color=${char_colors[firstKey]}
    color_start_index=${firstKey}
    color_end_index=${firstKey}
    output_line=""
    for char_color_index in "${!char_colors[@]}"
    do
      current_char_color=${char_colors[char_color_index]}
      ((diff=char_color_index-color_end_index))
      if [[ "$color" != "$current_char_color" ]] || [ $diff -gt 1 ] 
      then
        output_line="${output_line}${line:current_line_index:color_start_index-current_line_index}${ESCAPED_E}[1;${color}m${line:color_start_index:color_end_index-color_start_index+1}${ESCAPED_E}[0m"

        current_line_index=${color_end_index}+1
        color=${char_colors[char_color_index]}
        color_start_index=${char_color_index}
      fi
      color_end_index=$char_color_index
    done

    output_line="${output_line}${line:current_line_index:color_start_index-current_line_index}${ESCAPED_E}[1;${color}m${line:color_start_index:color_end_index-color_start_index+1}${ESCAPED_E}[0m${line:color_end_index+1}"

    printf "%s\n" "${output_line}"

  done
}

