
## 1. compile debug version of mariadb

```
cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS_DEBUG="-g -O0 -rdynamic -fno-inline -Wno-error"

make -j8
```

- build type: `CMAKE_BUILD_TYPE=Debug`
- per-config: `CMAKE_CXX_FLAGS_DEBUG`
- fno-inline: forbid inline function expansion
- Wno-error: not make all warnings into errors, otherwise building abort early.


## 2. start mysqld

[**running-mariadb-from-the-build-directory**](https://mariadb.com/kb/en/library/running-mariadb-from-the-build-directory/)

**write ~/.my.cnf**

- datadir=/home/grakra/data/mysql
- socket=/home/grakra/data/mysql/sock
- language=/home/grakra/workspace/mariadb/server/sql/share/english
- log-error=/home/grakra/data/mysql/error.log
- general-log=TRUE
- general-log-file=/home/grakra/data/mysql/general.log
- slow-query-log=TRUE
- slow-query-log-file=/home/grakra/data/mysql/slow.log

```
# Example mysql config file.
# You can copy this to one of:
# /etc/my.cnf to set global options,
# /mysql-data-dir/my.cnf to get server specific options or
# ~/my.cnf for user specific options.
# 
# One can use all long options that the program supports.
# Run the program with --help to get a list of available options

# This will be passed to all mysql clients
[client]
#password=my_password
#port=3306
#socket=/tmp/mysql.sock

# Here is entries for some specific programs
# The following values assume you have at least 32M ram

# The MySQL server
[mysqld]
#port=3306
#socket=/tmp/mysql.sock
temp-pool

# The following three entries caused mysqld 10.0.1-MariaDB (and possibly other versions) to abort...
# skip-locking
# set-variable  = key_buffer=16M
# set-variable  = thread_cache=4

loose-innodb_data_file_path = ibdata1:1000M
loose-mutex-deadlock-detector
gdb

######### Fix the two following paths

# Where you want to have your database
datadir=/home/grakra/data/mysql
socket=/home/grakra/data/mysql/sock
# Where you have your mysql/MariaDB source + sql/share/english
language=/home/grakra/workspace/mariadb/server/sql/share/english
log-error=/home/grakra/data/mysql/error.log
general-log=TRUE
general-log-file=/home/grakra/data/mysql/general.log
slow-query-log=TRUE
slow-query-log-file=/home/grakra/data/mysql/slow.log

########## One can also have a different path for different versions, to simplify development.

#[mariadb-10.1]
#lc-messages-dir=/my/maria-10.1/sql/share

#[mariadb-10.2]
#lc-messages-dir=/my/maria-10.2/sql/share

[mysqldump]
quick
set-variable = max_allowed_packet=16M

[mysql]
no-auto-rehash

[myisamchk]
set-variable= key_buffer=128M
```

```
./scripts/mysql_install_db --srcdir=$PWD --datadir=/home/grakra/data/mysql --user=$LOGNAME

sql/mysqld

mysql -S /home/grakra/data/mysql/sock
```
## 3. running TPC-C benchmark and generating flumegraph.

[**tpcc-mysql**](https://github.com/Percona-Lab/tpcc-mysql)

```
mysqladmin -S /home/grakra/data/mysql/sock -uroot create tpcc1000

mysql -S /home/grakra/data/mysql/sock -uroot tpcc1000 < create_table.sql

./tpcc_load -h127.0.0.1 -d tpcc1000 -u root -p "" -w 1000
```

meanwhile

[**FlameGraph**](https://github.com/brendangregg/FlameGraph)

```
perf record -F 99 -p $(ps h -C mysqld -o pid) -g -- sleep 60
perf script > out.perf
./stackcollapse-perf.pl ../tpcc-mysql/out.perf |./flamegraph.pl >mysql.svg
google-chrome-stable mysql.svg
```

## 4. A priori knowledge and guessing

**fact**
- disk-based and persistent=> call fsync when write WAL log and checkpoint.[must]
- support several engine=> separated WAL and engine. [maybe]
- consist of local store, txn CC, process model, query module, buffer pool, catalog, protocol and etc.=> start local store first.

## 5. Ag for fsync

- source code search is not a good way.
- so use gdb.

## 6. gdb

```
# enable gdb to attach to a process
su
echo 0 > /proc/sys/kernel/yama/ptrace_scope
exit

# hunt for fsync
gdb sql/mysqld 23372
br fsync
c
bt
generate-core-file mysqld_core.23372
```
```
#0  0x00007f80c6eebc60 in fsync () from /usr/lib/libpthread.so.0
#1  0x00005649da40ecaa in os_file_fsync_posix (file=10)
    at /home/grakra/workspace/mariadb/server/storage/innobase/os/os0file.cc:2426
#2  0x00005649da40f0d3 in os_file_flush_func (file=10)
    at /home/grakra/workspace/mariadb/server/storage/innobase/os/os0file.cc:2542
#3  0x00005649da65b789 in pfs_os_file_flush_func (file=..., 
    src_file=0x5649dab77360 "/home/grakra/workspace/mariadb/server/storage/innobase/fil/fil0fil.cc", src_line=962)
    at /home/grakra/workspace/mariadb/server/storage/innobase/include/os0file.ic:496
#4  0x00005649da65f2e2 in fil_flush_low (space=0x5649dc5b4e90)
    at /home/grakra/workspace/mariadb/server/storage/innobase/fil/fil0fil.cc:962
#5  0x00005649da66d53c in fil_flush (space_id=4294967280)
    at /home/grakra/workspace/mariadb/server/storage/innobase/fil/fil0fil.cc:5528
#6  0x00005649da3ec138 in log_write_flush_to_disk_low ()
    at /home/grakra/workspace/mariadb/server/storage/innobase/log/log0log.cc:1063
#7  0x00005649da3ecb92 in log_write_up_to (lsn=9832047807, flush_to_disk=true)
    at /home/grakra/workspace/mariadb/server/storage/innobase/log/log0log.cc:1291
#8  0x00005649da3ecd05 in log_buffer_sync_in_background (flush=true)
    at /home/grakra/workspace/mariadb/server/storage/innobase/log/log0log.cc:1337
#9  0x00005649da50cf66 in srv_sync_log_buffer_in_background ()
    at /home/grakra/workspace/mariadb/server/storage/innobase/srv/srv0srv.cc:2127
#10 0x00005649da50d4b1 in srv_master_do_active_tasks ()
    at /home/grakra/workspace/mariadb/server/storage/innobase/srv/srv0srv.cc:2300
#11 0x00005649da50ddea in srv_master_thread (arg=0x0)
    at /home/grakra/workspace/mariadb/server/storage/innobase/srv/srv0srv.cc:2511
#12 0x00007f80c6ee2049 in start_thread () from /usr/lib/libpthread.so.0
#13 0x00007f80c42b7f0f in clone () from /usr/lib/libc.so.6
```

```
gdb --batch --quiet -ex "thread apply all bt" -ex "quit" sql/mysqld mysqld_core.23372 > mysqld_gdb_stacktrace.dat
```

```
./stackcollapse-gdb.pl ../mariadb/server/mysqld_gdb_stacktrace.dat |./flamegraph.pl > mysqld_fsync.svg
```

```
pip install gprof2dot
```

```
./stacktrace2callgraph_gdb.pl ~/workspace/mariadb/server/mysqld_gdb_stacktrace.dat  |gprof2dot -c print | dot -Tpng -o mysqld_fsync.png
```

![image](mysqld_fsync.png)

## 8. mariadb architecture

**in thread perspective**

- `mysqld_main`

> 
- main thread
- handle_connections_sockets:  listen and accept connection request from clients.

- `handle_one_connection`

> 
- each client has a corresponding `handle_one_connection` thread for communication.
- `my_net_read_packet`: recv req message from clients
- process cmd
- send resp message to clients

- 

**in component perspective**


##
