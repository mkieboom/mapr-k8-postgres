# Postgres on Kubernetes & MapR
# using the MapR Volume Driver Plugin for Kubernetes
#
# VERSION 0.1 - not for production, use at own risk
#

#
# Use a CentOS 7 image as the base
FROM centos

MAINTAINER mkieboom @ mapr.com

# Set Postgres environment variables, change to your liking
ENV PGDATA_LOCATION /mapr/demo.mapr.com/postgres
ENV PG_USER mapr
ENV PG_PWD mapr
ENV PG_DB mapr

# Install Postgres
RUN yum install -y postgresql-server

# Add the launch script and make it executable
ADD ./launch.sh /launch.sh
RUN chmod +x /launch.sh

# Expose the Postgres server port
EXPOSE 5432

CMD /launch.sh