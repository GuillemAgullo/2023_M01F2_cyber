#!/bin/bash

IP_SERVER="localhost"
IP_LOCAL="127.0.0.1"
IP_MD5=`echo $IP_LOCAL | md5sum | cut -d " " -f 1`

PORT="4242"

echo "Cliente HMTP"

echo "(1) SEND - Enviando el Handshake"

echo "GREEN_POWA $IP_LOCAL $IP_MD5" | nc $IP_SERVER $PORT

echo "(2) LISTEN - Escuchando confirmación"

MSG=`nc -l $PORT`

echo "$MSG"

if [ "$MSG" != "OK_HMTP" ]
then
	echo "ERROR 1: Handshake mal formado"
	exit 1
fi

echo "(5) SEND - file_Name (enviem el nom del arxiu)"

FILE_NAME="elon_musk.jpg"

FIlE_MD5=`echo $FILE_NAME | md5sum | cut -d " " -f 1`

echo "FILE_NAME $FILE_NAME $FILE_MD5" | nc $IP_SERVER $PORT

echo "(6) LISTEN - Escoltant confirmació d'arxiu"
MSG=`nc -l $PORT`
if [ "$MSG" != "OK_FILE_NAME" ]
then
	echo "ERROR 2: Nombre de archivo enviado incorrectamente"
	exit 2
fi

echo "(9) SEND - Enviamos los datos del archivo"

cat memes/$FILE_NAME | nc $IP_SERVER $PORT

echo "(10) LISTEN - Escuchamos confirmación de datos del archivo"

MSG=`nc -l $PORT`

if [ "$MSG" != "OK DATA_RCPT" ]
then
	echo 
fi

echo "(13) SEND - Enviant el Hash del contingut del arxiu"

DATA_MD5=`cat memes/$FILE_NAME | md5sum | cut -d " " -f 1`

echo " DATA_MD5 $DATA_MD5" | nc $IP_CLIENT $PORT

echo "(14) LISTEN - MD5 Comprobación"

MSG=`nc -l $PORT`

if  [ "$MSG" != "OK_DATA_MD5" ]
then
		echo "ERROR 4: MD5 incorrecto"
		echo "Mensaje de error: $MSG"
		exit 4
fi
exit 0
