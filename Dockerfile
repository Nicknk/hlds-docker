FROM debian:buster

LABEL maintainer "Nick NK <n47@paragenesis.ru>"

ARG steam_user=anonymous
ARG steam_password=

RUN apt-get update && apt-get install -y lib32gcc1 curl python3 apt-utils

# Install SteamCMD
RUN mkdir -p /opt/steam && cd /opt/steam && \
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# Install HLDS
RUN mkdir -p /opt/hlds
# Workaround for "app_update 90" bug, see https://forums.alliedmods.net/showthread.php?p=2518786
RUN /opt/steam/steamcmd.sh +login $steam_user $steam_password +force_install_dir /opt/hlds +app_update 90 validate +quit || \
    /opt/steam/steamcmd.sh +login $steam_user $steam_password +force_install_dir /opt/hlds +app_update 90 validate +quit
RUN /opt/steam/steamcmd.sh +login $steam_user $steam_password +force_install_dir /opt/hlds +app_update 70 validate +quit || :
RUN mkdir -p ~/.steam && ln -s /opt/hlds ~/.steam/sdk32
RUN ln -s /opt/steam/ /opt/hlds/steamcmd
ADD files/steam_appid.txt /opt/hlds/steam_appid.txt
ADD hlds_run.sh /bin/hlds_run.sh

# Add default config
ADD files/server.cfg /opt/hlds/cstrike/server.cfg

# Add maps and bots
ADD cstrike/ /opt/hlds/cstrike/
ADD files/mapcycle.txt /opt/hlds/cstrike/mapcycle.txt

# Cleanup
RUN apt-get remove -y curl

WORKDIR /opt/hlds

ENTRYPOINT ["/bin/hlds_run.sh"]
