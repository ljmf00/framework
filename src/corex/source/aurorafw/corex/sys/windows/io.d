module aurorafw.corex.sys.windows.io;

version(Windows):
@nogc nothrow:
extern(C):

import core.stdc.config : c_long;

//TODO: Documentation at https://docs.microsoft.com/en-us/cpp/c-runtime-library/reference/crt-alphabetical-function-reference?view=vs-2019

int _access(const(char*) path, int mode);

int _dup( int fd );
int _dup2( int fd1, int fd2 );

int _chsize(int fd, c_long size);

int _unlink(const(char*) filename);

int _read(const(int) fd, const(void*) buffer, const(uint) buffer_size);
int _write(int fd, const(void*) buffer, uint count);
