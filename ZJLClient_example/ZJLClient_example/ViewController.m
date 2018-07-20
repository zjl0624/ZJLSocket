//
//  ViewController.m
//  ZJLClient_example
//
//  Created by zjl on 2018/7/19.
//  Copyright © 2018年 zjl. All rights reserved.
//

#import "ViewController.h"
#import "ZJLTCPSocket.h"
@interface ViewController ()
- (IBAction)receiveAction:(id)sender;
- (IBAction)connectAction:(id)sender;
- (IBAction)sendAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *IPAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *contentTextFiled;
@property (strong,nonatomic) ZJLTCPSocket *clientSocket;


@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


- (IBAction)receiveAction:(id)sender {
	[_clientSocket readScreamData];
}

- (IBAction)connectAction:(id)sender {
	_clientSocket = [[ZJLTCPSocket alloc] initTCPClientSocketWithIp:self.IPAddressTextField.text port:[self.portTextFiled.text integerValue]];
}

- (IBAction)sendAction:(id)sender {
	[_clientSocket sendScreamData:self.contentTextFiled.text];
}
@end
