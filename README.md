# mapr-k8-postgres

##### Pre-requisite
Make sure to have the MapR Volume Driver for Kubernetes installed and running on your Kubernetes environment.

##### Launch the dynamic MapR volume creation on Kubernetes
```
# Change the MapR specific parameters in the yaml file to reflect your MapR cluster configuration
  
kubectl create -f mapr-k8-postgres-part1-volumedriver.yaml
```
##### Launch container as deamon with auto restart  
```
# Change the MapR and Postgres specific parameters in the yaml file to reflect your MapR & Postgres configuration

kubectl create -f mapr-k8-postgres-part2-container.yaml
```

##### Use psql to connect  
```
# Install psql client on any other machine  
yum install -y postgresql
```

##### Connect to remote database  
```
# Use psql client to connect to the database server (username/password: mapr/mapr)
psql -U mapr -h k8snode01 -p 30003
```

##### Basic SQL testing
```
CREATE SCHEMA test;
CREATE TABLE test.test (coltest varchar(20));
insert into test.test (coltest) values ('It works!');
SELECT * from test.test;
```

##### Modify the Docker container (optional)

##### Clone the project
```
git clone https://github.com/mkieboom/mapr-k8-postgres  
cd mapr-k8-postgres  
```

##### Modify the Postgres variables
By modifying the Dockerfile, eg:  
```
vi Dockerfile
ENV PGDATA_LOCATION /postgres
ENV PG_DB mapr
ENV PG_GROUP mapr
ENV PG_USER mapr
ENV PG_PWD mapr
ENV PG_UID 5000
ENV PG_GID 5000
```

##### Build the container  
```
docker build -t mkieboom/mapr-k8-postgres .
```
