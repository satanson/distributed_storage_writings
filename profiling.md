# gperftools & gprof

## [gperftools](https://github.com/gperftools/gperftools)

- CXXFLAGS `-lprofiler`

```
g++ -g -O0 -rdynamic -fno-inline -Wall -Wno-error -std=c++0x -static -L out-static -L ../snappy-src/.libs -L/usr/local/lib -I include/ -o demo demo.cc  -lleveldb -lpthread -lsnappy -lprofiler
```
- ./demo

- [**gprof2dot**](https://github.com/jrfonseca/gprof2dot)