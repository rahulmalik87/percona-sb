on master

create user 'replication_user'@'%' identified with caching_sha2_password by 'PASSWORD';
GRANT REPLICATION SLAVE ON *.* TO 'replication_user'@'%';
FLUSH PRIVILEGES;
show master status;

on slave

change master to MASTER_HOST='127.0.0.1', MASTER_PORT=1320, MASTER_USER='replication_user', MASTER_PASSWORD='PASSWORD' , GET_MASTER_PUBLIC_KEY=1, MASTER_LOG_FILE='binlog.000001',MASTER_LOG_POS=1076;
start slave;
