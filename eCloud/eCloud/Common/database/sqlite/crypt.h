#ifndef DCG_SQLITE_CRYPT_FUNC_

#define DCG_SQLITE_CRYPT_FUNC_

/**************************************************************************************************************************************************

������д��SQLITE���ܹؼ�������

**************************************************************************************************************************************************/

/***********

�ؼ����ܺ���

***********/

int Encrypt( unsigned char * pData, unsigned int data_len, const char * key, unsigned int len_of_key );

/***********

�ؼ����ܺ���

***********/

int Decrypt( unsigned char * pData, unsigned int data_len, const char * key, unsigned int len_of_key );

#endif