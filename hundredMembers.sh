#!/bin/bash

########################################
####     the100.io Members v3.3     ####
#### Get the100.io members from API ####
#### 	  the100:  /u/L0r3          ####
####      Reddit:  /u/L0r3_Titan    ####
####      Twitter: @L0r3_Titan      ####
########################################

# final list of group members is in bash array "arrMembers"
# number of members in final list in string "$totalMembers"

#### INPUT LAUNCH PARAMETERS ####
the100group="$1"

#### MAIN FUNCTION ####
hundredMembers ()
{

#### CHECK IF THE100 GROUP ID PARAMETER ENTERED ON LAUNCH ####
source ${BASH_SOURCE[0]/%hundredMembers.sh/apiKeys.sh}

if [ -z "$the100group" ]
then
	echo
	echo  "Please enter a group id when launching"
	echo  "Usage: ./100members.sh [id number from the100]"
	echo  "Usage: ./100members.sh 1412"
	echo
	exit
else
	echo; echo; echo "### Getting members of group $the100group from the the100 API ###"
fi

#### SET UP VARIABLES ####
let pageCnt='0'
let memberPages='1000'

#### LOOP TO GET GROUP MEMBERS FROM THE100 API ####
while [ $pageCnt -lt "$memberPages" ]; do
	
	let pageCnt=$pageCnt+'1'
	echo "Page $pageCnt..."

	get100group=`curl -s -X GET \
	-H "Content-Type: application/json" -H "Accept: application/json" -H "Authorization: Token $authKey100" \
	"https://www.the100.io/api/v1/groups/$the100group/users?page=$pageCnt"`

	nice100users=`echo "$get100group" | python -mjson.tool`

	#### TEST FOR FINAL PAGE ####
	if [ "$nice100users" == "[]" ]; then
		memberPages="$pageCnt"
	fi

	#### FIND GAMERTAG AND ADD TO MASTER LIST ####
	extractMembers=`echo "$nice100users" | grep -o 'gamertag.*' | cut -c 13- | rev | cut -c 3- | rev | sed 's/ /%20/g'`
	allMembers="$allMembers $extractMembers"
	delimitMembers=`echo $allMembers | sed 's/ /,/g'`

done

#### PUT MASTER LIST INTO ARRAY ####
oIFS="$IFS"; IFS=','
arrMembers=($delimitMembers)
IFS="$oIFS"

#### PRINT MEMBER LIST ####
totalMembers=`echo ${#arrMembers[*]}`
echo "### Group $the100group total members: $totalMembers ###"
theList=`printf '%s\n' "${arrMembers[@]}" | sed 's/%20/ /g'`
#echo "$theList"

}

#### UNCOMMENT 2 LINES BELOW TO RUN STAND ALONE ####
#hundredMembers
#echo "$theList"