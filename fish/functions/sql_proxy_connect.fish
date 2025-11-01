function sql_proxy_connect
    if test (count $argv) -lt 2
        echo "Usage: sql_proxy_connect <db_name> <env> [port]"
        return 1
    end

    set db_name $argv[1]
    set env $argv[2]
    set port 1234
    if test (count $argv) -ge 3
        set port $argv[3]
    end

    set connection ""
    switch $db_name
        case fulfillment
            set connection "flink-core-$env:europe-west3:fulfillment"
        case flow-management
            set connection "flink-rider-engagement-$env:europe-west3:flow-management"
        case rider-state
            if test $env = staging
                set env dev
            end
            set connection "flink-ridertech-$env:europe-west3:rider-state-service-$env"
        case rider-profile
            if test $env = staging
                set env dev
            end
            set connection "flink-ridertech-$env:europe-west3:rider-profile-service-$env"
        case equipment
            set connection "flink-rider-engagement-$env:europe-west3:rider-equipment"
        case fleet
            set connection "flink-fleet-management-$env:europe-west3:fleet-management-$env"
        case ops-staff
            set connection "flink-core-$env:europe-west3:ops-staff-info"
        case qsm
            set connection "flink-ridertech-$env:europe-west3:quinyx-rider-shifts-$env"
        case '*'
            echo "Undefined database name: $db_name."
            read -P "Do you want to connect in flink-core [y/n]? " choice
            if test $choice = Y -o $choice = y
                set connection "flink-core-$env:europe-west3:$db_name"
            else
                echo "Add the database in the script with the correct connection string."
                return 1
            end
    end

    set cmd "$HOME/cloud-sql-proxy --address 0.0.0.0 --port $port $connection"
    echo "Connecting to $cmd"
    eval $cmd
end
