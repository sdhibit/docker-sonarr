#!/bin/ash

#export LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:$LD_LIBRARY_PATH
#PATH=/usr/bin:/usr/local/bin:$PATH
# Start Sonarr
/sbin/su-exec sonarr /usr/bin/mono /opt/sonarr/NzbDrone.exe \
   --no-browser \
   -data=/config