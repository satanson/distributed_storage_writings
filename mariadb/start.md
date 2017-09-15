
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