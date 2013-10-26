#!/bin/sh
#Shell Password Manager 1.1
#By: Justin Woodcox
#Created: 10/14/13
#Requires gpg for encryption(installed on most linux distros)

#Provides password storage via terminal and will also encrypt password files with gpg so info is not stored in clear text.
#Allows access to passwords from a variety of locations aslong as the end user has access to ssh and the internet.

#for now just provides rough access to a txt file. Will add specific entry editing and viewing later.
#want script to edit the password file directly without using an external editor such as nano or vi, for now we will just use nano.

#(FIXED)passphrase for gpg needs to be recreated each time the file is edited(encrypted), would like to require the same passphrase each time.
#(FIXED)gpg throws some error messages that need to be fixed or made not to show up(doesn't seem to break anything)

#gpg --yes --batch --passphrase=pass -c filename.txt

#gpg --yes --batch --passphrase=[Enter your passphrase here] filename.txt.gpg

#script now tries to find and use password file in users home directory
#in theory this should allow script to be placed in /usr/bin/ and also let multiple users have their own passwords stored in their own directories unless location is modified.
clear
echo "###############  Shell Password Manager  ###############"
echo "###############    By: Justin Woodcox    ###############"
echo "#####  WARNING! THIS IS NOT 100% SECURE (yet...)  ######"
echo "###############  USE AT YOUR OWN RISK!   ###############"

#trap to remove cleartext password file if something happens to the script before encryption occurs.
trap 'rm -f ${passpath}"passdb.txt"; clear' INT TERM EXIT
passdbphrase=0
#encryption function, 
function encryptpassdb {
		#passdbphrase must be set before running
		gpg --yes --batch --passphrase=$passdbphrase -c ${passpath}passdb.txt > /dev/null 2>&1
		#clear passdbphrase
		passdbphrase=0
		#remove unencrypted file
		rm -f ${passpath}passdb.txt
        }

function decryptpassdb {
		echo -n "Enter Your Passphrase:"
		read -s passdbphrase
		gpg --yes --batch --passphrase=$passdbphrase ${passpath}passdb.txt.gpg > /dev/null 2>&1
		#encryptpassdb function must be called after or password file will be left cleartext
		}   
           
function quitclean {
               exit
           }


passdb="passdb.txt.gpg"

#Password file will go in users home directory be default, to change the location you can edit "passpath" variable.
passpath=`~/`
passdbphrase=0

#checks if path to save password file is writable, if not program exits.
if [ -w $passpath ]
then 
	#echo "Writable!"
	#check if password file exists and create one if there is none
	if [ -f ${passpath}"$passdb" ]
	then
		echo "password file found"
	else
		echo "creating new password file"
		touch ${passpath}passdb.txt
		echo "Encrypting password file, you must create a passphrase that will be required for each use of this program"
		read -p "Press [Enter] to Continue..."
		#encrypts password file with gpg so things are not stored in clear text
		gpg --yes --batch -c ${passpath}passdb.txt > /dev/null 2>&1
		#gpg --yes --batch --passphrase=$passdbphrase -c ${passpath}passdb.txt
		#remove unencrypted file
		rm -f ${passpath}passdb.txt
	fi
else
	echo "You do not have write permissions! Exiting..."
	exit 0
fi

#list options available to user 
echo ""
echo "1: Add Entry"
echo "2: List All"
echo "3: Line Count"
echo "4: Remove Password File"
echo "5: Backup Entries"
echo ""
echo -n "Select an option:"


#take the user input and perform the selected request
SEL1=0
read SEL1
case $SEL1 in
1)
#allows user to edit the current password file
  echo "Adding New Entry."
  #decrypt password file
  decryptpassdb
  
  #edit file
  nano ${passpath}passdb.txt
  
  #encrypt password file
  encryptpassdb
  ;;
2)
#allows user to view the entire password file
  echo "Listing All Entries"
  #unencrypt password file
  #gpg -q ${passpath}passdb.txt.gpg > /dev/null 2>&1
  #display password file
  #cat ${passpath}passdb.txt
  #remove unencrypted file
  #rm -f ${passpath}passdb.txt
  #echo "Displaying List for 15 seconds..."
  #display for 15 seconds the clear screen
  #sleep 15
  #clear
  
  gpg -qd ${passpath}passdb.txt.gpg
  read -p "Press [Enter] to Continue..."
  ;;
3)
  echo "Line Count"
  #unencrypt password file
  gpg -q ${passpath}passdb.txt.gpg > /dev/null 2>&1
  #display password file
  wc -l < ${passpath}passdb.txt
  #remove unencrypted file
  rm -f ${passpath}passdb.txt
  ;;
4)
  echo "Removing Password File"
  rm -f ${passpath}passdb.txt.gpg
  ;;
5)
  echo "Backing up Entries"
  
  ;;
*)
#if user enters an invalid selection the program will exit
  echo "Invalid Selection. Exiting"
  ;;
esac


