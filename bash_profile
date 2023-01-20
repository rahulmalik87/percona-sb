HISTSIZE=10000
HISTFILESIZE=10000
BX=""
BBX="" #if set means, running with backup directory:w
PORT=""
#global alias
alias tap='patch -p1 < /tmp/1.patch'
alias csc='cscope -i ./cscope.files'
alias gs='git status'
alias cdp='cd ~/pstress/src'
alias gpc='git push -f -u origin `echo $(basename $PWD)`' #git push current
alias cdh='cd $HOME/MySQL'
alias cdsh='cd $HOME/MySQL/scripts'
alias cds='cd $HOME/study'
alias cdsb='cd $HOME/MySQL/src/percona-sb'
alias cdc='cd $HOME/study/cpp'
export xb="$HOME/MySQL/rahul-xb"
alias f='find . -name '
alias bkpup='$XB $XC --backup --stream=xbstream | xbcloud put `date "+%m%d%H%M%Y%S"` $XBCLOUD_CREDENTIALS'

#sandboxes default is o7 ; o for oracle-mysql , p for perocna-server , x xtrabackup
N_HELP="pick one of the box by o7|o8|o81|p7|p2|xp7|xo7|xo71 \nst: start server \ninit: initialize server \nclean : clean data and logdir\ncon: connect the server\nmkdir: make log and data directory\nbkp: to bkp xtrab backup using $BX sandbox \nprep : prepare backp \nres : restore backup\nbkp_res backup prepare and restore\n\nmodify CMK for CMAKE build\nXT_COMANND to modify XTRABCKUP option\nMO to modify mysqld options"
alias ll='ls -ltr'
n() {
if [ -z $1 ]; then
 echo -e $N_HELP;
elif [ -z $BX ]; then
  sandbox $1
elif [ "st" = $1 ]; then
 $MD $MO --port $PORT 2>&1 | tee $LOGDIR/mysql_$BX.log & #to start server
elif [ "init" = $1 ]; then
 n clean
 $MD $MO --initialize-insecure 2>&1 | tee $LOGDIR/mysql_init_$BX.log #to start server
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
# todo modify code to only expected mysqld
 killall -9 mysqld
 return 0;
elif [ "con" = $1 ]; then
 $MYSQL --socket $SOCKET -uroot
elif [ "bkp" = $1 ]; then
 if [ -z $BBX ]; then
  echo " use xtrabckup sandox "
 else
  rm -r $DATADIR*
  mkdir $DATADIR
  $XB $XC --backup 2>&1 | tee $LOGDIR/backup_$BX.log
  grep "completed OK!" $LOGDIR/backup_$BX.log -c
 fi
elif [ "inc" = $1 ]; then
 mv $DATADIR $DATADIR"_bkp"
 $XB $XC --backup --incremental-basedir=$DATADIR"_bkp" 2>&1 | tee $LOGDIR/increment_$BX.log
 grep "completed OK!" $LOGDIR/increment_$BX.log -c
elif [ "prep_again" = $1 ]; then
 rm -r $HOME/MySQL/data/$BOX
 unzip $LOGDIR/bkp.zip -d $HOME/MySQL/data
 $XB $XC --prepare 2>&1 | tee $LOGDIR/prepare_$BX.log
 grep "completed OK!" $LOGDIR/prepare_$BX.log -c
elif [ "pr" = $1 ]; then
 $XB $XC --prepare 2>&1 | tee $LOGDIR/prepare_$BX.log
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
 $XB $XC --prepare --apply-log-only 2>&1 | tee $LOGDIR/prepare_base$BX.log
 grep "completed OK!" $LOGDIR/prepare_base$BX.log -c
elif [ "prep_inc" = $1 ]; then
 $XB $XC --prepare --incremental-dir=$DATADIR"_inc"  2>&1 | tee $LOGDIR/prepare_inc$BX.log
 grep "completed OK!" $LOGDIR/prepare_inc$BX.log -c
elif [ "copy_src" = $1 ]; then
 rm $LOGDIR/src_data_bkp.zip
 mv $LOGDIR/src_data.zip $LOGDIR/src_data_bkp.zip
 cd $HOME/MySQL/data && zip -r $LOGDIR/src_data.zip $BBX --exclude $BBX/\#innodb_redo/*tmp #copy source data directory rm -r $SRC_DATADIR
 cp $SRC_DATADIR/key.key $LOGDIR
elif [ "res" = $1 ]; then
 n copy_src && n res_only
elif [ "res_only" = $1 ]; then
 rm -r $SRC_DATADIR/*
 $XB $XC --copy-back --datadir=$SRC_DATADIR 2>&1 | tee $LOGDIR/restore_$BX.log
 cp $LOGDIR/key.key $SRC_DATADIR
elif [ "bkp_res" = $1 ]; then
 n bkp && n inc && n kill && n copy_src && n prep && n prep_inc && n res
 #remake
elif [ "rm" = $1 ]; then
	cd $SRC/bld &&  cmake --build .
	return;
elif [ "clone" = $1 ]; then
  if [ -z $2 ]; then 
    echo "n clone --branch=mysql-8.0.31"
    echo "you can also set DEPTH, DEPTH=30 && n clone --branch=mysql-8.0.31"
    return
  fi
  if [ -z $DEPTH ]; then
    DEPTH=7
  fi
  rm -rf $SRC
  cd $HOME
  git clone $REMOTE --depth $DEPTH $SRC $2 --single-branch

elif [ "make" = $1 ]; then
 if [ -z $2 ]; then
  CPK=$CMK
 elif [ $2 = "debug" ]; then
  CPK=$CMK" -DWITH_DEBUG=on"
 else
  echo "wrong choice; use debug";
  return;
 fi
 cd $SRC
 git submodule update --init --recursive
 rm -rf $HOME/MySQL/build/$BX && rm -rf bld && mkdir bld && cd bld && cmake $CPK -G Ninja -DCMAKE_INSTALL_PREFIX=~/MySQL/build/$BX .. 2>&1 |tee $LOGDIR/cmake.log && cmake --build . 2>&1 | tee $LOGDIR/build.log && ninja install && rm -rf $SRC/compile_commands.json && ln -s $SRC/bld/compile_commands.json $SRC/compile_commands.json && cd $SRC && cr
else
  sandbox $1
fi
}

#test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

cr() {
find . -path ./bld -prune -o \( -name \*.i -o -name \*.ic -o -name \*.h -o -name \*.c -o -name \*.cc -o -name \*.yy -o -name \*.ll -o -name \*.y -o -name \*.I -o -name \*.cpp -o -name \*.txt -o -name \*.hpp \) > cscope.files
ctags --langmap=c++:+.ic --langmap=c++:+.i -L cscope.files
\cscope -i ./cscope.files
}


#call macos related methods
darwin() {
eval "$(/opt/homebrew/bin/brew shellenv)"
export ctags='/usr/local/Cellar/ctags/5.8_1/bin/ctags'
export LDFLAGS="-L/opt/homebrew/opt/openssl@1.1/lib -L/opt/homebrew/opt/libgcrypt/lib -L/opt/homebrew/opt/libev/lib  -L/opt/homebrew/opt/zstd/lib -L/opt/homebrew/opt/zlib/lib "
export CPPFLAGS="-I/opt/homebrew/opt/openssl@1.1/include -I/opt/homebrew/opt/libgcrypt/include -I /opt/homebrew/opt/libev/include -I /opt/homebrew/opt/zstd/include -I/opt/homebrew/opt/zlib/include "
export QA06='rahul.malik@10.30.6.206'
export QA09='rahul.malik@10.30.6.209'
export QA20='rahul.malik@10.30.7.20'
export QA02='rahul.malik@10.30.6.202'
export QA03='rahul.malik@10.30.6.203'
export QAsatya='rahul.malik@10.30.3.209'
export QAfast='rahul.malik@10.30.7.117'
export QAp='rahul.malik@10.30.7.117'
export QAmanish='rahul.malik@10.30.6.61'
export md5sum='md5'
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
		$ID $i |grep se_private_id
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
	PORT=31
    else
	PORT=32
	export m_version="ps";
    fi

    if [ ${#1} = 2 ] ; then
	ab=0
    else
        ab=`echo $1 | cut -c2-3`
    fi
    BX=$1
    PORT=$PORT$ab$ver
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
    export pt=" --socket $SOCKET  --tables 4 --threads 4 --no-partition-tables --no-temp-tables "
    export DATADIR=$HOME/MySQL/data/$BOX
    export SRC_DATADIR=$HOME/MySQL/data/$BBX
    export LOGDIR=$HOME/MySQL/log/$BOX
    export XC=" --target-dir=$DATADIR --user=root --socket $SOCKET --loose_keyring-file-data=$SRC_DATADIR/key.key"
    export MO=" --loose-log-error-verbosity=3 --loose-early-plugin-load=keyring_file.so --socket $SOCKET --datadir $DATADIR --loose_keyring_file_data=$DATADIR/key.key --loose-debug-sync-timeout=1000 --loose-enforce-gtid-consistency --server-id=$PORT --loose-gtid-mode=ON --loose-binlog_format=row --log-bin --log-slave-updates --innodb_buffer_pool_size=4GB --loose_innodb_redo_log_capacity=1073741824"
    export SRC=$HOME/MySQL/src/$BX
    export CMK='-DDOWNLOAD_BOOST=1 -DWITH_BOOST=../../boost -DCMAKE_EXPORT_COMPILE_COMMANDS=on -DWITH_ZLIB=bundled'
    alias cdd='cd $DATADIR'
    alias cdl='cd $LOGDIR'
    alias cds='cd $SRC'
    BASEDIR=$HOME/MySQL/build/$BX
    alias cdm='cd ~/MySQL/build/$BX'
    alias cdsm='cd ~/MySQL/src/$BX'
    alias cqa='cd ~/MySQL/percona-qa'
    alias cdsx='cd $SRC/storage/innobase/xtrabackup'
    alias cdsxb='cd $SRC/storage/innobase/xtrabackup/src/xbcloud'
    alias cdbl='cd $HOME/MySQL/src/$BX/bld'
    alias gc="git checkout"
    alias gp='git pull'
    LSCP=$QAsatya
    alias lscp='scp /tmp/1.patch $LSCP:/tmp'
    alias rscp='scp $LSCP:/tmp/1.patch /tmp/1.patch && patch -p1 < /tmp/1.patch'
    alias ttp='git diff --cached > /tmp/1.patch'
    ulimit -c unlimited
    ulimit -n4000

     #opition based on mysql version 5.7 or 8.0
    if [ $ver = "7" ] ; then
      export MYSQL_HOME=$HOME/MySQL/build/$BX
      export MD=$HOME/MySQL/src/$BX/bld/sql/mysqld
      export MYSQL=$HOME/MySQL/src/$BX/bld/client/mysql
      export XB=$HOME/MySQL/src/$BX/bld/storage/innobase/xtrabackup/src/xtrabackup
      MO=$MO" --basedir=$MYSQL_HOME"
      XC=$XC" --xtrabackup-plugin-dir=$HOME/MySQL/src/$BX/bld/storage/innobase/xtrabackup/src/keyring"
      export PATH=$PATH":$HOME/MySQL/src/$BX/bld/storage/innobase/xtrabackup/src/xbcloud"
    else
      export MYSQL_HOME=$HOME/MySQL/src/$BX/bld/runtime_output_directory
      export MYSQL=$MYSQL_HOME/mysql
      export MD=$MYSQL_HOME/mysqld
      export ID=$MYSQL_HOME/ibd2sdi
      export XB=$MYSQL_HOME/xtrabackup
      MO=$MO" --loose_mysqlx_port=$PORT --loose_mysqlx_socket=/tmp/mysqx_`expr $PORT - 50`.sock  --loose_mysqlx_port=`expr $PORT - 50` --basedir=$MYSQL_HOME --plugin-dir=$HOME/MySQL/src/$BX/bld/plugin_output_directory "
      XC=$XC" --xtrabackup-plugin-dir=$HOME/MySQL/src/$BX/bld/plugin_output_directory"
    fi
      alias cdt='cd $HOME/MySQL/src/$BX/bld/mysql-test'
      export MYSQL_o8=$HOME/MySQL/src/o8/bld/runtime_output_directory/mysql
      alias cdb='$MYSQL  --socket $SOCKET -uroot -e "create database test;"'
      alias dt='$MYSQL_o8  --socket $SOCKET -uroot test'

    #options based on PXB
    if [ -z $BBX ] ; then
	export PS1="{\[\e[32m\]\h\[\e[m\]\[\e[36m\] $BX \[\e[m\]\W}$"
        if [ $bx = "p" ] ; then
	  CMK=$CMK" -DWITH_TOKUDB=OFF -DWITH_ROCKSDB=OFF"
	fi
    else
	export PS1="{\[\e[32m\]\h\[\e[m\]\[\e[36m\] $BX $BBX \[\e[m\]\W}$"
	if [ $ver = "7" ] ; then
	 alias cdt='cd $HOME/MySQL/build/$BX/xtrabackup-test/test'
        else
        export PATH=$PATH":$HOME/MySQL/src/$BX/bld/runtime_output_directory"
	 alias cdt='cd $HOME/MySQL/src/$BX/bld/storage/innobase/xtrabackup/test'
	fi
	 #link box
	 alias lnb='cdt && rm -rf server && ln -s  $HOME/MySQL/build/$BBX server'
    fi;
    n mkdir
	REMOTE="https://github.com"
	if [ -z $BBX ]; then 
	  if [[ $BX == "o"* ]]; then
	    REMOTE="${REMOTE}/mysql/mysql-server"
	  else
	    REMOTE="${REMOTE}/percona/percona-server"
	  fi
	else
	  REMOTE="${REMOTE}/percona/percona-xtrabackup"
	fi
}

function get_gca {
  if [ -z $1 ]; then
    echo "example get_gca ps 5.7 ps 8.0"
    return
  fi
  cd $xb
  git fetch  $1 $2
  git fetch $3 $4
  git checkout $1/$2
  git show `git rev-list "$1/$2" ^"$3/$4" --first-parent --topo-order | tail -1`
}

function create_wt {
  if [ -z $1 ]; then
    echo "example create_wt ps 8.0 2429"
    echo "example create_wt ps 8.0 2429 commit_id"
    return
  fi
  REPO=$1
  BRANCH=$2
  BUG="$1-$2-$3"
  if [ -z $4 ]; then
	  echo "executing without commit_id"
  cd $xb && git fetch $REPO $BRANCH && git worktree add -b $BUG ../$BUG $REPO/$BRANCH  && cd ../$BUG
  else
	  echo "executing with commit_id"
  cd $xb && git fetch $REPO $BRANCH && git worktree add -b $BUG ../$BUG $4^  && cd ../$BUG
  fi
}

function remove_wt {
  if [ -z $1 ]; then
    echo "example remove_wt ps-8.0-2429"
    return
  fi
	BUG=$1
	cd $xb &&  git worktree remove  $BUG --force && git branch -D $BUG
}

#open file name matching
function fo() {
         find -L $PWD -name $1  -exec vim {} \;
}

#example git_push force
function git_push {
  FORCE=""
  repo=rahul-`basename $PWD |  cut -d"-" -f1`
  if [ -z $1 ]; then
    git push $repo `basename $PWD`
  else
    git push $repo `basename $PWD` --force
  fi
}

function git_merge_branch {
  if [ -z $1 ]; then
	  echo git_merge_branch pxb-2.4-1234
	  return
  fi
  git merge $1 -s ours --no-commit
  tap
  git commit --all
}


function git_show {
  if [ -z $1 ]; then
	  echo git_show last commit
	  return
  fi

  git show `git log -n 1 --skip $1 --pretty=format:"%H"` $2

}
function git_link(){
	cd $SRC
	if [ -z $1 ]; then
		echo "git_link tag file line"
		return
	fi
	full_path=$(find . -name $2)
	local link="${REMOTE}/blob/""$1/$2#L$3"
	echo "link is $link"
	return

}


# find the information of page
#example find_info INPUT_FILE MAX_BLOCK BLOCK_SIZE
#example find_info t1.ibd 12 2048
function find_info() {
  if [ -z $1 ]; then
          echo "find_info t1.ibd 12 2048"
	  return
  fi
        max=$2
        for i in `seq 0 $max`
        do
                dd ibs=$3 skip=$i count=1 if=$1 > /tmp/out$i.bin
                f=/tmp/out$i.bin
                echo "----------------------------------------"
                echo "Processing file $f";
                echo "SPACE ID:      ";od -j34  -N4 -An -t x1 $f;
                echo "PAGE OFFSET:   ";od -j4   -N4 -An -t x1 $f;
                echo "PAGE LSN:      ";od -j16  -N8 -An -t x1 $f;
                echo "PAGE LEVEL:    ";od -j64  -N2 -An -t x1 $f;
                echo "PAGE INDEX ID: ";od -j66  -N8 -An -t x1 $f;
                echo "PAGE TYPE:     ";od -j24  -N2 -An -t x1 $f;
                echo "PAGE PREV:     ";od -j8   -N4 -An -t x1 $f;
                echo "PAGE NEXT:     ";od -j12  -N4 -An -t x1 $f;
                rm $f
        done
}

copy_sandbox() {
  if [ -z $1 ]; then
          echo "copy_sandbox o2"
	  return
  fi
	old_sandbox=$1
	rm -rf $DATADIR && cp -r $HOME/MYSQL/data/$old_sandbox $DATADIR

}


bp() {
  if [ -z $BX ] ; then
	  echo "use sandbox"
	  return
  fi

  if [  $BBX ] ; then
	  echo "use ps/ms sandbox"
	  return
  fi

  local PCMK; 
  if [ $m_version == "oracle" ]; then 
    PCMK=" -DMYSQL=ON"
  elif [ $m_version == "ps" ];  then
    PCMK=" -DPERCONASERVER=ON"
  fi
  if [ ! `ls -d pstress` ]; then  
    echo "not in pstress source "
    return 
  fi

  rm -rf bld  && mkdir bld && cd bld
  cmake .. -DBASEDIR=$BASEDIR $PCMK -DCMAKE_EXPORT_COMPILE_COMMANDS=on -DCMAKE_BUILD_TYPE=Debug && make -j 
  cd .. && rm -rf compile_commands.json && ln -s bld/compile_commands.json .

}

[ `uname` = Darwin ] && darwin
