#!/usr/bin/env bash
#------------------
set_session_env() {
    SESSION_2="lingmo-session"

    # Adding dbus-launch may cause problems with vscode.
    #
    DBUS_CMD="dbus-launch"

    [[ ! -s /etc/environment ]] || source /etc/environment
    # /run/user/$UID
    [[ -n ${XDG_RUNTIME_DIR} ]] || export XDG_RUNTIME_DIR=/tmp/runtime-${UID}
    [[ -e ${XDG_RUNTIME_DIR} ]] || mkdir -pv ${XDG_RUNTIME_DIR}
}

start_session() {
    for i in ${SESSION_2}; do
        if [[ -n $(command -v $i) ]]; then
            exec ${DBUS_CMD} ${i} ${@}
            break
        fi
    done
}
set_session_env
start_session ${@}

