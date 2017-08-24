///////////////////////////////
// http://mingcn.cnblogs.com //
//  xelz CopyRight (c) 2010  //
///////////////////////////////


#if !defined(AFX_AES_H__6BDD3760_BDE8_4C42_85EE_6F7A434B81C4__INCLUDED_)
#define		 AFX_AES_H__6BDD3760_BDE8_4C42_85EE_6F7A434B81C4__INCLUDED_

#include"stdio.h"

	extern void InitAes();
	extern void SetKeyAes(unsigned char* key);


	/*************************************************
	Function:    加密函数
	Description: 加密数据串
	Input:  input:输入内存缓存,length:加密内存长度,output:输出缓存
	Output:         // 对输出参数的说明。
	Return:         // 函数返回值的说明
	*************************************************/
	extern int EncryptAes(void* input, int length,void* output,int* outLength );

	extern int DecryptAes(void* input, int length, void* output,int* outLength );

 	extern unsigned char* InvCipher(unsigned char* input,unsigned char* output);
	extern unsigned char*  Cipher(unsigned char* input,unsigned char* output);

extern 	unsigned char Sbox[256];
extern 	unsigned char InvSbox[256];
extern 	unsigned char w[11][4][4];

	extern void KeyExpansion(unsigned char* key, unsigned char w[][4][4]);
	extern unsigned char FFmul(unsigned char a, unsigned char b);

	extern void SubBytes(unsigned char state[][4]);
	extern void ShiftRows(unsigned char state[][4]);
	extern void MixColumns(unsigned char state[][4]);
	extern void AddRoundKey(unsigned char state[][4], unsigned char k[][4]);

	extern void InvSubBytes(unsigned char state[][4]);
	extern void InvShiftRows(unsigned char state[][4]);
	extern void InvMixColumns(unsigned char state[][4]);


#endif // !defined(AFX_AES_H__6BDD3760_BDE8_4C42_85EE_6F7A434B81C4__INCLUDED_)
