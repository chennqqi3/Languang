/******************************************************************
@file SysLog.cpp
@brief ϵͳ��־��
@author 
@date 2010-10-21
@note <PRE></PRE>
*******************************************************************/

#include "SysLog.h"
#include <assert.h>
#include <ctype.h>
#include <fcntl.h>

const char* LOG_LEVEL_STR[] = 
{
	"ERROR",
	"WARNING",
	"INFO",
	"DEBUG"
};

SysLog::SysLog() :
	m_Logfp(NULL),
	m_LogLevel(INFO_LEVEL),
	m_DayOfYear(0)
{
    m_fConsolePrint = true;
	pthread_mutex_init(&m_LogLocker,NULL);
	m_FileName[0] = '\0';	
    m_nMaxFileSize = 512000000;
    m_nFileSerial = 0;
}

SysLog::~SysLog()
{
	if (NULL!=m_Logfp)
	{
		fclose(m_Logfp);
		pthread_mutex_destroy(&m_LogLocker);
		m_Logfp = NULL;
	}
}

bool SysLog::OpenLogFile(const char * filename)
{
	assert(NULL != filename);

	if (NULL == filename)
	{
		return false;
	}

	if (NULL != m_Logfp)
	{
		return false;
	}

	time_t now = time(NULL);
	struct tm* t = localtime(&now);
	char str[20];
	strftime(str, sizeof(str), "%Y-%m-%d.log", t);
	str[ sizeof(str)-1 ] = '\0';

	char temp[500];
	snprintf(temp, sizeof(temp)-1, "%s%s", filename, str);
	temp[ sizeof(temp)-1 ] = '\0';

	pthread_mutex_lock(&m_LogLocker);
	m_Logfp = fopen(temp, "a");
	if (NULL==m_Logfp)
	{
		pthread_mutex_unlock(&m_LogLocker);
		return false;
	}
	strncpy(m_FileName, filename, sizeof(m_FileName)-1);
	m_FileName[ sizeof(m_FileName)-1 ] = '\0';
	m_DayOfYear = t->tm_yday;
	pthread_mutex_unlock(&m_LogLocker);
	return true;	 	
}

bool SysLog::PrintLog(int LogLevel, const char * format, ...)
{
	if (LogLevel<ERROR_LEVEL || LogLevel>DEBUG_LEVEL)
	{
		return false;
	}

	if (NULL == m_Logfp)
	{
		if (!SwitchLogFile())
		{
			return false;
		}
	}

	if (LogLevel>m_LogLevel)
	{
		return false;
	}

	time_t now = time(NULL);
	struct tm* t = localtime(&now);
	if (m_DayOfYear != t->tm_yday)
	{
        m_nFileSerial = 0;

		if (!SwitchLogFile())
		{
			return false;
		}
	}

    CheckMaxSize();

	char str[20];
	strftime(str, sizeof(str), "%Y-%m-%d %H:%M:%S", t);
	str[ sizeof(str)-1 ] = '\0';

	pthread_mutex_lock(&m_LogLocker);
	assert(NULL!=m_Logfp);
	fprintf(m_Logfp, "%s %s ", str, LOG_LEVEL_STR[LogLevel-1]);
	va_list args;
	va_start(args, format);
	vfprintf(m_Logfp, format, args);

    if (m_fConsolePrint)
    {
        printf("%s %s ", str, LOG_LEVEL_STR[LogLevel-1]);
        vprintf(format, args);
        printf("\n");
    }

	va_end(args);
	fprintf(m_Logfp, "\n");
	fflush(m_Logfp);
	pthread_mutex_unlock(&m_LogLocker);
	return true;
}

void SysLog::Hexdump(int LogLevel, void *pBuff, int buflen, const char *format, ...)
{
    unsigned char *buf = (unsigned char*)pBuff;
    int i, j;
	
	if (NULL == m_Logfp)
	{
		if (!SwitchLogFile())
		{
			return;
		}
	}

	if (LogLevel>m_LogLevel)
	{
		return;
	}

	time_t now = time(NULL);
	struct tm* t = localtime(&now);
	if (m_DayOfYear != t->tm_yday)
	{
		if (!SwitchLogFile())
		{
			return;
		}
	}

    CheckMaxSize();

	char str[20];
	strftime(str, sizeof(str), "%Y-%m-%d %H:%M:%S", t);
	str[ sizeof(str)-1 ] = '\0';

    pthread_mutex_lock(&m_LogLocker);
  
    assert(NULL!=m_Logfp);
	fprintf(m_Logfp, "%s %s ", str, LOG_LEVEL_STR[LogLevel-1]);
    va_list args;
	va_start(args, format);
	vfprintf(m_Logfp, format, args);
	va_end(args);
	fprintf(m_Logfp, "\n");
             
    for (i=0; i<buflen; i+=16)
    {
        fprintf(m_Logfp, "%06x: ", i);

        for (j=0; j<16; j++)
        {
            if (j == 8)
                fprintf(m_Logfp, " ");

            if (i+j < buflen)
                fprintf(m_Logfp, "%02x ", buf[i+j]);
            else
                fprintf(m_Logfp, "   ");
        }

        fprintf(m_Logfp, " ");

        for (j=0; j<16; j++)
        {
            if (j == 8)
                fprintf(m_Logfp, " ");

            if (i+j < buflen)
                fprintf(m_Logfp, "%c", isprint(buf[i+j]) ? buf[i+j] : '.');
        }

        fprintf(m_Logfp, "\n");
    }
	
    fflush(m_Logfp);

    pthread_mutex_unlock(&m_LogLocker);
} 

bool SysLog::SwitchLogFile()
{
	pthread_mutex_lock(&m_LogLocker);
	if (NULL!=m_Logfp)
	{
		fclose(m_Logfp);
		m_Logfp = NULL;
	}
	time_t now = time(NULL);
	struct tm* t = localtime(&now);
	char str[20];
	strftime(str, sizeof(str), "%Y-%m-%d.log", t);
	str[ sizeof(str)-1 ] = '\0';

	char temp[120];
	snprintf(temp, sizeof(temp)-1, "%s%s", m_FileName, str);
	temp[ sizeof(temp)-1 ] = '\0';

	m_Logfp = fopen(temp, "a");
	if (NULL==m_Logfp)
	{
		pthread_mutex_unlock(&m_LogLocker);
		return false;
	}
	m_DayOfYear = t->tm_yday;
	pthread_mutex_unlock(&m_LogLocker);
	return true;	 	
}


bool SysLog::SetLogLevel(int Loglevel)
{
	if (Loglevel<ERROR_LEVEL || Loglevel>DEBUG_LEVEL)
	{
		return false;
	}
	m_LogLevel = Loglevel;
	return true;
}
		
int SysLog::GetLogLevel()
{
	return m_LogLevel;	
}

bool SysLog::SetLogLevel(const char* str)
{
	const int COUNT = 4;
	for (int i=0; i<COUNT; i++)
	{
		if (0==strcmp(str, LOG_LEVEL_STR[i]))
		{
			m_LogLevel = i+1;
			return true;
		}
	}
	return false;
}

bool SysLog::CheckMaxSize()
{
    struct stat info;
    memset(&info, 0, sizeof(struct stat));
	
    pthread_mutex_lock(&m_LogLocker);

    if(fileno(m_Logfp) > 0)
        fstat(fileno(m_Logfp), &info);

    if (info.st_size >= m_nMaxFileSize)
    {
        fflush(m_Logfp);
        fclose(m_Logfp);
        m_Logfp = NULL;

        time_t now = time(NULL);
        struct tm* t = localtime(&now);
        char str[20];
        strftime(str, sizeof(str), "%Y-%m-%d.log", t);
        str[ sizeof(str)-1 ] = '\0';

        char temp[256];
        snprintf(temp, sizeof(temp)-1, "%s%s", m_FileName, str);
        temp[ sizeof(temp)-1 ] = '\0';

        char aszNewFileName[256] = {0};
        sprintf(aszNewFileName, "%s_%d", temp, ++m_nFileSerial);

        // �������ļ�����ɾ��
        remove(aszNewFileName);

        // ����ǰ�ļ�����
        rename(temp, aszNewFileName);

        // �����ļ������ļ�
        FILE *pLogfp = fopen(temp, "a");
        if (NULL == pLogfp)
        {
            // error
            pthread_mutex_unlock(&m_LogLocker);
            return false;
        }

		m_Logfp = pLogfp;
    }
	
    pthread_mutex_unlock(&m_LogLocker);

    return true;
}
