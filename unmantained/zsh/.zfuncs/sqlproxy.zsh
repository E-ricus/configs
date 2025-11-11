function sql_proxy_connect() {
    if [[ -z "$1" || -z "$2" ]]; then
        echo "Usage: sql_proxy_connect <db_name> <env>"
        return 1
    fi

    local port="1234"
    if [[ -n "$3" ]]; then
        port="$3"
    fi

    local connection=""
    case "$1" in
      fulfillment)
        connection="flink-core-"$2":europe-west3:fulfillment"
        ;;
      flow-management)
        connection="flink-rider-engagement-"$2":europe-west3:flow-management"
        ;;
      rider-state)
        connection="flink-ridertech-"$2":europe-west3:rider-state-service-$2"
        ;;
      rider-profile)
        connection="flink-ridertech-"$2":europe-west3:rider-profile-service-$2"
        ;;
      equipment)
        connection="flink-rider-engagement-"$2":europe-west3:rider-equipment"
        ;;
      fleet)
        connection="flink-fleet-management-"$2":europe-west3:fleet-management-$2"
        ;;
      ops-staff)
        connection="flink-core-"$2":europe-west3:ops-staff-info"
        ;;
      qsm)
        connection="flink-ridertech-"$2":europe-west3:quinyx-rider-shifts-$2"
        ;;
      *)
        echo "Undefined database name: $1."
        read -q "CHOICE?Do you want to connect in flink-core [y/n]?\n"
        if [[ $CHOICE == "Y" || $CHOICE == "y" ]]; then
            connection="flink-core-"$2":europe-west3:$1"
        else
            echo "Add the database in the script with the correct connection string."
            return 1
        fi
        ;;
    esac
    local cmd="$HOME/cloud-sql-proxy --address 0.0.0.0 --port $port $connection"
    echo "Connecting to $cmd"
    eval $cmd
}
