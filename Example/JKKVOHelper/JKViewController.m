//
//  JKViewController.m
//  JKKVOHelper
//
//  Created by xindizhiyin2014 on 08/30/2019.
//  Copyright (c) 2019 xindizhiyin2014. All rights reserved.
//

#import "JKViewController.h"
#import "JKAViewController.h"
#import "JKPersonModel.h"

@interface JKViewController ()

@property (nonatomic,strong) JKPersonModel *person;

@end

@implementation JKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self addObserver:self forKeyPath:@"aaa" options:NSKeyValueObservingOptionNew context:nil];
    
//    [self performSelector:@selector(showVC) withObject:nil afterDelay:3];
}

- (void)showVC
{
    JKAViewController *vc = [JKAViewController new];
    self.person = [JKPersonModel new];
    vc.person = self.person;
    [self presentViewController:vc animated:YES completion:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
