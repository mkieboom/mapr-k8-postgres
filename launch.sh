#!/bin/bash

echo "###################################################################"
echo "########        Postgres configuration details             ########"
echo "###################################################################"
echo PGDATA_LOCATION:	$PGDATA_LOCATION
echo PG_USER:			$PG_USER
#echo PG_PWD:			$PG_PWD
echo PG_DB:				$PG_DB
echo
echo "Running Postgres launch script now."
echo

# Set access rights for postgres user on database location folder
chown -R postgres:postgres $PGDATA_LOCATION

# Set location of database directory
sed -ie "s|/var/lib/pgsql/data|$PGDATA_LOCATION|g" /usr/lib/systemd/system/postgresql.service

# Initdb
su postgres -c "/usr/bin/initdb --auth-host=md5 --auth-local=trust --pgdata=$PGDATA_LOCATION"

# Open Postgres from all client IP's
echo "host    all             all             0.0.0.0/0               md5" >> $PGDATA_LOCATION/pg_hba.conf
echo "listen_addresses = '*'" >> $PGDATA_LOCATION/postgresql.conf

# Launch Postgres shortly to create users and database provided
su postgres -c "/usr/bin/pg_ctl start --pgdata=$PGDATA_LOCATION -w"
su postgres -c "psql --command \"CREATE USER $PG_USER WITH SUPERUSER PASSWORD '$PG_DB';\""
su postgres -c "createdb -O $PG_USER $PG_DB"
su postgres -c "/usr/bin/pg_ctl stop --pgdata=$PGDATA_LOCATION -w"

# Launch Postgres to make it a long living container
echo "Postgres server running."
su postgres -c "/usr/bin/postgres -D $PGDATA_LOCATION -h 0.0.0.0"
