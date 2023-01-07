set -m

: ${SERVER_NAME:=my-server}
: ${GAME_VERSION:=public}
: ${LISTEN_IP:=$(hostname -I)}
: ${ADMIN_PASSWORD:=$(</run/secrets/admin-password)}

data_dir="$HOME/Zomboid"
scripts_dir="$HOME/scripts"
server_data_dir="$HOME/.steam/steamapps/common/Project Zomboid Dedicated Server"
server_cmd_path="$server_data_dir/start-server.sh"
default_config="$scripts_dir/default.ini"

steamcmd_install_or_update_server() {
    script=$(mktemp)
    cat >$script <<EOF
@NoPromptForPassword 1
login anonymous
app_update 380870 -beta $GAME_VERSION validate
quit
EOF
    steamcmd +runscript $script
    rm $script
}

world_exists() {
    test -f "$data_dir/Server/$SERVER_NAME.ini"
}

_server_cmd() {
    "$server_cmd_path" \
        -servername "$SERVER_NAME" \
        -ip "$LISTEN_IP" \
        -adminpassword "$ADMIN_PASSWORD"
}

install_or_update_server() {
    steamcmd_install_or_update_server
    # Fix bugs in provided start_server.sh
    patch -u "$server_cmd_path" -i "$scripts_dir/start-server.patch"
    # Fix broken LD_PRELOAD configuration in start_server.sh
    ln -frs "$server_data_dir/jre64/lib/server/libjsig.so" "$server_data_dir/libjsig.so"
}

initial_run() {
    # If this is a new world, there will be no ini file for the current server
    # name. In this case, we copy over the default.ini file in order
    # to enable mods before world generation.
    cp --no-clobber "$default_config" "$data_dir/Server/$SERVER_NAME.ini"
    _server_cmd<<<quit
}

run_server() {
    [ -e user-input ] && rm user-input
    mkfifo user-input
    tail -f user-input | _server_cmd
}
