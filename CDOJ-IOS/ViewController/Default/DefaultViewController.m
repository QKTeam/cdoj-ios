//
//  DefaultViewController.m
//  CDOJ-IOS
//
//  Created by GuessEver on 16/8/9.
//  Copyright © 2016年 UESTCACM QKTeam. All rights reserved.
//

#import "DefaultViewController.h"

@implementation DefaultViewController

- (instancetype)init {
    if(self = [super init]) {
        [self.view setBackgroundColor:[ColorSchemeModel defaultColorScheme].backgroundColor2];
    }
    return self;
}

@end
