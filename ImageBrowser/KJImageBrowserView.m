//
//  KJImageBrowserView.h
//  Version 0.1
//  Created by chester lee on 7.25.14.
//

#import "KJImageBrowserView.h"
#import "UIImageView+WebCache.h"

// if you want to open debug mode,
#define KJBrowser_VerboseMode 0

#pragma mark - ########## InnerImageUnit Declare ##########

// zoom ratio for the max zoom and min zoom
#define maxZoom (2)
#define minZoom (1)


/**
 *  inner image showing unit
 */
@interface InnerImageUnit : UIView<UIScrollViewDelegate>

@property (nonatomic, weak)   UIImageView *contentImageView;
@property (nonatomic, retain) UIImage *placeHolderImage;
@property (nonatomic, retain) UITapGestureRecognizer *singleTapGesture;
@property (nonatomic, retain) UITapGestureRecognizer *doubleTapGesture;
@property (nonatomic, retain) NSURL *firstURL;
@property (nonatomic, retain) NSURL *secondURL;
@property (nonatomic, retain) UIScrollView *zoomScrollView;                 //zoom scrollView
@property (nonatomic, retain) UITapGestureRecognizer *doubleTappedGesture;

// waiting, progress indicator reference
@property (nonatomic, copy) NSString *indicatorClassName;
@property (nonatomic, copy) NSString *progressClassName;
@property (nonatomic, retain) id indicatorView;  //waiting indicator object corresponse from indicatorClassName
@property (nonatomic, retain) id progressView;   //progress indicator object corresponse from progressClassName

/**
 *  init the InnterImageUnit
 *
 *  @param frame                the frame
 *  @param firstImageURL        first image url array
 *  @param secondImageURL       second image url array
 *  @param placeHolderImage     place holder image
 *  @param beZoomSupport        if you want zoom, set it with YES
 *  @param beDoubleTouchSupport if you want double tapped for zooming, set it with YES
 *  @param indicatorClassName   the class name of waiting indicator view
 *  @param progressClassName    the class name of progress indicator view
 *
 *  @return InnterImageUnit instance
 */
-(instancetype)initWithFrame:(CGRect)frame
               firstImageURL:(NSURL *)firstImageURL
              secondImageURL:(NSURL *)secondImageURL
            placeHolderImage:(UIImage *)placeHolderImage
                 zoomSupport:(BOOL)beZoomSupport
          doubleTouchSupport:(BOOL)beDoubleTouchSupport
          indicatorClassName:(NSString *)indicatorClassName
           progressClassName:(NSString *)progressClassName;

/**
 *  reset image showing state
 */
-(void)resetImageZoom;

@end

#pragma mark - ########## InnerImageUnit implementation ##########
@implementation InnerImageUnit
/**
 *  init the InnterImageUnit
 */
-(instancetype)initWithFrame:(CGRect)frame
               firstImageURL:(NSURL *)firstImageURL
              secondImageURL:(NSURL *)secondImageURL
            placeHolderImage:(UIImage *)placeHolderImage
                 zoomSupport:(BOOL)beZoomSupport
          doubleTouchSupport:(BOOL)beDoubleTouchSupport
          indicatorClassName:(NSString *)indicatorClassName
           progressClassName:(NSString *)progressClassName
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.firstURL = firstImageURL;
        self.secondURL = secondImageURL;
        self.placeHolderImage = placeHolderImage;
        self.indicatorClassName = indicatorClassName;
        self.progressClassName = progressClassName;
        
        // construct inner scrollView
        [self constructInnerScrollViewWithZoomSupport:beZoomSupport beDoubleTouchSupport:beDoubleTouchSupport];
        
        // construct waiting Indicator
        [self constructIndicator];
        
        // construct imageView for loading image
        [self constructInnerImageView];
        
        // load images correspond to the imageURL in the first image array
        [self loadImage];
    }
    return self;
}

/**
 *  construct zoomScrollView
 *
 *  @param beZoomSupport        support zooming
 *  @param beDoubleTouchSupport support double zooming
 */
-(void)constructInnerScrollViewWithZoomSupport:(BOOL) beZoomSupport beDoubleTouchSupport:(BOOL)beDoubleTouchSupport
{
    NSInteger width = self.frame.size.width;
    NSInteger height = self.frame.size.height;
    self.zoomScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    self.zoomScrollView.showsHorizontalScrollIndicator = NO;
    self.zoomScrollView.showsVerticalScrollIndicator = NO;
    self.zoomScrollView.delegate = self;
    [self addSubview:self.zoomScrollView];
    
    if (beZoomSupport)
    {
        if (beDoubleTouchSupport)
        {
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                         action:@selector(doubleTapped:)];
            self.doubleTapGesture = tapGesture;
            self.doubleTapGesture.numberOfTapsRequired = 2;
            [self addGestureRecognizer:self.doubleTapGesture];
        }
        
        self.zoomScrollView.multipleTouchEnabled = YES;
        self.zoomScrollView.minimumZoomScale = minZoom;
        self.zoomScrollView.maximumZoomScale = maxZoom;
    }
    else
    {
        self.zoomScrollView.maximumZoomScale = self.zoomScrollView.minimumZoomScale;
    }
}

/**
 *  construct inner ImageView
 */
-(void)constructInnerImageView
{
    NSInteger width = self.frame.size.width;
    NSInteger height = self.frame.size.height;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.zoomScrollView addSubview:imageView];
    self.contentImageView = imageView;
}

/**
 *  load images correspond to the imageURL in the first image array
 */
-(void)loadImage
{
    __weak InnerImageUnit *_self = self;
    [self startWaitIndicatorAnimation];
    [self.contentImageView sd_setImageWithURL:self.firstURL
                          placeholderImage:_placeHolderImage
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     __strong InnerImageUnit *self_ = _self;
                                     if (self_)
                                     {
                                         self_.placeHolderImage = image;

                                         // 请求第二张图片
                                         [self_ performSelector:@selector(requestNextImage)
                                                     withObject:nil
                                                     afterDelay:0.2];
                                     }
                                 }];
}

/**
 *  load images correspond to the imageURL in the second image array
 */
-(void)requestNextImage
{
    __weak InnerImageUnit *_self = self;
    if (!self.secondURL)
    {
        [self stopWaitIndicatorAnimation];
        return;
    }
    
    [self stopWaitIndicatorAnimation];
    [self startProgressIndicator];
    [self.contentImageView sd_setImageWithURL:self.secondURL
                             placeholderImage:self.placeHolderImage
                                      options:SDWebImageRetryFailed
                                     progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                         
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             __strong InnerImageUnit *self_ = _self;
                                             if (self_)
                                             {
                                                 CGFloat ratio = (CGFloat)receivedSize/(CGFloat)expectedSize;
                                                 if (ratio < 0 || ratio - 0 < 0.0001) {
                                                     return;
                                                 }
                                                 [self_ updateProgressIndicatorWithRatio:ratio];
                                             }
                                         });
                                     } completed:^(UIImage *image, NSError *error,
                                                   SDImageCacheType cacheType, NSURL *imageURL) {
                                         
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             __strong InnerImageUnit *self_ = _self;
                                             if (self_)
                                             {
                                                 [UIView animateWithDuration:1 animations:^{
                                                     if (self_.progressView && [self_.progressView respondsToSelector:@selector(setValue:forKeyPath:)])
                                                     {
                                                         [self_.progressView setValue:[NSNumber numberWithFloat:1] forKeyPath:@"progress"];
                                                     }
                                                 } completion:^(BOOL finished) {
                                                     [self_ stopProgressIndicator];
                                                 }];
                                             }
                                         });
                                     }];
}

#pragma mark - indicator refer
/**
 *  construct waiting indicator
 */
-(void)constructIndicator
{
    Class indicatorClass = NSClassFromString(self.indicatorClassName);
    if (indicatorClass && [indicatorClass isSubclassOfClass:[UIView class]])
    {
        CGRect frame = self.frame;
        CGPoint point = CGPointMake(frame.size.width / 2, frame.size.height / 2);
        UIView *indicatorView = [[indicatorClass alloc] initWithFrame:CGRectMake(point.x - 50, point.y - 50, 100, 100)];
        
        if (!indicatorView)
        {
            return;
        }
        
        self.indicatorView = indicatorView;
        [self addSubview:indicatorView];
    }
}

/**
 *  start waiting animation if exist
 */
-(void)startWaitIndicatorAnimation
{
    if (self.indicatorView && [self.indicatorView respondsToSelector:@selector(startAnimating)]) {
        [self.indicatorView startAnimating];
    }
}

/**
 *  stop waiting animation if exist
 */
-(void)stopWaitIndicatorAnimation
{
    if (self.indicatorView)
    {
        [self.indicatorView removeFromSuperview];
    }
}

/**
 *  start showing the progress indicator
 */
-(void)startProgressIndicator
{
    if (!_progressView)
    {
        CGRect frame = self.frame;
        CGPoint point = CGPointMake(frame.size.width / 2, frame.size.height / 2);
        
        Class progressViewClass = NSClassFromString(self.progressClassName);
        if (progressViewClass && [progressViewClass isSubclassOfClass:[UIView class]])
        {
            UIView *progressView = [[progressViewClass alloc] initWithFrame:CGRectMake(point.x - 50, point.y - 50, 100, 100)];
            if (!progressView)
            {
                return;
            }
            
            [self addSubview:progressView];
            self.progressView = progressView;
            if (self.progressView && [self.progressView respondsToSelector:@selector(setValue:forKeyPath:)])
            {
                [self.progressView setValue:[NSNumber numberWithFloat:0.001f] forKeyPath:@"progress"];
            }
            [progressView setNeedsDisplay];
        }
    }
}

/**
 *  update progress indicator value
 */
-(void)updateProgressIndicatorWithRatio:(CGFloat)ratio
{
    
#if KJBrowser_VerboseMode
    NSLog(@"current ratio = %f",ratio);
#endif
    
    if (self.progressView && [self.progressView respondsToSelector:@selector(setValue:forKeyPath:)])
    {
        [self.progressView setValue:[NSNumber numberWithFloat:ratio] forKeyPath:@"progress"];
    }
}

/**
 *  stop showing progress indicator
 */
-(void)stopProgressIndicator
{
    if (self.progressView)
    {
        [self.progressView removeFromSuperview];
    }
}

#pragma mark - Event Handler
/**
 *  doubleTapped event handler
 */
-(void)doubleTapped:(UITapGestureRecognizer *)tapGesture
{
    CGPoint point = [tapGesture locationInView:self.zoomScrollView];
    
    if (self.zoomScrollView.maximumZoomScale - self.zoomScrollView.zoomScale < 0.001)
    {
        [self zoomToPointInRootView:point atScale:minZoom];
    }
    else
    {
        [self zoomToPointInRootView:point atScale:maxZoom];
    }
}

/**
 *  zooming for given center point
 *
 *  @param center zoom center
 *  @param scale  zoom scale
 */
- (void)zoomToPointInRootView:(CGPoint)center atScale:(float)scale
{
    CGRect zoomRect;
    zoomRect.size.height = [_zoomScrollView frame].size.height / scale;
    zoomRect.size.width  = [_zoomScrollView frame].size.width  / scale;
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    [_zoomScrollView zoomToRect:zoomRect animated:YES];
}

/**
 *  reset zooming state
 */
-(void)resetImageZoom
{
    self.zoomScrollView.zoomScale = 1.0;
    [self.zoomScrollView setNeedsDisplay];
}

#pragma mark UIScrollViewDelegate for InnerImageUnit
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _contentImageView;
}

@end

#pragma mark - ######### KJImageBrowserView Declare #########

#define InnerImageUnitTagBase (500)

@interface KJImageBrowserView () <UIScrollViewDelegate>

@property (nonatomic, assign) NSInteger currentImageIndex; //current showing Image Index, with the initial value -1
@property (nonatomic) UIScrollView *imageScrollView;
@property (nonatomic) UIImage *placeHolderImage;
@property (nonatomic) NSNumber *paddingDistance;
@property (nonatomic, weak) id<KJImageBrowerViewDelegate> delegate;
@property (nonatomic, assign) BOOL beSupportZoom;
@property (nonatomic, assign) BOOL beSupportDoubleTouch;
@property (nonatomic) UITapGestureRecognizer *singleTapGesture;
@property (nonatomic) NSMutableArray *photoViews;   //InnerImageUnit caches

@end

#pragma mark - ######### KJImageBrowserView implementation #########
@implementation KJImageBrowserView

/**
 *  Init KJImageBrowserView interface
 */
-(instancetype)initWithFrame:(CGRect)frame
                     padding:(NSNumber *)paddingDistance
            placeHolderImage:(UIImage *)placeHolderImage
                    delegate:(id<KJImageBrowerViewDelegate>)delegate
{
    if (self = [super initWithFrame:frame])
    {
        [self setClipsToBounds:YES];
        self.currentImageIndex = -1;
        self.backgroundColor = [UIColor blackColor];
        self.paddingDistance = paddingDistance? paddingDistance : [NSNumber numberWithInteger:0];
        self.placeHolderImage = placeHolderImage;
        self.beSupportZoom = YES;
        self.beSupportDoubleTouch = YES;
        
        if (delegate)
        {
            self.delegate = delegate;
            [self constructSingleTapGesture];
        }
        
        [self constructScrollContent];
    }
    
    return self;
}

/**
 *  Construct Single Tap Gesture
 */
-(void)constructSingleTapGesture
{
    if (_singleTapGesture)
    {
        return;
    }
    
    self.singleTapGesture = [[UITapGestureRecognizer alloc]
                             initWithTarget:self
                             action:@selector(singleTapped:)];

    _singleTapGesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:_singleTapGesture];
}

// Construct scrollview for composing InnerImageUnit
-(void)constructScrollContent
{
    CGRect frame = self.bounds;
    frame.origin.x -=[self.paddingDistance intValue];
    frame.size.width += 2 * [self.paddingDistance intValue];
    self.imageScrollView = [[UIScrollView alloc] initWithFrame:frame];
    [self.imageScrollView setBackgroundColor:self.backgroundColor];
    [_imageScrollView setPagingEnabled:YES];
    _imageScrollView.showsHorizontalScrollIndicator = NO;
    _imageScrollView.showsVerticalScrollIndicator = NO;
    _imageScrollView.multipleTouchEnabled = NO;
    [self addSubview:self.imageScrollView];
    
    _imageScrollView.delegate = self;
}

/**
 *  Update URL Data for browsering
 */
-(void)updateFirstURLArray:(NSArray *)firstLoadImageURLArray
       secondImageURLArray:(NSArray *)secondLoadImageURLArray
{
    self.firstLoadImageURLArray = firstLoadImageURLArray;
    self.secondLoadImageURLArray = secondLoadImageURLArray;
    
    //Reset Exhibition content
    [self resetImageExhibition];
}

/**
 *  Reset Exhibition content
 */
-(void)resetImageExhibition
{
    // clean subiviews
    NSArray *subViewArray = [self.imageScrollView subviews];
    for (UIView *view in subViewArray)
    {
        [view removeFromSuperview];
    }
    
    [self calcScrollViewContentSize];
    
    //expire function
//    [self constructInternViews];
  
    [self resetImageUnitCache];
    
    self.currentImageIndex = 0;
}

/**
 *  calculate ScrollView Conten tSize
 */
- (void)calcScrollViewContentSize
{
    NSInteger width = self.imageScrollView.frame.size.width;
    NSInteger height = self.imageScrollView.frame.size.height;
    NSInteger count = [_firstLoadImageURLArray count];
    NSInteger destWidth = count * width;
    self.imageScrollView.contentSize = CGSizeMake(destWidth, height/2);
    self.imageScrollView.contentOffset = CGPointZero;
}

/**
 * reset cache for image unit
 */
- (void)resetImageUnitCache
{
    NSInteger imageCount = [_firstLoadImageURLArray count];
    
    self.photoViews = [[NSMutableArray alloc] initWithCapacity:imageCount];
    for (int i=0; i < imageCount; i++)
    {
        [self.photoViews addObject:[NSNull null]];
    }
}

/**
 *  load image in dynamic loading way with current showing image index
 */
-(void)setCurrentImageIndex:(NSInteger)currentImageIndex
{
    _currentImageIndex = currentImageIndex;
    [self loadImageAtIndex:currentImageIndex];
    [self loadImageAtIndex:currentImageIndex - 1];
    [self loadImageAtIndex:currentImageIndex + 1];
    [self unloadImageView:currentImageIndex - 2];
    [self unloadImageView:currentImageIndex + 2];
}

/**
 *  showing the image correspond with the image index
 */
-(void)loadImageAtIndex:(NSInteger) imageIndex
{
    if (imageIndex >= [_firstLoadImageURLArray count] || imageIndex < 0)
    {
        return;
    }
    
#if KJBrowser_VerboseMode
    NSLog(@"######load index = %d",imageIndex);
#endif
    
    id currentPhotoView = self.photoViews[imageIndex];
    if (NO == [currentPhotoView isKindOfClass:[InnerImageUnit class]])
    {
        NSInteger width = self.imageScrollView.frame.size.width;
        NSInteger height = self.imageScrollView.frame.size.height;
        NSURL *firstImageURL = _firstLoadImageURLArray[imageIndex];
        NSURL *secondImageURL = nil;
        if (_secondLoadImageURLArray)
        {
            secondImageURL = _secondLoadImageURLArray[imageIndex];
        }
        
        CGRect frame = CGRectMake(imageIndex * width + [self.paddingDistance intValue],
                                  0,
                                  width - 2 * [self.paddingDistance intValue],
                                  height);
        
        InnerImageUnit *imageUnit = [[InnerImageUnit alloc] initWithFrame:frame
                                                            firstImageURL:firstImageURL
                                                           secondImageURL:secondImageURL
                                                         placeHolderImage:self.placeHolderImage
                                                              zoomSupport:self.beSupportZoom
                                                       doubleTouchSupport:self.beSupportDoubleTouch
                                                       indicatorClassName:self.indicatorClassName
                                                        progressClassName:self.progressViewName];
        
        [_imageScrollView addSubview:imageUnit];
        imageUnit.tag = InnerImageUnitTagBase + imageIndex;
        [self.photoViews replaceObjectAtIndex:imageIndex withObject:imageUnit];
        [_imageScrollView setClipsToBounds:YES];
        
        if (imageUnit.doubleTapGesture)
        {
            [self.singleTapGesture requireGestureRecognizerToFail:imageUnit.doubleTapGesture];
        }
    }
}

/**
 *  unload InnerImageUnit with imageIndex
 */
- (void)unloadImageView:(NSInteger)imageIndex
{
    if (imageIndex < 0 || imageIndex >= [_firstLoadImageURLArray count])
    {
        return;
    }
    
#if KJBrowser_VerboseMode
    NSLog(@"######unload index = %d",imageIndex);
#endif
    
    id currentPhotoView = [self.photoViews objectAtIndex:imageIndex];
    if ([currentPhotoView isKindOfClass:[InnerImageUnit class]])
    {
        [currentPhotoView removeFromSuperview];
        [self.photoViews replaceObjectAtIndex:imageIndex withObject:[NSNull null]];
    }
}

/**
 *  deprecated method for static constructing InnerImageUnit
 */
-(void)constructInternViews __deprecated_msg("no use for dynamic loader InnerImageUnit");
{
    NSInteger width = self.imageScrollView.frame.size.width;
    NSInteger height = self.imageScrollView.frame.size.height;
    NSInteger imageCount = [_firstLoadImageURLArray count];
    if (imageCount > 0)
    {
        _currentImageIndex = 0;
    }
    
    for (int i = 0; i < imageCount; ++i)
    {
        NSURL *firstImageURL = _firstLoadImageURLArray[i];
        NSURL *secondImageURL = nil;
        if (_secondLoadImageURLArray)
        {
            secondImageURL = _secondLoadImageURLArray[i];
        }
        
        CGRect frame = CGRectMake(i * width + [self.paddingDistance intValue],
                                  0,
                                  width - 2 * [self.paddingDistance intValue],
                                  height);
        
        InnerImageUnit *imageUnit = [[InnerImageUnit alloc] initWithFrame:frame
                                                            firstImageURL:firstImageURL
                                                           secondImageURL:secondImageURL
                                                         placeHolderImage:self.placeHolderImage
                                                              zoomSupport:self.beSupportZoom
                                                       doubleTouchSupport:self.beSupportDoubleTouch
                                                       indicatorClassName:self.indicatorClassName
                                                        progressClassName:self.progressViewName];
        [_imageScrollView addSubview:imageUnit];
        imageUnit.tag = InnerImageUnitTagBase + i;
        
        if (imageUnit.doubleTapGesture)
        {
            [self.singleTapGesture requireGestureRecognizerToFail:imageUnit.doubleTapGesture];
        }
    }
}

#pragma mark - GestureTappedCallback
-(void)singleTapped:(UITapGestureRecognizer *)singleTapped
{
    if (_delegate && [_delegate respondsToSelector:@selector(onTappedWithImageIndex:)])
    {
        [_delegate onTappedWithImageIndex:_currentImageIndex];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger pageIndex = floor(fractionalPage);
	if (pageIndex != self.currentImageIndex)
    {
		[self setCurrentImageIndex:pageIndex];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat width  = scrollView.frame.size.width;
    CGFloat offset = scrollView.contentOffset.x;
    NSInteger page = offset/width;
    
    NSInteger beforevalue = page - 1;
    NSInteger afterValue = page + 1;
    
    // reset zoom
    InnerImageUnit *beforeUnit = (InnerImageUnit *)[_imageScrollView viewWithTag:InnerImageUnitTagBase + beforevalue];
    InnerImageUnit *afterUnit = (InnerImageUnit *)[_imageScrollView viewWithTag:InnerImageUnitTagBase + afterValue];
    
    if (beforeUnit && [beforeUnit isKindOfClass:[InnerImageUnit class]])
    {
        [beforeUnit resetImageZoom];
    }
    
    if (afterUnit && [afterUnit isKindOfClass:[InnerImageUnit class]])
    {
        [afterUnit resetImageZoom];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(onScrollEndWithImageIndex:)])
    {
        [_delegate onScrollEndWithImageIndex:page];
    }
}

@end
