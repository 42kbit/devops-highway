#!/bin/bash
# ^ this line at the begining tells shell, where you execute script,
# which interpreter to use, thus
# you can use /bin/python or /bin/node if you feel so

# you can run commands inside variables like following:
first_way=$(pwd)
second_way=`pwd`
# no space inbetween = (this is dumb)

echo $first_way
echo $second_way

variable="Hello"

echo "$variable, world!"

# OK lets have some fun...

echo "What is your name, good sir?"

# read SIR_NAME # cut this out, since too boring...
sir_name="Lord Terry, the Great"

# btw "\$" string will return $, just like in C with printf("%%");
echo "Hello, your magesty, $sir_name!"

readonly pi=3.14

echo "this is readonly $pi"
# PI=10 # this throws error.
# ./main.bash: line 30: PI: readonly variable

echo "I KNOW WHO YOU ARE: $(whoami)"

# fuf... so far so good, now lets try some lists... (or arrays whatever)

# those are space separated
my_super_array=("Hello" 222 \
"world")

echo "${my_super_array[0]}, ${my_super_array[2]}"
echo "${my_super_array}" # returns indexed zero thing

# ok, lesson learned `` or $() for running commands, ${} for accessing arrays...

# space separated arguments
echo "${my_super_array[@]}"

# length of the first string (my_super_array without index returns 0th element)
echo "${#my_super_array}"

# returns length of full array
echo "${#my_super_array[@]}"

my_super_array[0]=10
my_super_array[0]+=20 # adds "20" to first entry

my_super_array+=(10) # adds one list to another
echo "${my_super_array[@]}"
unset my_super_array[2]
echo "${my_super_array[@]}"

all_strings=("apple" "banana split" "orange")
echo "${#all_strings} VS ${#all_strings[@]} VS ${#all_strings[*]}"

echo "$0 $1 $2 $3"
echo "$#"

bullshit=$(echo "1 2 3 4 5") # this is a single "1 2 3 4 5" string
bullshit2=($(echo "1 2 3 4 5")) # this is a (1 2 3 4 5) array

prod=$((${bullshit2[2]} * ${bullshit2[3]})) # this is 3 * 4

echo "${#bullshit} VS ${#bullshit[@]} VS ${#bullshit[*]}"
echo "$prod"

# echo "$(5 + 10)" # does not work!
echo "$((5 + 10))"

# see calculator in super_calculator.bash!

some_string="Bash syntax is a piece of shit"
shit="${some_string::4}"
other="${some_string:4}"

echo "$shit"
echo "$other"

echo "${some_string/"shit"/"total shit!!!"}"
# there is 1000000510238420184 ways to substitute a string in bash, but i wont
# cover them...

# spaces between [ ] are MUST
if true; then
    echo "wtf"
fi

if [ $(whoami) = "root" ]; then
    echo "you are a root!"
else
    echo "you are NOT the fa... root!"
fi

age=18

# the "[" is the command in linux...
# so "17 -lt 18 ]" are the arguments to it.
if [ $age -lt 18 ]; then
    echo nah man...
elif [ $age -eq 18 ]; then
    echo almost...
else
    echo fair game
fi

echo done

switch_variable="world"

# what the fuck is this syntax dog
case $switch_variable in 
    "hello" )
        echo "no";;
    "world" )
        echo "yes";;
    "world" )
        # wont reach this.
        echo "YES";;
esac

my_char='a'

case $my_char in 
    [A-Z] )
        echo "no";;
    [0-9] )
        echo "still no";;
    [a-z] )
        echo "yep";;
esac

