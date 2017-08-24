
#ifndef __TRSA_H_ 
#define __TRSA_H_

#include<time.h>
#include <string.h>
#include<stdio.h>
#include<stdlib.h>
#ifdef WIN32

#include <WinSock2.h>
#ifndef Q_WS_WIN32
#pragma comment(lib,"ws2_32.lib")
#endif

#endif

typedef struct  RSA_PARAM_Tag
{
    unsigned long long    p, q;   //两个素数，不参与加密解密运算
    unsigned long long    f;      //f=(p-1)*(q-1)，不参与加密解密运算
    unsigned long long    n, e;   //公匙，n=p*q，gcd(e,f)=1
    unsigned long long    d;      //私匙，e*d=1 (mod f)，gcd(n,d)=1
} RSA_PARAM;//小素数表
const static long    g_PrimeTable[]=
{
	3,
	5,
	7,
	11,
	13,
	17,
	19,
	23,
	29,
	31,
	37,
	41,
	43,
	47,
	53,
	59,
	61,
	67,
	71,
	73,
	79,
	83,
	89,
	97
};
const static long       g_PrimeCount=sizeof(g_PrimeTable) / sizeof(long);
extern   unsigned long long  multiplier;
extern   unsigned long long  adder ;//随机数类
extern unsigned long long    randSeed;/* */
extern RSA_PARAM m_oKey;//钥匙
extern char m_strAesKey[17];
extern char m_strRsaPathFile[200];
//const unsigned long long  multiplier=1274729382;//12747293821;
//const unsigned long long  adder=2274729382;//随机数类
extern  unsigned long long  htonl64e(unsigned long long  host) ;
extern unsigned long long  ntohl64e(unsigned long long   host) ;

/*
模乘运算，返回值 x=a*b mod n
*/
extern unsigned long long MulMod(unsigned long long a, unsigned long long b, unsigned long long *n);
/*
模幂运算，返回值 x=base^pow mod n
*/
extern unsigned long long PowMod(unsigned long long base, unsigned long long pow, unsigned long long *n);
/*
Rabin-Miller素数测试，通过测试返回1，否则返回0。
n是待测素数。*/
extern long RabinMillerKnl(unsigned long long *n);
/*
Rabin-Miller素数测试，循环调用核心loop次
全部通过返回1，否则返回0
*/
extern long RabinMiller(unsigned long long *n, long loop);
/*
随机生成一个bits位(二进制位)的素数，最多32位
*/
extern unsigned long long RandomPrime(char bits);
/*
欧几里得法求最大公约数
*/
extern unsigned long long EuclidGcd(unsigned long long *p, unsigned long long *q);
/*
Stein法求最大公约数
*/
extern unsigned long long SteinGcd(unsigned long long *p, unsigned long long *q);
/*
已知a、b，求x，满足a*x =1 (mod b)
相当于求解a*x-b*y=1的最小整数解
*/
extern unsigned long long Euclid(unsigned long long *a, unsigned long long *b);
/*
随机产生一个RSA加密参数
*/
extern RSA_PARAM RsaGetParam(void);

//随机数生产
extern unsigned long long  Random(unsigned long long n);

//生成钥匙对, 0success <0 fail
extern int CreateKey();
extern RSA_PARAM GetKey();
//保存公钥文件
extern int SavePublicKeyFile(char* path);
//保存私钥文件
extern int SavePrivateKeyFile(char* path);
//加载公钥匙 0success <0 fail
extern int LoadPublicKeyFile(char* path);
//加载私钥匙 0success <0 fail
extern int LoadPrivateKeyFile(char* path);

//保存加密数据到文件
extern int SaveDataFile(char* path,char* pData,int nLen);
//读取加密的文件到缓存
extern int LoadDataFile(char* path,char* pData );
extern char * RandStr();//获取固定16ge字符数字串
extern char * GetAesKey();

extern int EncryptRsa(unsigned char* pInput,int iInputLen,unsigned char* pOut,int *pOutLen);

//解密数据
extern int DecryptRsa(unsigned char* pInput,int iInputLen,unsigned char* pOut,int *pOutLen);



extern void InitRsa(void);
 
#endif
