
## 1. compile debug version of mariadb

```
cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS_DEBUG="-g -O0 -rdynamic -fno-inline -Wno-error"
```

- build type: `CMAKE_BUILD_TYPE=Debug`
- per-config: `CMAKE_CXX_FLAGS_DEBUG`
- fno-inline: forbid inline function expansion
- Wno-error: 

## 