# gperftools & gprof


## gprof

- CXXFLAGS `-lprofiler`

```
g++ -g -O0 -rdynamic -fno-inline -Wall -Wno-error -std=c++0x -static -L out-static -L ../snappy-src/.libs -L/usr/local/lib -I include/ -o demo demo.cc  -lleveldb -lpthread -lsnappy -lprofiler
```
- ./demo

- gprof demo gmon.out > report.dat

- [**gprof2dot**](https://github.com/jrfonseca/gprof2dot)

```
gprof2dot  report.dat |dot -Tsvg -o output.svg
```

## [gperftools](https://github.com/gperftools/gperftools)

