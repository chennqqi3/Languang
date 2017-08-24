#include "./crypt.h"
#include <memory.h>

/***********

关键加密函数

***********/
unsigned char GetByteSumKey( const char * key, unsigned int len_of_key )
{
	unsigned int iIndex = 0;
	unsigned int i32Sum = 0;
	for(iIndex = 0; iIndex < len_of_key; iIndex++)
	{
		i32Sum += key[iIndex];
	}

	i32Sum += len_of_key;
	while(i32Sum > 0xFF)
	{
		i32Sum = (i32Sum >> 8) + (i32Sum & 0xFF);
	}

	return (unsigned char)i32Sum;
}

int Encrypt( unsigned char * pData, unsigned int data_len, const char * key, unsigned int len_of_key )
{
	unsigned int i;
	unsigned char val;
	unsigned char u8KeySum = GetByteSumKey(key, len_of_key);

	for (i = 0; i < data_len; i++)
	{
		val = u8KeySum ^ (*pData);
		*pData = val;
		pData++;
	}
	return 0;
}

/***********

关键解密函数

***********/

int Decrypt( unsigned char * pData, unsigned int data_len, const char * key, unsigned int len_of_key )
{
	unsigned int i;
	unsigned char val;
	unsigned char u8KeySum = GetByteSumKey(key, len_of_key);

	for (i = 0; i < data_len; i++)
	{
		val = u8KeySum ^ (*pData);
		*pData = val;
		pData++;
	}
	return 0;
}