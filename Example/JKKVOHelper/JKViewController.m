//
//  JKViewController.m
//  JKKVOHelper
//
//  Created by xindizhiyin2014 on 08/30/2019.
//  Copyright (c) 2019 xindizhiyin2014. All rights reserved.
//

#import "JKViewController.h"
#import "JKTeacher.h"
#import "JKKVOItemManager.h"

@interface JKViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datas;
@end

@implementation JKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.datas = [NSMutableArray new];
//    for (NSInteger i = 0; i< 100; i++) {
//        NSString *title = [NSString stringWithFormat:@"aaa %@",@(i)];
//        [self.datas addObject:title];
//    }
    JKTeacher *teacher = [JKTeacher new];
//    [JKKVOItemManager jk_exchangeClassMethod:[NSMutableArray class] originalSel:@selector(new)
//    swizzledSel:NSSelectorFromString(@"jk_new")];
    JKTeacher *teacher1 = [JKTeacher new];

//   NSMutableArray *array = [NSMutableArray new];
//    NSLog(@"array %@",array.description);
//    [array addObject:teacher];
//    NSLog(@"array1 %@",array.description);
//    [array addObject:teacher];
//    NSLog(@"array2 %@",array.description);
////    [array removeLastObject];
////    NSLog(@"array3 %@",array.description);
//    NSMutableDictionary *dic = [NSMutableDictionary new];
//    [dic setObject:teacher forKey:@"a"];
//    NSLog(@"dic %@",dic.description);
//    [dic setObject:teacher forKey:@"a1"];
//    NSLog(@"dic1 %@",dic.description);





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
