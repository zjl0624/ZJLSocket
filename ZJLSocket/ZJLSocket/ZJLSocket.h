//
//  ZJLTCPSocket.h
//  ZJLSocket
//
//  Created by zjl on 2018/7/20.
//  Copyright © 2018年 zjl. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ReadDataDelegate
@optional
- (void)readDataFromServer:(id)content;

- (void)readDataFromClient:(id)content;
@end
@interface ZJLSocket : NSObject

@property (nonatomic,weak) id<ReadDataDelegate> delegate;

- (instancetype)initUDPServerSocketWithPort:(NSInteger)port;

- (instancetype)initUDPClientSocketWithIP:(NSString *)ipAddress port:(NSInteger)port;

- (instancetype)initTCPClientSocketWithIp:(NSString *)ipAddress port:(NSInteger)port;

- (instancetype)initTCPServerSocketWithPort:(NSInteger)port;

- (void)sendScreamData:(NSString *)content;

- (void)sendScreamDataByWriteScream:(NSString *)content;

- (void)readScreamData;
@end
