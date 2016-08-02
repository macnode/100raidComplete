#!/bin/bash

########################################
#### the100.io raidCompletions v3.3 ####
####   Call the100 API get members  ####
####   Call Bungie API get grim     ####
#### 	  the100:  /u/L0r3          ####
####      Reddit:  /u/L0r3_Titan    ####
####      Twitter: @L0r3_Titan      ####
########################################

clear

#### UNCOMMENT ONE ####
currentCard='603010,raidCompletions'

#### INCLUDE FILE WITH YOUR BUNGIE API KEY ####
source ${BASH_SOURCE[0]/%raidCompletions.sh/apiKeys.sh}
source ${BASH_SOURCE[0]/%raidCompletions.sh/hundredMembers.sh}

#### SEPRATE GRIM CARD ID AND NAME ####
grimID=`echo $currentCard | sed 's/,.*[^,]*//'`
grimName=`echo $currentCard | rev | sed 's/,.*[^,]*//' | rev`

#### XBOX OR PSN ####
selectedAccountType='1'

#### CALL FUNCTION TO GET THE100 GROUP MEMBERS ####
hundredMembers

#### FUCTION TO SEND GAMERTAG TO BUNGIE TO GET MEMBER ID ####
funcMemID ()
{
getUser=`curl -s -X GET \
-H "Content-Type: application/json" -H "Accept: application/xml" -H "$authKeyBungie" \
"https://www.bungie.net/Platform/Destiny/SearchDestinyPlayer/$selectedAccountType/$player/"`
memID=`echo "$getUser" | grep -o 'membershipId.*' | cut -c 16- | sed 's/displayName.*[^displayName]*//' | rev | cut -c 4- | rev`
}

#### FUNCTION TO GET ALL THE DATA FROM A SPECIFIC GRIM CARD ("statNumber":1)  ####
funcGetGrimData ()
{
grimMinion=`curl -s -X GET \
-H "Content-Type: application/json" -H "Accept: application/xml" -H "$authKeyBungie" \
"https://www.bungie.net/Platform/Destiny/Vanguard/Grimoire/1/$memID/?single=$grimID"`
grimStatOne=`echo "$grimMinion" | grep -o 'statNumber":1.*' | sed 's/displayValue.*[^displayValue]*//' | rev | cut -c 5- | sed 's/eulav.*[^eulav]*//' | rev | cut -c 3-`
}

#### LOOP THROUGH MEMBERS TO GET SCORES FROM BUNGIE ####
echo;echo "#### GET RESULTS FROM BUNGIE ####"
let playerCnt='0'
let groupTotal='0'
while [ "$playerCnt" -lt "$totalMembers" ]; do
	player=`echo "${arrMembers[$playerCnt]}"`
	sleep 1
	funcMemID
	funcGetGrimData
	scorePlayer="$grimStatOne,$player"
	echo "$playerCnt: $scorePlayer"
	let playerCnt=playerCnt+1
	grimArr[$playerCnt]="$scorePlayer"
	let groupTotal=groupTotal+grimStatOne
done

#### SORT SCORES HIGHEST TO LOWEST ####
function arrSort 
{ for i in ${grimArr[@]}; do echo "$i"; done | sort -n -r -s ; }
grimScoresSort=( $(arrSort) )

sortList=`printf '%s\n' "${grimScoresSort[@]}" | sed 's/,/ /g' | sed 's/%20/ /g'`

echo; echo; echo "#### GROUP TOTAL $grimName kills: $groupTotal ####"

echo "$sortList"

echo; echo
exit
