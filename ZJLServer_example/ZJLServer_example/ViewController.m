//
//  ViewController.m
//  ZJLServer_example
//
//  Created by zjl on 2018/7/19.
//  Copyright © 2018年 zjl. All rights reserved.
//

#import "ViewController.h"
#import "ZJLSocket.h"
@interface ViewController ()<ReadDataDelegate>
- (IBAction)sendAction:(id)sender;

- (IBAction)startServerAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextField *contentTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (strong,nonatomic) ZJLSocket *serverSocket;

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
//	[_serverSocket sendScreamData:self.contentTextField.text];
}

- (IBAction)startServerAction:(id)sender {
	_serverSocket = [[ZJLSocket alloc] initTCPServerSocketWithPort:[self.portTextField.text integerValue]];
//	_serverSocket = [[ZJLSocket alloc] initUDPServerSocketWithPort:[self.portTextField.text integerValue]];
	_serverSocket.delegate = self;

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	[self.view endEditing:YES];
}
@end
