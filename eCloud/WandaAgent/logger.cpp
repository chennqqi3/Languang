/*
 * logger.c
 *
 *  Created on: 2010-12-1
 *      Author: xzw
 */

#include "logger.h"

//#define LOG_PATH 											"./log/"
#define MAX_LOGFILE_SIZE									1024 * 1024 //* 2000		//~=2G.
enum
{
	LOG_LEVEL_TRACE = 0x00, LOG_LEVEL_DEBUG, LOG_LEVEL_INFO, LOG_LEVEL_WARN, LOG_LEVEL_ERROR, LOG_LEVEL_FAULT
};
static int logger_ppid = 0xFFFF;
static int logger_level = LOG_LEVEL_DEBUG;//LOG_LEVEL_ERROR;
static FILE* logger_fd();
static void logger_setlevel(int le);

char *logFilePath = new char[200];

void logger_setLogPath(const char* str)
{
	sprintf(logFilePath,"%s",str);
}

/*--------------------------------------------------------------------*/
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
void logger_init()
{
#ifdef LINUX
	sleep(1);
	logger_ppid = getppid();
#endif
}

void logger_log(const char* str, ...)
{
	FILE* fd = logger_fd();
	if (fd != NULL)
	{
		va_list args;
		va_start(args, str);
		vfprintf(fd, str, args);
		va_end(args);
		fclose(fd);
	}else
	{
#ifdef WIN32
		char buff[0x2000] = { 0 };
		va_list args;
		va_start(args, str);
		vsnprintf(buff, 0x2000, str, args);
		va_end(args);
		OutputDebugStringA(buff);
#endif
	}
	if (logger_ppid != 1)
	{
		va_list args;
		va_start(args, str);
		vfprintf(stdout, str, args);
		va_end(args);
	}
}

FILE* logger_fd()
{
//	char yymmdd[0x10] = { 0 };
//	logger_yyyy_mm_dd_now(yymmdd);
	char logfilename[200] = { 0 };
	sprintf(logfilename, "%s", logFilePath);
	struct stat filestat;
	if (stat(logfilename, &filestat) != -1)
	{
		if (filestat.st_size > MAX_LOGFILE_SIZE)
		{
			char newlogfilename[0x20] = { 0 };
			sprintf(newlogfilename, "%s.bak", logfilename);
			remove(newlogfilename);
			rename(logfilename, newlogfilename);
		}
	}
	FILE *fp;
	if ((fp = fopen(logfilename, "a+")) == NULL)
		return NULL;
	return fp;
}

void logger_set2trace()
{
	logger_setlevel(LOG_LEVEL_TRACE);
}

void logger_set2debug()
{
	logger_setlevel(LOG_LEVEL_DEBUG);
}

void logger_set2info()
{
	logger_setlevel(LOG_LEVEL_INFO);
}

void logger_set2warn()
{
	logger_setlevel(LOG_LEVEL_WARN);
}

void logger_set2error()
{
	logger_setlevel(LOG_LEVEL_ERROR);
}

void logger_set2fault()
{
	logger_setlevel(LOG_LEVEL_FAULT);
}

void logger_setlevel(int le)
{
	if (le <= LOG_LEVEL_ERROR && le >= LOG_LEVEL_TRACE)
		logger_level = le;
}

/*--------------------------------------------------------------------*/
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
int logger_istrace()
{
	return (logger_level <= LOG_LEVEL_TRACE) ? 0 : 1;
}

int logger_isdebug()
{
	return (logger_level <= LOG_LEVEL_DEBUG) ? 0 : 1;
}

int logger_isinfo()
{
	return (logger_level <= LOG_LEVEL_INFO) ? 0 : 1;
}

int logger_iswarn()
{
	return (logger_level <= LOG_LEVEL_WARN) ? 0 : 1;
}

int logger_iserror()
{
	return (logger_level <= LOG_LEVEL_ERROR) ? 0 : 1;
}

int logger_isfault()
{
	return (logger_level <= LOG_LEVEL_FAULT) ? 0 : 1;
}

/*--------------------------------------------------------------------*/
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
/**yyyy-mm-dd hh*/
void logger_yyyy_mm_dd_hh_now(char *buff)
{
	time_t now;
	time(&now);
	struct tm *t = localtime(&now);
	sprintf(buff, "%04d-%02d-%02d-%02d", t->tm_year + 1900, t->tm_mon + 1, t->tm_mday, t->tm_hour);
}

/**yyyy-mm-dd hh:mi:ss*/
void logger_yyyy_mm_dd_hh_mi_ss_now(char *buff)
{
	time_t now;
	time(&now);
	struct tm *t = localtime(&now);
	sprintf(buff, "%04d-%02d-%02d %02d:%02d:%02d", t->tm_year + 1900, t->tm_mon + 1, t->tm_mday, t->tm_hour, t->tm_min, t->tm_sec);
}

void logger_yyyy_mm_dd_hh_mi_ss(char *buff, time_t* time)
{
	struct tm *t = localtime(time);
	sprintf(buff, "%04d-%02d-%02d %02d:%02d:%02d", t->tm_year + 1900, t->tm_mon + 1, t->tm_mday, t->tm_hour, t->tm_min, t->tm_sec);
}

/**yyyy-mm-dd*/
void logger_yyyy_mm_dd_now(char *buff)
{
	time_t now;
	time(&now);
	struct tm *t = localtime(&now);
	sprintf(buff, "%04d-%02d-%02d", t->tm_year + 1900, t->tm_mon + 1, t->tm_mday);
}

/**yyyymm*/
void logger_yyyymm(char *buff)
{
	time_t now;
	time(&now);
	struct tm *t = localtime(&now);
	sprintf(buff, "%04d%02d", t->tm_year + 1900, t->tm_mon + 1);
}

/**last month.*/
void logger_yyyymm_lm(char *buff)
{
	time_t now;
	time(&now);
	struct tm *t = localtime(&now);
	int y = t->tm_year + 1900;
	int m = t->tm_mon + 1;
	if (m > 1)
		m -= 1;
	else
	{
		y -= 1;
		m = 12;
	}
	sprintf(buff, "%04d%02d", y, m);
}

/**hh:mi:ss*/
void logger_hhmiss(char *buff)
{
	time_t now;
	time(&now);
	struct tm *t = localtime(&now);
	strftime(buff, 0x10, "%X", t);
}

/**hh:mi:ss.use*/
char* logger_hhmissuse()
{
	static char buff[0x0D];
#if defined(WIN32) || defined(_WIN32)
	SYSTEMTIME t;
	GetLocalTime(&t);
	sprintf(buff, "%02d:%02d:%02d.%03d", t.wHour, t.wMinute, t.wSecond, t.wMilliseconds);
#else
	struct timeval tv;
	gettimeofday(&tv, NULL);
	struct tm *t = localtime((time_t*) &(tv.tv_sec));
	sprintf(buff, "%02d:%02d:%02d.%03d", t->tm_hour, t->tm_min, t->tm_sec, (int) (tv.tv_usec / 1000));
#endif
	return buff;
}
