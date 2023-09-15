#!/bin/bash

# Author: Tushar
# Date Creadted: 16/3/2023
# Last Modified: 16/3/2023

# Description
# This programme asks the user for a year and generates all possible valid Singapore NRICs for that year.
# NOTE: This programme is for educational purposes only.

Credits and Inspiration:
Breaking the NRIC check digit algorithm: https://www.ngiam.net/NRIC/NRIC_numbers.pdf
Singapore NRIC Number Validator: https://samliew.com/singapore-nric-validator

# Terminal colour variables
Black='\033[0;30m'
Red='\033[0;31m'
Green='\033[0;32m'
Orange='\033[0;33m'
Blue='\033[0;34m'
Purple='\033[0;35m'
Cyan='\033[0;36m'
Light_Gray='\033[0;37m'
Dark_Gray='\033[1;30m'
Light_Red='\033[1;31m'
Light_Green='\033[1;32m'
Yellow='\033[1;33m'
Light_Blue='\033[1;34m'
Light_Purple='\033[1;35m'
Light_Cyan='\033[1;36m'
White='\033[1;37m'
NC='\033[0m' # No Color

# BASH trap to handle ctrl+c exit
trap 'echo -e "\n${Yellow}[!]${NC} Ctrl+C Detected. Exiting.\n"; rm probable_nric.lst; exit 130' SIGINT

curr_year=$(date +%Y)


declare -a without_checksum

declare -A S_checksum
declare -A T_checksum

S_checksum[10]="A"
S_checksum[9]="B"
S_checksum[8]="C"
S_checksum[7]="D"
S_checksum[6]="E"
S_checksum[5]="F"
S_checksum[4]="G"
S_checksum[3]="H"
S_checksum[2]="I"
S_checksum[1]="Z"
S_checksum[0]="J"

T_checksum[10]="H"
T_checksum[9]="I"
T_checksum[8]="Z"
T_checksum[7]="J"
T_checksum[6]="A"
T_checksum[5]="B"
T_checksum[4]="C"
T_checksum[3]="D"
T_checksum[2]="E"
T_checksum[1]="F"
T_checksum[0]="G"

function get_yyyy {
	read -p "Please enter a year in the format YYYY: " YYYY
	charlen=$(echo -n $YYYY | wc -m)
	time_diff=$(($YYYY-$curr_year))
	
	if [[ $charlen < 4 ]]
	then
		echo -e "\n${Light_Purple}[???]${NC}The NRIC was first issued in 1966, this year is FAR too early in time!\n"
		get_yyyy

	elif [[ $YYYY < 1966 ]]
	then
		echo -e "\n${Light_Purple}[ ! ]${NC}The NRIC was first issued in 1966, this is too early in time!\n"
		get_yyyy
	elif [[ $time_diff -gt 0 ]]
	then
		echo -e "\n${Light_Purple}[???]${NC}Easy there time-traveller! The year you selected is ${Cyan}${time_diff}${NC} year(s) ahead of this year! Those babies do not yet exist!\n"
		get_yyyy
	elif [[ $charlen == 4 ]]
	then
		echo -ne "\n${Light_Green}[ + ]${NC}You have selected the year ${Light_Cyan}${YYYY}${NC}!\n"
	fi
	
	}
function get_cen {
	readarray -t split_year < <(echo $YYYY | fold -w2)
	echo -ne "\n${Orange}[ ! ]${NC}Establishing Century Prefix..."
	for century in ${split_year[0]}; do
		if [[ $century == 19 ]]
		then
			cenprefix=S
			echo -ne "\n${Light_Green}[ + ]${NC}Your Century Prefix is ${Light_Blue}S${NC}"
		elif [[ $century == 20 ]]
		then
			cenprefix=T
			echo -ne "\n${Light_Green}[ + ]${NC}Your Century Prefix is ${Light_Blue}T${NC}"
		fi
	done
	}
function get_year {
	echo -ne "\n${Orange}[ ! ]${NC}Building NRICs..."
	for i in ${split_year[1]}; do
	year="$i"
	echo -ne "\n${Light_Green}[ + ]${NC}The first 2 digits are ${Light_Blue}${year}${NC}"
	done
	}
function generate_num {
	echo -ne "\n${Orange}[ ! ]${NC}Using crunch to generate permuations..."
	readarray -t last_five < <(crunch 5 5 0123456789)
	echo -ne "\n${Orange}[ ! ]${NC}Generating raw nric number list using permutations..."

	last_five_index=0

	while [ $last_five_index -lt 39000 ];

	do
		sevendigits=${year}${last_five[$last_five_index]}
		echo "$sevendigits" >> probable_nric.lst
		last_five_index=$((${last_five_index}+1))

	done
	}
function generate_num_sub68 {
	echo -ne "\n${Orange}[ ! ]${NC}Using crunch to generate permuations..."
	readarray -t last_6 < <(crunch 6 6 0123456789)
	echo -ne "\n${Orange}[ ! ]${NC}Generating raw nric number list using permutations..."

	last_6_index=0
	while [ $last_6_index -lt 1000000 ];

	do
		sevendigits1=${year1}${last_6[$last_6_index]}
		sevendigits2=${year2}${last_6[$last_6_index]}
		echo "$sevendigits1" >> probable_nric.lst
		echo "$sevendigits2" >> probable_nric.lst
		last_6_index=$((${last_6_index}+1))

	done
	}
function create_list_file {
	filename="${cenprefix}${YYYY}.lst"
	touch $filename
	echo -e "\n${Orange}[ ! ]${NC}$filename created!"
	}
function get_checksum {
	echo -ne "\n${Orange}[ ! ]${NC}Generating checksum using algorithm..."	

	for num in $(cat probable_nric.lst); do
		readarray -t digits < <(echo "$num" | fold -w1)
		d1=$((2*${digits[0]}))
		d2=$((7*${digits[1]}))
		d3=$((6*${digits[2]}))
		d4=$((5*${digits[3]}))
		d5=$((4*${digits[4]}))
		d6=$((3*${digits[5]}))
		d7=$((2*${digits[6]}))
		d_total=$(($d1+$d2+$d3+$d4+$d5+$d6+$d7))
		d_mod=$(($d_total % 11))

		if [[ $cenprefix == "S" ]]
		then
			checksum="${S_checksum[$d_mod]}"
			nric=${cenprefix}${num}${checksum}
			echo "$nric" >> $filename
		elif [[ $cenprefix == "T" ]]
		then
			checksum="${T_checksum[$d_mod]}"
			nric=${cenprefix}${num}${checksum}
			echo "$nric" >> $filename
		fi	
	done
	rm probable_nric.lst
	}
function super_68 {
	get_cen
	get_year
	generate_num
	create_list_file
	get_checksum
	}
function sub_68 {
	cenprefix=S
	echo -ne "\n${Light_Green}[ + ]${NC}Your Century Prefix is ${Light_Blue}S${NC}"
	echo -ne "\n${Orange}[ ! ]${NC}Building NRICs..."
	year1="0"
	year2="1"
	echo -ne "\n${Light_Green}[ + ]${NC}The first digit is ${Light_Blue}0${NC} ${Light_Red}OR${NC} ${Light_Blue}1${NC}"
	generate_num_sub68
	create_list_file
	get_checksum
	}
function main {
	if [[ $YYYY -le 1968 ]]
	then
		sub_68
	else
		super_68
	fi
	}



get_yyyy	
main
