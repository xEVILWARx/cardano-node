usage_app() {
     usage "app" "Multi-container application" <<EOF
    compose               Multi-container description file

EOF
}

app() {
  local op=${1:-show}; test $# -gt 0 && shift

  case "$op" in

    # wb app compose $WORKBENCH_SHELL_PROFILE_DIR/{profile,node-specs}.json name tag
    compose )
      # jq 'keys|.[]' --raw-output $WORKBENCH_SHELL_PROFILE_DIR/node-specs.json
      local usage="USAGE: wb app $op PROFILE-NAME/JSON NODE-SPECS/JSON IMAGE_NAME IMAGE_TAG"
      local profile=${1:?$usage}
      local nodespecs=${2:?$usage}
      local imageName=${3:?$usage}
      local imageTag=${4:?$usage}

      # Hack
      global_rundir_def=$PWD/run

      yq --yaml-output "{
        services:
          (
              .
            | with_entries(
                {
                    key: .key
                  , value: {
                        container_name: \"\(.value.name)\"
                      , pull_policy: \"never\"
                      , image: \"$imageName:$imageTag\"
                      , networks: [\"cardano-node-network\"]
                      , ports: [\"\(.value.port):\(.value.port)\"]
                      , volumes: [
                            \"SHARED:/var/cardano-node\"
                          , \"LOCAL-\(.value.name):/var/cardano-node/local\"
                        ]
                      , environment: [
                            \"DATA_DIR=/var/cardano-node/local\"
                          , \"NODE_CONFIG=/var/cardano-node/local/config.json\"
                          , \"NODE_TOPOLOGY=/var/cardano-node/local/topology.json\"
                        ]
                    }
                }
              )
          )
        , \"networks\": {\"cardano-node-network\": {}}
        , volumes:
          (
              .
            | with_entries (
                {
                    key: \"LOCAL-\(.value.name)\"
                  , value: {
                        external: false
                      , driver_opts: {
                            type: \"none\"
                          , o: \"bind\"
                          , device: \"./run/current/\(.value.name)\"
                        }
                    }
                }
              )
            +
              {SHARED:
                {
                    external: false
                  , driver_opts: {
                        type: \"none\"
                      , o: \"bind\"
                      , device: \"./run/current\"
                    }
                }
              }
          )
      }" $nodespecs;;

    * ) usage_app;; esac
}
