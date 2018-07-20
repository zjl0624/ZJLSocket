//
//  ZJLTCPSocket.m
//  ZJLSocket
//
//  Created by zjl on 2018/7/20.
//  Copyright © 2018年 zjl. All rights reserved.
//

#import "ZJLTCPSocket.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
@interface ZJLTCPSocket()
@property (nonatomic,assign) CFSocketRef socketRef;
@property (nonatomic,strong) NSMutableDictionary *writeStreamDic;
@end
@implementation ZJLTCPSocket
#pragma mark - Init Method
- (instancetype)initTCPClientSocketWithIp:(NSString *)ipAddress port:(NSInteger)port{
	self = [super init];
	if (self) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			CFDataRef dataRef = [self createSocketWithip:ipAddress port:port CFSocketCallBackType:kCFSocketConnectCallBack];
			//连接
			CFSocketConnectToAddress(_socketRef, dataRef, -1);
			[self addRunLoop];
		});
	}
	return self;

}

- (instancetype)initTCPServerSocketWithPort:(NSInteger)port{
	self = [super init];
	if (self) {
		_writeStreamDic = [[NSMutableDictionary alloc] init];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			CFDataRef dataRef = [self createSocketWithip:@"127.0.0.1" port:port CFSocketCallBackType:kCFSocketAcceptCallBack];
			BOOL reused = YES;
			//设置允许重用本地地址和端口
			setsockopt(CFSocketGetNative(_socketRef), SOL_SOCKET, SO_REUSEADDR, (const void *)&reused, sizeof(reused));
			//将CFSocket绑定到指定IP地址
			if (CFSocketSetAddress(_socketRef,dataRef) != kCFSocketSuccess) {
				//如果_socket不为NULL，则释放_socket
				if (_socketRef) {
					CFRelease(_socketRef);
					exit(1);
				}
				_socketRef = NULL;
			}
			[self addRunLoop];
		});
	}
	return self;

}

- (CFDataRef)createSocketWithip:(NSString *)ipAddress port:(NSInteger)port CFSocketCallBackType:(CFSocketCallBackType)type{
	//创建socket上下文
	CFSocketContext context = {0,(__bridge void *)(self),NULL,NULL,NULL};
	//创建socket
	_socketRef = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, type, SocketCallBack, &context);
	//创建服务器地址
	struct sockaddr_in addr;
	memset(&addr, 0, sizeof(addr));
	addr.sin_len = sizeof(addr);
	addr.sin_family = AF_INET;
	addr.sin_port = port;
	addr.sin_addr.s_addr = inet_addr([ipAddress UTF8String]);
	//创建CFDataRef
	CFDataRef dataRef = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&addr, sizeof(addr));

	return dataRef;
}

- (void)addRunLoop {
	//把source加入当前runloop中
	CFRunLoopRef runloopRef = CFRunLoopGetCurrent();
	CFRunLoopSourceRef runLoopSourceRef = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _socketRef, 0);
	CFRunLoopAddSource(runloopRef, runLoopSourceRef, kCFRunLoopCommonModes);
	CFRelease(runLoopSourceRef);
	CFRunLoopRun();
}
#pragma mark - public Method
//从服务器读取数据
- (void)readScreamData {
	char buffer[1024];
	long data;
	while ((data = recv(CFSocketGetNative(_socketRef), buffer, sizeof(buffer), 0))) {
		NSString *result = [[NSString alloc] initWithBytes:buffer length:data encoding:NSUTF8StringEncoding];
		NSLog(@"result = %@",result);
		
	}
	perror("recv");
}
//向服务器发送数据
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
- (void)sendScreamDataByWriteScream:(NSString *)content {
	const char *str = [content UTF8String];
	for (NSString *key in self.writeStreamDic) {
		//向客户端输出数据
		CFWriteStreamWrite((CFWriteStreamRef)self.writeStreamDic[key], (UInt8 *)str, strlen(str) + 1);
	}

}
#pragma mark - CallBack Method
CFReadStreamRef readStreamRef;
CFWriteStreamRef writeStreamRef;
void readStreamCallback(CFReadStreamRef readStream,
				CFStreamEventType evenType,
				void *clientCallBackInfo) {
	UInt8 buff[2048];
	
	NSString *address = (__bridge NSString *)(clientCallBackInfo);
	
//	NSLog(@"%@", aaa);
	
	// ----从可读的数据流中读取数据，返回值是多少字节读到的，如果为0就是已经全部结束完毕，如果是-1则是数据流没有打开或者其他错误发生
	CFIndex hasRead = CFReadStreamRead(readStream, buff, sizeof(buff));
	
	if (hasRead > 0) {
		NSLog(@"%@发来%s\n",address,buff);
//
//		const char *str = "for the lich king！！\n";
//		//向客户端输出数据
//		CFWriteStreamWrite(writeStreamRef, (UInt8 *)str, strlen(str) + 1);
	}
}

//连接服务器的回调
void SocketCallBack( CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info ) {
	ZJLTCPSocket *selfClass = (__bridge ZJLTCPSocket *)(info);
	if (callbackType == kCFSocketConnectCallBack) {
		if (data != NULL) {
			NSLog(@"连接失败");
		}else {
			NSLog(@"连接成功");
			[selfClass readScreamData];
		}
	}else if (callbackType == kCFSocketAcceptCallBack) {
		CFSocketNativeHandle handle = *(CFSocketNativeHandle *)data;
		uint8_t name[SOCK_MAXADDRLEN];
		socklen_t namelen = sizeof(name);
		if (getpeername(handle, (struct sockaddr *)name, &namelen) != 0) {
			perror("getpeername:");
			exit(1);
		}
		
		struct sockaddr_in *addr = (struct sockaddr_in *)name;
		NSLog(@"%s:%d连接进来了",inet_ntoa(addr->sin_addr),addr->sin_port);
		
		readStreamRef = NULL;
		writeStreamRef = NULL;
		CFStreamCreatePairWithSocket(kCFAllocatorDefault, handle, &readStreamRef, &writeStreamRef);
		if (readStreamRef && writeStreamRef) {
			CFReadStreamOpen(readStreamRef);
			CFWriteStreamOpen(writeStreamRef);
			NSString *address = [NSString stringWithFormat:@"%s:%d",inet_ntoa(addr->sin_addr),addr->sin_port];
			CFStreamClientContext context = {0,(__bridge void *)(address),NULL,NULL};
			
			if (!CFReadStreamSetClient(readStreamRef, kCFStreamEventHasBytesAvailable, readStreamCallback, &context)) {
				exit(1);
			}
			CFReadStreamScheduleWithRunLoop(readStreamRef, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
			[selfClass.writeStreamDic setObject:(__bridge id)(writeStreamRef) forKey:[NSString stringWithFormat:@"%s:%d",inet_ntoa(addr->sin_addr),addr->sin_port]];
//			const char *str = "welcome！\n";
//
//			//向客户端输出数据
//			CFWriteStreamWrite(writeStreamRef, (UInt8 *)str, strlen(str) + 1);
		}else {
			close(handle);
		}
		
	}else if (callbackType == kCFSocketReadCallBack) {
		
	}else if (callbackType == kCFSocketWriteCallBack){
		
	}else if (callbackType == kCFSocketDataCallBack){
		
	}

}



@end
