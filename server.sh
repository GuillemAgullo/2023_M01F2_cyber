#!/bin/bash

echo "Servidor HMTP"

MSG=`nc -l 4242`

HANDSHAKE=`echo $MSG | cut -d " " -f 1`
IP_CLIENT=`echo $MSG | cut -d " " -f 2`

if [ "$HANDSHAKE" != "GREEN_POWA" ]
then
	echo "KO_HMTP" | nc $IP_CLIENT 4242
else
	echo "OK_HMTP" | nc $IP_CLIENT 4242
fi



