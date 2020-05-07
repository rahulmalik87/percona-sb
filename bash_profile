
BX=""
BBX="" #if set means, running with backup directory:w
PORT=""
#global alias
alias csc='cdsm && cscope -i ./cscope.files'
alias gs='git status'
alias cdp='cd ~/pstress/src'
alias gpc='git push -f -u origin `echo $(basename $PWD)`' #git push current
alias cdh='cd $HOME/MySQL'
alias cds='cd $HOME/study'
alias cdc='cd $HOME/study/cpp'
export xb="$HOME/MySQL/rahul-xb"

#sandboxes default is o7 ; o for oracle-mysql , p for perocna-server , x xtrabackup
N_HELP="pick one of the box by o7|o8|o81|p7|p2|xp7|xo7|xo71 \nst: start server \ninit: initialize server \nclean : clean data and logdir\ncon: connect the server\nmkdir: make log and data directory\nbkp: to bkp xtrab backup using $BX sandbox \nprep : prepare backp \nres : restore backup\nbkp_res backup prepare and restore\n\nmodify CMK for CMAKE build\nXT_COMANND to modify XTRABCKUP option\nMYSQLD_OPTION to modify mysqld options"
alias ll='ls -ltr'
n() {
if [ -z $1 ]; then
 echo -e $N_HELP;
elif [ -z $BX ]; then
  sandbox $1
elif [ "st" = $1 ]; then
 $MYSQLD $MYSQLD_OPTION --port $PORT 2>&1 | tee $LOGDIR/mysql_$BX.log & #to start server
elif [ "init" = $1 ]; then
 n kill
 n clean
 $MYSQLD $MYSQLD_OPTION --initialize-insecure 2>&1 | tee $LOGDIR/mysql_init_$BX.log #to start server
 n st &
elif [ "clean" = $1 ]; then
 echo "cleaning direcotry $LOGDIR and $DATADIR"
 rm -r $LOGDIR
 rm -r $DATADIR
 n mkdir
elif [ "mkdir" = $1 ]; then
 mkdir -p $LOGDIR
 mkdir -p $DATADIR
elif [ "kill" = $1 ]; then
# modify code to only expected mysqld
 killall -9 mysqld
elif [ "con" = $1 ]; then
 $MYSQL --socket $SOCKET -uroot
elif [ "bkp" = $1 ]; then
 rm -r $DATADIR*
 mkdir $DATADIR
 $XT_COMMAND --backup 2>&1 | tee $LOGDIR/backup_$BX.log
 grep "completed OK!" $LOGDIR/backup_$BX.log -c
elif [ "inc" = $1 ]; then
 mv $DATADIR $DATADIR"_bkp"
 $XT_COMMAND --backup --incremental-basedir=$DATADIR"_bkp" | tee $LOGDIR/increment_$BX.log
 grep "completed OK!" $LOGDIR/backup_$BX.log -c
elif [ "prep_again" = $1 ]; then
 rm -r $HOME/MySQL/data/$BOX
 unzip $LOGDIR/bkp.zip -d $HOME/MySQL/data
 $XT_COMMAND --prepare 2>&1 | tee $LOGDIR/prepare_$BX.log
 grep "completed OK!" $LOGDIR/prepare_$BX.log -c
elif [ "prep" = $1 ]; then
 #if it is increment backup"
 if [ -d $DATADIR"_bkp" ]; then
  mv $DATADIR $DATADIR"_inc"
  rm $LOGDIR/inc_zip.zip
  mv $LOGDIR/inc.zip $LOGDIR/inc_old.zip
  mv $DATADIR"_bkp" $DATADIR
  cd $HOME/MySQL/data && zip -r $LOGDIR/inc.zip $BOX"_inc" #copy source data directory
 fi
 #backup of backup directory
 rm $LOGDIR/bkp_old.zip
 mv $LOGDIR/bkp.zip $LOGDIR/bkp_old.zip
 cd $HOME/MySQL/data && zip -r $LOGDIR/bkp.zip $BOX #copy source data directory
 $XT_COMMAND --prepare --apply-log-only 2>&1 | tee $LOGDIR/prepare_base$BX.log
 grep "completed OK!" $LOGDIR/prepare_base$BX.log -c
elif [ "prep_inc" = $1 ]; then
 $XT_COMMAND --prepare --incremental-dir=$DATADIR"_inc"  2>&1 | tee $LOGDIR/prepare_inc$BX.log
 grep "completed OK!" $LOGDIR/prepare_inc$BX.log -c
elif [ "copy_src" = $1 ]; then
 rm $LOGDIR/src_data_bkp.zip
 mv $LOGDIR/src_data.zip $LOGDIR/src_data_bkp.zip
 cd $HOME/MySQL/data && zip -r $LOGDIR/src_data.zip $BBX #copy source data directory rm -r $SRC_DATADIR
 cp $SRC_DATADIR/key.key $LOGDIR
elif [ "res" = $1 ]; then
 n copy_src && n res_only
elif [ "res_only" = $1 ]; then
 rm -r $SRC_DATADIR/*
 $XT_COMMAND --copy-back --datadir=$SRC_DATADIR 2>&1 | tee $LOGDIR/restore_$BX.log
 cp $LOGDIR/key.key $SRC_DATADIR
elif [ "bkp_res" = $1 ]; then
 n bkp && n inc && n kill && n copy_src && n prep && n prep_inc && n res
elif [ "make" = $1 ]; then
 if [ -z $2 ]; then
  CPK=$CMK
 elif [ $2 = "debug" ]; then
  CPK=$CMK" -DWITH_DEBUG=on"
 else
  echo "wrong choice; use debug";
  return;
 fi
 cd $SRC && rm -rf storage/rocksdb && rm -rf storage/tokudb && rm -rf $HOME/MySQL/build/$BX && rm -rf bld && mkdir bld && cd bld && cmake $CPK -DCMAKE_INSTALL_PREFIX=~/MySQL/build/$BX .. && make -j7 && make install
else
    sandbox $1
fi
}

#test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

cr() {
find . -path ./bld -prune -o \( -name \*.i -o -name \*.ic -o -name \*.h -o -name \*.c -o -name \*.cc -o -name \*.yy -o -name \*.ll -o -name \*.y -o -name \*.I -o -name \*.cpp -o -name \*.txt \) > cscope.files
ctags --langmap=c++:+.ic --langmap=c++:+.i -L ./cscope.files
\cscope -i ./cscope.files
}


#call macos related methods
darwin() {
export ctags='/usr/local/Cellar/ctags/5.8_1/bin/ctags'
#path for openssl
export LDFLAGS="-L/usr/local/opt/openssl/lib"
export CPPFLAGS="-I/usr/local/opt/openssl/include"
export PATH="/usr/local/opt/openssl/bin:$PATH"
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
    export SRC_DATADIR=$HOME/MySQL/data/$BBX
    export LOGDIR=$HOME/MySQL/log/$BOX
    export XT_COMMAND=" --target-dir=$DATADIR --core-file --user=root --socket $SOCKET --keyring-file-data=$SRC_DATADIR/key.key --early-plugin-load=keyring_file.so"
    export MYSQLD_OPTION=" --log-error-verbosity=3 --core-file --early-plugin-load=keyring_file.so --socket $SOCKET --datadir $DATADIR --keyring_file_data=$DATADIR/key.key --loose-debug-sync-timeout=1000"
    export SRC=$HOME/MySQL/src/$BX
    export CMK='-DDOWNLOAD_BOOST=1 -DWITH_BOOST=../../boost -DWITH_ROCKSDB=OFF -DWITHOUT_TOKUDB=OFF -DCMAKE_EXPORT_COMPILE_COMMANDS=on'
    alias cdd='cd $DATADIR'
    alias cdl='cd $LOGDIR'
    alias cds='cd $SRC'
    alias cdm='cd ~/MySQL/build/$BX'
    alias bo='cd ~/pstress && git clean -fdx && cmake -DBASEDIR=$HOME/MySQL/build/$BX -DMYSQL=ON . && make -j && cdp && ctags -R';
    alias bp='cd ~/pstress  && git clean -fdx && cmake -DBASEDIR=$HOME/MySQL/build/$BX -DPERCONASERVER=ON . && make -j && cdp && ctags -R';
    alias cdsm='cd ~/MySQL/src/$BX'
    alias cqa='cd ~/MySQL/percona-qa'
    alias cdsx='cd $SRC/storage/innobase/xtrabackup'
    alias cdbl='cd $HOME/MySQL/src/$BX/bld'
    alias gc='git clean -fdx'
    alias gp='git pull'
    alias lscp='git diff --cached > /tmp/1.patch && scp /tmp/1.patch $QA20:/tmp'
    alias tap='patch -p1 < /tmp/1.patch'
    alias ttp='git diff --cached > /tmp/1.patch'
    ulimit -c unlimited

     #opition based on mysql version 5.7 or 8.0
    if [ $ver = "7" ] ; then
      export MYSQL_HOME=$HOME/MySQL/build/$BX
      export MYSQL=$MYSQL_HOME/bin/mysql
      export MYSQLD=$MYSQL_HOME/bin/mysqld
      export XTRABACKUP=$HOME/MySQL/src/$BX/bld/storage/innobase/xtrabackup/src/xtrabackup
      export XTRABACKUP_BASEDIR=$HOME/MySQL/src/$BX/bld/storage/innobase/xtrabackup/src
      MYSQLD_OPTION=$MYSQLD_OPTION" --basedir=$MYSQL_HOME"
      XT_COMMAND=$XTRABACKUP$XT_COMMAND" --xtrabackup-plugin-dir=$HOME/MySQL/src/$BX/bld/storage/innobase/xtrabackup/src/keyring"
      alias dt='$HOME/MySQL/build/o7/bin/mysql  --socket $SOCKET -uroot test'
      alias cdb='$HOME/MySQL/build/o7/bin/mysql  --socket $SOCKET -uroot -e "create database test;"'
    else
      export MYSQL_HOME=$HOME/MySQL/src/$BX/bld/runtime_output_directory
      export MYSQL=$MYSQL_HOME/mysql
      export MYSQLD=$MYSQL_HOME/mysqld
      export XTRABACKUP=$MYSQL_HOME/xtrabackup
      MYSQLD_OPTION=$MYSQLD_OPTION" --loose_mysqlx_port=$PORT --loose_mysqlx_socket=/tmp/mysqx_`expr $PORT - 50`.sock  --loose_mysqlx_port=`expr $PORT - 50` --basedir=$MYSQL_HOME --plugin-dir=$HOME/MySQL/src/$BX/bld/plugin_output_directory "
      XT_COMMAND=$XTRABACKUP$XT_COMMAND" --xtrabackup-plugin-dir=$HOME/MySQL/src/$BX/bld/plugin_output_directory"
      alias dt='$HOME/MySQL/build/o8/bin/mysql  --socket $SOCKET -uroot test'
      alias cdb='$HOME/MySQL/build/o8/bin/mysql  --socket $SOCKET -uroot -e "create database test;"'
    fi

    #options based on PXB
    if [ -z $BBX ] ; then
	export PS1="{\[\e[32m\]\h\[\e[m\]\[\e[36m\] $BX \[\e[m\]\W}$"
    else
	export PS1="{\[\e[32m\]\h\[\e[m\]\[\e[36m\] $BX $BBX \[\e[m\]\W}$"
        export PATH=$PATH":$HOME/MySQL/build/$BX/bin"
	if [ $ver = "7" ] ; then
	 alias cdt='cd $HOME/MySQL/build/$BX/xtrabackup-test'
        else 
	 alias cdt='cd $HOME/MySQL/src/$BX/bld/storage/innobase/xtrabackup/test'
	fi
    fi;
    n mkdir
}

[ `uname` = Darwin ] && darwin
