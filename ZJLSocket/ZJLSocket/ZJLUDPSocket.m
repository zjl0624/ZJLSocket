//
//  ZJLUDPSocket.m
//  ZJLSocket
//
//  Created by zjl on 2018/7/20.
//  Copyright © 2018年 zjl. All rights reserved.
//

#import "ZJLUDPSocket.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
@interface ZJLUDPSocket()
@property (nonatomic,assign) CFSocketRef socketRef;
@end
@implementation ZJLUDPSocket
- (void)createTCPClientSocketWithIp:(NSString *)ipAddress port:(NSInteger)port {
	//创建socket上下文
	CFSocketContext context = {0,(__bridge void *)(self),NULL,NULL,NULL};
	//创建socket
	_socketRef = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketConnectCallBack, ServerConnectCallBack, &context);
	//创建服务器地址
	struct sockaddr_in addr;
	memset(&addr, 0, sizeof(addr));
	addr.sin_len = sizeof(addr);
	addr.sin_family = AF_INET;
	addr.sin_port = port;
	addr.sin_addr.s_addr = inet_addr([ipAddress UTF8String]);
	//创建CFDataRef
	CFDataRef dataRef = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&addr, sizeof(addr));
	//连接
	CFSocketConnectToAddress(_socketRef, dataRef, -1);
	//把shource加入当前runloop中
	CFRunLoopRef runloopRef = CFRunLoopGetCurrent();
	CFRunLoopSourceRef runLoopSourceRef = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _socketRef, 0);
	CFRunLoopAddSource(runloopRef, runLoopSourceRef, kCFRunLoopCommonModes);
	CFRelease(runLoopSourceRef);
}

//连接服务器的回调
void ServerConnectCallBack( CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info ) {
	if (data != NULL) {
		NSLog(@"连接失败");
	}else {
		NSLog(@"连接成功");
	}
}


- (void)readScreamData {
	char buffer[1024];
	long data = 0;
	while (data == recv(CFSocketGetNative(_socketRef), buffer, sizeof(buffer), 0)) {
		NSString *result = [[NSString alloc] initWithBytes:buffer length:data encoding:NSUTF8StringEncoding];
		NSLog(@"result = %@",result);
		
	}
	perror("recv");
}

- (void)sendScreamData:(NSString *)content {
	const char *data = [content UTF8String];
	long sendDataResult = send(CFSocketGetNative(_socketRef), data, strlen(data) + 1, 0);
	if (sendDataResult < 0) {
		NSLog(@"发送失败");
		perror("send");
	}else {
		NSLog(@"发送成功");
	}
}
@end
