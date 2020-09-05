//
//  JKViewController.m
//  JKKVOHelper
//
//  Created by xindizhiyin2014 on 08/30/2019.
//  Copyright (c) 2019 xindizhiyin2014. All rights reserved.
//

#import "JKViewController.h"
#import "JKTeacher.h"
#import "JKKVOHelper.h"
#import <objc/runtime.h>

@interface JKViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datas;
@end

@implementation JKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
        
    
//    JKTeacher *teacher = [JKTeacher new];
//    [teacher jk_addObserverForKeyPath:@"students" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
//        NSLog(@"change %@",change);
//    }];
//    JKPersonModel *person = [JKPersonModel new];
//    person.name = @"1";
//    teacher.students = @[person].mutableCopy;
//    JKPersonModel *person1 = [JKPersonModel new];
//    person1.name = @"2";
//    [teacher.students jk_addObject:person1];
//    teacher.students = @[person,person1].mutableCopy;
//    teacher.students = nil;
    
//    NSMutableArray *array = [NSMutableArray new];
//    [array addObject:@1];
//    [array removeObjectAtIndex:1];
    
    
//    JKPersonModel *person = [JKPersonModel new];
//    unsigned int a;
//
//        objc_property_t * result = class_copyPropertyList(object_getClass(person), &a);
//
//        for (unsigned int i = 0; i < a; i++) {
//            objc_property_t o_t =  result[i];
////            NSLog(@"name: %@", [NSString stringWithFormat:@"%s", property_getName(o_t)]);
//            NSLog(@"att: %@", [NSString stringWithFormat:@"%s", property_getAttributes(o_t)]);
//
//        }
//        return;
//    [person jk_initComputed];
//    person.firstName = @"A";
//    person.lastName = @"B";
//    NSLog(@"AAA_fullName1 %@",person.fullName);
//    NSLog(@"AAA_fullName2 %@",person.fullName);
//
//    [person jk_addObserverForKeyPath:@"fullName" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
//        NSLog(@"JKJK");
//    }];
//
//    [person jk_addObserverForKeyPath:@"firstName" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
//        NSLog(@"MMM");
//    }];
//    person.firstName = @"C";
//    NSLog(@"AAA");
    
//    JKPersonModel *person1 = [JKPersonModel new];
//    person1.firstName = @"C";
//    person1.lastName = @"D";
//    NSLog(@"BBB_fullName1 %@",person1.fullName);
//    NSLog(@"BBB");
//     NSLog(@"UIViewController : %s", @encode(JKPersonModel));
//    JKPersonModel *person = [JKPersonModel new];
//    [person jk_initComputed];
//    person.width = 1;
//    person.height = 2;
//    NSLog(@"width %@",@(person.width));
//    NSLog(@"height %@",@(person.height));
//
//    //
//    NSLog(@"width_1 %ld",(long)person.size.width);
//    NSLog(@"height_1 %ld",(long)person.size.height);
    
//    [person jk_addObserverForKeyPath:@"fullName" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
//        NSLog(@"JKJK");
//    }];
//
//    [person jk_addObserverForKeyPath:@"firstName" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
//        NSLog(@"MMM");
//    }];
//    person.firstName = @"C";
//    NSLog(@"AAA");




}

- (void)reload
{
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = self.datas[indexPath.row];
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"AAA");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        NSLog(@"BBB");
    }
}


#pragma mark - - getter - -
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
