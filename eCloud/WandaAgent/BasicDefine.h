// BasicDefine.h
//
//////////////////////////////////////////////////////////////////////
#ifndef __BASICDEFINE_H__
#define __BASICDEFINE_H__
//////////////////////////////////////////////////////////////////////
//变量前缀:
//    b : 布尔型        c : 字符型        s : 字符串数组     p : 指针
//    i : 整型(2)       l : 整型(4)       f : 浮点型(4)      d : 浮点型(8)
//    t : 结构体实例    o : 类实例
//////////////////////////////////////////////////////////////////////
//数据类型前缀:
//    T : 结构体        C : 类
//////////////////////////////////////////////////////////////////////
// 平台定义
// _SXPLAT_SOLARIS_
// _SXPLAT_WINDOWS_
// _SXPLAT_REDHAT_
// _SXPLAT_AIX_

//////////////////////////////////////////////////////////////////////

// IN means an input parameter; OUT is an output parameter
// IN OUT is both input and output parameter
// OPTIONAL means, that value is not required - a default will be used instead
#ifndef        IN
#define        IN
#endif
#ifndef        OUT
#define        OUT
#endif
#ifndef        OPTIONAL
#define        OPTIONAL
#endif

//////////////////////////////////////////////////////////////////////

//32位
#define  ADDRNUM              UINT32
#define  ADDRLEN                   4

//64位
//#define  ADDRNUM              UINT64
//#define  ADDRLEN                   8

 
//////////////////////////////////////////////////////////////////////
#ifndef WIN32                 //unix/linux platform
//////////////////////////////////////////////////////////////////////
#include <arpa/inet.h>
#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <netdb.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <stdio.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include <stdarg.h>
#include <semaphore.h>
#include <signal.h>
//#include <sys/io.h>
#include <sys/socket.h>
#include <sys/stat.h>                            //mkdir
#include <sys/time.h>
#include <sys/timeb.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/sem.h>
//#include <stropts.h>
#include <time.h>
#include <unistd.h>
#include <iconv.h>
#include <dlfcn.h>                               //dlopen
#include "Errors.h"

typedef  int HRESULT;

#ifndef  INT8
#define  INT8                                    char
#endif
#ifndef  INT16
#define  INT16                                   short int
#endif
#ifndef  INT32
#define  INT32                                   int
#endif
#ifndef  INT64
#define  INT64                                   long long
#endif

#ifndef  UINT8
#define  UINT8                                   unsigned char
#endif
#ifndef  UINT16
#define  UINT16                                  unsigned short int
#endif
#ifndef  UINT32
#define  UINT32                                  unsigned int
#endif
#ifndef  UINT64
#define  UINT64                                  unsigned long long
#endif

#ifndef  PASCAL
#define  PASCAL
#endif

#define  BOOL                                    bool
#define  TRUE                                    1
#define  FALSE                                   0

#define  SOCKET                                  int
#define  SOCKET_RETURN_ERROR                     -1

#define  MYTYPE_THREAD_FUNC                      void*

#define  PATH_TAG                                '/'

#define  TRACE                                   printf

#define  HMODULE                                 void*

#define WSAGetLastError()                        errno
//#define CLOSE_(s) (s > 0 ? close(s) : s)
#define	 CLOSE_(s)			{ if (s > 0) { close(s); s = 0;} }

//////////////////////////////////////////////////////////////////////
#else                       //windows platform
//////////////////////////////////////////////////////////////////////
#ifndef Q_WS_WIN32
#pragma warning(disable:4996 )
#pragma warning(disable:4083 )
#pragma warning(disable:4819 )

#endif

#include <stdio.h>
#include <iostream>
//#include <ostream>
//#include <string>
#include <stdlib.h>
#include <ctype.h>
#include <direct.h>
#include <fcntl.h>
#include <io.h>
#include <process.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/timeb.h>
#include <winsock2.h>
#include <WS2tcpip.h>
#include <errno.h>
#include "Errors.h"

#ifndef  INT8
#define  INT8                                    char
#endif
#ifndef  INT16
#define  INT16                                   short int
#endif
#ifndef  INT32
#define  INT32                                   int
#endif
#ifndef  INT64
#define  INT64                                   LONGLONG
#endif

#ifndef  UINT
#define  UINT                                    unsigned int
#endif
#ifndef  UINT8
#define  UINT8                                   unsigned char
#endif
#ifndef  UINT16
#define  UINT16                                  unsigned short int
#endif
#ifndef  UINT32
#define  UINT32                                  unsigned int
#endif
#ifndef  UINT64
#define  UINT64                                  ULONGLONG
#endif

#define  PATH_TAG                                '\\'

#define  pthread_mutex_t                         CRITICAL_SECTION
#define  pthread_mutex_init(T,P2)                InitializeCriticalSection(T)
#define  pthread_mutex_destroy(T)                DeleteCriticalSection(T)
#define  pthread_mutex_lock(T)                   EnterCriticalSection(T)
#define  pthread_mutex_unlock(T)                 LeaveCriticalSection(T)

#define  sem_t                                   HANDLE
#define  sem_init(pT,P2,P3)                      ( *(pT)= CreateSemaphore(NULL,0,1000000,NULL) )
#define  sem_destroy(pT)                         CloseHandle(*(pT))
#define  sem_wait(pT)                            WaitForSingleObject(*(pT), INFINITE)
#define  sem_post(pT)                            ReleaseSemaphore(*(pT), 1, NULL)

#define  pthread_cond_t                          HANDLE
#define  pthread_cond_init(pT,P2)                ( *(pT)= CreateSemaphore(NULL,0,1000000,NULL) )
#define  pthread_cond_destroy(pT)                CloseHandle(*(pT))
#define  pthread_cond_signal(pT)                 ReleaseSemaphore(*(pT), 1, NULL)
#define  pthread_cond_broadcast(pT)              ReleaseSemaphore(*(pT), 1000000, NULL)
#define  pthread_cond_wait(pT,P2)                WaitForSingleObject(*(pT), INFINITE)
#define  pthread_cond_timedwait(pT,P2,P3)        WaitForSingleObject(*(pT), P3)


#define  MYTYPE_THREAD_FUNC                      DWORD WINAPI      //线程返回类型
#define  pthread_t                               HANDLE
#define  pthread_create( pid, attr, hfunc, arg ) do{ HANDLE h = ::CreateThread( NULL, 0, hfunc, (void*)arg, 0, NULL ); CloseHandle(h); }while(0)    //返回0表示成功

#define  pthread_self                            GetCurrentThreadId
#define  pthread_detach(a)                       -10001

//#define  sleep(a)                                Sleep(a*1000)
//#define  close(s)                                closesocket(s)

#define  SHUT_RDWR                               2

#ifdef EWOULDBLOCK
#  undef   EWOULDBLOCK
#endif
#define  EWOULDBLOCK                             WSAEWOULDBLOCK//10035

#ifdef ENOBUFS
#  undef ENOBUFS
#endif
#define  ENOBUFS                                 WSAENOBUFS//10055

#ifndef  EAGAIN
//#define  EAGAIN                                  WSATRY_AGAIN//11002
#define  EAGAIN                                  EWOULDBLOCK
#endif
#define  F_OK                                    0


#define  snprintf                                _snprintf

#ifndef  ENOENT
#define  ENOENT                                  2
#endif
#define  vsnprintf( buffer, len, format, argptr )   \
                                                 vsprintf( buffer, format, argptr )
#ifndef strcasecmp
#define  strcasecmp(P1,P2)                       stricmp(P1,P2)
#endif

#ifndef strncasecmp
#define  strncasecmp(P1,P2,n)                    strnicmp(P1,P2,n)
#endif

#define  bzero(pMemory, MemoryLen)               memset(pMemory, 0, MemoryLen)

#define  dlopen(pathname, mode)                  LoadLibrary(pathname)
#define  dlsym(handle, name)                     GetProcAddress(handle, name)
#define  dlclose(handle)                         FreeLibrary(handle)
#define  dlerror()                              "Please use GetLastError"

#ifndef localtime_r
#define  localtime_r( pTime, pTm )               memcpy( pTm, localtime(pTime), sizeof(struct tm) )
#endif

#define	 CLOSE_(s)			{ if ((s) != INVALID_SOCKET && (s) != 0) { closesocket(s); (s) = INVALID_SOCKET; } }

#define	 SOCKET_RETURN_ERROR	INVALID_SOCKET
//#define  TRACE                                   printf
//////////////////////////////////////////////////////////////////////
#endif    //windows platform

#ifdef WIN32
#ifdef CLIENT_EXPORTS
#define IM_API(RET) _declspec(dllexport) RET __stdcall
#elif CLIENT_IMPORTS
#define IM_API(RET) _declspec(dllimport) RET __stdcall
#else
#define IM_API(RET) RET __stdcall
#endif
#else

#ifdef CLIENT_EXPORTS
#define IM_API _declspec(dllexport)
#elif CLIENT_IMPORTS
#define IM_API _declspec(dllimport)
#else
#define IM_API
#endif
#endif

/*
#define EIMERR_SUCCESS 0 
#define EIMERR_RECV_TIMEOUT_SOCKET 1
#define EIMERR_SOCKETFD_SOCKET -100
#define EIMERR_RECVDATA_TOOBIG_SOCKET -101
#define EIMERR_RSAKEY_SOCKET -102
#define EIMERR_OPENRSAFILE_SOCKET -103 //open 公钥文件失败
#define EIMERR_RECVSOCKET_SOCKET -104 //recv 返回错误
#define EIMERR_SOCKETCLOSE_SOCKET -105 //socket 关闭 
#define SENDSOCKET_EWOULDBLOCK_ERR_SOCKET -106  //send socket 错误
#define EIMERR_SENDSOCKET_SOCKET -107  //send socket again 错误
#define EIMERR_RECV_TIMEOUT_SOCKET -108  //recv socket 超时
#define EIMERR_CONNCB_SOCKET -109  //ConnCB error
#define EIMERR_GETHOSTNAME_SOCKET -110  //ConnCB error
#define CONNECT_TIMEOUT_ERR_SOCKET -111  //Conn access manager service timeout error
#define EIMERR_SOCKET_GETOPT_SOCKET -112  //getsockopt error
#define EIMERR_SOCKET_OTHERS_ERR -113 //socket 其他错误
#define EIMERR_GETHOSTNAME_SERVICE_SOCKET -114  //Conn timeout error
#define EIMERR_CONNECT_SERVICE_TIMEOUT_SOCKET -115 //connect 接入service  超时
#define EIMERR_RECV_DATA_SOCKET     -116//recv exception


//业务层
#define ACCESS_MANAGER_FAIL -150
#define ACCESS_MANAGER_FAIL_ERR  -151 //接入管理错误
#define ACCESS_MANAGER_OVERLOAD_ERR -152 //接入管理过载保护
#define ACCESS_MANAGER_BLACKUSER_ERR  -153 //接入管理黑名单 


#define EIMERR_ALIVE_NO_CONNECT -170 //无连接
#define EIMERR_ALIVE_NO_LOGIN -171 //无login

#define EIMERR_INVALID_PARAMTER -180 //函数参数错误
#define EIMERR_FUNCTION_PARAM_MAXVALUE_ERR -181 //函数参数超过最大值
*/

#endif    //ifndef __BASICDEFINE_H__
//////////////////////////////////////////////////////////////////////
