# MySQL Test

MySQL test framework

- driver, programs: run test cases, verify result.
- test script language: create test cases.
- test cases
- mostly of SQL statements, verifying that MySQL Server and its client programs operate according to expectations. 
- ​



**programs**

- mysql-test/mysql-test-run.pl:  mtr(symlink in the same directory) for short.  run test suite.
- mysqld: mtr start/restart mysqld with different arguments.
- mysqltest: mtr invoke mysqltest to read test case file in, interpret, and send SQL statement to server.

**test cases**

- mysql-test/t/${testcase}.test:  test case stored in separated files with suffix ".test", input of mysqltest
- mysql-test/r/${testcase}.result: expected result for each corresponding test case with the same basename. 
- mysql-test/var/log: the diff between actual and expected result stored in this directory with suffix ".reject".



**mysql-test-run.pl**

- --ssl-xxx: enable mysqld to accept SSL connections.

- ```
  ./mysql-test-run.pl test_name
  ```

**report bug**

- ```
  ./mysql-test-run.pl test_name
  ```

- ```
   cmake -DWITH_DEBUG
   mysql-test-run.pl --debug test_name
   # mysql-test/var/tmp/master.trace
  ```

- ```
   mysql-test-run.pl --force
  ```

- ```
  mysql-test-run.pl --gdb test_name
  ```

- ```
  # run test suite
  ./mysql-test-run.pl --force --suite=binlog
  ```

[mysql-test-run.pl options](https://dev.mysql.com/doc/dev/mysql-server/latest/PAGE_MYSQL_TEST_RUN_PL.html)

- ```
  ./mysql-test-run.pl --do-test=prefix
  ```

- ```
  test case files is a mix of commands that the mysqltest programs understands and SQL statements. 

  mtr start server or servers as needed, use ports int the range 13000 by default.
  ```

- run tests in parallel

  ```
  run several mysqltest instance should use different log dir, --vardir.

  run multi-thread in a single mtr use --parallel
  --parallel=auto: pick a value automaticlly.
  environment MTR_PARALLEL
  ```



**writing test cases**

- test case: a separated test file
- test case: contain test sequence, a number of individual tests that are grouped together in the same test file.
- command: input test that mysqltest recognizes and executable itself.
- statement: an SQL statement sent to MySQL server to be executed.
- ​





**unit test**

- ```
  # top-level Makefile
  # invoke executable with "-t" suffix, recursively
  make test-unit
  ```



**Unit Testing Using TAP**



**TAP**: Test Anything Protocol, from Perl

**unittest/mytap**: MyTAP protocol code

**xxx-t.c**: base name  of test case file having suffix "-t"



**Unit Testing Using the Google Test Framework**

