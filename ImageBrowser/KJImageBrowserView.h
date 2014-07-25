//
//  KJImageBrowserView.h
//  Version 0.1
//  Created by chester lee on 7.25.14.
//

// This code is distributed under the terms and conditions of the MIT license.

// Copyright (c) 2014 chester lee<chester.lee0218@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>

/*
 use sample:

 NSArray *imageURLArray1 = [NSArray arrayWithObjects:imageURL1, imageURL2, imageURL3, imageURL4, nil];
 NSArray *imageURLArray2 = [NSArray arrayWithObjects:imageURL10, imageURL20, imageURL30, imageURL40, nil];
 
 
 KJImageBrowserView *imageBrower = [[KJImageBrowserView alloc]
                    initWithFrame:CGRectMake(50, 60, 800, 700)
                    padding:[NSNumber numberWithInt:10]
                    placeHolderImage:nil
                    delegate:self];

 imageBrower.indicatorClassName = @"ETActivityIndicatorView";
 imageBrower.progressViewName = @"DACircularProgressView";
 
 [imageBrower updateFirstURLArray:imageURLArray1 secondImageURLArray:imageURLArray2];
 [self.view addSubview:imageBrower];
 
 Done!!!
*/

@protocol KJImageBrowerViewDelegate <NSObject>

@optional

/**
 *  the callback function called when single tap on KJImageBrowserView
 */
-(void)onTappedWithImageIndex:(NSUInteger)imageIndex;

/**
 *  the callback function called when scrolling end to imageIndex page
 */
-(void)onScrollEndWithImageIndex:(NSUInteger)imageIndex;

@end

/**
 *  KJImageBrowerView:
 *  It provide the Simple View for the internet image browsering
 */
@interface KJImageBrowserView : UIView

/**
 *  First load image URL list (It'll not show any results if this given the value for nil),
 *  for loading small images regularly
 */
@property (nonatomic, retain) NSArray *firstLoadImageURLArray;

/**
 *  Second load image URL list (it can be nil), KJImageBrowserView will load it if exists.
 */
@property (nonatomic, retain) NSArray *secondLoadImageURLArray;


#pragma  mark - readonly property
/**
 *  The padding distance between to image
 */
@property (nonatomic, retain, readonly) NSNumber *paddingDistance;

/**
 *  The backgroundColor of the Browser, it's black if you don't specify a new color
 */
@property (nonatomic, retain, readonly) UIColor *backgroundColor;

/**
 *  Delegate for the KJImageBrowerViewDelegate protocol
 */
@property (nonatomic, weak, readonly) id<KJImageBrowerViewDelegate> delegate;

/**
 *  Placeholder image
 */
@property (nonatomic, retain, readonly) UIImage *placeHolderImage;

#pragma mark - zoom reference
/**
 *  Check if it suppport zooming
 */
@property (nonatomic, assign, readonly, getter = isSupportZoom) BOOL beSupportZoom;

/**
 *  Check if it suppport double tapped for zooming
 */
@property (nonatomic, assign, readonly, getter = isSupportDoubleTouch) BOOL beSupportDoubleTouch;

#pragma mark - waiting indicator and progress indicator
/**
 *  Waiting indicator class name
 *  Notice：this class MUST have the interface of -(void)startAnimating. In case the animation will not show up.
 */
@property (nonatomic, copy) NSString *indicatorClassName;

/**
 *  Progress indicator class name
 *  Notice: this class MUST have the public property "progress", In case the program cannot update the lastest progress for the progress indicator you provided
 */
@property (nonatomic, copy) NSString *progressViewName;

#pragma mark - interfaces

/**
 *  Update URL Data for browsering
 *
 *  @param firstLoadImageURLArray  first image url array
 *  @param secondLoadImageURLArray second image url array
 */
-(void)updateFirstURLArray:(NSArray *)firstLoadImageURLArray
       secondImageURLArray:(NSArray *)secondLoadImageURLArray;

/**
 *  KJImageBrowserView init interface
 *
 *  @param frame                frame             (cannot be nil)
 *  @param paddingDistance      padding distance  (can be nil)
 *  @param placeHolderImage     placeholder image (can be nil)
 *  @param delegate             the delegate      (can be nil)
 *
 *  @return KJImageBrowser instance
 */
-(instancetype)initWithFrame:(CGRect)frame
                     padding:(NSNumber *)paddingDistance
            placeHolderImage:(UIImage *)placeHolderImage
                    delegate:(id<KJImageBrowerViewDelegate>)delegate;

@end
