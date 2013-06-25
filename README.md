# Amazon Web Service - Tools

### Prérequis
Installation des EC2 API Tools : http://aws.amazon.com/developertools/351
Installation des RDS API Tools : http://aws.amazon.com/developertools/2928

### Création de snapshot de volume ebs (snapshots_volumes)

#### Description
Automatisation de la création des snapshots des différents volumes portant le tag Backup a true

#### Usage

```
./snapshots_volumes.sh
```

### Suppression des snapshots de volume ebs (snapshots_volumes_purge)

#### Description
Automatisation de la suppression plus de vieux de x jours des snapshots des différents volumes portant le tag AutoCreated a true

#### Usage

```
./snapshots_volumes_purge.sh
```

### Création de snapshot d'une instance RDS (snapshots_rds)

#### Description
Automatisation de la création des snapshot des instances RDS indiquées dans un fichier passé en paramètre

#### Usage

```
./snapshots_rds.sh FILE_RDS_IDENTIFIER
```

### Suppression des snapshots d'une instance RDS (snapshots_rds_purge)

#### Description
Automatisation de la suppression des snapshots RDS

#### Usage

```
./snapshots_rds_purge.sh DB_IDENTIFIER MAX_RETENTION_DELAY
```
