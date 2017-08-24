/*
 * logger.h
 *
 *  Created on: 2010-12-1
 *      Author: xzw
 */

#ifndef LOGGER_H_
#define LOGGER_H_

#include <stdio.h>
#include <stdarg.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#if defined(WIN32) || defined(_WIN32)
# include <windows.h>
#elif defined(LINUX) || defined(_LINUX)

#endif

#ifdef __cplusplus
extern "C"
{
#endif

	void logger_setLogPath(const char* str);

void logger_init();
	
void logger_log(const char* str, ...);

void logger_set2trace();

void logger_set2debug();

void logger_set2info();

void logger_set2warn();

void logger_set2error();

void logger_set2fault();

int logger_istrace();

int logger_isdebug();

int logger_isinfo();

int logger_iswarn();

int logger_iserror();

int logger_isfault();

void logger_yyyy_mm_dd_hh_now(char *buff);

void logger_yyyy_mm_dd_hh_mi_ss_now(char *buff);

void logger_yyyy_mm_dd_hh_mi_ss(char *buff, time_t* time);

void logger_yyyy_mm_dd_now(char *buff);

void logger_yyyymm(char *buff);

void logger_hhmiss(char *buff);

char* logger_hhmissuse();
	
#ifdef __cplusplus
}
#endif

#define LOGGER_TRACE(format, ...)	\
if(logger_istrace() == 0)		\
	logger_log("%s [TRAC](%s %d) " format"", logger_hhmissuse(), __FUNCTION__, __LINE__,  ##__VA_ARGS__);

#define LOGGER_DEBUG(format, ...) 	\
if(logger_isdebug() == 0)	\
	logger_log("%s [DEBU](%s %d) " format"", logger_hhmissuse(), __FUNCTION__, __LINE__,  ##__VA_ARGS__);

#define LOGGER_INFO(format, ...) 	\
if(logger_isinfo() == 0)	\
	logger_log("%s [INFO](%s %d) " format"", logger_hhmissuse(), __FUNCTION__, __LINE__,  ##__VA_ARGS__);

#define LOGGER_WARN(format, ...)	\
if(logger_iswarn() == 0)	\
	logger_log("%s [WARN](%s %d) " format"", logger_hhmissuse(), __FUNCTION__, __LINE__,  ##__VA_ARGS__);

#define LOGGER_ERROR(format, ...)	\
if(logger_iserror() == 0)	\
	logger_log("%s [ERRO](%s %d) " format"", logger_hhmissuse(), __FUNCTION__, __LINE__,  ##__VA_ARGS__);

#define LOGGER_FAULT(format, ...)	\
if(logger_isfault() == 0)	\
	logger_log("%s [FAUL](%s %d) " format"", logger_hhmissuse(), __FUNCTION__, __LINE__,  ##__VA_ARGS__);
	

#endif /* LOGGER_H_ */
