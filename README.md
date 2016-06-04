# 100raidCompletions by L0r3 #
the100.io: https://www.the100.io/u/L0r3<br>
Twitter: @L0r3_Titan<br>
XB1 GT: L0r3<br>

# WHAT IS THIS JUNK? #
Script will scrape list of member from the the100.io for group ID you specify<br>
Next it will call the Bungie API and get the raid completions each member<br>

# WHAT STATE IS IT IN? #
Beta<br>
No error handling yet<br>
Works for me where expected<br>
Last bit of core work is to automate number of pages to scrape for users<br>
Its hard coded at '9' for now<br>
Find your group number in the URL when viewing your groups the100 page<br>
https://www.the100.io/groups/1412<br>

# HOW DO I USE IT #
Launch it with the required command line arguments of group ID:<br>
./raidCompletions.sh [groupID]<br>
./raidCompletions.sh 1412<br>

# REQUIRED FILES
apiKey.sh: Get a Bungie API key and insert in file (https://www.bungie.net/en/User/API)<br>
raidCompletions.sh: Primary script<br>

# ABOUT apiKey.sh #
Get yourself an API key at Bungie.net<br>
Place it in the file<br>
Thats all<br>
<br>
<br>
"I dont have time to explain why I dont have time to explain" --The Stranger<br>
