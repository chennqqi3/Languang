/******************************************************************
@file SysLog.h
@brief 系统日志类
@author 
@date 2010-10-21
@note <PRE></PRE>
*******************************************************************/

#ifndef _SYSLOG_H_
#define _SYSLOG_H_

#include "BasicDefine.h"

/// 日志级别
enum LogLevel
{
	ERROR_LEVEL = 1,    ///< 错误级别
	WARNING_LEVEL = 2,  ///< 警告级别
	INFO_LEVEL = 3,     ///< 信息级别
	DEBUG_LEVEL = 4     ///< 调试级别
};

//这个宏可以在调试日志中增加行号


/// 系统日志类
class SysLog
{
public:
	/// 构造函数
	SysLog();

	/// 析构函数
	~SysLog();

	/// 初始化，创建日志文件
	/// @param filename 日志文件的路径
	/// @return 打开成功返回true。路径不存在或创建文件失败的时候返回false。
	bool OpenLogFile(const char* filename);

	/// 系统运行过程中，打印日志
	/// @param LogLevel 日志级别
	/// @param format 格式化字符串
	/// @param ... 动态参数
	/// @return 打印日志是否成功
	bool PrintLog(int LogLevel, const char* format, ...);
    void Hexdump(int Loglevel, void *pBuff, int buflen, const char *format, ...);

	/// 系统运行过程中，切换日志文件接口。到下一天的时候，文件名变成下一天的。
	bool SwitchLogFile();
    

	/// 设置日志级别
	/// @param Loglevel 日志级别 \see LogLevel
	bool SetLogLevel(int Loglevel);

	/// 设置日志级别，使用字符串ERROR WARNING INFO DEBUG
	bool SetLogLevel(const char* str);
	
	/// 获取日志级别
	int GetLogLevel();

private:
	SysLog(const SysLog& rsh);
	SysLog& operator=(const SysLog& rsh);
//-----------------------------------------------------------------------------
//
    /// 检查文件大小
    bool CheckMaxSize();

private:
	FILE* m_Logfp;
	char  m_FileName[256];
	int   m_LogLevel;
	pthread_mutex_t m_LogLocker;
	int m_DayOfYear;

    bool  m_fConsolePrint;

    int   m_nMaxFileSize;
    int   m_nFileSerial;
};

#endif
