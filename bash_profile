
BX=""
BBX=""
PORT=""



#sandboxes default is o7 ; o for oracle-mysql , p for perocna-server , x xtrabackup
N_HELP="pick one of the box by o7|o8|o81|p7|p2|xp7|xo7|xo71 \nst: start server \ninit: initialize server \nclean : clean data and logdir\ncon: connect the server\nmkdir: make log and data directory\nbkp: to bkp xtrab backup using $BX sandbox \n prep : prepare backp \n res : restore backup\n bkp_res backup prepare and restor 
"
alias ll='ls -ltr'
n() {
if [ -z $1 ]; then
 echo -e $N_HELP;
elif [ -z $BX ]; then
  sandbox $1
elif [ "st" = $1 ]; then 
 $MYSQLD $nopt --port $PORT 2>&1 | tee $ldir/mysql_$BX.log & #to start server
elif [ "init" = $1 ]; then 
 n kill
 n clean
 rm -rf $MYSQL_HOME/key.key
 $MYSQLD $nopt --initialize-insecure 2>&1 | tee $ldir/mysql_init_$BX.log #to start server
 n st &
elif [ "clean" = $1 ]; then
 echo "cleaning direcotry $ldir and $DATADIR"
 rm -r $ldir
 rm -r $DATADIR
 n mkdir
elif [ "mkdir" = $1 ]; then
 mkdir -p $ldir
 mkdir -p $DATADIR
elif [ "kill" = $1 ]; then
# modify code to only expected mysqld
 killall -9 mysqld
elif [ "con" = $1 ]; then
 $MYSQL --socket $SOCKET -uroot 
elif [ "bkp" = $1 ]; then
 rm -r $DATADIR 
 $XT_COMMAND --backup 2>&1 | tee $ldir/backup_$BX.log 
 grep "completed OK!" $ldir/backup_$BX.log -c
elif [ "prep_again" = $1 ]; then
 rm -r $HOME/MySQL/data/$BOX 
 unzip $ldir/bkp.zip -d $HOME/MySQL/data
 $XT_COMMAND --prepare 2>&1 | tee $ldir/prepare_$BX.log
 grep "completed OK!" $ldir/prepare_$BX.log -c
elif [ "prep" = $1 ]; then
 rm $ldir/bkp_old.zip 
 mv $ldir/bkp.zip $ldir/bkp_old.zip
 cd $HOME/MySQL/data && zip -r $ldir/bkp.zip $BOX #copy source data directory 
 $XT_COMMAND --prepare 2>&1 | tee $ldir/prepare_$BX.log
 grep "completed OK!" $ldir/prepare_$BX.log -c
elif [ "res" = $1 ]; then
 rm $ldir/src_data_bkp.zip
 mv $ldir/src_data.zip $ldir/src_data_bkp.zip
 cd $HOME/MySQL/data && zip -r $ldir/src_data.zip $BBX #copy source data directory rm -r $SRC_DATADIR 
 rm -r $SRC_DATADIR/*
 $XT_COMMAND --copy-back --datadir=$SRC_DATADIR 2>&1 | tee $ldir/restore_$BX.log
elif [ "bkp_res" = $1 ]; then
 n bkp && n kill && n prep && n res
elif [ "make" = $1 ]; then
 cd $HOME/MySQL/src_$BX && rm -rf storage/rocksdb && rm -rf storage/tokudb && rm -rf ../$BX && rm -rf bld && mkdir bld && cd bld && cmake $cmk -DCMAKE_INSTALL_PREFIX=~/MySQL/$BX .. && make -j7 && make install
else
    sandbox $1
fi
}

alias cdp='cd ~/pquery/src'

BBX=o8 #box to copy

#test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"


cr() {
find . -path ./bld -prune -o \( -name \*.i -o -name \*.ic -o -name \*.h -o -name \*.c -o -name \*.cc -o -name \*.yy -o -name \*.ll -o -name \*.y -o -name \*.I -o -name \*.cpp -o -name \*.txt \) > cscope.files
ctags --langmap=c++:+.ic --langmap=c++:+.i -L ./cscope.files
\cscope -i ./cscope.files
}

alias csc='cdsm && cscope -i ./cscope.files'

#call macos related methods 
darwin() {
export ctags='/usr/local/Cellar/ctags/5.8_1/bin/ctags'
#path for openssl
export LDFLAGS="-L/usr/local/opt/openssl/lib"
export CPPFLAGS="-I/usr/local/opt/openssl/include"
export PATH="/usr/local/opt/openssl/bin:$PATH"export PATH="/usr/local/opt/openssl/bin:$PATH"
alias rscp='scp $QA20:/tmp/1.patch /tmp/1.patch && patch -p1 < /tmp/1.patch'
export QA06='rahul.malik@10.30.6.206'
export QA09='rahul.malik@10.30.6.209'
export QA20='rahul.malik@10.30.7.20'
export QA02='rahul.malik@10.30.6.202'
}

print_space_id_low() {
        format=`find . -type f -name "$1" -exec echo "{}" \;`
        for i in $format;
        do
                # if [[ "$i" == "$format" ]]
                # then
                #    echo "No Files"
                # else
                echo "file name $i"
                od -j34 -N4 -t x1 -An "$i"
                # fi
        done
}

print_space_id() {
        print_space_id_low "*.ibd"
        print_space_id_low "undo*"
        print_space_id_low "*ibtmp*"
}

function subbox() {
    tp=`echo $1 | cut -c1`
    if [ $tp != "o" ] && [ $tp != "p" ] ; then
      echo -e "invalid options "$N_HELP
	return 0; fi

    export ver=`echo $1 | cut -c2`
    if [ $ver != 7 ] && [ $ver != 8 ]; then
	BX="";
      echo -e "invalid options "$N_HELP
	return;
    fi

    if [ $tp = "o" ] ; then
	export m_version="oracle";
	PORT=132
    else
	PORT=122
	export m_version="ps";
    fi

    if [ ${#1} = 2 ] ; then
	ab=0 
    else
        ab=`echo $1 | cut -c2-3`
    fi
    BX=$1
    PORT=$PORT$ab
}

function sandbox() {
    bx=`echo $1 | cut -c1`
    if [ $bx != "o" ] && [ $bx != "p" ] && [ $bx != "x" ] ; then
        echo -e "invalid options "$N_HELP
	return 0;
    fi

    if [ $bx = "o" ] || [ $bx = "p" ] ; then
	subbox $1;
	BBX=""
    else
	sd=`echo $1 | cut -c2`
	re='^[0-9]+$'
	if  [[ $sd =~ $re ]] ; then
	    new=`echo $1 | cut -c3-5`
	    bx=$bx$sd
	else
	    new=`echo $1 | cut -c2-5`
	fi
	    subbox $new;
	    BBX=$BX;
	    if [ $BX ] ; then
	    BX=$bx$ver;
	    fi
    fi
      export BOX=$1
      export SOCKET=/tmp/socket_$PORT.sock
      export DATADIR=$HOME/MySQL/data/$BOX
      export ldir=$HOME/MySQL/log/$BOX
      export SRC_DATADIR=$HOME/MySQL/data/$BBX
    if [ $ver = "7" ] ; then
      export MYSQL_HOME=$HOME/MySQL/$BX
      export MYSQL=$MYSQL_HOME/bin/mysql
      export MYSQLD=$MYSQL_HOME/bin/mysqld
      alias dt='$HOME/MySQL/o7/bin/mysql  --socket $SOCKET -uroot test' 
      alias cdb='$HOME/MySQL/o7/bin/mysql  --socket $SOCKET -uroot -e "create database test;"' 
      export XTRABACKUP=$HOME/MySQL/src_$BX/bld/storage/innobase/xtrabackup/src/xtrabackup
      export XTRABACKUP_BASEDIR=$HOME/MySQL/src_$BX/bld/storage/innobase/xtrabackup/src
    export XT_COMMAND=$XTRABACKUP" --target-dir=$DATADIR --core-file --user=root --keyring-file-data=$HOME/MySQL/$BBX/key.key --socket $SOCKET --xtrabackup-plugin-dir=$HOME/MySQL/src_$BX/bld/storage/innobase/xtrabackup/src/keyring"
      export nopt=" --basedir=$MYSQL_HOME --log-error-verbosity=3 --debug-sync-timeout=1000 --core-file --early-plugin-load=keyring_file.so --keyring_file_data=$MYSQL_HOME/key.key --socket $SOCKET --datadir $DATADIR"
      export XT_COMMAND=$XTRABACKUP" --target-dir=$DATADIR --core-file --user=root --keyring-file-data=$HOME/MySQL/$BBX/key.key --socket $SOCKET --xtrabackup-plugin-dir=$HOME/MySQL/src_$BX/bld/storage/innobase/xtrabackup/src/keyring"
    else
      export MYSQL_HOME=$HOME/MySQL/src_$BX/bld/runtime_output_directory
      export MYSQL=$MYSQL_HOME/mysql
      export MYSQLD=$MYSQL_HOME/mysqld
      alias dt='$HOME/MySQL/o8/bin/mysql  --socket $SOCKET -uroot test' 
      alias cdb='$HOME/MySQL/o8/bin/mysql  --socket $SOCKET -uroot -e "create database test;"' 
      export XTRABACKUP=$MYSQL_HOME/xtrabackup
      export nopt="--loose_mysqlx_port=$PORT --loose_mysqlx_socket=/tmp/mysqx_`expr $PORT - 50`.sock  --loose_mysqlx_port=`expr $PORT - 50` --basedir=$MYSQL_HOME --log-error-verbosity=3 --debug-sync-timeout=1000 --core-file --early-plugin-load=keyring_file.so --keyring_file_data=$MYSQL_HOME/key.key --plugin-dir=$HOME/MySQL/src_$BX/bld/plugin_output_directory --socket $SOCKET --datadir $DATADIR"
    fi
    export XT_COMMAND=$XTRABACKUP" --target-dir=$DATADIR --core-file --user=root --keyring-file-data=$HOME/MySQL/$BBX/key.key --socket $SOCKET --xtrabackup-plugin-dir=$HOME/MySQL/src_$BX/bld/plugin_output_directory"
    ulimit -c unlimited
    export src=$HOME/MySQL/src_$BX
    alias cdd='cd $DATADIR'
    alias cdl='cd $ldir'
    alias cds='cd $src'
    alias cdm='cd ~/MySQL/$BX'
    alias bo='cd ~/pquery && git clean -fdx && cmake -DBASEDIR=$HOME/MySQL/$BX -DMYSQL=ON . && make -j && cdp && ctags -R';
    alias bp='cd ~/pquery && git clean -fdx && cmake -DBASEDIR=$HOME/MySQL/$BX -DPERCONASERVER=ON . && make -j && cdp && ctags -R';
    alias cdsm='cd ~/MySQL/src_$BX'
    alias cqa='cd ~/MySQL/percona-qa'
    alias cdsx='cd $src/storage/innobase/xtrabackup'
    alias cdbl='cd $HOME/MySQL/src_$BX/bld'
    alias gc='git clean -fdx'
    alias gs='git status'
    alias gp='git pull'
    alias lscp='git diff --cached > /tmp/1.patch && scp /tmp/1.patch $QA20:/tmp'
    alias tap='patch -p1 < /tmp/1.patch'
    alias ttp='git diff --cached > /tmp/1.patch'
cmk='-DDOWNLOAD_BOOST=1 -DWITH_BOOST=../../boost -DWITH_ROCKSDB=OFF -DWITHOUT_TOKUDB=OFF -DWITH_DEBUG=on -DCMAKE_EXPORT_COMPILE_COMMANDS=on'
    if [ -z $BBX ] ; then
	export PS1="{\[\e[32m\]\h\[\e[m\]\[\e[36m\] $BX \[\e[m\]\W}$"
    else 
	export PS1="{\[\e[32m\]\h\[\e[m\]\[\e[36m\] $BX $BBX \[\e[m\]\W}$"
    fi;
    n mkdir
}

[ `uname` = Darwin ] && darwin
