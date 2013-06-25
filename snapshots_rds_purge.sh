#!/bin/bash
#################################################################################
# Ident         : snapshots_rds_purge.sh - 1.0
# Auteur        : J.Behuet
#
# Description   : Automatisation de la suppression des snapshots RDS
# 
# Usage         : ./snapshots_rds_purge.sh DB_IDENTIFIER MAX_RETENTION_DELAY
# Remarque(s)   : Ce script nécessite l'installation des Amazon RDS API Tools
#                 http://aws.amazon.com/developertools/2928
#
# Versions      :
#  V   | Date     | Auteur           | Description des modifications
# -----|----------|------------------|------------------------------------------        
# 1.0  |21-06-2013| J.Behuet         | Initial
#
#
#################################################################################
export JAVA_HOME=/usr/
export AWS_RDS_HOME=/usr/local/rds/
export EC2_REGION=eu-west-1
export PATH=$PATH:$AWS_RDS_HOME/bin

export AWS_ACCESS_KEY=NEED_YOUR_KEY
export AWS_SECRET_KEY=NEED_YOUR_KEY

SCRIPTNAME=`basename $0`
VERSION="1.0"
DESCRIPTION="Automatisation de la suppression des snapshot RDS"

function print_usage() {
  echo -e "Usage\t: ./snapshots_rds_purge.sh DB_IDENTIFIER MAX_RETENTION_DELAY"
  echo -e "ARGS"
  echo -e "\t-h : Print help"
}

function print_help() {
  print_version
  echo ""
  print_usage
  echo $DESCRIPTION
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

echo "[INFO] $(date +'%d/%m/%Y %H:%M:%S') -- RDS $1 snapshot purge [ START ] --"

if [ -z $1 ];then
  echo "[ERROR] Must specified RDS indentifier"
  exit 1
fi
if [ -z $2 ];then
  echo "[ERROR] Must specified RDS Max retention delay"
  exit 1
fi

SNAP_LIST=(`rds-describe-db-snapshots --db-instance-identifier $1 -H -I $AWS_ACCESS_KEY -S $AWS_SECRET_KEY --region $EC2_REGION | awk '{ print $2";"$3";"$8; }' | grep auto | grep available`) 

DELETED=0
TOTAL=0

for v in "${SNAP_LIST[@]}"; do

  SNAP_INFO=(`echo $v | tr ';' ' '`)
  TODAY=$(date -d "$date" "+%s")
  SNAP_DATE=$(date -d "${SNAP_INFO[1]}" "+%s")
  SEC_IN_DAY=86400

  DATE_DIFF=`echo \($TODAY - $SNAP_DATE\) / $SEC_IN_DAY | bc`

  # Test si la date est suppérieur à Xjours alors suppresion 
  if [ $DATE_DIFF -gt $2 ]; then
    expect -c "spawn rds-delete-db-snapshot --db-snapshot-identifier ${SNAP_INFO[0]} -I $AWS_ACCESS_KEY -S $AWS_SECRET_KEY --region $EC2_REGION 
    send \"y\r\"
    expect eof"
    echo "[INFO] $(date +'%d/%m/%Y %H:%M:%S') ${SNAP_INFO[0]} [ DELETED ]"
    ((DELETED++))
  else
    echo "[INFO] $(date +'%d/%m/%Y %H:%M:%S') ${SNAP_INFO[0]} [ KEEP ]"
  fi  

  ((TOTAL++))
done

echo "[INFO] $(date +'%d/%m/%Y %H:%M:%S') -- Result : $DELETED/$TOTAL Snapshot(s) deleted --"
echo "[INFO] $(date +'%d/%m/%Y %H:%M:%S') -- RDS snapshots purge [ END ] --"
