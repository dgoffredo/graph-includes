#lang racket

(provide c c++ posix)

; Thank you, Jonathan Leffler: https://stackoverflow.com/questions/2027991/

(define added-by-c89 (set
  "assert.h" "limits.h" "signal.h" "stdlib.h"
  "ctype.h" "locale.h" "stdarg.h" "string.h"
  "errno.h" "math.h" "stddef.h" "time.h"
  "float.h" "setjmp.h" "stdio.h"))

(define added-by-c94 (set
  "iso646.h" "wchar.h" "wctype.h"))

(define added-by-c99 (set
  "complex.h" "inttypes.h" "stdint.h" "tgmath.h"
  "fenv.h" "stdbool.h"))

(define added-by-c11 (set
  "stdalign.h" "stdatomic.h" "stdnoreturn.h" "threads.h" "uchar.h"))

(define c (set-union added-by-c89 added-by-c94 added-by-c99 added-by-c11))

; POSIX, including C99
(define posix (set
  "aio.h" "libgen.h" "spawn.h" "sys/time.h"
  "arpa/inet.h" "limits.h" "stdarg.h" "sys/times.h"
  "assert.h" "locale.h" "stdbool.h" "sys/types.h"
  "complex.h" "math.h" "stddef.h" "sys/uio.h"
  "cpio.h" "monetary.h" "stdint.h" "sys/un.h"
  "ctype.h" "mqueue.h" "stdio.h" "sys/utsname.h"
  "dirent.h" "ndbm.h" "stdlib.h" "sys/wait.h"
  "dlfcn.h" "net/if.h" "string.h" "syslog.h"
  "errno.h" "netdb.h" "strings.h" "tar.h"
  "fcntl.h" "netinet/in.h" "stropts.h" "termios.h"
  "fenv.h" "netinet/tcp.h" "sys/ipc.h" "tgmath.h"
  "float.h" "nl_types.h" "sys/mman.h" "time.h"
  "fmtmsg.h" "poll.h" "sys/msg.h" "trace.h"
  "fnmatch.h" "pthread.h" "sys/resource.h" "ulimit.h"
  "ftw.h" "pwd.h" "sys/select.h" "unistd.h"
  "glob.h" "regex.h" "sys/sem.h" "utime.h"
  "grp.h" "sched.h" "sys/shm.h" "utmpx.h"
  "iconv.h" "search.h" "sys/socket.h" "wchar.h"
  "inttypes.h" "semaphore.h" "sys/stat.h" "wctype.h"
  "iso646.h" "setjmp.h" "sys/statvfs.h" "wordexp.h"
  "langinfo.h" "signal.h"))

(define c++98 (set
  "algorithm" "iomanip" "list" "ostream" "streambuf"
  "bitset" "ios" "locale" "queue" "string"
  "complex" "iosfwd" "map" "set" "typeinfo"
  "deque" "iostream" "memory" "sstream" "utility"
  "exception" "istream" "new" "stack" "valarray"
  "fstream" "iterator" "numeric" "stdexcept" "vector"
  "functional" "limits"
  "cassert" "ciso646" "csetjmp" "cstdio" "ctime"
  "cctype" "climits" "csignal" "cstdlib" "cwchar"
  "cerrno" "clocale" "cstdarg" "cstring" "cwctype"
  "cfloat" "cmath" "cstddef"))

(define c++11 (set
  "algorithm" "initializer_list" "numeric" "system_error"
  "array" "iomanip" "ostream" "thread"
  "atomic" "ios" "queue" "tuple"
  "bitset" "iosfwd" "random" "type_traits"
  "chrono" "iostream" "ratio" "typeindex"
  "codecvt" "istream" "regex" "typeinfo"
  "complex" "iterator" "scoped_allocator" "unordered_map"
  "condition_variable" "limits" "set" "unordered_set"
  "deque" "list" "sstream" "utility"
  "exception" "locale" "stack" "valarray"
  "forward_list" "map" "stdexcept" "vector"
  "fstream" "memory" "streambuf"
  "functional" "mutex" "string"
  "future" "new" "strstream"
  "cassert" "cinttypes" "csignal" "cstdio" "cwchar"
  "ccomplex" "ciso646" "cstdalign" "cstdlib" "cwctype"
  "cctype" "climits" "cstdarg" "cstring"
  "cerrno" "clocale" "cstdbool" "ctgmath"
  "cfenv" "cmath" "cstddef" "ctime"
  "cfloat" "csetjmp" "cstdint" "cuchar"))

(define c++14 (set
  "algorithm" "initializer_list" "numeric" "strstream"
  "array" "iomanip" "ostream" "system_error"
  "atomic" "ios" "queue" "thread"
  "bitset" "iosfwd" "random" "tuple"
  "chrono" "iostream" "ratio" "type_traits"
  "codecvt" "istream" "regex" "typeindex"
  "complex" "iterator" "scoped_allocator" "typeinfo"
  "condition_variable" "limits" "set" "unordered_map"
  "deque" "list" "shared_mutex" "unordered_set"
  "exception" "locale" "sstream" "utility"
  "forward_list" "map" "stack" "valarray"
  "fstream" "memory" "stdexcept" "vector"
  "functional" "mutex" "streambuf"
  "future" "new" "string"
  "cassert" "cinttypes" "csignal" "cstdio" "cwchar"
  "ccomplex" "ciso646" "cstdalign" "cstdlib" "cwctype"
  "cctype" "climits" "cstdarg" "cstring"
  "cerrno" "clocale" "cstdbool" "ctgmath"
  "cfenv" "cmath" "cstddef" "ctime"
  "cfloat" "csetjmp" "cstdint" "cuchar"))

(define c++17 (set
  "algorithm" "future" "numeric" "strstream"
  "any" "initializer_list" "optional" "system_error"
  "array" "iomanip" "ostream" "thread"
  "atomic" "ios" "queue" "tuple"
  "bitset" "iosfwd" "random" "type_traits" "charconv"
  "chrono" "iostream" "ratio" "typeindex"
  "codecvt" "istream" "regex" "typeinfo"
  "complex" "iterator" "scoped_allocator" "unordered_map"
  "condition_variable" "limits" "set" "unordered_set"
  "deque" "list" "shared_mutex" "utility"
  "exception" "locale" "sstream" "valarray"
  "execution" "map" "stack" "variant"
  "filesystem" "memory" "stdexcept" "vector"
  "forward_list" "memory_resource" "streambuf"
  "fstream" "mutex" "string"
  "functional" "new" "string_view"
  "cassert" "cinttypes" "csignal" "cstdio" "cwchar"
  "ccomplex" "ciso646" "cstdalign" "cstdlib" "cwctype"
  "cctype" "climits" "cstdarg" "cstring"
  "cerrno" "clocale" "cstdbool" "ctgmath"
  "cfenv" "cmath" "cstddef" "ctime"
  "cfloat" "csetjmp" "cstdint" "cuchar"))

(define c++ (set-union c++98 c++11 c++14 c++17))
