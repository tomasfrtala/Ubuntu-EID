#!/bin/bash

PATTERN="Aplikacia_pre_eID.*deb$"
matchCount=$(ls | egrep $PATTERN -c)

case $matchCount in
	0)
		echo "CHYBA: Nebol nájdený DEB balík aplikácie pre eID"
		exit 1
		;;
	1)
		DEB_PACKAGE_TO_INSTALL="$(ls | egrep $PATTERN )" 
		;;
	*)
		echo "Boli nájdené viaceré DEB balíky aplikácie pre eID. Zvoľte balík, ktorý chcete inštalovať: "
		
		echo 
		echo "0: ZRUŠIŤ INŠTALÁCIU! "
		echo

		ls | egrep $PATTERN | sort | egrep -n $PATTERN
		Files=( $(ls | egrep $PATTERN | sort))

		optionCheck=0
		while [ 0 -eq $optionCheck ]; do
			read -p "Zvoľte možnosť: " option
			echo 
				
			if [ $option -ge 0 ] && [ $option -le $matchCount ]
			then 
				optionCheck=1
			else
				echo "CHYBA: Nesprávne zadaná možnosť! Skúste znovu."
			fi
		done

		if [ 0 -eq $option ]
		then 
			echo "Inštalácia bola zrušená"
			exit 2
		else
			DEB_PACKAGE_TO_INSTALL="${Files[$[$option-1]]}"
		fi
		;;
esac

if [ $(uname -m | grep 'x86_64') ]; then
	if ! [ $(ls $DEB_PACKAGE_TO_INSTALL | grep 'amd64' ) ]; then
		echo "CHYBA: Tento inštalačný balík nie je určený pre Váš operačný systém. Váš operačný systém bol identifikovaný ako 64-bit, no balík je určený pre 32-bit operačný systém. Stiahnite si prosím balík pre 64-bit platformu."
		exit 2
	fi
else
	if [ $(ls $DEB_PACKAGE_TO_INSTALL | grep 'amd64' ) ]; then
		echo "CHYBA: Tento inštalačný balík nie je určený pre Váš operačný systém. Váš operačný systém bol identifikovaný ako 32-bit, no balík je určený pre 64-bit operačný systém. Stiahnite si prosím balík pre 32-bit platformu."
		exit 2
	fi
fi

PACKAGE="gdebi-core"
INSTALLEDSTR="install ok installed"

if	[ 1 -eq  $(dpkg --list | grep --count --word-regexp $PACKAGE) ] && \
	[ "$INSTALLEDSTR" == "$(dpkg-query --show --showformat='${Status}' ${PACKAGE})" ]
	then
		echo ""
	else
		echo "gdebi-core musí byť nainštalovaný"
		echo "Inštalujem..."
		sudo apt-get update
		sudo apt-get install "$PACKAGE"
fi

echo "Inštalujeme balík: $DEB_PACKAGE_TO_INSTALL"
sudo gdebi "$DEB_PACKAGE_TO_INSTALL"
exit 0
