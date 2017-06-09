//
//  MYHttpRequest.h
//  MYDownload
//
//  Created by ifly on 2017/6/8.
//  Copyright © 2017年 Meiyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ASIHTTPRequest/ASIHTTPRequest.h>


@class MYHttpRequest;
@protocol MYHttpRequestDelegate <NSObject>
/**请求出错*/
- (void)requestFailed:(MYHttpRequest *)request;
/**请求开始*/
- (void)requestStarted:(MYHttpRequest *)request;
/**收到信息头*/
- (void)request:(MYHttpRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders;
/**已接收大小*/
- (void)request:(MYHttpRequest *)request didReceiveBytes:(long long)bytes;
/**请求完成*/
- (void)requestFinished:(MYHttpRequest *)request;
@optional
/***/
- (void)request:(MYHttpRequest *)request willRedirectToURL:(NSURL *)newURL;

@end

@interface MYHttpRequest : NSObject
// 协议
@property (nonatomic, weak) id<MYHttpRequestDelegate> delegate;
// 网址
@property (nonatomic, strong) NSURL *url;
// 原始网址
@property (nonatomic, strong) NSURL *originalUrl;
// 用户信息
@property (nonatomic, strong) NSDictionary *userInfo;
// 标签
@property (nonatomic, assign) NSInteger tag;
// 下载路劲
@property (nonatomic, copy  ) NSString *downloadDestrnationPath;
// 临时文件路径
@property (nonatomic, copy  ) NSString *temporaryFileDownloadPath;
// 错误
@property (nonatomic, strong, readonly) NSError *error;

// 初始化
- (instancetype)initWithUrl:(NSURL *)url;
// 
- (void)startAsynchronous;
// 是否完成
- (BOOL)isFinished;
//
- (BOOL)isExecuting;
// 取消请求
- (void)cancel;




@end
