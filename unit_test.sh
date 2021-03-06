#! /bin/sh

source ./hi.sh

export DEBUG=true

testSingleWordRegex() {
  actual="$(echo "aaabbbccc" | hi b )"
  expected="$(echo -e "aaa""\e[1;36m""bbb""\e[0m""ccc")"
  assertEquals "${expected}" "${actual}" 
}

testSinglePatternRegex() {
  actual="$(echo "aaabbbccc" | hi b+ )"
  expected="$(echo -e "aaa""\e[1;36m""bbb""\e[0m""ccc")"
  assertEquals "${expected}" "${actual}" 
}

testTwoRegexes() {
  actual="$(echo "aaabbbcccddd" | hi b+ c+ )"
  expected="$(echo -e "aaa""\e[1;36m""bbb""\e[0m""\e[1;32m""ccc""\e[0m""ddd")"
  assertEquals "${expected}" "${actual}" 
}

testTwoOverlapingRegexesShorterAfter() {
  actual="$(echo "aaabbbcccddd" | hi [bc]+ bc )"
  expected="$(echo -e "aaa""\e[1;36m""bb""\e[0m""\e[1;32m""bc""\e[0m""\e[1;36m""cc""\e[0m""ddd")"
  assertEquals "${expected}" "${actual}" 
}

testTwoOverlapingRegexesLongerAfter() {
  actual="$(echo "aaabbbcccddd" | hi bc [bc]+ )"
  expected="$(echo -e "aaa""\e[1;32m""bbbccc""\e[0m""ddd")"
  assertEquals "${expected}" "${actual}" 
}

testSinglePatternRegexMultipleOccurences() {
  actual="$(echo "aaabbbcccbbb" | hi b+ )"
  expected="$(echo -e "aaa""\e[1;36m""bbb""\e[0m""ccc""\e[1;36m""bbb""\e[0m")"
  assertEquals "${expected}" "${actual}" 
}

source shunit2