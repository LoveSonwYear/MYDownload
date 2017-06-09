//
//  MYHttpRequest.m
//  MYDownload
//
//  Created by ifly on 2017/6/8.
//  Copyright © 2017年 Meiyang. All rights reserved.
//

#import "MYHttpRequest.h"


@interface MYHttpRequest () <
ASIHTTPRequestDelegate,
ASIProgressDelegate> {
    
    ASIHTTPRequest *_realRequest;
}
@end


@implementation MYHttpRequest


- (instancetype)initWithUrl:(NSURL *)url {
    if (self = [super init]) {
        _url = url;
        _realRequest = [[ASIHTTPRequest alloc] initWithURL:url];
        _realRequest.delegate = self;
        [_realRequest setDownloadProgressDelegate:self];
        // 设置超时自动重连最大次数
        [_realRequest setNumberOfTimesToRetryOnTimeout:2];
        // 支持断点续传
        [_realRequest setAllowResumeForFileDownloads:YES];
        // 设置请求超时时间
        [_realRequest setTimeOutSeconds:30.0f];
    }
    return self;
}


- (void)setUserInfo:(NSDictionary *)userInfo {
    _userInfo = userInfo;
}

- (void)setTag:(NSInteger)tag {
    _tag = tag;
    _realRequest.tag = tag;
}

- (NSURL *)originalUrl {
    return _realRequest.originalURL;
}

- (NSError *)error {
    return _realRequest.error;
}

- (BOOL)isExecuting {
    return [_realRequest isExecuting];
}

- (void)cancel {
    [_realRequest clearDelegatesAndCancel];
}

- (void)setDownloadDestrnationPath:(NSString *)downloadDestrnationPath {
    _downloadDestrnationPath = downloadDestrnationPath;
    [_realRequest setDownloadDestinationPath:_downloadDestrnationPath];
}

- (void)setTemporaryFileDownloadPath:(NSString *)temporaryFileDownloadPath {
    _temporaryFileDownloadPath = temporaryFileDownloadPath;
    [_realRequest setTemporaryFileDownloadPath:_temporaryFileDownloadPath];
}

- (void)startAsynchronous {
    [_realRequest startAsynchronous];
}

#pragma mark -- ASIHttpDelegate
- (void)requestStarted:(ASIHTTPRequest *)request {
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestStarted:)]) {
        [self.delegate requestStarted:self];
    }
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders {
    if (self.delegate && [self.delegate respondsToSelector:@selector(request:didReceiveResponseHeaders:)]) {
        [self.delegate request:self didReceiveResponseHeaders:responseHeaders];
    }
}

- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes {
    if (self.delegate && [self.delegate respondsToSelector:@selector(request:didReceiveBytes:)]) {
        [self.delegate request:self didReceiveBytes:bytes];
    }
}

- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL {
    if (self.delegate && [self.delegate respondsToSelector:@selector(request:willRedirectToURL:)]) {
        [self.delegate request:self willRedirectToURL:newURL];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestFinished:)]) {
        [self.delegate requestFinished:self];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestFailed:)]) {
        [self.delegate requestFailed:self];
    }
}


/**
 *全部暂停的时候, Request并不retain他们的代理 所以已经释放了代理 而之后Request完成 这将会引起崩溃
 *大多数情况下 如果你的代理即将被释放 你一定也希望取消所以的Request 因为你已经不再关心他们的情况了
 *所以在MYHttpRequest这个类的dealloc里面加上一个[Request clearDelegaresAndCancel]
 *代理类的dealloc函数
 */
- (void)dealloc {
    
    // NSLog(@"%@ 释放了", _realRequest);
    [_realRequest clearDelegatesAndCancel];
}



@end
