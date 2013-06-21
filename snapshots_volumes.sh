#!/bin/bash
#################################################################################
# Ident		: snapshots_volumes.sh - 1.0
# Auteur	: J.Behuet
#
# Description 	: Automatisation de la création des snapshot des volumes ayant
#		  le tag Backup à true
# 
# Usage		: ./snapshot_volumes.sh
# Remarque(s)	: Ce script nécessite l'installation des Amazon EC2 API Tools
#		  http://aws.amazon.com/developertools/351
#
# Versions	:
#  V   | Date     | Auteur           | Description des modifications
# -----|----------|------------------|------------------------------------------	
# 1.0  |21-06-2013| J.Behuet	     | Initial
#
#
#################################################################################
export EC2_HOME=/usr/local/ec2/
export EC2_URL=https://ec2.eu-west-1.amazonaws.com

export AWS_ACCESS_KEY=NEED_YOUR_KEY
export AWS_SECRET_KEY=NEED_YOUR_KEY

SCRIPTNAME=`basename $0`
VERSION="1.0"
DESCRIPTION="Automatisation de la création des snapshot des volumes ayant le tag Backup à true"

function print_usage() {
  echo -e "Usage\t: ./snapshots_volumes.sh"
  echo -e "ARGS"
  echo -e "\t-h : Print help"
}

function print_version() {
  echo -e "Ident\t: $SCRIPTNAME version $VERSION"
  echo -e "Auteur\t: J.Behuet"
}

while getopts :hv OPT
do
  case $OPT in
    h)
      print_help
      exit 0
      ;;
    \?)
      echo -e "$SCRIPTNAME : Option incorrecte : $OPTARG"
      print_usage
      exit 0
      ;;
   esac
done

echo "$(date +'%d/%m/%Y %H:%M:%S') -- Daily snapshot [ START ] --"
echo "$(date +'%d/%m/%Y %H:%M:%S') Get volumes list"

VOLUME_LIST=(`ec2-describe-volumes --filter "tag:Backup=true" | grep ATTACHMENT | awk '{ print $2";"$3; }'`)

for v in "${VOLUME_LIST[@]}"; do

  VOLUME_INFO=(`echo $v | tr ';' ' '`)
  echo "$(date +'%d/%m/%Y %H:%M:%S') Get instance name (${VOLUME_INFO[1]})"
  INSTANCE_NAME=(`ec2-describe-instances ${VOLUME_INFO[1]} | grep TAG | awk '{ print $5 }'`)

  echo "$(date +'%d/%m/%Y %H:%M:%S') Snapshot $INSTANCE_NAME - volume id : ${VOLUME_INFO[0]}";
  SNAP_ID=(`ec2-create-snapshot ${VOLUME_INFO[0]} --description "$INSTANCE_NAME-$(date +'%d%m%Y')" | awk '{ print $2 }'`)

  echo "$(date +'%d/%m/%Y %H:%M:%S') add tag to snapshot ($SNAP_ID)"
  ec2-create-tags $SNAP_ID --tag "AutoCreated=true"

done

echo "$(date +'%d/%m/%Y %H:%M:%S') -- Daily snapshot [ END ] --"

exit 0