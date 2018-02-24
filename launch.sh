#!/bin/bash

echo "###################################################################"
echo "########        Postgres configuration details             ########"
echo "###################################################################"

echo PGDATA_LOCATION:	$PGDATA_LOCATION
echo PG_DB:				$PG_DB
echo PG_GROUP:			$PG_GROUP
echo PG_USER:			$PG_USER
#echo PG_PWD:			$PG_PWD
echo PG_GID:			$PG_GID
echo PG_UID:			$PG_UID
echo
echo "Running Postgres launch script now."
echo

mkdir -p $PGDATA_LOCATION

# Set access rights for postgres user on database location folder
chown -R $PG_USER:$PG_GROUP $PGDATA_LOCATION

# Set location of database directory
sed -ie "s|/var/lib/pgsql/data|$PGDATA_LOCATION|g" /usr/lib/systemd/system/postgresql.service

sed -ie "s|User=postgres|User=$PG_USER|g" /usr/lib/systemd/system/postgresql.service
sed -ie "s|Group=postgres|Group=$PG_GROUP|g" /usr/lib/systemd/system/postgresql.service

chown -R $PG_USER:$PG_GROUP /var/run/postgresql
chown -R $PG_USER:$PG_GROUP /run/postgresql/

# Initdb
su $PG_USER -c "/usr/bin/initdb --auth-host=md5 --auth-local=trust --pgdata=$PGDATA_LOCATION --username=$PG_USER" 

# Open Postgres from all client IP's
echo "host    all             all             0.0.0.0/0               md5" >> $PGDATA_LOCATION/pg_hba.conf
echo "listen_addresses = '*'" >> $PGDATA_LOCATION/postgresql.conf

# Launch Postgres shortly to create users and database provided
su $PG_USER -c "/usr/bin/pg_ctl start --pgdata=$PGDATA_LOCATION -w"

# Create the user, db and grant priviliges
su $PG_USER -c "createuser $PG_USER"
su $PG_USER -c "createdb $PG_DB"
su $PG_USER -c "psql --command \"alter user $PG_USER with encrypted password '$PG_PWD';\""
su $PG_USER -c "psql --command \"grant all privileges on database $PG_DB to $PG_USER ;\""

# Stop the database server
su $PG_USER -c "/usr/bin/pg_ctl stop --pgdata=$PGDATA_LOCATION -w"

# Launch Postgres to make it a long living container
echo "Postgres server running."
su $PG_USER -c "/usr/bin/postgres -D $PGDATA_LOCATION -h 0.0.0.0"
