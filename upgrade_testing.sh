#If you want to start server on 5.6
n kill && sleep 10 && cdm && rm -rf $DATADIR && ./scripts/mysql_install_db --datadir=$DATADIR &&  n st 

#to shutdown
cdm && ./bin/mysqladmin shutdown -S $SOCKET

#Start the server on 5.7 by copying 5.6
DIR_56= && cd $HOME/MySQL/data && rm -rf $DATADIR &&  cp -r $DIR_56 $DATADIR && n st && sleep 10 && cd $SRC/bld && ./client/mysql_upgrade  --protocol tcp -P $PORT






