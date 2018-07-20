//
//  ViewController.m
//  ZJLServer_example
//
//  Created by zjl on 2018/7/19.
//  Copyright © 2018年 zjl. All rights reserved.
//

#import "ViewController.h"
#import "ZJLTCPSocket.h"
@interface ViewController ()<ReadDataDelegate>
- (IBAction)sendAction:(id)sender;

- (IBAction)startServerAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextField *contentTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (strong,nonatomic) ZJLTCPSocket *serverSocket;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}
#pragma mark - ReadDataDelegate
- (void)readDataFromClient:(id)content{
	self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"\n%@",content]];
}

- (IBAction)sendAction:(id)sender {
	[_serverSocket sendScreamDataByWriteScream:self.contentTextField.text];
}

- (IBAction)startServerAction:(id)sender {
	_serverSocket = [[ZJLTCPSocket alloc] initTCPServerSocketWithPort:[self.portTextField.text integerValue]];
	_serverSocket.delegate = self;

}
@end
