//
//  ViewController.m
//  NavHV
//
//  Created by guiping on 2017/9/8.
//  Copyright © 2017年 pingui. All rights reserved.
//

#import "ViewController.h"
#import "GPAlertView.h"

@interface ViewController ()
{
    NSMutableArray *dataSource;
}

@property (nonatomic, strong) UITableView *tbView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"首页";
    [self setNavigationItem];
    [self.view addSubview:self.tbView];
}

#pragma mark -------添加提示框--------
- (void) btnMoreClicked:(UIButton *) sender{
    NSArray *data = @[@"个人中心", @"活动介绍"];
    GPAlertView *alertView = [[GPAlertView alloc] initWithNavigationItemRect:sender.frame data:data];
    alertView.contentViewWidth = 80;
    alertView.tbCellHeight = 30;
//    //alertView.sanSize = CGSizeMake(20, 12);
    alertView.titleFont = [UIFont systemFontOfSize:12];
    alertView.target = (id <GPAlertViewDelegate>) self;
    [alertView show];
//    alertView.alignment = NSTextAlignmentLeft;
    [alertView setSelectedItemCallBack:^(NSString *title){
        NSLog(@"block :%@", title);
    }];
}

- (void) btnAddClicked:(UIButton *) sender{
    NSArray *data = @[@"扫一扫", @"添加设备"];
    GPAlertView *alertView   = [[GPAlertView alloc] initWithNavigationItemRect:sender.frame titleArray:data imageNameArray:data];
    alertView.target = (id <GPAlertViewDelegate>) self;
    [alertView show];
    alertView.headerViewAlignment = HeaderviewLocationRight;
//    [alertView setSelectedItemCallBack:^(NSString *title){
//        NSLog(@"block :%@", title);
//    }];
    [alertView onSelectRowWithTitleCallBack:^(NSString *title) {
        NSLog(@"block :%@", title);
    }];
}

- (void) btnShareClicked:(UIButton *) sender{
    NSArray *data = @[@"悟空", @"增强版", @"红外感应", @"智能门磁", @"海曼检测", @"S3网关", @"门栓"];
    GPAlertView *alertView = [[GPAlertView alloc] initWithNavigationItemRect:sender.frame data:data];
    alertView.target = (id <GPAlertViewDelegate>) self;
    alertView.backgroundColor = [UIColor orangeColor];
    [alertView show];
    alertView.contentViewWidth = 100;
    alertView.cellNumbersMax = 5;
    alertView.tbCellHeight = 35;
    
    alertView.titleFont = [UIFont systemFontOfSize:15];
    [alertView setSelectedItemCallBack:^(NSString *title){
        NSLog(@"block :%@", title);
    }];
}

- (void) longGesture:(UILongPressGestureRecognizer *) gesture{
    if(gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gesture locationInView:_tbView];
        NSIndexPath *indexPath = [_tbView indexPathForRowAtPoint:point];
        if(indexPath == nil) return ;
        
//        CGRect rectInTableView = [myTableView rectForRowAtIndexPath:indexPath];
//        CGRect cellRrect = [myTableView convertRect:rectInTableView toView:[myTableView superview]];
//        NSLog(@" %@", NSStringFromCGRect(rect));
        GPTableViewCell *cell = [_tbView cellForRowAtIndexPath:indexPath];
        
        // 获取cell中的子视图在屏幕上的位置
        CGRect rect1 = [cell.lb convertRect:cell.lb.frame fromView:cell.contentView];
        CGRect lbRrect = [cell.lb convertRect:rect1 toView:self.view];
//        NSLog(@"rect2 = %@", NSStringFromCGRect(lbRrect));
        
        NSArray *data = @[@"布防", @"修改名称", @"撤防", @"报警"];
        GPAlertView *alertView = [[GPAlertView alloc] initWithTableViewCell:lbRrect data:data indexPath:indexPath];
        alertView.titleFont = [UIFont systemFontOfSize:12];
        if (indexPath.row % 2) {
            alertView.backgroundColor = [UIColor colorWithRed:40/255.0 green:170/255.0 blue:230/255.0 alpha:1];
            alertView.lineColor = [UIColor blackColor];
        }
        alertView.target = (id <GPAlertViewDelegate>) self;
        [alertView show];
    }
}


#pragma mark --- GPAlertViewDelegate ----
- (void)didSlectedItemWithTitle:(NSString *)title{
    NSLog(@"delegate :%@", title);
}

- (void)didSlectedItemWithTitle:(NSString *)title indexPath:(NSIndexPath *) indexPath{
    NSLog(@"%@ == %@", dataSource[indexPath.row], title);
}


#pragma mark ------------ UITableViewDelegate ------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[GPTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.lb.text = dataSource[indexPath.row];
    return cell;
}

#pragma mark ------------ 懒加载 ------------------
-(UITableView *)tbView{
    if (!_tbView) {
        _tbView = [[UITableView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_tbView];
        _tbView.dataSource = (id <UITableViewDataSource>)self;
        _tbView.delegate = (id <UITableViewDelegate>)self;
        [_tbView registerClass:[GPTableViewCell class] forCellReuseIdentifier:@"cell"];
        [self loadData];
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesture:)];
        [_tbView addGestureRecognizer:longGesture];
    }
    return _tbView;
}

- (void) setNavigationItem{
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:40/255.0 green:170/255.0 blue:230/255.0 alpha:1];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:17]};
    
    UIBarButtonItem *itemSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    itemSpace.width = -12;
    
    
    UIButton *btnMore = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [btnMore setImage:[UIImage imageNamed:@"更多"] forState:UIControlStateNormal];
    [btnMore addTarget: self action:@selector(btnMoreClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *btnShare0 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [btnShare0 setImage:[UIImage imageNamed:@"分享"] forState:UIControlStateNormal];
    [btnShare0 addTarget: self action:@selector(btnShareClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *itemMore = [[UIBarButtonItem alloc] initWithCustomView:btnMore];
    UIBarButtonItem *itemMore1 = [[UIBarButtonItem alloc] initWithCustomView:btnShare0];
    
    
    UIButton *btnAdd = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [btnAdd setImage:[UIImage imageNamed:@"添加"] forState:UIControlStateNormal];
    [btnAdd addTarget: self action:@selector(btnAddClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *btnShare = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [btnShare setImage:[UIImage imageNamed:@"分享"] forState:UIControlStateNormal];
    [btnShare addTarget: self action:@selector(btnShareClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *itemAdd = [[UIBarButtonItem alloc] initWithCustomView:btnAdd];
    UIBarButtonItem *itemShare = [[UIBarButtonItem alloc] initWithCustomView:btnShare];
    
    [self.navigationItem setLeftBarButtonItems:@[itemSpace,itemMore, itemMore1]];
    self.navigationItem.rightBarButtonItems = @[itemSpace, itemAdd, itemShare];
}

- (void) loadData{
    if (!dataSource) {
        dataSource = [NSMutableArray array];
    }
    [dataSource addObject:@"悟空增强版"];
    [dataSource addObject:@"智能插座"];
    [dataSource addObject:@"红外感应器"];
    [dataSource addObject:@"智能门磁"];
    [dataSource addObject:@"光照计"];
    [dataSource addObject:@"网关"];
    
    for (int i=0; i<10; i++) {
        NSString *s = [NSString stringWithFormat:@"第%d行", i];
        [dataSource addObject:s];
    }
    [_tbView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end




#pragma mark --------GPTableViewCell------------
@implementation GPTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
        [self.contentView addSubview:imageView];
        imageView.backgroundColor = [UIColor greenColor];
        
        _lb = [[UILabel alloc] initWithFrame: CGRectMake(70, 15, 100, 30)];
        [self.contentView addSubview:_lb];
    }
    return self;
}
@end
