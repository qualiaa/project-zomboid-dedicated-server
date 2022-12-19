FROM steamcmd/steamcmd

RUN apt-get update && apt-get upgrade -y && \
    apt-get install patch && \
    rm -rf /var/lib/apt/lists/*

# Create unprivileged user to run server
RUN useradd -m zomboid
ENV USER_HOME /home/zomboid
ENV STEAM_HOME "$USER_HOME/.steam"
ENV INSTALL_DIR "$STEAM_HOME/steamapps/common/Project Zomboid Dedicated Server"

# We must move steam install to unprivileged user, and create all volume
# mount-points with correct ownership before they are mounted for the first time
RUN mv /root/.steam "$STEAM_HOME" && \
    ln -sf "$STEAM_HOME" "$STEAM_HOME"/root && \
    ln -sf "$STEAM_HOME" "$STEAM_HOME"/steam && \
    mv "$STEAM_HOME"/{SteamApps,steamapps} && \
    mkdir "$INSTALL_DIR" && \
    touch "$INSTALL_DIR/ProjectZomboid64.json" && \
    mkdir -p "$USER_HOME/Zomboid/Server" && \
    chown -R zomboid:zomboid "$USER_HOME/Zomboid" "$STEAM_HOME"

USER zomboid
# These variables are not set correctly automatically for some reason
ENV HOME "$USER_HOME"
ENV USER zomboid

WORKDIR $HOME

ENTRYPOINT ["bash", "-c"]
CMD ["$HOME/scripts/run"]
