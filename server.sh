#!/bin/bash

PORT="4242"

echo "Servidor HMTP"

echo "(0) Listen - Levantando servidor"

MSG=`nc -l $PORT`

HANDSHAKE=`echo $MSG | cut -d " " -f 1`
IP_CLIENT=`echo $MSG | cut -d " " -f 2`
IP_CLIENT_MD5=`echo $MSG | cut -d " " -f 3`
COMPROVACIO_MD5=`echo $IP_CLIENT | md5sum | cut -d " " -f 1`

echo "(3) Send - Confirmación Handshake"

if [ "$HANDSHAKE" != "GREEN_POWA" ]
then
	echo "KO_HMTP" | nc $IP_CLIENT $PORT
	exit 1
fi

if [ "$IP_CLIENT_MD5" != "$COMPROVACIO_MD5" ]
then
	echo "KO_HMTP_MD5"
	exit 1
fi 
echo "OK_HMTP" | nc $IP_CLIENT $PORT
echo "(4) Listen"

MSG=`nc -l $PORT`

echo "$MSG"
PREFIX=`echo $MSG | cut -d " " -f 1`
FILE_NAME=`echo $MSG | cut -d " " -f 2`
FILE_MD5=`echo $MSG | cut -d " " -f 3`
echo "(7) SEND - Confirmación del nombre del archivo"

if [ $PREFIX != "FILE_NAME" ]
then
	echo "KO_HMTP" | nc $IP_CLIENT
	exit 2
fi

echo "OK_FILE_NAME" | nc $IP_CLIENT $PORT

echo "(8) LISTEN - Escuchando datos de archivo"

nc -l $PORT > inbox/$FILE_NAME

echo "(11) SEND - Confirmació recepció"

echo "OK_DATA_RCPT" | nc $IP_CLIENT $PORT

echo "(12) LISTEN - MD5 de los datos"

MSG=`nc -l $PORT`

PREFIX=`echo $MSG | cut -d " " -f 1`
DATA_MD5=`echo $MSG | cut -d " " -f 2`

if [ "$PREFIX" != "DATA_MD5" ]
then
	echo "KO_MD5_PREFIX" | nc $IP_CLIENT $PORT
	exit 4
fi

FILE_MD5=`cat inbox/$FILE_NAME | md55sum | cut -d " " -f 1`

if [ "$DATA_MD5" != "$FILE_MD5" ]
then
	echo "KO_DATA_MD5" | nc $IP_CLIENT $PORT
	exit 5
fi

echo "OK_DATA_MD5" | nc $IP_CLIENT $PORT
					
echo "Fi de la recepció"

exit 0 
