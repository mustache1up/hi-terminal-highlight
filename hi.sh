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
  
  ESCAPED_E=$'\e'
  declare -a color_map;
  color_map[0]=36 #cyan
  color_map[1]=32 #green
  color_map[2]=33 #yellow
  color_map[3]=31 #red
  color_map[4]=34 #blue
  color_map[5]=35 #magenta
  color_map[6]=30 #black

  if [[ "$#" -gt ${#color_map[@]} ]]; then
    return 1
  fi

  declare -a char_colors

  while read line
  do
    color_map_index=0
    char_colors=()
    for regex in "$@"
    do
      current_color="${color_map[color_map_index]}"
      sub_line="${line}"
      while [ ! -z ${#sub_line} ]
      do
        [[ "$sub_line" =~ $regex ]] || break
        text_match="${BASH_REMATCH[0]}"
        text_before_match="${sub_line/$text_match*/''}"
        let relative_start="${#text_before_match}"
        let relative_end=relative_start+"${#text_match}"
        let start=relative_start+"${#line}"-"${#sub_line}"
        let end=relative_end+"${#line}"-"${#sub_line}"-1
        sub_line=${sub_line:${relative_end}}
        for (( i=$start; i<=$end; i++ ))
        do 
          char_colors[$i]=${current_color}
        done
      done
      let color_map_index++
    done
    
    firstKey=("${!char_colors[@]}")
    current_line_index=0
    color=${char_colors[firstKey]}
    color_start_index=${firstKey}
    color_end_index=${firstKey}
    output_line=""
    for char_color_index in "${!char_colors[@]}"
    do
      current_char_color=${char_colors[char_color_index]}
      let diff=char_color_index-color_end_index
      if [[ "$color" != "$current_char_color" ]] || [ $diff -gt 1 ]
      then
        output_line="${output_line}"\
"${line:current_line_index:color_start_index-current_line_index}"\
"${ESCAPED_E}[1;"\
"${color}m"\
"${line:color_start_index:color_end_index-color_start_index+1}"\
"${ESCAPED_E}[0m"

        current_line_index=${color_end_index}+1
        color=${char_colors[char_color_index]}
        color_start_index=${char_color_index}
      fi
      color_end_index=$char_color_index
    done
    output_line="${output_line}"\
"${line:current_line_index:color_start_index-current_line_index}"\
"${ESCAPED_E}[1;"\
"${color}m"\
"${line:color_start_index:color_end_index-color_start_index+1}"\
"${ESCAPED_E}[0m"\
"${line:color_end_index+1}"

    echo "$output_line"
  done
}
