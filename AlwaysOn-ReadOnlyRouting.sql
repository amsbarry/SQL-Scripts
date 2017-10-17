SELECT  ar.replica_server_name ,
        ar.endpoint_url ,
        ar.replica_server_name ,
        ar.availability_mode_desc ,
        ar.failover_mode_desc ,
        ar.session_timeout ,
        ar.primary_role_allow_connections_desc ,
        ar.secondary_role_allow_connections_desc ,
        ar.backup_priority ,
        ar2.read_only_routing_url
FROM    sys.availability_replicas ar
        INNER JOIN sys.availability_read_only_routing_lists avr ON ar.replica_id = avr.replica_id
        INNER JOIN sys.availability_replicas ar2 ON avr.read_only_replica_id = ar2.replica_id;