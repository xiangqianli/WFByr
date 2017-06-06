//
//  WFHelpers.m
//  WFByr
//
//  Created by Andy on 2017/5/25.
//  Copyright © 2017年 andy. All rights reserved.
//
#import "WFHelpers.h"
#import "WFModels.h"
#import "MBProgressHUD.h"
#import "Reachability.h"


BOOL wf_checkToken(WFToken *aToken) {
#warning todo
    if (!aToken.accessToken) {
        return false;
    }
    return true;
}


BOOL wf_checkByrReachable() {
    //Reachability *reach = [Reachability reachabilityWithHostName:@"https://bbs.byr.cn"];
    return true;
}

NSString *wf_formatDateWithNowAndPast(NSDate *now, NSDate *past) {
    NSTimeInterval oneMinute = 60;
    NSTimeInterval oneHour = oneMinute * 60;
    NSTimeInterval oneDay  = oneHour * 24;
    
    NSTimeInterval seconds = now.timeIntervalSince1970 - past.timeIntervalSince1970;
    
    if (seconds / oneDay >= 1) return [NSString stringWithFormat:@"%.0f天前", seconds / oneDay];
    else if (seconds / oneHour >= 1) return [NSString stringWithFormat:@"%.0f小时前", seconds / oneHour];
    else if (seconds / oneMinute >= 1) return [NSString stringWithFormat:@"%.0f分钟前", seconds / oneMinute];
    else return @"刚刚";
}

NSURL *wf_saveImage(UIImage *image, NSString *name) {
    NSString *dir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSURL *fileUrl = [NSURL fileURLWithPath:[dir stringByAppendingPathComponent:name]];
    NSData *data = UIImageJPEGRepresentation(image, 1);
    NSError *err3;
    if (![data writeToURL:fileUrl options:NSDataWritingAtomic error:&err3]) {
        NSLog(@"save error:%@", err3);
        return nil;
    }
    
    return fileUrl;
}

void wf_showHud(UIView *toView, NSString *text, CGFloat duration) {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:toView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:duration];
}
