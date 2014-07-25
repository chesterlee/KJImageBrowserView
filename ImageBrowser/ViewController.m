//
//  ViewController.m
//  ImageBrowser
//
//  Created by chester on 7/9/14.
//  Copyright (c) 2014 chester. All rights reserved.
//
#import "ViewController.h"
#import "KJImageBrowserView.h"

// test data

#define imageURL1 @"http://pic17.nipic.com/20111021/7675329_213741424000_2.jpg"
#define imageURL2 @"http://pic17.nipic.com/20111021/7675329_213741424000_2.jpg"
#define imageURL3 @"http://images.ccoo.cn/bbs/20101226/2010122610564395.jpg"
#define imageURL4 @"http://octodex.github.com/images/front-end-conftocat.png"


#define imageURL10 @"http://pic3.zhongsou.com/image/380710317cdddeb894b.jpg"
#define imageURL20 @"http://img1.soufun.com/bbs/2004_08/09/1092063245030.jpeg"
#define imageURL30 @"http://pic3.zhongsou.com/image/38015ed7f68454d9ec3.jpg"
#define imageURL40 @"http://pic3.zhongsou.com/image/38025530ea64284177d.jpg"

@interface ViewController ()<KJImageBrowerViewDelegate>

@property (nonatomic, retain) NSArray *imageURLArray;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageURLArray = [NSArray arrayWithObjects:imageURL1, imageURL2, imageURL3, imageURL4, nil];
    NSArray *array2 = [NSArray arrayWithObjects:imageURL10, imageURL20, imageURL30, imageURL40, nil];

    [self.view setBackgroundColor:[UIColor blueColor]];
    
    KJImageBrowserView *imageBrower = [[KJImageBrowserView alloc]
                                       initWithFrame:CGRectMake(50, 60, 800, 700)
                                       padding:[NSNumber numberWithInt:10]
                                       placeHolderImage:nil
                                       delegate:self];
    
    imageBrower.indicatorClassName = @"ETActivityIndicatorView";
    imageBrower.progressViewName = @"DACircularProgressView";
    
    [imageBrower updateFirstURLArray:_imageURLArray secondImageURLArray:array2];
    [self.view addSubview:imageBrower];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// callbacks
-(void)onTappedWithImageIndex:(NSUInteger)imageIndex
{
    NSLog(@"######## index = %d########",imageIndex);
    BOOL ishidden = [self.navigationController.navigationBar isHidden];
    [self.navigationController setNavigationBarHidden:!ishidden animated:YES];
}

-(void)onScrollEndWithImageIndex:(NSUInteger)imageIndex
{
    NSLog(@"######## Out Index= %d",imageIndex);
}

@end
