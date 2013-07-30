#!/bin/sh

read -p "CUSTOM_USERNAME [wcravens]     :" CUSTOM_USERNAME
read -p "CUSTOM_FULLNAME [Wes Cravens]  :" CUSTOM_FULLNAME
read -p "CUSTOM_HOSTNAME [argus]        :" CUSTOM_HOSTNAME
read -p "CUSTOM_TIMEZONE [US/Central]   :" CUSTOM_TIMEZONE
read -p "CUSTOM_DOMAIN   [moxigen.com]  :"   CUSTOM_DOMAIN
read -p "TARGET_BUILD    [dev]          :"    TARGET_BUILD

: ${CUSTOM_USERNAME:=wcravens};
: ${CUSTOM_FULLNAME:='Wes Cravens'};
: ${CUSTOM_HOSTNAME:='argus'};
: ${CUSTOM_TIMEZONE:=''};
: ${CUSTOM_DOMAIN:=moxigen.com};
: ${TARGET_BUILD:=dev};

export \
 CUSTOM_USERNAME\
 CUSTOM_FULLNAME\
 CUSTOM_HOSTNAME\
 CUSTOM_TIMEZONE\
 CUSTOM_DOMAIN\
 TARGET_BUILD

sudo -E make
