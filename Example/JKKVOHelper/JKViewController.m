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
