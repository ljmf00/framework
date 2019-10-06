module aurorafw.corex.sys.posix.unistd;

version (OSX)
    version = Darwin;
else version (iOS)
    version = Darwin;
else version (TVOS)
    version = Darwin;
else version (WatchOS)
    version = Darwin;

extern (C):
nothrow:
@nogc:

version(Posix)
{
	public import core.sys.posix.unistd;
} else {
	public import core.stdc.stdint;
	public import core.stdc.stdlib;
	import core.stdc.config : c_long;

	/**
	 * For communication from `getopt' to the caller.
	 *
	 * When `getopt' finds an option that takes an argument,
	 * the argument value is returned here.
	 * Also, when `ordering' is RETURN_IN_ORDER,
	 * each non-option ARGV-element is returned here.
	 */
	extern __gshared char* optarg;


	/**
	 * Index in ARGV of the next element to be scanned.
	 *
	 * This is used for communication to and from the caller
	 * and for communication between successive calls to `getopt'.
	 * On entry to `getopt', zero means this is the first call; initialize.
	 * When `getopt' returns -1, this is the index of the first of the
	 * non-option elements that the caller should itself scan.
	 * Otherwise, `optind' communicates from one call to the next
	 * how much of ARGV has been scanned so far.
	 *
	 * Standards: 1003.2 says this must be 1 before any call.
	 */
	extern __gshared int optind;


	/**
	 * Callers store zero here to inhibit the error message
	 * for unrecognized options.
	 */
	extern __gshared int opterr;


	/**
	 * Set to an option character which was unrecognized.
	 * This must be initialized on some systems to avoid linking in the
	 * system's own getopt implementation.
	 */
	extern __gshared int optopt;

	enum
	{
		STDIN_FILENO = 0, /** standard input file descriptor */
		STDOUT_FILENO = 1, /** standard output file descriptor */
		STDERR_FILENO = 2 /** standard error file descriptor */
	}

	enum R_OK = 4; /** Test for read permission. */
	enum W_OK = 2; /** Test for write permission. */
	enum F_OK = 0; /** Test for existence. */

	version(Windows) {
		public import aurorafw.corex.sys.windows.io;
		public import core.stdc.stdio;

		version(Win64)
			alias ssize_t = int64_t;
		else version(Win32)
			alias ssize_t = c_long;

		alias srandom = srand;
		alias random = rand;

		alias access = _access;
		alias dup2 = _dup2;
		alias ftruncate = _chsize;
		alias unlink = _unlink;

	} else {
		version(X86_64)
			alias ssize_t = int64_t;
		else version(X86)
			alias ssize_t = c_long;

		enum X_OK = 1; /** Test for execute permission. */
	}
}
