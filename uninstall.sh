#!/bin/bash

DEBPACKAGE=eac-mw-klient
APPBINARY=EAC_MW_klient
AUTOSTARTSCRIPT=.config/autostart/aplikacia-pre-eid.desktop

ps cax | grep $APPBINARY > /dev/null
if [ $? -eq 0 ]; then
	pkill -x $APPBINARY
fi
echo "Odstraňujeme balík: $DEBPACKAGE"

sudo dpkg -r $DEBPACKAGE

if [ -f ${HOME}/${AUTOSTARTSCRIPT} ]; then
	sudo rm ${HOME}/${AUTOSTARTSCRIPT}
fi
