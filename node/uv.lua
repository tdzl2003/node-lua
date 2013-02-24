--[[
THis file is a minimized copy of libuv header file, in LuaJIT ffi format.
libuv is part of Node project: http://nodejs.org/
libuv is distributed alone under Node's license:

Copyright Joyent, Inc. and other Node contributors. All rights reserved.
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to
deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
IN THE SOFTWARE.
]]

local ffi = require("ffi")

local UV_REQ_PRIVATE_FIELDS = ""

local UV_HANDLE_PRIVATE_FIELDS = ""

local UV_STREAM_PRIVATE_FIELDS = ""

local UV_PRIVATE_REQ_TYPES = ""

local UV_WRITE_PRIVATE_FIELDS = ""

local UV_TCP_PRIVATE_FIELDS = ""

local UV_CONNECT_PRIVATE_FIELDS = ""

local UV_UDP_PRIVATE_FIELDS = ""

local UV_UDP_SEND_PRIVATE_FIELDS = ""

local UV_TTY_PRIVATE_FIELDS = ""

local UV_PIPE_PRIVATE_FIELDS = ""

local UV_POLL_PRIVATE_FIELDS = ""

local UV_PREPARE_PRIVATE_FIELDS = ""

local UV_CHECK_PRIVATE_FIELDS = ""

local UV_IDLE_PRIVATE_FIELDS = ""

local UV_ASYNC_PRIVATE_FIELDS = ""

local UV_TIMER_PRIVATE_FIELDS = ""

local UV_GETADDRINFO_PRIVATE_FIELDS = ""

local UV_PROCESS_PRIVATE_FIELDS = ""

local UV_WORK_PRIVATE_FIELDS = ""

local UV_FS_PRIVATE_FIELDS = ""

local UV_FS_EVENT_PRIVATE_FIELDS = ""

local UV_SIGNAL_PRIVATE_FIELDS = ""

local UV_LOOP_PRIVATE_FIELDS = ""

if (ffi.os == "Windows") then
	UV_REQ_PRIVATE_FIELDS = [[
		union {                                                                     
			/* Used by I/O operations */                                              
			struct {                                                                  
				OVERLAPPED overlapped;                                                  
				size_t queued_bytes;                                                    
			};                                                                        
		};                                                                          
		struct uv_req_s* next_req;
	]]

	UV_HANDLE_PRIVATE_FIELDS = [[
		uv_handle_t* endgame_next;
		unsigned int flags;
	]]

	UV_STREAM_PRIVATE_FIELDS = [[
		unsigned int reqs_pending;
		int activecnt;
		uv_read_t read_req;
		union {
			struct { 
				unsigned int write_reqs_pending;
				uv_shutdown_t* shutdown_req;
			};
			struct {
				uv_connection_cb connection_cb;
			};
		};
	]]

	UV_WRITE_PRIVATE_FIELDS = [[
		int ipc_header;
		uv_buf_t write_buffer;
		HANDLE event_handle;
		HANDLE wait_handle;
	]]

	UV_TCP_PRIVATE_FIELDS = [[
		SOCKET socket;
		int bind_error;
		union {
			struct {
				uv_tcp_accept_t* accept_reqs;
				unsigned int processed_accepts;
				uv_tcp_accept_t* pending_accepts;
				LPFN_ACCEPTEX func_acceptex;
			};
			struct {
				uv_buf_t read_buffer;
				LPFN_CONNECTEX func_connectex;			
			};
		};
	]]

	UV_UDP_PRIVATE_FIELDS = [[
		SOCKET socket;
		unsigned int reqs_pending;
		int activecnt;
		uv_req_t recv_req;
		uv_buf_t recv_buffer;
		struct sockaddr_storage recv_from;
		int recv_from_len;
		uv_udp_recv_cb recv_cb;
		uv_alloc_cb alloc_cb;
		LPFN_WSARECV func_wsarecv;
		LPFN_WSARECVFROM func_wsarecvfrom;
	]]

	UV_TTY_PRIVATE_FIELDS = [[
		HANDLE handle;
		union {
			struct {
				/* Used for readable TTY handles */
				HANDLE read_line_handle;
				uv_buf_t read_line_buffer;
				HANDLE read_raw_wait;
				DWORD original_console_mode;
				/* Fields used for translating win keystrokes into vt100 characters */  \
				char last_key[8];
				unsigned char last_key_offset;
				unsigned char last_key_len;
				WCHAR last_utf16_high_surrogate;
				INPUT_RECORD last_input_record;
			};
			struct {
				/* Used for writable TTY handles */
				/* utf8-to-utf16 conversion state */
				unsigned int utf8_codepoint;
				unsigned char utf8_bytes_left;
				/* eol conversion state */
				unsigned char previous_eol;
				/* ansi parser state */
				unsigned char ansi_parser_state;
				unsigned char ansi_csi_argc;
				unsigned short ansi_csi_argv[4];
				COORD saved_position;
				WORD saved_attributes;
			};
		};
  	]]

  	UV_PIPE_PRIVATE_FIELDS = [[
		HANDLE handle;
		WCHAR* name;
		union {
			struct {
				int pending_instances;
				uv_pipe_accept_t* accept_reqs;
				uv_pipe_accept_t* pending_accepts;
			};
			struct {
				uv_timer_t* eof_timer;
				uv_write_t ipc_header_write_req;
				int ipc_pid;
				uint64_t remaining_ipc_rawdata_bytes;
				unsigned char reserved[sizeof(void*)];
				struct {
					WSAPROTOCOL_INFOW* socket_info;
					int tcp_connection;
				} pending_ipc_info;
				uv_write_t* non_overlapped_writes_tail;
			};
		};
  	]]

  	UV_POLL_PRIVATE_FIELDS = [[
		SOCKET socket;
		/* Used in fast mode */
		SOCKET peer_socket;
		AFD_POLL_INFO afd_poll_info_1;
		AFD_POLL_INFO afd_poll_info_2;
		/* Used in fast and slow mode. */
		uv_req_t poll_req_1;
		uv_req_t poll_req_2;
		unsigned char submitted_events_1;
		unsigned char submitted_events_2;
		unsigned char mask_events_1;
		unsigned char mask_events_2;
		unsigned char events;
  	]]

  	UV_PREPARE_PRIVATE_FIELDS = [[
		uv_prepare_t* prepare_prev;
		uv_prepare_t* prepare_next;
		uv_prepare_cb prepare_cb;
  	]]

  	UV_CHECK_PRIVATE_FIELDS = [[
		uv_check_t* check_prev;
		uv_check_t* check_next;
		uv_check_cb check_cb;
  	]]

  	UV_IDLE_PRIVATE_FIELDS = [[
		uv_idle_t* idle_prev;
		uv_idle_t* idle_next;
		union {uv_idle_cb idle_cb; int idle_cb_lua;};
  	]]

  	UV_ASYNC_PRIVATE_FIELDS = [[
		struct uv_req_s async_req;
		uv_async_cb async_cb;
		/* char to avoid alignment issues */
		char volatile async_sent;
  	]]

  	UV_TIMER_PRIVATE_FIELDS = [[
  		struct {
			struct uv_timer_s *rbe_left;        /* left element */
			struct uv_timer_s *rbe_right;       /* right element */
			struct uv_timer_s *rbe_parent;      /* parent element */
			int rbe_color;                /* node color */
		}	tree_entry;
		int64_t due;
		int64_t repeat;
		uint64_t start_id;
		union {uv_timer_cb timer_cb; int timer_cb_lua;};
  	]]

  	UV_GETADDRINFO_PRIVATE_FIELDS = [[
		uv_getaddrinfo_cb getaddrinfo_cb;
		void* alloc;
		WCHAR* node;
		WCHAR* service;
		struct addrinfoW* hints;
		struct addrinfoW* res;
		int retcode;
  	]]

  	UV_PROCESS_PRIVATE_FIELDS = [[
		struct uv_process_exit_s {
			void* data;
			uv_req_type type;
			ngx_queue_t active_queue;
	]] .. UV_REQ_PRIVATE_FIELDS ..[[
		} exit_req;
		BYTE* child_stdio_buffer;
		uv_err_t spawn_error;
		int exit_signal;
		HANDLE wait_handle;
		HANDLE process_handle;
		volatile char exit_cb_pending;
	]]

	UV_FS_PRIVATE_FIELDS = [[
		int flags;
		DWORD sys_errno_;
		union {
			/* TODO: remove me in 0.9. */
			WCHAR* pathw;
			int fd;
		};
		union {
			struct {
				int mode;
				WCHAR* new_pathw;
				int file_flags;
				int fd_out;
				void* buf;
				size_t length;
				int64_t offset;
			};
			struct {
				double atime;
				double mtime;
			};
		};
	]]

	UV_FS_EVENT_PRIVATE_FIELDS = [[
		struct uv_fs_event_req_s {                                                  \
			void* data;
			uv_req_type type;
			ngx_queue_t active_queue;
	]] .. UV_REQ_PRIVATE_FIELDS ..[[
		} req;                                                                      \
		HANDLE dir_handle;                                                          \
		int req_pending;                                                            \
		uv_fs_event_cb cb;                                                          \
		WCHAR* filew;                                                               \
		WCHAR* short_filew;                                                         \
		WCHAR* dirw;                                                                \
		char* buffer;
  	]]

  	UV_SIGNAL_PRIVATE_FIELDS = [[
  		struct {
			struct uv_signal_s *rbe_left;        /* left element */
			struct uv_signal_s *rbe_right;       /* right element */
			struct uv_signal_s *rbe_parent;      /* parent element */
			int rbe_color;                /* node color */
		} tree_entry;
		struct uv_req_s signal_req;                                                 \
		unsigned long pending_signum;
  	]]

  	UV_LOOP_PRIVATE_FIELDS = [[
		HANDLE iocp;
		uint64_t time;
		uv_req_t* pending_reqs_tail;
		uv_handle_t* endgame_handles;
		struct uv_timer_tree_s{
			struct uv_timer_s *rbh_root;
		} timers;
		uv_prepare_t* prepare_handles;
		uv_check_t* check_handles;
		uv_idle_t* idle_handles;
		uv_prepare_t* next_prepare_handle;
		uv_check_t* next_check_handle;
		uv_idle_t* next_idle_handle;
		SOCKET poll_peer_sockets[3];
		unsigned int active_tcp_streams;
		unsigned int active_udp_streams;
		uint64_t timer_counter;
	]]

	ffi.cdef [[
		typedef unsigned int _dev_t;        /* device code */

		typedef unsigned short _ino_t;      /* i-node number (not used on DOS) */

		typedef __int64 __time64_t;     /* 64-bit time value */		

		struct _stat64 {
			_dev_t     st_dev;
			_ino_t     st_ino;
			unsigned short st_mode;
			short      st_nlink;
			short      st_uid;
			short      st_gid;
			_dev_t     st_rdev;
			__int64    st_size;
			__time64_t st_atime;
			__time64_t st_mtime;
			__time64_t st_ctime;
        };

        typedef struct _stat64 uv_statbuf_t;

        typedef unsigned short ADDRESS_FAMILY;

        typedef struct sockaddr_storage {
        	ADDRESS_FAMILY ss_family;
        	char __ss_pad1[6];
        	__int64 __ss_align;
        	char __ss_pad2[112];
    	} SOCKADDR_STORAGE_LH, *PSOCKADDR_STORAGE_LH, *LPSOCKADDR_STORAGE_LH;

        typedef uintptr_t ULONG_PTR, *PULONG_PTR;

        typedef unsigned char 		UCHAR;
        typedef uint8_t				BYTE;
        typedef short 				SHORT;
        typedef unsigned short 		USHORT;
        typedef unsigned short      WORD;
        typedef unsigned long       DWORD;
        typedef DWORD				*LPDWORD;
        typedef int 				*LPINT;
        typedef unsigned int 		UINT;
        typedef long 				LONG;
        typedef unsigned long 		ULONG;
        typedef long long 			LONGLONG;
        typedef char 				CHAR;
        typedef wchar_t				WCHAR;

		typedef int              BOOL;

        typedef void *PVOID;
        typedef void *HANDLE;
        typedef struct {int unused;} *HINSTANCE;
        typedef HINSTANCE HMODULE;

        typedef union _LARGE_INTEGER {
			struct {
				DWORD LowPart;
				LONG HighPart;
			};
			struct {
				DWORD LowPart;
				LONG HighPart;
			} u;
			LONGLONG QuadPart;
		} LARGE_INTEGER;

        typedef struct _OVERLAPPED {
		    ULONG_PTR Internal;
			ULONG_PTR InternalHigh;
			union {
		        struct {
		            DWORD Offset;
		            DWORD OffsetHigh;
		        };

		        PVOID Pointer;
		    };

		    HANDLE  hEvent;
		} OVERLAPPED, *LPOVERLAPPED;

		typedef uintptr_t        SOCKET;

		typedef
			BOOL
			(__stdcall * LPFN_ACCEPTEX)(
				SOCKET sListenSocket,
				SOCKET sAcceptSocket,
				PVOID lpOutputBuffer,
				DWORD dwReceiveDataLength,
				DWORD dwLocalAddressLength,
				DWORD dwRemoteAddressLength,
				LPDWORD lpdwBytesReceived,
				LPOVERLAPPED lpOverlapped
				);

		typedef
			BOOL
			(__stdcall * LPFN_CONNECTEX) (
				SOCKET s,
				const struct sockaddr *name,
				int namelen,
				PVOID lpSendBuffer,
				DWORD dwSendDataLength,
				LPDWORD lpdwBytesSent,
				LPOVERLAPPED lpOverlapped
				);

		typedef OVERLAPPED WSAOVERLAPPED;
		typedef LPOVERLAPPED LPWSAOVERLAPPED;

		typedef struct _WSABUF {
				unsigned long len;     /* the length of the buffer */
				char *buf; /* the pointer to the buffer */
			} WSABUF, * LPWSABUF;

		typedef
			void
			(__stdcall * LPWSAOVERLAPPED_COMPLETION_ROUTINE)(
				DWORD dwError,
				DWORD cbTransferred,
				LPWSAOVERLAPPED lpOverlapped,
				DWORD dwFlags
				);
		typedef 
			int 
			(__stdcall* LPFN_WSARECV) (
	            SOCKET socket,
				LPWSABUF buffers,
				DWORD buffer_count,
				LPDWORD bytes,
				LPDWORD flags,
				LPWSAOVERLAPPED overlapped,
				LPWSAOVERLAPPED_COMPLETION_ROUTINE completion_routine
				);

		typedef 
			int 
			(__stdcall* LPFN_WSARECVFROM) (
				SOCKET socket,
				LPWSABUF buffers,
				DWORD buffer_count,
				LPDWORD bytes,
				LPDWORD flags,
				struct sockaddr* addr,
				LPINT addr_len,
				LPWSAOVERLAPPED overlapped,
				LPWSAOVERLAPPED_COMPLETION_ROUTINE completion_routine
				);

		typedef struct _COORD {
			SHORT X;
			SHORT Y;
		} COORD, *PCOORD;

		typedef struct _KEY_EVENT_RECORD {
			BOOL bKeyDown;
			WORD wRepeatCount;
			WORD wVirtualKeyCode;
			WORD wVirtualScanCode;
			union {
				WCHAR UnicodeChar;
				CHAR   AsciiChar;
			} uChar;
			DWORD dwControlKeyState;
		} KEY_EVENT_RECORD, *PKEY_EVENT_RECORD;

		typedef struct _MOUSE_EVENT_RECORD {
			COORD dwMousePosition;
			DWORD dwButtonState;
			DWORD dwControlKeyState;
			DWORD dwEventFlags;
		} MOUSE_EVENT_RECORD, *PMOUSE_EVENT_RECORD;

		typedef struct _WINDOW_BUFFER_SIZE_RECORD {
			COORD dwSize;
		} WINDOW_BUFFER_SIZE_RECORD, *PWINDOW_BUFFER_SIZE_RECORD;

		typedef struct _MENU_EVENT_RECORD {
			UINT dwCommandId;
		} MENU_EVENT_RECORD, *PMENU_EVENT_RECORD;

		typedef struct _FOCUS_EVENT_RECORD {
			BOOL bSetFocus;
		} FOCUS_EVENT_RECORD, *PFOCUS_EVENT_RECORD;

		typedef struct _INPUT_RECORD {
			WORD EventType;
			union {
				KEY_EVENT_RECORD KeyEvent;
				MOUSE_EVENT_RECORD MouseEvent;
				WINDOW_BUFFER_SIZE_RECORD WindowBufferSizeEvent;
				MENU_EVENT_RECORD MenuEvent;
				FOCUS_EVENT_RECORD FocusEvent;
			} Event;
		} INPUT_RECORD, *PINPUT_RECORD;

		typedef struct _GUID {
			unsigned long  Data1;
			unsigned short Data2;
			unsigned short Data3;
			unsigned char  Data4[ 8 ];
		} GUID;

		typedef struct _WSAPROTOCOLCHAIN {
			int ChainLen;                                 /* the length of the chain,     */
			                                              /* length = 0 means layered protocol, */
			                                              /* length = 1 means base protocol, */
			                                              /* length > 1 means protocol chain */
			DWORD ChainEntries[7];      				  /* a list of dwCatalogEntryIds */
		} WSAPROTOCOLCHAIN, * LPWSAPROTOCOLCHAIN;

		typedef struct _WSAPROTOCOL_INFOW {
			DWORD dwServiceFlags1;
			DWORD dwServiceFlags2;
			DWORD dwServiceFlags3;
			DWORD dwServiceFlags4;
			DWORD dwProviderFlags;
			GUID ProviderId;
			DWORD dwCatalogEntryId;
			WSAPROTOCOLCHAIN ProtocolChain;
			int iVersion;
			int iAddressFamily;
			int iMaxSockAddr;
			int iMinSockAddr;
			int iSocketType;
			int iProtocol;
			int iProtocolMaxOffset;
			int iNetworkByteOrder;
			int iSecurityScheme;
			DWORD dwMessageSize;
			DWORD dwProviderReserved;
			WCHAR  szProtocol[256];
		} WSAPROTOCOL_INFOW, * LPWSAPROTOCOL_INFOW;

		typedef LONG NTSTATUS, *PNTSTATUS;

		typedef struct _AFD_POLL_HANDLE_INFO {
			HANDLE Handle;
			ULONG Events;
			NTSTATUS Status;
		} AFD_POLL_HANDLE_INFO, *PAFD_POLL_HANDLE_INFO;

		typedef struct _AFD_POLL_INFO {
			LARGE_INTEGER Timeout;
			ULONG NumberOfHandles;
			ULONG Exclusive;
			AFD_POLL_HANDLE_INFO Handles[1];
		} AFD_POLL_INFO, *PAFD_POLL_INFO;

		typedef struct in_addr {
			union {
				struct { UCHAR s_b1,s_b2,s_b3,s_b4; } S_un_b;
				struct { USHORT s_w1,s_w2; } S_un_w;
				ULONG S_addr;
			} S_un;
        } IN_ADDR, *PIN_ADDR, *LPIN_ADDR;

		typedef struct sockaddr_in {
			ADDRESS_FAMILY sin_family;
			USHORT sin_port;
			IN_ADDR sin_addr;
			CHAR sin_zero[8];
		} SOCKADDR_IN, *PSOCKADDR_IN;

		typedef struct in6_addr {
			union {
				UCHAR       Byte[16];
				USHORT      Word[8];
			} u;
		} IN6_ADDR, *PIN6_ADDR, *LPIN6_ADDR;

		typedef struct {
			union {
				struct {
					ULONG Zone : 28;
					ULONG Level : 4;
				};
				ULONG Value;
			};
		} SCOPE_ID, *PSCOPE_ID;

		typedef struct sockaddr_in6 {
			ADDRESS_FAMILY sin6_family; // AF_INET6.
			USHORT sin6_port;           // Transport level port number.
			ULONG  sin6_flowinfo;       // IPv6 flow information.
			IN6_ADDR sin6_addr;         // IPv6 address.
			union {
				ULONG sin6_scope_id;     // Set of interfaces for a scope.
				SCOPE_ID sin6_scope_struct; 
			};
		} SOCKADDR_IN6_LH, *PSOCKADDR_IN6_LH, *LPSOCKADDR_IN6_LH;

		typedef struct _LIST_ENTRY {
		   struct _LIST_ENTRY *Flink;
		   struct _LIST_ENTRY *Blink;
		} LIST_ENTRY, *PLIST_ENTRY, *PRLIST_ENTRY;

		typedef struct _RTL_CRITICAL_SECTION_DEBUG {
		    WORD   Type;
		    WORD   CreatorBackTraceIndex;
		    struct _RTL_CRITICAL_SECTION *CriticalSection;
		    LIST_ENTRY ProcessLocksList;
		    DWORD EntryCount;
		    DWORD ContentionCount;
		    DWORD Flags;
		    WORD   CreatorBackTraceIndexHigh;
		    WORD   SpareWORD  ;
		} RTL_CRITICAL_SECTION_DEBUG, *PRTL_CRITICAL_SECTION_DEBUG, RTL_RESOURCE_DEBUG, *PRTL_RESOURCE_DEBUG;

		typedef struct _RTL_CRITICAL_SECTION {
			PRTL_CRITICAL_SECTION_DEBUG DebugInfo;

			//
			//  The following three fields control entering and exiting the critical
			//  section for the resource
			//

			LONG LockCount;
			LONG RecursionCount;
			HANDLE OwningThread;        // from the thread's ClientId->UniqueThread
			HANDLE LockSemaphore;
			ULONG_PTR SpinCount;        // force size on 64-bit systems when packed
		} RTL_CRITICAL_SECTION, *PRTL_CRITICAL_SECTION;

		typedef RTL_CRITICAL_SECTION CRITICAL_SECTION;

		enum {
			O_RDONLY = 0x0000,
			O_WRONLY = 0x0001,
			O_RDWR = 0x0002,
			O_APPEND = 0x0008,
			O_CREAT = 0x0100,
			O_TRUNC = 0x0200,
			O_EXCL = 0x0400,
			O_TEXT = 0x4000,
			O_BINARY = 0x8000,
			O_WTEXT = 0x10000,
			O_U16TEXT = 0x20000,
			O_U8TEXT = 0x40000,
			O_NOINHERIT = 0x0080,
			O_TEMPORARY = 0x0040,
			O_SHORT_LIVED = 0x1000,
			O_SEQUENTIAL = 0x0020,
			O_RANDOM = 0x0010,
			O_RAW = 0x8000,
		};

		typedef SOCKET uv_os_sock_t;
		typedef int uv_file;

		typedef unsigned char uv_uid_t;
		typedef unsigned char uv_gid_t;

		typedef struct {
			HMODULE handle;
			char* errmsg;
		} uv_lib_t;

		typedef CRITICAL_SECTION uv_mutex_t;

		typedef PVOID SRWLOCK;

		typedef union {
			/* srwlock_ has type SRWLOCK, but not all toolchains define this type in */
			/* windows.h. */
			SRWLOCK srwlock_;
			struct {
				uv_mutex_t read_mutex_;
				uv_mutex_t write_mutex_;
				unsigned int num_readers_;
			} fallback_;
		} uv_rwlock_t;

		typedef HANDLE uv_sem_t;

		typedef PVOID CONDITION_VARIABLE, *PCONDITION_VARIABLE;

		typedef union {
			CONDITION_VARIABLE cond_var;
			struct {
				unsigned int waiters_count;
				CRITICAL_SECTION waiters_count_lock;
				HANDLE signal_event;
				HANDLE broadcast_event;
			} fallback;
		} uv_cond_t;

		typedef struct {
			unsigned int n;
			unsigned int count;
			uv_mutex_t mutex;
			uv_sem_t turnstile1;
			uv_sem_t turnstile2;
		} uv_barrier_t;

		typedef struct uv_once_s {
			unsigned char ran;
			HANDLE event;
		} uv_once_t;

		typedef HANDLE uv_thread_t;
	]]
else
	UV_HANDLE_PRIVATE_FIELDS = [[
		int flags;
		uv_handle_t* next_closing;
	]]

	UV_STREAM_PRIVATE_FIELDS = [[
		uv_connect_t *connect_req;
		uv_shutdown_t *shutdown_req;
		uv__io_t io_watcher;
		ngx_queue_t write_queue;
		ngx_queue_t write_completed_queue;
		uv_connection_cb connection_cb;
		int delayed_error;
		int accepted_fd;
	]] -- TODO: darwin has a "void* select;" field here.

	UV_WRITE_PRIVATE_FIELDS = [[
		ngx_queue_t queue;
		int write_index;
		uv_buf_t* bufs;
		int bufcnt;
		int error;
		uv_buf_t bufsml[4];
	]]

	UV_CONNECT_PRIVATE_FIELDS = [[
		ngx_queue_t queue;
	]]

	UV_UDP_PRIVATE_FIELDS = [[
		uv_alloc_cb alloc_cb;
		uv_udp_recv_cb recv_cb;
		uv__io_t io_watcher;
		ngx_queue_t write_queue;
		ngx_queue_t write_completed_queue;
	]]

	UV_UDP_SEND_PRIVATE_FIELDS = [[
		ngx_queue_t queue;
		struct sockaddr_in6 addr;
		int bufcnt;
		uv_buf_t* bufs;
		ssize_t status;
		uv_udp_send_cb send_cb;
		uv_buf_t bufsml[4];
	]]

	UV_TTY_PRIVATE_FIELDS = [[
		struct termios orig_termios;
		int mode;
	]]

  	UV_POLL_PRIVATE_FIELDS = [[
		uv__io_t io_watcher;
  	]]

  	UV_PREPARE_PRIVATE_FIELDS = [[
		uv_prepare_cb prepare_cb;
		ngx_queue_t queue;
  	]]

  	UV_CHECK_PRIVATE_FIELDS = [[
		uv_check_cb check_cb;
		ngx_queue_t queue;
  	]]

  	UV_IDLE_PRIVATE_FIELDS = [[
		uv_idle_cb idle_cb;
		ngx_queue_t queue;
  	]]

  	UV_ASYNC_PRIVATE_FIELDS = [[
  		volatile sig_atomic_t pending;
		uv_async_cb async_cb;
		ngx_queue_t queue;
  	]]

  	UV_TIMER_PRIVATE_FIELDS = [[
		struct {
			struct uv_timer_s* rbe_left;
			struct uv_timer_s* rbe_right;
			struct uv_timer_s* rbe_parent;
			int rbe_color;
		} tree_entry;
		uv_timer_cb timer_cb;
		uint64_t timeout;
		uint64_t repeat;
		uint64_t start_id;
  	]]

  	UV_GETADDRINFO_PRIVATE_FIELDS = [[
		struct uv__work work_req;
		uv_getaddrinfo_cb cb;
		struct addrinfo* hints;
		char* hostname;
		char* service;
		struct addrinfo* res;
		int retcode;
  	]]

  	UV_PROCESS_PRIVATE_FIELDS = [[
		ngx_queue_t queue;
		int errorno;
  	]]

  	UV_WORK_PRIVATE_FIELDS = [[
  		struct uv__work work_req;
  	]]

  	UV_FS_PRIVATE_FIELDS = [[
		const char *new_path;
		uv_file file;
		int flags;
		mode_t mode;
		void* buf;
		size_t len;
		off_t off;
		uid_t uid;
		gid_t gid;
		double atime;
		double mtime;
		struct uv__work work_req;  
  	]]

  	UV_FS_EVENT_PRIVATE_FIELDS = [[
  		uv_fs_event_cb cb;
  		UV_PLATFORM_FS_EVENT_FIELDS
  	]]

  	UV_SIGNAL_PRIVATE_FIELDS = [[
		struct {
			struct uv_signal_s* rbe_left;
			struct uv_signal_s* rbe_right;
			struct uv_signal_s* rbe_parent;
			int rbe_color;
		} tree_entry;
		unsigned int caught_signals;
		unsigned int dispatched_signals;
  	]]

  	UV_LOOP_PRIVATE_FIELDS = [[
		unsigned long flags;
		int backend_fd;
		ngx_queue_t pending_queue;
		ngx_queue_t watcher_queue;
		uv__io_t** watchers;
		unsigned int nwatchers;
		unsigned int nfds;
		ngx_queue_t wq;
		uv_mutex_t wq_mutex;
		uv_async_t wq_async;
		uv_handle_t* closing_handles;
		ngx_queue_t process_handles[1];
		ngx_queue_t prepare_handles;
		ngx_queue_t check_handles;
		ngx_queue_t idle_handles;
		ngx_queue_t async_handles;
		uv__io_t async_watcher;
		int async_pipefd[2];
		/* RB_HEAD(uv__timers, uv_timer_s) */
		struct uv__timers {
		struct uv_timer_s* rbh_root;
		} timer_handles;
		uint64_t time;
		int signal_pipefd[2];
		uv__io_t signal_io_watcher;
		uv_signal_t child_watcher;
		int emfile_fd;
		uint64_t timer_counter;
  	]]

	ffi.cdef [[
		typedef int uv_os_sock_t;
		typedef int uv_file;

		typedef struct uv__io_s uv__io_t;

		struct uv__io_s {
			uv__io_cb cb;
			ngx_queue_t pending_queue;
			ngx_queue_t watcher_queue;
			unsigned int pevents; /* Pending event mask i.e. mask at next tick. */
			unsigned int events;  /* Current event mask. */
			int fd;
			UV_IO_PRIVATE_FIELDS
		};

		struct uv__work {
			void (*work)(struct uv__work *w);
			void (*done)(struct uv__work *w, int status);
			struct uv_loop_s* loop;
			ngx_queue_t wq;
		};

		typedef struct {
			void* handle;
			char* errmsg;
		} uv_lib_t;
	]]
end

local UV_REQ_FIELDS = [[
		void* data;
		uv_req_type type;
		ngx_queue_t active_queue;
]] .. UV_REQ_PRIVATE_FIELDS

local UV_HANDLE_FIELDS = [[
	uv_close_cb close_cb;
	void* data;
	/* read-only */
	uv_loop_t* loop;
	uv_handle_type type;
	/* private */
	ngx_queue_t handle_queue;
]] .. UV_HANDLE_PRIVATE_FIELDS

local UV_STREAM_FIELDS = [[
	size_t write_queue_size;
	uv_alloc_cb alloc_cb;
	uv_read_cb read_cb;
	uv_read2_cb read2_cb;
]] .. UV_STREAM_PRIVATE_FIELDS

if (ffi.os == "Windows") then

	UV_PRIVATE_REQ_TYPES = [[
		typedef struct uv_pipe_accept_s {
			]] .. UV_REQ_FIELDS .. [[
			HANDLE pipeHandle;
			struct uv_pipe_accept_s* next_pending;
		} uv_pipe_accept_t;
		                                                                          \
		typedef struct uv_tcp_accept_s {
			]] .. UV_REQ_FIELDS .. [[
			SOCKET accept_socket;
			char accept_buffer[128 * 2 + 32];
			HANDLE event_handle;
			HANDLE wait_handle;
			struct uv_tcp_accept_s* next_pending;
		} uv_tcp_accept_t;
		                                                                          \
		typedef struct uv_read_s {
			]] .. UV_REQ_FIELDS .. [[
			HANDLE event_handle;
			HANDLE wait_handle;
		} uv_read_t;
	]]
end

ffi.cdef([[
	typedef struct ngx_queue_s  ngx_queue_t;

	struct ngx_queue_s {
		ngx_queue_t  *prev;
		ngx_queue_t  *next;
	};

	typedef struct uv_buf_t {
		unsigned long len;
		char* base;
	} uv_buf_t;
	typedef intptr_t ssize_t;

	typedef enum {
		UV_UNKNOWN = -1, 
		UV_OK =  0, 
		UV_EOF =  1, 
		UV_EADDRINFO =  2, 
		UV_EACCES =  3, 
		UV_EAGAIN =  4, 
		UV_EADDRINUSE =  5, 
		UV_EADDRNOTAVAIL =  6, 
		UV_EAFNOSUPPORT =  7, 
		UV_EALREADY =  8, 
		UV_EBADF =  9, 
		UV_EBUSY = 10, 
		UV_ECONNABORTED = 11, 
		UV_ECONNREFUSED = 12, 
		UV_ECONNRESET = 13, 
		UV_EDESTADDRREQ = 14, 
		UV_EFAULT = 15, 
		UV_EHOSTUNREACH = 16, 
		UV_EINTR = 17, 
		UV_EINVAL = 18, 
		UV_EISCONN = 19, 
		UV_EMFILE = 20, 
		UV_EMSGSIZE = 21, 
		UV_ENETDOWN = 22, 
		UV_ENETUNREACH = 23, 
		UV_ENFILE = 24, 
		UV_ENOBUFS = 25, 
		UV_ENOMEM = 26, 
		UV_ENOTDIR = 27, 
		UV_EISDIR = 28, 
		UV_ENONET = 29, 
		UV_ENOTCONN = 31, 
		UV_ENOTSOCK = 32, 
		UV_ENOTSUP = 33, 
		UV_ENOENT = 34, 
		UV_ENOSYS = 35, 
		UV_EPIPE = 36, 
		UV_EPROTO = 37, 
		UV_EPROTONOSUPPORT = 38, 
		UV_EPROTOTYPE = 39, 
		UV_ETIMEDOUT = 40, 
		UV_ECHARSET = 41, 
		UV_EAIFAMNOSUPPORT = 42, 
		UV_EAISERVICE = 44, 
		UV_EAISOCKTYPE = 45, 
		UV_ESHUTDOWN = 46, 
		UV_EEXIST = 47, 
		UV_ESRCH = 48, 
		UV_ENAMETOOLONG = 49, 
		UV_EPERM = 50, 
		UV_ELOOP = 51, 
		UV_EXDEV = 52, 
		UV_ENOTEMPTY = 53, 
		UV_ENOSPC = 54, 
		UV_EIO = 55, 
		UV_EROFS = 56, 
		UV_ENODEV = 57, 
		UV_ESPIPE = 58, 
		UV_ECANCELED = 59, 
		UV_MAX_ERRORS
	} uv_err_code;

	typedef enum {
		UV_UNKNOWN_HANDLE = 0,
		UV_ASYNC,
		UV_CHECK,
		UV_FS_EVENT,
		UV_FS_POLL,
		UV_HANDLE,
		UV_IDLE,
		UV_NAMED_PIPE,
		UV_POLL,
		UV_PREPARE,
		UV_PROCESS,
		UV_STREAM,
		UV_TCP,
		UV_TIMER,
		UV_TTY,
		UV_UDP,
		UV_SIGNAL,
		UV_FILE,
		UV_HANDLE_TYPE_MAX
	} uv_handle_type;

	typedef enum {
		UV_UNKNOWN_REQ = 0,
		UV_REQ,
		UV_CONNECT,
		UV_WRITE,
		UV_SHUTDOWN,
		UV_UDP_SEND,
		UV_FS,
		UV_WORK,
		UV_GETADDRINFO,
		UV_REQ_TYPE_PRIVATE,
		UV_REQ_TYPE_MAX
	} uv_req_type;

	/* Handle types. */
	typedef struct uv_loop_s uv_loop_t;
	typedef struct uv_err_s uv_err_t;
	typedef struct uv_handle_s uv_handle_t;
	typedef struct uv_stream_s uv_stream_t;
	typedef struct uv_tcp_s uv_tcp_t;
	typedef struct uv_udp_s uv_udp_t;
	typedef struct uv_pipe_s uv_pipe_t;
	typedef struct uv_tty_s uv_tty_t;
	typedef struct uv_poll_s uv_poll_t;
	typedef struct uv_timer_s uv_timer_t;
	typedef struct uv_prepare_s uv_prepare_t;
	typedef struct uv_check_s uv_check_t;
	typedef struct uv_idle_s uv_idle_t;
	typedef struct uv_async_s uv_async_t;
	typedef struct uv_process_s uv_process_t;
	typedef struct uv_fs_event_s uv_fs_event_t;
	typedef struct uv_fs_poll_s uv_fs_poll_t;
	typedef struct uv_signal_s uv_signal_t;

	/* Request types. */
	typedef struct uv_req_s uv_req_t;
	typedef struct uv_getaddrinfo_s uv_getaddrinfo_t;
	typedef struct uv_shutdown_s uv_shutdown_t;
	typedef struct uv_write_s uv_write_t;
	typedef struct uv_connect_s uv_connect_t;
	typedef struct uv_udp_send_s uv_udp_send_t;
	typedef struct uv_fs_s uv_fs_t;
	typedef struct uv_work_s uv_work_t;

	/* None of the above. */
	typedef struct uv_cpu_info_s uv_cpu_info_t;
	typedef struct uv_interface_address_s uv_interface_address_t;

	typedef enum {
		UV_RUN_DEFAULT = 0,
		UV_RUN_ONCE,
		UV_RUN_NOWAIT
	} uv_run_mode;

	uv_loop_t* uv_loop_new(void);

	void uv_loop_delete(uv_loop_t*);

	uv_loop_t* uv_default_loop(void);

	int uv_run(uv_loop_t*, uv_run_mode mode);

	void uv_ref(uv_handle_t*);
	void uv_unref(uv_handle_t*);

	void uv_update_time(uv_loop_t*);
	uint64_t uv_now(uv_loop_t*);

	int uv_backend_fd(const uv_loop_t*);

	int uv_backend_timeout(const uv_loop_t*);

	typedef uv_buf_t (*uv_alloc_cb)(uv_handle_t* handle, size_t suggested_size);

	typedef void (*uv_read_cb)(uv_stream_t* stream, ssize_t nread, uv_buf_t buf);

	typedef void (*uv_read2_cb)(uv_pipe_t* pipe, ssize_t nread, uv_buf_t buf,
	    uv_handle_type pending);

	typedef void (*uv_write_cb)(uv_write_t* req, int status);
	typedef void (*uv_connect_cb)(uv_connect_t* req, int status);
	typedef void (*uv_shutdown_cb)(uv_shutdown_t* req, int status);
	typedef void (*uv_connection_cb)(uv_stream_t* server, int status);
	typedef void (*uv_close_cb)(uv_handle_t* handle);
	typedef void (*uv_poll_cb)(uv_poll_t* handle, int status, int events);
	typedef void (*uv_timer_cb)(uv_timer_t* handle, int status);

	typedef void (*uv_async_cb)(uv_async_t* handle, int status);
	typedef void (*uv_prepare_cb)(uv_prepare_t* handle, int status);
	typedef void (*uv_check_cb)(uv_check_t* handle, int status);
	typedef void (*uv_idle_cb)(uv_idle_t* handle, int status);
	typedef void (*uv_exit_cb)(uv_process_t*, int exit_status, int term_signal);
	typedef void (*uv_walk_cb)(uv_handle_t* handle, void* arg);
	typedef void (*uv_fs_cb)(uv_fs_t* req);
	typedef void (*uv_work_cb)(uv_work_t* req);
	typedef void (*uv_after_work_cb)(uv_work_t* req, int status);
	typedef void (*uv_getaddrinfo_cb)(uv_getaddrinfo_t* req,
	                                  int status,
	                                  struct addrinfo* res);

	typedef void (*uv_fs_event_cb)(uv_fs_event_t* handle, const char* filename,
	    int events, int status);

	typedef void (*uv_fs_poll_cb)(uv_fs_poll_t* handle,
	                              int status,
	                              const uv_statbuf_t* prev,
	                              const uv_statbuf_t* curr);

	typedef void (*uv_signal_cb)(uv_signal_t* handle, int signum);

	typedef enum {
		UV_LEAVE_GROUP = 0,
		UV_JOIN_GROUP
	} uv_membership;

	struct uv_err_s {
		/* read-only */
		uv_err_code code;
		/* private */
		int sys_errno_;
	};


	uv_err_t uv_last_error(uv_loop_t*);
	const char* uv_strerror(uv_err_t err);
	const char* uv_err_name(uv_err_t err);

	struct uv_req_s {
]] .. UV_REQ_FIELDS .. [[
	};

]] .. UV_PRIVATE_REQ_TYPES .. [[

	int uv_shutdown(uv_shutdown_t* req, uv_stream_t* handle,
	    uv_shutdown_cb cb);

	struct uv_shutdown_s {
]] .. UV_REQ_FIELDS .. [[
		uv_stream_t* handle;
		uv_shutdown_cb cb;
	};

	struct uv_handle_s {
]] .. UV_HANDLE_FIELDS .. [[
	};

	size_t uv_handle_size(uv_handle_type type);

	size_t uv_req_size(uv_req_type type);

	int uv_is_active(const uv_handle_t* handle);

	void uv_walk(uv_loop_t* loop, uv_walk_cb walk_cb, void* arg);

	void uv_close(uv_handle_t* handle, uv_close_cb close_cb);

	uv_buf_t uv_buf_init(char* base, unsigned int len);

	size_t uv_strlcpy(char* dst, const char* src, size_t size);

	size_t uv_strlcat(char* dst, const char* src, size_t size);

	struct uv_stream_s {
]] .. UV_HANDLE_FIELDS .. [[
]] .. UV_STREAM_FIELDS .. [[
	};

	int uv_listen(uv_stream_t* stream, int backlog, uv_connection_cb cb);

	int uv_accept(uv_stream_t* server, uv_stream_t* client);

	int uv_read_start(uv_stream_t*, uv_alloc_cb alloc_cb,
		uv_read_cb read_cb);

	int uv_read_stop(uv_stream_t*);

	int uv_read2_start(uv_stream_t*, uv_alloc_cb alloc_cb,
		uv_read2_cb read_cb);

	int uv_write(uv_write_t* req, uv_stream_t* handle,
    	uv_buf_t bufs[], int bufcnt, uv_write_cb cb);

	int uv_write2(uv_write_t* req, uv_stream_t* handle, uv_buf_t bufs[],
    	int bufcnt, uv_stream_t* send_handle, uv_write_cb cb);

	struct uv_write_s {
]] .. UV_REQ_FIELDS .. [[
		uv_write_cb cb;
		uv_stream_t* send_handle;
		uv_stream_t* handle;
]] .. UV_WRITE_PRIVATE_FIELDS .. [[
	};

	int uv_is_readable(const uv_stream_t* handle);

	int uv_is_writable(const uv_stream_t* handle);

	int uv_is_closing(const uv_handle_t* handle);

	struct uv_tcp_s {
]] .. UV_HANDLE_FIELDS .. [[
]] .. UV_STREAM_FIELDS .. [[
]] .. UV_TCP_PRIVATE_FIELDS .. [[
	};

	int uv_tcp_init(uv_loop_t*, uv_tcp_t* handle);

	int uv_tcp_open(uv_tcp_t* handle, uv_os_sock_t sock);

	int uv_tcp_nodelay(uv_tcp_t* handle, int enable);

	int uv_tcp_keepalive(uv_tcp_t* handle,
                               int enable,
                               unsigned int delay);

	int uv_tcp_simultaneous_accepts(uv_tcp_t* handle, int enable);

	int uv_tcp_bind(uv_tcp_t* handle, struct sockaddr_in);
	int uv_tcp_bind6(uv_tcp_t* handle, struct sockaddr_in6);
	int uv_tcp_getsockname(uv_tcp_t* handle, struct sockaddr* name,
	    int* namelen);
	int uv_tcp_getpeername(uv_tcp_t* handle, struct sockaddr* name,
	    int* namelen);

	int uv_tcp_connect(uv_connect_t* req, uv_tcp_t* handle,
		struct sockaddr_in address, uv_connect_cb cb);
	int uv_tcp_connect6(uv_connect_t* req, uv_tcp_t* handle,
    	struct sockaddr_in6 address, uv_connect_cb cb);

	struct uv_connect_s {
]] .. UV_REQ_FIELDS .. [[
		uv_connect_cb cb;
		uv_stream_t* handle;
]] .. UV_CONNECT_PRIVATE_FIELDS .. [[
	};

	enum uv_udp_flags {
		/* Disables dual stack mode. Used with uv_udp_bind6(). */
		UV_UDP_IPV6ONLY = 1,
		/*
		* Indicates message was truncated because read buffer was too small. The
		* remainder was discarded by the OS. Used in uv_udp_recv_cb.
		*/
		UV_UDP_PARTIAL = 2
	};

	typedef void (*uv_udp_send_cb)(uv_udp_send_t* req, int status);

	typedef void (*uv_udp_recv_cb)(uv_udp_t* handle, ssize_t nread, uv_buf_t buf,
	    struct sockaddr* addr, unsigned flags);

	struct uv_udp_s {
]] .. UV_HANDLE_FIELDS .. [[
]] .. UV_UDP_PRIVATE_FIELDS .. [[
	};

	struct uv_udp_send_s {
]] .. UV_REQ_FIELDS .. [[
		uv_udp_t* handle;
		uv_udp_send_cb cb;
]] .. UV_UDP_SEND_PRIVATE_FIELDS .. [[
	};

	int uv_udp_init(uv_loop_t*, uv_udp_t* handle);

	int uv_udp_open(uv_udp_t* handle, uv_os_sock_t sock);

	int uv_udp_bind(uv_udp_t* handle, struct sockaddr_in addr,
		unsigned flags);

	int uv_udp_bind6(uv_udp_t* handle, struct sockaddr_in6 addr,
		unsigned flags);

	int uv_udp_getsockname(uv_udp_t* handle, struct sockaddr* name,
		int* namelen);

	int uv_udp_set_membership(uv_udp_t* handle,
		const char* multicast_addr, const char* interface_addr,
		uv_membership membership);

	int uv_udp_set_multicast_loop(uv_udp_t* handle, int on);

	int uv_udp_set_multicast_ttl(uv_udp_t* handle, int ttl);

	int uv_udp_set_broadcast(uv_udp_t* handle, int on);

	int uv_udp_set_ttl(uv_udp_t* handle, int ttl);

	int uv_udp_send(uv_udp_send_t* req, uv_udp_t* handle,
		uv_buf_t bufs[], int bufcnt, struct sockaddr_in addr,
		uv_udp_send_cb send_cb);

	int uv_udp_send6(uv_udp_send_t* req, uv_udp_t* handle,
		uv_buf_t bufs[], int bufcnt, struct sockaddr_in6 addr,
		uv_udp_send_cb send_cb);

	int uv_udp_recv_start(uv_udp_t* handle, uv_alloc_cb alloc_cb,
		uv_udp_recv_cb recv_cb);

	int uv_udp_recv_stop(uv_udp_t* handle);

	struct uv_tty_s {
]] .. UV_HANDLE_FIELDS .. [[
]] .. UV_STREAM_FIELDS .. [[
]] .. UV_TTY_PRIVATE_FIELDS .. [[
	};

	int uv_tty_init(uv_loop_t*, uv_tty_t*, uv_file fd, int readable);

	int uv_tty_set_mode(uv_tty_t*, int mode);

	void uv_tty_reset_mode(void);

	int uv_tty_get_winsize(uv_tty_t*, int* width, int* height);

	uv_handle_type uv_guess_handle(uv_file file);

	struct uv_pipe_s {
]] .. UV_HANDLE_FIELDS .. [[
]] .. UV_STREAM_FIELDS .. [[
		int ipc; /* non-zero if this pipe is used for passing handles */
]] .. UV_PIPE_PRIVATE_FIELDS .. [[
	};

	int uv_pipe_init(uv_loop_t*, uv_pipe_t* handle, int ipc);

	int uv_pipe_open(uv_pipe_t*, uv_file file);

	int uv_pipe_bind(uv_pipe_t* handle, const char* name);

	void uv_pipe_connect(uv_connect_t* req, uv_pipe_t* handle,
		const char* name, uv_connect_cb cb);

	void uv_pipe_pending_instances(uv_pipe_t* handle, int count);

	struct uv_poll_s {
]] .. UV_HANDLE_FIELDS .. [[
		uv_poll_cb poll_cb;
]] .. UV_POLL_PRIVATE_FIELDS .. [[
	};

	enum uv_poll_event {
		UV_READABLE = 1,
		UV_WRITABLE = 2
	};

	int uv_poll_init(uv_loop_t* loop, uv_poll_t* handle, int fd);

	int uv_poll_init_socket(uv_loop_t* loop, uv_poll_t* handle,
		uv_os_sock_t socket);

	int uv_poll_start(uv_poll_t* handle, int events, uv_poll_cb cb);

	int uv_poll_stop(uv_poll_t* handle);

	struct uv_prepare_s {
]] .. UV_HANDLE_FIELDS .. [[
]] .. UV_PREPARE_PRIVATE_FIELDS .. [[
	};

	int uv_prepare_init(uv_loop_t*, uv_prepare_t* prepare);

	int uv_prepare_start(uv_prepare_t* prepare, uv_prepare_cb cb);

	int uv_prepare_stop(uv_prepare_t* prepare);

	struct uv_check_s {
]] .. UV_HANDLE_FIELDS .. [[
]] .. UV_CHECK_PRIVATE_FIELDS .. [[
	};

	int uv_check_init(uv_loop_t*, uv_check_t* check);

	int uv_check_start(uv_check_t* check, uv_check_cb cb);

	int uv_check_stop(uv_check_t* check);

	struct uv_idle_s {
]] .. UV_HANDLE_FIELDS .. [[
]] .. UV_IDLE_PRIVATE_FIELDS .. [[
	};

	int uv_idle_init(uv_loop_t*, uv_idle_t* idle);

	int uv_idle_start(uv_idle_t* idle, uv_idle_cb cb);

	int uv_idle_stop(uv_idle_t* idle);

	struct uv_async_s {
]] .. UV_HANDLE_FIELDS .. [[
]] .. UV_ASYNC_PRIVATE_FIELDS .. [[
	};

	int uv_async_init(uv_loop_t*, uv_async_t* async,
		uv_async_cb async_cb);

	int uv_async_send(uv_async_t* async);

	struct uv_timer_s {
]] .. UV_HANDLE_FIELDS .. [[
]] .. UV_TIMER_PRIVATE_FIELDS .. [[
	};

	int uv_timer_init(uv_loop_t*, uv_timer_t* timer);

	int uv_timer_start(uv_timer_t* timer,
                             uv_timer_cb cb,
                             uint64_t timeout,
                             uint64_t repeat);

	int uv_timer_stop(uv_timer_t* timer);

	int uv_timer_again(uv_timer_t* timer);

	void uv_timer_set_repeat(uv_timer_t* timer, uint64_t repeat);

	uint64_t uv_timer_get_repeat(const uv_timer_t* timer);

	struct uv_getaddrinfo_s {
]] .. UV_REQ_FIELDS .. [[
		/* read-only */
		uv_loop_t* loop;
]] .. UV_GETADDRINFO_PRIVATE_FIELDS .. [[
	};

	int uv_getaddrinfo(uv_loop_t* loop,
                             uv_getaddrinfo_t* req,
                             uv_getaddrinfo_cb getaddrinfo_cb,
                             const char* node,
                             const char* service,
                             const struct addrinfo* hints);

	void uv_freeaddrinfo(struct addrinfo* ai);

	typedef enum {
		UV_IGNORE         = 0x00,
		UV_CREATE_PIPE    = 0x01,
		UV_INHERIT_FD     = 0x02,
		UV_INHERIT_STREAM = 0x04,

		/* When UV_CREATE_PIPE is specified, UV_READABLE_PIPE and UV_WRITABLE_PIPE
		* determine the direction of flow, from the child process' perspective. Both
		* flags may be specified to create a duplex data stream.
		*/
		UV_READABLE_PIPE  = 0x10,
		UV_WRITABLE_PIPE  = 0x20
	} uv_stdio_flags;

	typedef struct uv_stdio_container_s {
		uv_stdio_flags flags;

		union {
			uv_stream_t* stream;
			int fd;
		} data;
	} uv_stdio_container_t;

	typedef struct uv_process_options_s {
		uv_exit_cb exit_cb;
		const char* file;
		char** args;
		char** env;
		char* cwd;
		unsigned int flags;
		int stdio_count;
		uv_stdio_container_t* stdio;
		uv_uid_t uid;
		uv_gid_t gid;
	} uv_process_options_t;

	enum uv_process_flags {
		UV_PROCESS_SETUID = (1 << 0),
		UV_PROCESS_SETGID = (1 << 1),
		UV_PROCESS_WINDOWS_VERBATIM_ARGUMENTS = (1 << 2),
		UV_PROCESS_DETACHED = (1 << 3),
		UV_PROCESS_WINDOWS_HIDE = (1 << 4)
	};

	struct uv_process_s {
]] .. UV_HANDLE_FIELDS .. [[
		uv_exit_cb exit_cb;
		int pid;
]] .. UV_PROCESS_PRIVATE_FIELDS .. [[
	};

	int uv_spawn(uv_loop_t*, uv_process_t*,
		uv_process_options_t options);

	int uv_process_kill(uv_process_t*, int signum);

	uv_err_t uv_kill(int pid, int signum);

	struct uv_work_s {
]] .. UV_REQ_FIELDS .. [[
		uv_loop_t* loop;
		uv_work_cb work_cb;
		uv_after_work_cb after_work_cb;
]] .. UV_WORK_PRIVATE_FIELDS .. [[
	};

	int uv_queue_work(uv_loop_t* loop, uv_work_t* req,
		uv_work_cb work_cb, uv_after_work_cb after_work_cb);

	int uv_cancel(uv_req_t* req);

	struct uv_cpu_info_s {
		char* model;
		int speed;
		struct uv_cpu_times_s {
			uint64_t user;
			uint64_t nice;
			uint64_t sys;
			uint64_t idle;
			uint64_t irq;
		} cpu_times;
	};

	struct uv_interface_address_s {
		char* name;
		int is_internal;
		union {
			struct sockaddr_in address4;
			struct sockaddr_in6 address6;
		} address;
	};

	char** uv_setup_args(int argc, char** argv);
	uv_err_t uv_get_process_title(char* buffer, size_t size);
	uv_err_t uv_set_process_title(const char* title);
	uv_err_t uv_resident_set_memory(size_t* rss);
	uv_err_t uv_uptime(double* uptime);

	uv_err_t uv_cpu_info(uv_cpu_info_t** cpu_infos, int* count);
	void uv_free_cpu_info(uv_cpu_info_t* cpu_infos, int count);

	uv_err_t uv_interface_addresses(uv_interface_address_t** addresses,
		int* count);

	void uv_free_interface_addresses(uv_interface_address_t* addresses,
		int count);

	typedef enum {
		UV_FS_UNKNOWN = -1,
		UV_FS_CUSTOM,
		UV_FS_OPEN,
		UV_FS_CLOSE,
		UV_FS_READ,
		UV_FS_WRITE,
		UV_FS_SENDFILE,
		UV_FS_STAT,
		UV_FS_LSTAT,
		UV_FS_FSTAT,
		UV_FS_FTRUNCATE,
		UV_FS_UTIME,
		UV_FS_FUTIME,
		UV_FS_CHMOD,
		UV_FS_FCHMOD,
		UV_FS_FSYNC,
		UV_FS_FDATASYNC,
		UV_FS_UNLINK,
		UV_FS_RMDIR,
		UV_FS_MKDIR,
		UV_FS_RENAME,
		UV_FS_READDIR,
		UV_FS_LINK,
		UV_FS_SYMLINK,
		UV_FS_READLINK,
		UV_FS_CHOWN,
		UV_FS_FCHOWN
	} uv_fs_type;

	struct uv_fs_s {
]] .. UV_REQ_FIELDS .. [[
		uv_fs_type fs_type;
		uv_loop_t* loop;
		union {uv_fs_cb cb; int cb_lua;};
		ssize_t result;
		void* ptr;
		const char* path;
		uv_err_code errorno;
		uv_statbuf_t statbuf;  /* Stores the result of uv_fs_stat and uv_fs_fstat. */
]] .. UV_FS_PRIVATE_FIELDS .. [[
	};

	void uv_fs_req_cleanup(uv_fs_t* req);
	
	int uv_fs_close(uv_loop_t* loop, uv_fs_t* req, uv_file file,
		uv_fs_cb cb);

	int uv_fs_open(uv_loop_t* loop, uv_fs_t* req, const char* path,
		int flags, int mode, uv_fs_cb cb);

	int uv_fs_read(uv_loop_t* loop, uv_fs_t* req, uv_file file,
		void* buf, size_t length, int64_t offset, uv_fs_cb cb);

	int uv_fs_unlink(uv_loop_t* loop, uv_fs_t* req, const char* path,
		uv_fs_cb cb);

	int uv_fs_write(uv_loop_t* loop, uv_fs_t* req, uv_file file,
		void* buf, size_t length, int64_t offset, uv_fs_cb cb);

	int uv_fs_mkdir(uv_loop_t* loop, uv_fs_t* req, const char* path,
		int mode, uv_fs_cb cb);

	int uv_fs_rmdir(uv_loop_t* loop, uv_fs_t* req, const char* path,
		uv_fs_cb cb);

	int uv_fs_readdir(uv_loop_t* loop, uv_fs_t* req,
		const char* path, int flags, uv_fs_cb cb);

	int uv_fs_stat(uv_loop_t* loop, uv_fs_t* req, const char* path,
		uv_fs_cb cb);

	int uv_fs_fstat(uv_loop_t* loop, uv_fs_t* req, uv_file file,
		uv_fs_cb cb);

	int uv_fs_rename(uv_loop_t* loop, uv_fs_t* req, const char* path,
		const char* new_path, uv_fs_cb cb);

	int uv_fs_fsync(uv_loop_t* loop, uv_fs_t* req, uv_file file,
		uv_fs_cb cb);

	int uv_fs_fdatasync(uv_loop_t* loop, uv_fs_t* req, uv_file file,
		uv_fs_cb cb);

	int uv_fs_ftruncate(uv_loop_t* loop, uv_fs_t* req, uv_file file,
		int64_t offset, uv_fs_cb cb);

	int uv_fs_sendfile(uv_loop_t* loop, uv_fs_t* req, uv_file out_fd,
		uv_file in_fd, int64_t in_offset, size_t length, uv_fs_cb cb);

	int uv_fs_chmod(uv_loop_t* loop, uv_fs_t* req, const char* path,
		int mode, uv_fs_cb cb);

	int uv_fs_utime(uv_loop_t* loop, uv_fs_t* req, const char* path,
		double atime, double mtime, uv_fs_cb cb);

	int uv_fs_futime(uv_loop_t* loop, uv_fs_t* req, uv_file file,
		double atime, double mtime, uv_fs_cb cb);

	int uv_fs_lstat(uv_loop_t* loop, uv_fs_t* req, const char* path,
		uv_fs_cb cb);

	int uv_fs_link(uv_loop_t* loop, uv_fs_t* req, const char* path,
		const char* new_path, uv_fs_cb cb);

	enum {
		UV_FS_SYMLINK_DIR 		= 0x0001,
		UV_FS_SYMLINK_JUNCTION	= 0x0002,
	};

	int uv_fs_symlink(uv_loop_t* loop, uv_fs_t* req, const char* path,
		const char* new_path, int flags, uv_fs_cb cb);

	int uv_fs_readlink(uv_loop_t* loop, uv_fs_t* req, const char* path,
		uv_fs_cb cb);

	int uv_fs_fchmod(uv_loop_t* loop, uv_fs_t* req, uv_file file,
		int mode, uv_fs_cb cb);

	int uv_fs_chown(uv_loop_t* loop, uv_fs_t* req, const char* path,
		int uid, int gid, uv_fs_cb cb);

	int uv_fs_fchown(uv_loop_t* loop, uv_fs_t* req, uv_file file,
		int uid, int gid, uv_fs_cb cb);

	enum uv_fs_event {
		UV_RENAME = 1,
		UV_CHANGE = 2
	};

	struct uv_fs_event_s {
]] .. UV_HANDLE_FIELDS .. [[
		char* filename;
]] .. UV_FS_EVENT_PRIVATE_FIELDS .. [[
	};

	struct uv_fs_poll_s {
]] .. UV_HANDLE_FIELDS .. [[
		/* Private, don't touch. */
		void* poll_ctx;
	};

	int uv_fs_poll_init(uv_loop_t* loop, uv_fs_poll_t* handle);

	int uv_fs_poll_start(uv_fs_poll_t* handle,
							uv_fs_poll_cb poll_cb,
							const char* path,
							unsigned int interval);

	int uv_fs_poll_stop(uv_fs_poll_t* handle);

	struct uv_signal_s {
]] .. UV_HANDLE_FIELDS .. [[
		uv_signal_cb signal_cb;
		int signum;
]] .. UV_SIGNAL_PRIVATE_FIELDS .. [[
	};

	int uv_signal_init(uv_loop_t* loop, uv_signal_t* handle);

	int uv_signal_start(uv_signal_t* handle,
                              uv_signal_cb signal_cb,
                              int signum);

	int uv_signal_stop(uv_signal_t* handle);

	void uv_loadavg(double avg[3]);

	enum uv_fs_event_flags {
		UV_FS_EVENT_WATCH_ENTRY = 1,
		UV_FS_EVENT_STAT = 2,
		UV_FS_EVENT_RECURSIVE = 3,
	};

	int uv_fs_event_init(uv_loop_t* loop, uv_fs_event_t* handle,
		const char* filename, uv_fs_event_cb cb, int flags);

	struct sockaddr_in uv_ip4_addr(const char* ip, int port);
	struct sockaddr_in6 uv_ip6_addr(const char* ip, int port);

	int uv_ip4_name(struct sockaddr_in* src, char* dst, size_t size);
	int uv_ip6_name(struct sockaddr_in6* src, char* dst, size_t size);

	uv_err_t uv_inet_ntop(int af, const void* src, char* dst, size_t size);

	uv_err_t uv_inet_pton(int af, const char* src, void* dst);

	int uv_exepath(char* buffer, size_t* size);

	uv_err_t uv_cwd(char* buffer, size_t size);

	uv_err_t uv_chdir(const char* dir);

	uint64_t uv_get_free_memory(void);
	uint64_t uv_get_total_memory(void);

	extern uint64_t uv_hrtime(void);

	void uv_disable_stdio_inheritance(void);

	int uv_dlopen(const char* filename, uv_lib_t* lib);

	void uv_dlclose(uv_lib_t* lib);

	int uv_dlsym(uv_lib_t* lib, const char* name, void** ptr);

	const char* uv_dlerror(uv_lib_t* lib);

	int uv_mutex_init(uv_mutex_t* handle);
	void uv_mutex_destroy(uv_mutex_t* handle);
	void uv_mutex_lock(uv_mutex_t* handle);
	int uv_mutex_trylock(uv_mutex_t* handle);
	void uv_mutex_unlock(uv_mutex_t* handle);

	int uv_rwlock_init(uv_rwlock_t* rwlock);
	void uv_rwlock_destroy(uv_rwlock_t* rwlock);
	void uv_rwlock_rdlock(uv_rwlock_t* rwlock);
	int uv_rwlock_tryrdlock(uv_rwlock_t* rwlock);
	void uv_rwlock_rdunlock(uv_rwlock_t* rwlock);
	void uv_rwlock_wrlock(uv_rwlock_t* rwlock);
	int uv_rwlock_trywrlock(uv_rwlock_t* rwlock);
	void uv_rwlock_wrunlock(uv_rwlock_t* rwlock);

	int uv_sem_init(uv_sem_t* sem, unsigned int value);
	void uv_sem_destroy(uv_sem_t* sem);
	void uv_sem_post(uv_sem_t* sem);
	void uv_sem_wait(uv_sem_t* sem);
	int uv_sem_trywait(uv_sem_t* sem);

	int uv_cond_init(uv_cond_t* cond);
	void uv_cond_destroy(uv_cond_t* cond);
	void uv_cond_signal(uv_cond_t* cond);
	void uv_cond_broadcast(uv_cond_t* cond);

	void uv_cond_wait(uv_cond_t* cond, uv_mutex_t* mutex);

	int uv_cond_timedwait(uv_cond_t* cond, uv_mutex_t* mutex,
		uint64_t timeout);

	int uv_barrier_init(uv_barrier_t* barrier, unsigned int count);
	void uv_barrier_destroy(uv_barrier_t* barrier);
	void uv_barrier_wait(uv_barrier_t* barrier);

	void uv_once(uv_once_t* guard, void (*callback)(void));

	int uv_thread_create(uv_thread_t *tid,
    	void (*entry)(void *arg), void *arg);
	unsigned long uv_thread_self(void);
	int uv_thread_join(uv_thread_t *tid);

	union uv_any_handle {
		uv_handle_t handle;
		uv_stream_t stream;
		uv_tcp_t tcp;
		uv_pipe_t pipe;
		uv_prepare_t prepare;
		uv_check_t check;
		uv_idle_t idle;
		uv_async_t async;
		uv_timer_t timer;
		uv_fs_event_t fs_event;
		uv_fs_poll_t fs_poll;
		uv_poll_t poll;
		uv_process_t process;
		uv_tty_t tty;
		uv_udp_t udp;
	};

	union uv_any_req {
		uv_req_t req;
		uv_write_t write;
		uv_connect_t connect;
		uv_shutdown_t shutdown;
		uv_fs_t fs_req;
		uv_work_t work_req;
		uv_udp_send_t udp_send_req;
		uv_getaddrinfo_t getaddrinfo_req;
	};

	struct uv_loop_s {
		/* User data - use this for whatever. */
		void* data;
		/* The last error */
		uv_err_t last_err;
		/* Loop reference counting */
		unsigned int active_handles;
		ngx_queue_t handle_queue;
		ngx_queue_t active_reqs;
]] .. UV_LOOP_PRIVATE_FIELDS .. [[
	};
]])

-- uv-lua.h
ffi.cdef [[
	// CORE functions
	int uv_loop_alive(uv_loop_t* loop);

	// IDLE functions
	int uv_idle_start_lua(uv_idle_t* idle, int callback);

	// timer functions
	int uv_timer_start_lua(uv_timer_t* handle,
	                             int callback,
	                             uint64_t timeout,
	                             uint64_t repeat);

	uv_timer_t* uv_timer_query_lua(uv_loop_t* loop);

	// fs functions
	int uv_fs_close_lua(uv_loop_t* loop, uv_fs_t* req, uv_file file, int cb);

	int uv_fs_open_lua(uv_loop_t* loop, uv_fs_t* req, const char* path, int flags, int mode, int cb);

	int uv_fs_read_lua(uv_loop_t* loop, uv_fs_t* req, uv_file file, void* buf, size_t length, int64_t offset, int cb);

	int uv_fs_unlink_lua(uv_loop_t* loop, uv_fs_t* req, const char* path, int cb);

	int uv_fs_write_lua(uv_loop_t* loop, uv_fs_t* req, uv_file file, void* buf, size_t length, int64_t offset, int cb);

	int uv_fs_mkdir_lua(uv_loop_t* loop, uv_fs_t* req, const char* path, int mode, int cb);

	int uv_fs_rmdir_lua(uv_loop_t* loop, uv_fs_t* req, const char* path, int cb);

	int uv_fs_readdir_lua(uv_loop_t* loop, uv_fs_t* req, const char* path, int flags, int cb);

	int uv_fs_stat_lua(uv_loop_t* loop, uv_fs_t* req, const char* path, int cb);

	int uv_fs_fstat_lua(uv_loop_t* loop, uv_fs_t* req, uv_file file, int cb);

	int uv_fs_rename_lua(uv_loop_t* loop, uv_fs_t* req, const char* path, const char* new_path, int cb);

	int uv_fs_fsync_lua(uv_loop_t* loop, uv_fs_t* req, uv_file file, int cb);

	int uv_fs_fdatasync_lua(uv_loop_t* loop, uv_fs_t* req, uv_file file, int cb);

	int uv_fs_ftruncate_lua(uv_loop_t* loop, uv_fs_t* req, uv_file file, int64_t offset, int cb);

	int uv_fs_sendfile_lua(uv_loop_t* loop, uv_fs_t* req, uv_file out_fd, uv_file in_fd, int64_t in_offset, size_t length, int cb);

	int uv_fs_chmod_lua(uv_loop_t* loop, uv_fs_t* req, const char* path, int mode, int cb);

	int uv_fs_utime_lua(uv_loop_t* loop, uv_fs_t* req, const char* path, double atime, double mtime, int cb);

	int uv_fs_futime_lua(uv_loop_t* loop, uv_fs_t* req, uv_file file, double atime, double mtime, int cb);

	int uv_fs_lstat_lua(uv_loop_t* loop, uv_fs_t* req, const char* path, int cb);

	int uv_fs_link_lua(uv_loop_t* loop, uv_fs_t* req, const char* path, const char* new_path, int cb);
]]
if (ffi.os == "Windows") then
	ffi.cdef [[
		void uv_preprocess_fs_req(uv_loop_t* loop, uv_fs_t* req);

		int isPoolExAvailable(uv_loop_t* loop);
		void uv_poll(uv_loop_t* loop, int block);
		void uv_poll_ex(uv_loop_t* loop, int block);
	]]
else
end

local uv
if (ffi.os == "Windows") then
	uv = ffi.load("libuv")
else
	uv = ffi.load("uv")
end

return uv