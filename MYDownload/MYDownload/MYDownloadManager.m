//
//  MYDownloadManager.m
//  MYDownload
//
//  Created by ifly on 2017/6/8.
//  Copyright © 2017年 Meiyang. All rights reserved.
//

#import "MYDownloadManager.h"

static MYDownloadManager *shareDownloadManager = nil;

@interface MYDownloadManager ()
// 本地临时文件夹文件的个数
@property (nonatomic, assign) NSInteger count;
// 已下载完成的文件列表(文件对象)
@property (strong) NSMutableArray *finishedList;
// 正在下载的文件列表(ASIHttpRequest对象)
@property (strong) NSMutableArray *downingList;
// 未下载完成的临时文件数组(文件对象)
@property (strong) NSMutableArray *fileList;
// 下载文件的模型
@property (nonatomic, strong) MYFileModel *fileInfo;
@end


@implementation MYDownloadManager

#pragma mark -- init methods
+ (MYDownloadManager *)shareDownloadManager {
    static dispatch_once_t onecToken;
    dispatch_once(&onecToken, ^{
        shareDownloadManager = [[self alloc] init];
    });
    return shareDownloadManager;
}

- (instancetype)init {
    if (self = [super init]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *max = [userDefaults valueForKey:kMaxRequestCount];
        if (max == nil) {
            [userDefaults setObject:@"3" forKey:kMaxRequestCount];
            max = @"3";
        }
        [userDefaults synchronize];
        _maxCount     = [max integerValue];
        _fileList     = [NSMutableArray new];
        _downingList  = [NSMutableArray new];
        _finishedList = [NSMutableArray new];
        _count = 0;
        
    }
    return self;
}


#pragma mark - 已完成的下载任务在这里处理
/**
 将本地已经下载完成的文件加载到已下载列表里
 */
- (void)loadFinishedFiles {
    if ([[NSFileManager defaultManager] fileExistsAtPath:PLIST_PATH]) {
        NSMutableArray *finishArr = [[NSMutableArray alloc] initWithContentsOfFile:PLIST_PATH];
        for (NSDictionary *dict in finishArr) {
            MYFileModel *file = [[MYFileModel alloc] init];
            file.fileName  = [dict objectForKey:@"fileName"];
            file.fileType  = [file.fileName pathExtension];
            file.fileSize  = [dict objectForKey:@"fileSize"];
            file.time      = [dict objectForKey:@"time"];
            file.fileImage = [UIImage imageWithData:[dict objectForKey:@"fileImage"]];
            [_finishedList addObject:file];
        }
    }
}





#pragma mark - 从这里获取上次未完成下载的信息
/**
 将本地未完成下载的临时文件加载到正在下载列表里 不重新下载
 */
- (void)loadTempFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:TEMP_FOLDER error:&error];
    if (!error) {
        NSLog(@"%@", [error description]);
    }
    NSMutableArray *fileArr = [[NSMutableArray alloc] init];
    for (NSString *file in fileList) {
        NSString *fileType = [file pathExtension];
        if ([fileType isEqualToString:@"plist"]) {
            //[fileArr addObject:[self ]];
        }
        
        
        
    }
    
    
}


- (MYFileModel *)getTempFile:(NSString *)path {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    MYFileModel *file  = [[MYFileModel alloc] init];
    file.fileName      = [dict objectForKey:@"fileName"];
    file.fileType      = [file.fileName pathExtension];
    file.fileUrl       = [dict objectForKey:@"fileUrl"];
    file.fileSize      = [dict objectForKey:@"fileSize"];
    file.fileReceivedSize = [dict objectForKey:@"fileReceiveSize"];
    file.tempPath      = TEMP_PATH(file.fileName);
    file.time          = [dict objectForKey:@"time"];
    file.fileImage     = [UIImage imageWithData:[dict objectForKey:@"fileImage"]];
    file.downloadState = MYDownLoadState_Stoping;
    file.error         = NO;
    
    NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:file.tempPath];
    NSInteger receivedDataLength = [fileData length];
    file.fileReceivedSize = [NSString stringWithFormat:@"zd",receivedDataLength];
    return  file;
}





@end
