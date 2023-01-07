# Project Zomboid docker-compose configuration

This is my attempt to get the slightly cantankerous Project Zomboid dedicated
server working with docker compose.

## First-time installation

Clone this repo somewhere in your web server:

    git clone https://github.com/qualiaa/project-zomboid-dedicated-server

Then enter the repository root and run an init script

    cd project-zomboid-dedicated-server
    utils/init

You need to set the `HOST_UID` in the file `.env` to your UID (find this with the
command `id -u`). You may also wish to change the listening ports, also in
this file.

Set the server admin password by modifying the file `secrets/admin-password`.

Now install the server software with:

    docker-compose run --rm --build server scripts/update

> **NOTE**: After installation, you probably want to tweak is the `-Xmx8g`
> maximum allocated RAM in `config/jvm-config.yml`; replace `8g` with some other
> value in `m`egabytes or `g`igabytes.


## Starting a new world

To start a new world, change the `SERVER_NAME` value in the (hidden) file
`.env`.

> **NOTE**: If you want to set up mods for the server, modify the template
> config file at `scripts/default.ini` appropriately. Changes you make here will
> be copied into the world-specific config files generated later.

Now start the server with:

    docker-compose up

This will automatically exit after completing initial world setup.  You can then
find server config files in `config/Zomboid/Server`; edit them to suit your
needs.

On subsequent runs the server should be run with:

    docker-compose up --detach

You can bring the server down safely at any time with:

    docker-compose down

## Updating an existing server

When an update is released, you should bring the server down with:

    docker-compose down

then issue the command:

    docker-compose run --rm server scripts/update

then bring the server up again with:

    docker-compose up --detach

## Running multiple servers

In order to run multiple servers, duplicate the `.env` file, for example to
`server-1.env` and `server-2.env`. Make sure you set the ports and `SERVER_NAME`
differently for each server. Then launch each one with

    docker-compose --env-file "server-1.env" up --detach
    docker-compose --env-file "server-2.env" up --detach

Note that all servers will share the same config folder and game data. If you
want to separate them completely, for example to run servers at different game
versions, you need to copy the whole compose project folder and manage each one
independently.

## RCON

RCON is currently broken and I don't have time to work out how to fix it.

As a stop-gap measure, there is a script `utils/send-cmd` which passes its
arguments as input to the server:

    send-cmd help
    send-cmd players
    send-cmd quit
