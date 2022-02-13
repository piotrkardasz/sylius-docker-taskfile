#!/bin/bash

GLOBAL_IGNORE=$(git config --global core.excludesfile)

if [ ! -f "$GLOBAL_IGNORE" ]; then
    echo "$GLOBAL_IGNORE does not exist."
else
    if [ 0 -eq "$(grep -c docker-compose.debug.yml "$GLOBAL_IGNORE")" ]; then
        echo docker-compose.debug.yml >> "$GLOBAL_IGNORE";
    fi;
    if [ 0 -eq "$(grep -c Taskfile.yml "$GLOBAL_IGNORE")" ]; then
        echo Taskfile.yml >> "$GLOBAL_IGNORE";
    fi;
fi

command -v go >/dev/null 2>&1 || { echo >&2 "Go binary is required but it's not installed. Aborting."; exit 1; }
echo "Trying to install task file"
go install github.com/go-task/task/v3/cmd/task@latest

echo "Downloading configuration"
curl -s https://raw.githubusercontent.com/piotrkardasz/sylius-docker-taskfile/main/docker-compose.debug.yml --output ./docker-compose.debug.yml \
&& curl -s https://raw.githubusercontent.com/piotrkardasz/sylius-docker-taskfile/main/Taskfile.yml --output ./Taskfile.yml \
&& mkdir "$HOME/.sylius" \
&& curl -s https://raw.githubusercontent.com/piotrkardasz/sylius-docker-taskfile/main/.sylius/Taskfile.yml --output "$HOME/.sylius/Taskfile.yml" \
&& curl -s https://raw.githubusercontent.com/piotrkardasz/sylius-docker-taskfile/main/.sylius/.env.taskfile --output "$HOME/.sylius/.env.taskfile"

if [ -f "./Taskfile.yml" ] \
&& [ -f "./docker-compose.debug.yml" ] \
&& [ -f "$HOME/.sylius/Taskfile.yml" ] \
&& [ -f "$HOME/.sylius/.env.taskfile" ]; then
    echo "Configuration completed"
else
    echo "Something goes wrong :("
fi

echo "Now following commands are available via \"task\" command"
task --list
