#!/bin/bash
#################################################################################
# Ident		: snapshots_purge.sh - 1.0
# Auteur	: J.Behuet
#
# Description 	: Automatisation de la suppression des snapshots ayantle tag
#		  AutoCreate à true
# 
# Usage		: ./snapshots_purge.sh
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
export JAVA_HOME=/usr/
export EC2_HOME=/usr/local/ec2/
export EC2_URL=https://ec2.eu-west-1.amazonaws.com
export PATH=$PATH:$EC2_HOME/bin

export AWS_ACCESS_KEY=NEED_YOUR_KEY
export AWS_SECRET_KEY=NEED_YOUR_KEY

SCRIPTNAME=`basename $0`
VERSION="1.0"
DESCRIPTION="Automatisation de la suppression des snapshot ayant le tag AutoCreate à true"

function print_usage() {
  echo -e "Usage\t: ./snapshots_purge.sh"
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

echo "[INFO] $(date +'%d/%m/%Y %H:%M:%S') -- Snapshots purge [ START ] --"
echo "[INFO] $(date +'%d/%m/%Y %H:%M:%S') Get snapshots list"

SNAP_LIST=(`ec2-describe-snapshots --filter "tag:AutoCreated=true" | grep SNAPSHOT | awk '{ print $2";"$5";"$9; }'`)

if [ "$SNAP_LIST" = "0" ]; then
  echo "[ERROR] $(date +'%d/%m/%Y %H:%M:%S') Get snapshots list"
  exit 1
fi

#Modifier cette valeur pour augmenter ou diminuer la rention maximale d'un snapshot
MAX_RETENTION=7

DELETED=0
TOTAL=0

for v in "${SNAP_LIST[@]}"; do

  SNAP_INFO=(`echo $v | tr ';' ' '`)
  TODAY=$(date -d "$date" "+%s")
  SNAP_DATE=$(date -d "${SNAP_INFO[1]}" "+%s")
  SEC_IN_DAY=86400

  DATE_DIFF=`echo \($TODAY - $SNAP_DATE\) / $SEC_IN_DAY | bc`

  # Test si la date est suppérieur à Xjours alors suppresion 
  if [ $DATE_DIFF -gt $MAX_RETENTION ]; then
    ec2-delete-snapshot ${SNAP_INFO[0]}
    echo "[INFO] $(date +'%d/%m/%Y %H:%M:%S') ${SNAP_INFO[2]} (${SNAP_INFO[0]}) [ DELETED ]"
    ((DELETED++))
  else
    echo "[INFO] $(date +'%d/%m/%Y %H:%M:%S') ${SNAP_INFO[2]} (${SNAP_INFO[0]}) [ KEEP ]"
  fi

  ((TOTAL++))

done
echo "[INFO] $(date +'%d/%m/%Y %H:%M:%S') -- Result : $DELETED/$TOTAL Snapshot(s) deleted --"
echo "[INFO] $(date +'%d/%m/%Y %H:%M:%S') -- Snapshots purge [ END ] --"

exit 0
