//
//  GRNDefaultScreenVC.h
//  GRNForceUpdate
//
//  Created by Zamani Kord David on 18/04/2016.
//  Copyright © 2016 Guarana Technologies inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GRNDefaultScreenVC : UIViewController

@property (strong, nonatomic) UIImage *launchImage;
@property (strong, nonatomic) NSString *installationUrl;
@property (strong, nonatomic) NSString *environment;

- (void)addVC:(UIViewController *)vc;

@end
