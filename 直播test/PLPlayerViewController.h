//
//  PLPlayerViewController.h
//  直播test
//
//  Created by Zeus on 2017/7/24.
//  Copyright © 2017年 Zeus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PLPlayerKit/PLPlayerKit.h>
//#import "QNDnsManager.h"


@interface PLPlayerViewController : UIViewController <PLPlayerDelegate>

@property(nonatomic, strong)PLPlayer *player;

@end
