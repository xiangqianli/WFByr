//
//  WFReplyHeader.h
//  WFByr
//
//  Created by Andy on 2017/6/1.
//  Copyright © 2017年 andy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WFThread;

@interface WFReplyHeader : UIView

- (void)setupWithThread:(WFThread*)thread;

@end
