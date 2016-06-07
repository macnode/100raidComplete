#!/bin/bash

clear

#########################################
#### the100.io Raid Completions v2.2 ####
####  Scrapes member list from group ####
####   Calls Bungie API to get grim  ####
#### 	   the100:  /u/L0r3          ####
####       Reddit:  /u/L0r3_Titan    ####
####       Twitter: @L0r3_Titan      ####
#########################################

#### NUMBER AND NAME OF A GRIM CARD ####
currentCard='603010,raidCompletions'

#### INCLUDE FILE WITH YOUR BUNGIE API KEY ####
source ${BASH_SOURCE[0]/%raidCompletions.sh/apiKey.sh}

#### SEPRATE GRIM CARD ID AND NAME ####
grimID=`echo $currentCard | sed 's/,.*[^,]*//'`
grimName=`echo $currentCard | rev | sed 's/,.*[^,]*//' | rev`

#######################################
#### BEGIN 100 MEMBER LIST SECTION ####
#######################################

#### CHECK IF 100 GROUP ID PARAMETER ENTERED ON LAUNCH
the100group="$1"

if [ -z "$the100group" ]
then
	echo
	echo  "Please enter a group id when launching"
    echo  "Usage: ./100members.sh [id number from the100]"
    echo  "Usage: ./100members.sh 1412"
    echo
    exit
else
    echo; echo "Processing: https://the100.io/groups/$the100group"
fi

#### FUNCTION TO READ MEMBERS FROM LOCAL FILE ####
funcMembExtract ()
{
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
}

echo; echo "Deleting old temporary files"
rm '/tmp/membRawA.txt'
rm '/tmp/membRawB.txt'
rm '/tmp/membRawC.txt'
rm '/tmp/100_users.txt'
rm '/tmp/100_usersClean.txt'
echo

#### NUMER OF MEMBER PAGES TO GET FROM THE100 ###
memberPages='9'

#### LOOP TO CURL THE100 MEMBER PAGES TO FILE ####
let pageCnt='0'
while [ $pageCnt -lt "$memberPages" ]; do
	let pageCnt=$pageCnt+'1'
	membGet="https://www.the100.io/groups/$the100group?page=$pageCnt"
	curl -o "/tmp/membRawA.txt" "$membGet"
	sed -n '/herokuapp/,$p' "/tmp/membRawA.txt" > "/tmp/membRawB.txt"
	sed '/the100/ d' "/tmp/membRawB.txt" > "/tmp/membRawC.txt"
	funcMembExtract
done

#### CREATE ADDITIONAL MEMBERS FILE WITH %20 REMOVED ####
sed 's/ /%20/g' "/tmp/100_users.txt" > "/tmp/100_usersClean.txt"

#### DELETE TEMPORARY FILES ####
rm '/tmp/membRawA.txt'
rm '/tmp/membRawB.txt'
rm '/tmp/membRawC.txt'

#### DONE ####
echo
echo "Done creating member list"
echo "Members clean names: '/tmp/100_users.txt'"
echo "Members web names: '/tmp/100_usersClean.txt'"

#####################################
#### END 100 MEMBER LIST SECTION ####
#####################################

selectedAccountType='1'
playerList="/tmp/100_usersClean.txt"
echo

#### FUNCTION TO SEND USERNAME TO BUNGIE TO GET MEMBER ID ####
funcMemID ()
{
sleep 1
getUser=`curl -s -X GET \
-H "Content-Type: application/json" -H "Accept: application/xml" -H "$authKey" \
"http://www.bungie.net/Platform/Destiny/SearchDestinyPlayer/$selectedAccountType/$player/"`
memID=`echo "$getUser" | grep -o 'membershipId.*' | cut -c 16- | sed 's/displayName.*[^displayName]*//' | rev | cut -c 4- | rev`
}

#### FUNCTION TO GET ALL THE DATA FROM A SPECIFIC GRIM CARD ("statNumber":1)  ####
funcGetGrimData ()
{
sleep 1
grimMinion=`curl -s -X GET \
-H "Content-Type: application/json" -H "Accept: application/xml" -H "$authKey" \
"https://www.bungie.net/Platform/Destiny/Vanguard/Grimoire/1/$memID/?single=$grimID"`
grimStatOne=`echo "$grimMinion" | grep -o 'statNumber":1.*' | sed 's/displayValue.*[^displayValue]*//' | rev | cut -c 5- | sed 's/eulav.*[^eulav]*//' | rev | cut -c 3-`
}

#### LOOP THOUGH LIST OF MEMBERS, RUN FUNCTIONS TO GET BUNGIE GRIM DATA ####
let groupRaids='0'
let playerCnt='0'
while read 'player'; do
	funcMemID
	funcGetGrimData
	echo "$player: $grimStatOne $grimName kills"
	let groupRaids=groupRaids+$grimStatOne
	let playerCnt=playerCnt+1
	grimArr[$playerCnt]="$grimStatOne,$player"
done < "$playerList"

#### SORT RESULTS SO HIGHEST GRIM RESULT AT TOP ####
function arrSort 
{ for i in ${grimArr[@]}; do echo "$i"; done | sort -n -r -s ; }
echo
grimScoresSort=( $(arrSort) )
printf '%s\n' "${grimScoresSort[@]}"

echo
echo "Group $the100group: $groupRaids $grimName completions"
echo

exit
