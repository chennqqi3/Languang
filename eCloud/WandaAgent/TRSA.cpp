
#include "TRSA.h"
 
  unsigned long long  multiplier=12747293821;
  unsigned long long  adder=1343545677842234541;//随机数类
unsigned long long    randSeed;/* */
RSA_PARAM m_oKey;//钥匙
char m_strAesKey[17];
char m_strRsaPathFile[200];
	void InitRsa(void)
	{
		randSeed= (unsigned long long)time(NULL);
		memset(m_strAesKey,0, sizeof(m_strAesKey));
		RandStr();
	}

	//生成钥匙对文件,rsa_private.key rsa_public.key  0success <0 fail
	int  CreateKey()
	{
		m_oKey = RsaGetParam();
		return 0;
	}
char * GetAesKey(){return m_strAesKey;}

 RSA_PARAM GetKey() {return m_oKey;}
 //生成公钥文件
int  SavePublicKeyFile(char* path)
{
	FILE* fp = fopen(path,"w");
	if(!fp)
		return -1;
     char szKey[50]="";

	sprintf(szKey,"%010lld",m_oKey.n);
	fwrite(szKey,1,strlen(szKey),fp);
	sprintf(szKey,"%010lld",m_oKey.e);
	fwrite(szKey,1,strlen(szKey),fp);
	fclose(fp);
	return 0;
}

//生成私钥文件
int  SavePrivateKeyFile(char* path)
{
	FILE* fp = fopen(path,"w");
	if(!fp)
		return -1;
 char szKey[50]="";
	sprintf(szKey,"%010lld",m_oKey.n);
	fwrite(szKey,1,strlen(szKey),fp);
	sprintf(szKey,"%010lld",m_oKey.d);
	fwrite(szKey,1,strlen(szKey),fp);

	fclose(fp);
	return 0;
}


int  LoadPublicKeyFile(char* path)
{
	FILE* fp = fopen(path,"r");
	if(!fp)
	{
		return -1;
	}
	m_oKey.n = 0;
	m_oKey.e =0;
	 char szKey[50]="";
	fread(szKey,1,10, fp);
	m_oKey.n = atol(szKey);
	fread(szKey,1,10, fp);
	 m_oKey.e = atol(szKey);
	fclose(fp);
	return 0;
}

//加载私钥匙 0success <0 fail
int  LoadPrivateKeyFile(char* path)
{
	FILE* fp = fopen(path,"r");
	if(!fp)
	{
		return -1;
	}
	m_oKey.n = 0;
	m_oKey.d =0;
	 char szKey[50]="";
	fread(szKey,1,10, fp);
	m_oKey.n = atol(szKey);
	fread(szKey,1,10, fp);
	 m_oKey.d = atol(szKey);
	fclose(fp);
	return 0;
}
		//保存加密数据到文件
	int  SaveDataFile(char* path,char* pData,int nLen)
	{
		FILE* fp = fopen(path,"w");
		if(!fp)
			return -1;
		fwrite(pData,1,nLen,fp);
		fclose(fp);
		return 0;
	}
	//读取加密的文件到缓存
	int  LoadDataFile(char* path,char* pData )
	{

		FILE* fp = fopen(path,"r");
		if(!fp)
		{
			return -1;
		}
		fseek(fp,0,SEEK_END);
		int len = ftell(fp);
		fseek(fp,0,SEEK_SET);
		fread(pData,1,len, fp);
		fclose(fp);
		
		return len;
	}
 
//获取固定16ge字符数字串
	char * RandStr()
	{
		static int iFlag = 0;
		if(iFlag == 0)
		{
			srand(time(NULL));
			iFlag =1;
		}
		int i;

		for(i=0;i<10;++i)
			m_strAesKey[i]='A'+rand()%26;
		for(;i<15;++i)
			m_strAesKey[i]='0'+rand()%9;
		m_strAesKey[i++]='9';
		m_strAesKey[i]='\0';
		return m_strAesKey;
	}
 

	int  EncryptRsa(unsigned char* pInput,int iInputLen,unsigned char* pOut,int *pOutLen)
	{
		unsigned long long *pData = (unsigned long long *)pOut;
		for(unsigned long i=0; i < iInputLen; i++)
		{
			pData[i]= PowMod(pInput[i], m_oKey.e, &m_oKey.n);
			//cout << hex << pData[i] << " ";
		} 
		*pOutLen = iInputLen * sizeof(unsigned long long);
		return *pOutLen;
	}
	//解密数据
	int  DecryptRsa(unsigned char* pInput,int iInputLen,unsigned char* pOut,int *pOutLen)
	{
		unsigned long long *pData = (unsigned long long *)pInput;
		unsigned long i;
		for( i=0; i < (iInputLen/(sizeof(unsigned long long))); i++)
		{
			pOut[i]= PowMod(pData[i], m_oKey.d, &m_oKey.n);
			//cout << hex << pData[i] << " ";
		} 
		*pOutLen = i ;
		return *pOutLen;
	}

		unsigned long long  htonl64e(unsigned long long  host)   
	{   

		unsigned long long   ret = 0;   
		unsigned long   high,low;
		low   =   host & 0xFFFFFFFF;
		high   =  (host >> 32) & 0xFFFFFFFF;
		low   =   htonl(low);   
		high   =   htonl(high);   
		ret   =   low;
		ret   <<= 32;   
		ret   |=   high;   
		return   ret;   
	}

	unsigned long long  ntohl64e(unsigned long long   host)   
	{   
	unsigned long long   ret = 0;   
	unsigned long   high,low;
	low   =   host & 0xFFFFFFFF;
	high   =  (host >> 32) & 0xFFFFFFFF;
	low   =   ntohl(low);   
	high   =   ntohl(high);   
	ret   =   low;
	ret   <<= 32;   
	ret   |=   high;   
	return   ret;   
	}


/*
模乘运算，返回值 x=a*b mod n
*/
  unsigned long long MulMod(unsigned long long a, unsigned long long b, unsigned long long *n)
{
    return a * b % *n;
}
/*
模幂运算，返回值 x=base^pow mod n
*/
unsigned long long PowMod(unsigned long long base, unsigned long long pow, unsigned long long *n)
{
    unsigned long long    a=base, b=pow, c=1;
    while(b)
    {
        while(!(b & 1))
        {
            b>>=1;            //a=a * a % n;    //函数看起来可以处理64位的整数，但由于这里a*a在a>=2^32时已经造成了溢出，因此实际处理范围没有64位
            a=MulMod(a, a, n);
        }        b--;        //c=a * c % n;        //这里也会溢出，若把64位整数拆为两个32位整数不知是否可以解决这个问题。
        c=MulMod(a, c, n);
    }    return c;
}
/*
Rabin-Miller素数测试，通过测试返回1，否则返回0。
n是待测素数。*/
long RabinMillerKnl(unsigned long long *n)
{
    unsigned long long    b, m, j, v, i;
    m=*n - 1;
    j=0;    //0、先计算出m、j，使得n-1=m*2^j，其中m是正奇数，j是非负整数
    while(!(m & 1))
    {
        ++j;
        m>>=1;
    }    //1、随机取一个b，2<=b<n-1
    b=2 +  Random(*n - 3);    //2、计算v=b^m mod n
    v=PowMod(b, m, n);    //3、如果v==1，通过测试
    if(v == 1)
    {
        return 1;
    }    //4、令i=1
    i=1;    //5、如果v=n-1，通过测试
    while(v != *n - 1)
    {
        //6、如果i==l，非素数，结束
        if(i == j)
        {
            return 0;
        }        //7、v=v^2 mod n，i=i+1
        v=PowMod(v, 2, n);
        ++i;        //8、循环到5
    }    return 1;
}/*
Rabin-Miller素数测试，循环调用核心loop次
全部通过返回1，否则返回0
*/
long RabinMiller(unsigned long long *n, long loop)
{
    //先用小素数筛选一次，提高效率
	long i;
    for(  i=0; i < g_PrimeCount; i++)
    {
        if(*n % g_PrimeTable[i] == 0)
        {
            return 0;
        }
    }    //循环调用Rabin-Miller测试loop次，使得非素数通过测试的概率降为(1/4)^loop
    for(  i=0; i < loop; i++)
    {
        if(!RabinMillerKnl(n))
        {
            return 0;
        }
    }    return 1;
}/*
随机生成一个bits位(二进制位)的素数，最多32位
*/
unsigned long long RandomPrime(char bits)
{
    unsigned long long    base;
    do
    {
        base= (unsigned long)1 << (bits - 1);   //保证最高位是1
        base+= Random(base);               //再加上一个随机数
        base|=1;    //保证最低位是1，即保证是奇数
    } while(!RabinMiller(&base, 30));    //进行拉宾－米勒测试30次
    return base;    //全部通过认为是素数
}/*
欧几里得法求最大公约数
*/
unsigned long long EuclidGcd(unsigned long long *p, unsigned long long *q)
{
    unsigned long long    a=*p > *q ? *p : *q;
    unsigned long long    b=*p < *q ? *p : *q;
    unsigned long long    t;
    if(*p == *q)
    {
        return *p;   //两数相等，最大公约数就是本身
    }
    else
    {
        while(b)    //辗转相除法，gcd(a,b)=gcd(b,a-qb)
        {
            a=a % b;
            t=a;
            a=b;
            b=t;
        }        return a;
    }
}/*
Stein法求最大公约数
*/
unsigned long long SteinGcd(unsigned long long *p, unsigned long long *q)
{
    unsigned long long    a=*p > *q ? *p : *q;
    unsigned long long    b=*p < *q ? *p : *q;
    unsigned long long    t, r=1;
    if(*p == *q)
    {
        return *p;           //两数相等，最大公约数就是本身
    }
    else
    {
        while((!(a & 1)) && (!(b & 1)))
        {
            r<<=1;          //a、b均为偶数时，gcd(a,b)=2*gcd(a/2,b/2)
            a>>=1;
            b>>=1;
        }        if(!(a & 1))
        {
            t=a;            //如果a为偶数，交换a，b
            a=b;
            b=t;
        }        do
        {
            while(!(b & 1))
            {
                b>>=1;      //b为偶数，a为奇数时，gcd(b,a)=gcd(b/2,a)
            }            if(b < a)
            {
                t=a;        //如果b小于a，交换a，b
                a=b;
                b=t;
            }            b=(b - a) >> 1; //b、a都是奇数，gcd(b,a)=gcd((b-a)/2,a)
        } while(b);
        return r * a;
    }
}/*
已知a、b，求x，满足a*x =1 (mod b)
相当于求解a*x-b*y=1的最小整数解
*/
unsigned long long Euclid(unsigned long long *a, unsigned long long *b)
{
    unsigned long long    m, e, i, j, x, y;
    long                xx, yy;
    m=*b;
    e=*a;
    x=0;
    y=1;
    xx=1;
    yy=1;
    while(e)
    {
        i=m / e;
        j=m % e;
        m=e;
        e=j;
        j=y;
        y*=i;
        if(xx == yy)
        {
            if(x > y)
            {
                y=x - y;
            }
            else
            {
                y-=x;
                yy=0;
            }
        }
        else
        {
            y+=x;
            xx=1 - xx;
            yy=1 - yy;
        }        x=j;
    }    if(xx == 0)
    {
        x=*b - x;
    }    return x;
}/*
随机产生一个RSA加密参数
*/
RSA_PARAM RsaGetParam(void)
{
    RSA_PARAM           Rsa={ 0 };
 //   unsigned long long    t;
    Rsa.p=RandomPrime(16);          //随机生成两个素数
    Rsa.q=RandomPrime(16);
    Rsa.n=Rsa.p * Rsa.q;
    Rsa.f=(Rsa.p - 1) * (Rsa.q - 1);
    do
    {
        Rsa.e= Random(65536);  //小于2^16，65536=2^16
        Rsa.e|=1;                   //保证最低位是1，即保证是奇数，因f一定是偶数，要互素，只能是奇数
    } while(SteinGcd(&Rsa.e, &Rsa.f) != 1);
    Rsa.d=Euclid(&Rsa.e, &Rsa.f);
	return Rsa;
}

//随机数生产
unsigned long long  Random(unsigned long long n)
{
	randSeed=multiplier * randSeed + adder;
	return randSeed % n;
}
