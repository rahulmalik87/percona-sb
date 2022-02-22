 #test used for clone ./t/local_insert.test 
 INSTALL PLUGIN clone SONAME 'mysql_clone.so';
 create table t1(i int);
 SET DEBUG_SYNC = 'clone_file_copy SIGNAL page_signal WAIT_FOR go_page';
 CLONE LOCAL DATA DIRECTORY = "/tmp/rahul"
 
 #in some other session , SET DEBUG_SYNC = 'now SIGNAL go_page' 
