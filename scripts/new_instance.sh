mkdir -p $HOME/MySQL/src
cd MySQL/src
git clone https://github.com/rahulmalik87/percona-sb.git 
ln -s $HOME/MySQL/src/percona-sb/bash_profile .bash_profile
. .bash_profile
n xp8
n mkdir
git clone https://github.com/rahulmalik87/percona-xtrabackup.git $HOME/MySQL/src/$BX

echo "pick some branch and execute screen n make debug"

./bootstrap.sh --type=xtradb80 --version=8.0.22-13

mkdir -p 
ln -s $HOME/MySQL/src/x8/bld/storage/innobase/xtrabackup/test/server/bin $HOME/MySQL/build/o8/bin
ln -s /home/admin/MySQL/src/x8/bld/storage/innobase/xtrabackup/test/server/bin /home/admin/MySQL/src/$BX/bld/runtime_output_directory
ln -s /home/admin/MySQL/src/x8/bld/storage/innobase/xtrabackup/test/server/lib/plugin /home/admin/MySQL/src/$BX/bld/plugin_output_directory
