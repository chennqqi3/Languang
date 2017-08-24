#ifndef DCG_SQLITE_CRYPT_FUNC_

#define DCG_SQLITE_CRYPT_FUNC_

/**************************************************************************************************************************************************

董淳光写的SQLITE加密关键函数库

**************************************************************************************************************************************************/

/***********

关键加密函数

***********/

int Encrypt( unsigned char * pData, unsigned int data_len, const char * key, unsigned int len_of_key );

/***********

关键解密函数

***********/

int Decrypt( unsigned char * pData, unsigned int data_len, const char * key, unsigned int len_of_key );

#endif