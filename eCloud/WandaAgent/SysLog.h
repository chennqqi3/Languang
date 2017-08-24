/******************************************************************
@file SysLog.h
@brief ϵͳ��־��
@author 
@date 2010-10-21
@note <PRE></PRE>
*******************************************************************/

#ifndef _SYSLOG_H_
#define _SYSLOG_H_

#include "BasicDefine.h"

/// ��־����
enum LogLevel
{
	ERROR_LEVEL = 1,    ///< ���󼶱�
	WARNING_LEVEL = 2,  ///< ���漶��
	INFO_LEVEL = 3,     ///< ��Ϣ����
	DEBUG_LEVEL = 4     ///< ���Լ���
};

//���������ڵ�����־�������к�


/// ϵͳ��־��
class SysLog
{
public:
	/// ���캯��
	SysLog();

	/// ��������
	~SysLog();

	/// ��ʼ����������־�ļ�
	/// @param filename ��־�ļ���·��
	/// @return �򿪳ɹ�����true��·�������ڻ򴴽��ļ�ʧ�ܵ�ʱ�򷵻�false��
	bool OpenLogFile(const char* filename);

	/// ϵͳ���й����У���ӡ��־
	/// @param LogLevel ��־����
	/// @param format ��ʽ���ַ���
	/// @param ... ��̬����
	/// @return ��ӡ��־�Ƿ�ɹ�
	bool PrintLog(int LogLevel, const char* format, ...);
    void Hexdump(int Loglevel, void *pBuff, int buflen, const char *format, ...);

	/// ϵͳ���й����У��л���־�ļ��ӿڡ�����һ���ʱ���ļ��������һ��ġ�
	bool SwitchLogFile();
    

	/// ������־����
	/// @param Loglevel ��־���� \see LogLevel
	bool SetLogLevel(int Loglevel);

	/// ������־����ʹ���ַ���ERROR WARNING INFO DEBUG
	bool SetLogLevel(const char* str);
	
	/// ��ȡ��־����
	int GetLogLevel();

private:
	SysLog(const SysLog& rsh);
	SysLog& operator=(const SysLog& rsh);
//-----------------------------------------------------------------------------
//
    /// ����ļ���С
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
