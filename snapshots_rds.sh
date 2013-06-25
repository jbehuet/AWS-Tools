#!/bin/bash
#################################################################################
# Ident         : snapshots_rds.sh - 1.0
# Auteur        : J.Behuet
#
# Description   : Automatisation de la création des snapshot des instance RDS
#                 indiquées dans le fichier passé en paramètre
# 
# Usage         : ./snapshot_rds.sh FILE_RDS_IDENTIFIER
# Remarque(s)   : Ce script nécessite l'installation des Amazon RDS API Tools
#                 http://aws.amazon.com/developertools/2928
#
# Versions      :
#  V   | Date     | Auteur           | Description des modifications
# -----|----------|------------------|------------------------------------------        
# 1.0  |25-06-2013| J.Behuet         | Initial
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
DESCRIPTION="Automatisation de la création des snapshot des instances RDS indiquées dans le fichier passé en paramètre"

function print_usage() {
  echo -e "Usage\t: ./snapshots_rds.sh FILE_RDS_IDENTIFIER"
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

echo "[INFO] $(date +'%d/%m/%Y %H:%M:%S') -- RDS snapshot [ START ] --"

RDS_LIST=(`cat $1|awk '{ print $1 }'`)

if [ "$RDS_LIST" = "0" ]; then
  echo "[ERROR] $(date +'%d/%m/%Y %H:%M:%S') No RDS instances list"
  exit 1
fi

for rds in "${RDS_LIST[@]}"; do
  
  echo "[INFO] $(date +'%d/%m/%Y %H:%M:%S') Snapshot $rds";
  rds-create-db-snapshot --db-instance-identifier $rds -s "auto-$rds-$(date +'%d%m%Y-%H-%M-%S')" -I $AWS_ACCESS_KEY -S $AWS_SECRET_KEY --region $EC2_REGION

done

echo "[INFO] $(date +'%d/%m/%Y %H:%M:%S') -- RDS snapshot [ END ] --"

exit 0
