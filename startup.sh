#!/bin/bash

/etc/init.d/postgresql start
su -c "psql -c \"ALTER USER postgres PASSWORD 'postgres';\"" postgres

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi