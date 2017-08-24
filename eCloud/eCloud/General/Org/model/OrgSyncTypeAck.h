//保存组织架构同步类型应答

#import <Foundation/Foundation.h>

@interface OrgSyncTypeAck : NSObject

typedef enum
{
    sync_type_file = 0,
    sync_type_packet
}syncType;

//目前服务器端不发送全量文件
typedef enum
{
    file_type_all = 0,
    file_type_increment
}fileType;

@property (nonatomic,assign) int syncTypeDept;
@property (nonatomic,assign) int syncTypeEmpDept;

@property (nonatomic,assign) int fileTypeDept;
@property (nonatomic,assign) int fileTypeEmpDept;

@property (nonatomic,retain) NSString *filePathDept;
@property (nonatomic,retain) NSString *filePasswordDept;

@property (nonatomic,retain) NSString *filePathEmpDept;
@property (nonatomic,retain) NSString *filePasswordEmpDept;

@property (nonatomic,assign) int updateTimeDept;
@property (nonatomic,assign) int updateTimeEmpDept;

@end
