//
//  JKAViewController.m
//  JKKVOHelper_Example
//
//  Created by JackLee on 2019/9/2.
//  Copyright © 2019 xindizhiyin2014. All rights reserved.
//

#import "JKAViewController.h"
#import "JKKVOHelper.h"


@interface JKAViewController ()

@end

@implementation JKAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.person = [JKPersonModel new];
    [self.person jk_addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
        NSLog(@"change %@",change);
    }];
    self.person.name = @"hello";
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:3];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    NSLog(@"[][]");
//    [self.person jk_removeObserver:self forKeyPath:@"name"];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
