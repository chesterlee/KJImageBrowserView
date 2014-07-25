//
//  ImageBrowserViewController.h
//  ImageBrowser
//
//  Created by chester on 7/9/14.
//  Copyright (c) 2014 MLL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageBrowserViewController : UIViewController


/**
 *  大图数组 (请务必保证大图数量和小图数量一致，或其中一方不存在)
 */
@property (nonatomic, retain) NSArray *fullImageURLArray;

/**
 *  小图数组 (请务必保证大图数量和小图数量一致，或其中一方不存在)
 */
@property (nonatomic, retain) NSArray *thumbnailImageURLArray;


/**
 *  是否全屏幕
 */
@property (nonatomic, assign) BOOL beFullScreen;

@end
