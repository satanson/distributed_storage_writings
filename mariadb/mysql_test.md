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



**TAP**

- plan(num)

  ```
  #: expected number of tests to run
  no_plan: use done_test to issue a plan when finish running tests.
  skip_all: not run any tests
  ```

- assertion

  ```
  ok($got, $testname)

  is/isnt($got, $expected, $test_name)


  not ok ${testnumber} - ${testname}
  #   Failed test ${testname}
  #   at ${filename} line ${linenumber}.
  #          got: ${got}
  #     expected: ${expected}

  like/unlike( $got, qr/expected/, $test_name )

  cmp_ok( $got, $op, $expected, $test_name )

  can_ok($module, @methods)
  isa_ok($object,   $class, $object_name)
  new_ok( $class );
  subtest $name => \&code, @args;
  pass($test_name);
  fail($test_name);
  require_ok($module);
  BEGIN { use_ok($module); }
  is_deeply( $got, $expected, $test_name );

  diag(@diagnostic_message);
  note(@diagnostic_message);
  my @dump = explain @diagnostic_message;
  SKIP: something the user might not be able to do
  TODO: something the programmer hasn't done yet

  BAIL_OUT: test fail with exit code 255

  exit code
  0                   all tests successful
  255                 test died or all passed but wrong # of tests run
  any other number    how many failed (including missing or extras)




  ```

  ​

**tap specs**

- version
- plan
- test
- comment



**Unit Testing Using the Google Test Framework**

