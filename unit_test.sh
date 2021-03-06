#! /bin/sh

source ./hi.sh

testEquality() {
  assertEquals 1 1
}

testSingleWordRegex() {
  actual="$(echo "aaabbbccc" | hi b 2> /dev/null)"
  expected="$(echo -e "aaa""\e[1;30m""bbb""\e[0m""ccc")"
  assertEquals "${expected}" "${actual}" 
}

testSinglePatternRegex() {
  actual="$(echo "aaabbbccc" | hi b+ 2> /dev/null)"
  expected="$(echo -e "aaa""\e[1;30m""bbb""\e[0m""ccc")"
  assertEquals "${expected}" "${actual}" 
}

testTwoRegexes() {
  actual="$(echo "aaabbbcccddd" | hi b+ c+ 2> /dev/null)"
  expected="$(echo -e "aaa""\e[1;30m""bbb""\e[0m""\e[1;31m""ccc""\e[0m""ddd")"
  assertEquals "${expected}" "${actual}" 
}

testTwoOverlapingRegexesShorterAfter() {
  actual="$(echo "aaabbbcccddd" | hi [bc]+ bc 2> /dev/null)"
  expected="$(echo -e "aaa""\e[1;30m""bb""\e[0m""\e[1;31m""bc""\e[0m""\e[1;30m""cc""\e[0m""ddd")"
  assertEquals "${expected}" "${actual}" 
}

testTwoOverlapingRegexesLongerAfter() {
  actual="$(echo "aaabbbcccddd" | hi bc [bc]+ 2> /dev/null)"
  expected="$(echo -e "aaa""\e[1;31m""bbbccc""\e[0m""ddd")"
  assertEquals "${expected}" "${actual}" 
}

testSinglePatternRegexMultipleOccurences() {
  actual="$(echo "aaabbbcccbbb" | hi b+ 2> /dev/null)"
  expected="$(echo -e "aaa""\e[1;30m""bbb""\e[0m""ccc""\e[1;30m""bbb""\e[0m")"
  assertEquals "${expected}" "${actual}" 
}

source shunit2