//
//  NMViewController.m
//  Blur
//
//  Created by NayaMaal on 30/01/12
//  Copyright (c) 2012 NayaMaal. All rights reserved.
//

#import "NMViewController.h"
#import "UIImageView+Filters.h"

@interface NMViewController ()

@end


@implementation NMViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.imageView setImageToBlur:[UIImage imageNamed:@"example"]
                        blurRadius:kFiltersDefaultBlurRadius
                   completionBlock:^(NSError *error){
                       NSLog(@"Blurred image set");
                   }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
