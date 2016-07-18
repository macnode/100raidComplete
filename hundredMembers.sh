#!/bin/bash

########################################
####     the100.io Members v2.6     ####
#### Scrapes member list from group ####
#### 	  the100:  /u/L0r3          ####
####      Reddit:  /u/L0r3_Titan    ####
####      Twitter: @L0r3_Titan      ####
########################################

#######################################
#### BEGIN 100 MEMBER LIST SECTION ####
#######################################

the100group="$1"

hundredMembers ()
{

#### CHECK IF 100 GROUP ID PARAMETER ENTERED ON LAUNCH ####
#the100group="$1"

if [ -z "$the100group" ]
then
	echo
	echo  "Please enter a group id when launching"
	echo  "Usage: ./100members.sh [id number from the100]"
	echo  "Usage: ./100members.sh 1412"
	echo
	exit
else
	echo; echo; echo "#### PROCESSING: https://the100.io/groups/$the100group ####"
fi

echo; echo; echo "#### DELETING OLD TEMP FILES, ERRORS ARE NORMAL ####"
rm '/tmp/membPage1.txt'
rm '/tmp/membRawA.txt'
rm '/tmp/membRawB.txt'
rm '/tmp/membRawC.txt'
rm '/tmp/100_users.txt'
rm '/tmp/100_usersClean.txt'

#### GET NUMER OF MEMBER PAGES TO PROCESS FROM THE100 ###
echo; echo; echo "#### GETTING INITIAL PAGE TO FIND PAGE COUNT ####"
curl -o '/tmp/membPage1.txt' "https://www.the100.io/groups/$the100group?page=1"
pagesLine=`grep 'Last &raquo' '/tmp/membPage1.txt' | tail -n1`
memberPages=`echo "$pagesLine" | sed 's/raquo.*[^raquo]*//' | rev | cut -c 9- | sed 's/egap.*[^egap]*//' | rev | cut -c 2-`
echo; echo; echo "#### GETTING $memberPages PAGES OF MEMBERS ####"
let memberPages=$memberPages+'1'

#### LOOP TO CURL THE100 MEMBER PAGES TO FILE ####
let pageCnt='0'
while [ $pageCnt -lt "$memberPages" ]; do
	let pageCnt=$pageCnt+'1'
	membGet="https://www.the100.io/groups/$the100group?page=$pageCnt"
	curl -o "/tmp/membRawA.txt" "$membGet"
	sed -n '/herokuapp/,$p' "/tmp/membRawA.txt" > "/tmp/membRawB.txt"
	sed '/the100/ d' "/tmp/membRawB.txt" > "/tmp/membRawC.txt"

	if [ -f "/tmp/membRawC.txt" ]
	then
		while read line
		do
			echo $line | grep -q "Xbox One"
			if [ $? == 0 ]; then
				extractUser=`echo "$line" | rev | cut -c 34- | rev | cut -c 21- | sed 's/.*>//'`
				echo "$extractUser" >> "/tmp/100_users.txt"
			fi
		done < "/tmp/membRawC.txt"
	fi
	
done

#### CREATE ADDITIONAL MEMBERS FILE WITH %20 REMOVED ####
sed 's/ /%20/g' "/tmp/100_users.txt" > "/tmp/100_usersClean.txt"

#### DELETE TEMPORARY FILES ####
rm '/tmp/membRawA.txt'
rm '/tmp/membRawB.txt'
rm '/tmp/membRawC.txt'

#### DONE ####
echo; echo; echo "#### MEMBER LIST CREATION DONE ####"
echo "Members clean names: '/tmp/100_users.txt'"
echo "Members web names: '/tmp/100_usersClean.txt'"
echo

}

#####################################
#### END 100 MEMBER LIST SECTION ####
#####################################

#### UNCOMMENT LINE BELOW TO USE AS STAND ALONE MEMBER SCRAPER ####
#hundredMembers
