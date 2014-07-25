//
//  ImageBrowserViewController.m
//  ImageBrowser
//
//  Created by chester on 7/9/14.
//  Copyright (c) 2014 MLL. All rights reserved.
//

#import "ImageBrowserViewController.h"
#import "UIImageView+WebCache.h"

#pragma mark - BrowserImageView
@interface BrowserImageView : UIImageView

@end

@implementation BrowserImageView

@end

#pragma mark - ImageBrowserViewController
@interface ImageBrowserViewController ()<UIScrollViewDelegate>

@property (nonatomic, retain) UIScrollView *imageScrollView;

@end

@implementation ImageBrowserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.fullImageURLArray && [self.fullImageURLArray count] > 0)
    {
        [self resetImageExhibition];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_beFullScreen)
    {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (_beFullScreen)
    {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(UIScrollView *)imageScrollView
{
    if (!_imageScrollView)
    {
        _imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        _imageScrollView.delegate = self;
        [self.view addSubview:_imageScrollView];
        [_imageScrollView setBackgroundColor:[UIColor blackColor]];
    }
    
    return _imageScrollView;
}

-(void)resetImageExhibition
{
    // clean
    NSArray *subViewArray = [self.imageScrollView subviews];
    for (UIView *view in subViewArray)
    {
        [view removeFromSuperview];
    }
    
    // 计算scrollview内容大小
    [self calcScrollViewContentSize];
    
    
    // 计算并构造内部view
    [self constructInternViews];
    
    [self.view setNeedsDisplay];
}

/**
 *  可以优化padding
 */
- (void)calcScrollViewContentSize
{
    NSInteger width = self.imageScrollView.frame.size.width;
    NSInteger height = self.imageScrollView.frame.size.height;
    NSInteger count = [_fullImageURLArray count];
    NSInteger destWidth = count * width;
    self.imageScrollView.contentSize = CGSizeMake(destWidth, height);
}

-(void)constructInternViews
{
    NSInteger width = self.imageScrollView.frame.size.width;
    NSInteger height = self.imageScrollView.frame.size.height;
    
    // 
    for (int i = 0; i < [_fullImageURLArray count]; ++i)
    {
        NSURL *url = _fullImageURLArray[i];
        CGRect frame = CGRectMake(i * width, 0, width, height);
        BrowserImageView *imageView = [[BrowserImageView alloc] initWithFrame:frame];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_imageScrollView addSubview:imageView];
        [_imageScrollView setPagingEnabled:YES];
        
        [imageView sd_setImageWithURL:url
                  placeholderImage:nil
                           options:SDWebImageRetryFailed
                          progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
    }
    
}

#pragma mark -UIScrollViewDelegate


@end
