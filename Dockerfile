# dot is relative path to the Dockerfile
# docker build -t mydb .

# -it is for interactive mode
# docker run --name mydb_c -it mydb

# FROM gradescope/autograder-base:latest

FROM ubuntu:22.04
#ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update

# Installing postgres pauses to ask for timezone and geographical area
# and gets stuck in the Docker build process
# I think this fixes it
RUN DEBIAN_FRONTEND=noninteractive TZ=America/New_York apt-get -y install tzdata

# Need all this to install latest version of postgres 16 on Ubuntu 22.04
RUN apt-get install -y lsb-release   
RUN apt-get -y install curl ca-certificates
RUN install -d /usr/share/postgresql-common/pgdg
RUN curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN apt-get update
RUN apt-get -y install postgresql-16 postgresql-contrib
RUN apt-get update && apt-get install -y python3 python3-pip
RUN pip3 install gradescope-utils

# change the postgres user password to postgres
RUN echo postgres:postgres | chpasswd

# don't forget the port mapping on the docker run command -p 5432:5432
EXPOSE 5432

# start the postgres service
# CMD ["/etc/init.d/postgresql", "start"]

# change the postgres database user password to postgres
# These cannot be RUN commands because they need to be done after the service is started
#RUN su -c "psql -c \"ALTER USER postgres PASSWORD 'postgres';\"" postgres
#RUN su - postgres -c 'psql -c "ALTER USER postgres PASSWORD '\''postgres'\'';"'

# su - postgres
# \password postgres
# psql -U postgres -h localhost

# add the following line to the /etc/postgresql/16/main/pg_hba.conf file
# host    all             all             0.0.0.0/0               md5
RUN echo "host    all             all       0.0.0.0/0               md5" >> /etc/postgresql/16/main/pg_hba.conf

# add the following line to /etc/postgresql/16/main/postgresql.conf
# listen_addresses = '*'
RUN echo "listen_addresses = '*'" >> /etc/postgresql/16/main/postgresql.conf

# create a working directory in the container
WORKDIR /startup

# copy the startup script to the working directory
COPY startup.sh .

# run the startup script. The -d feels like a hack 
# https://github.com/sequenceiq/hadoop-docker/blob/master/Dockerfile
# https://stackoverflow.com/questions/28212380/why-docker-container-exits-immediately
CMD ["./startup.sh", "-d"]


