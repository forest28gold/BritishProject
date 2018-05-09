//
//  GRNForceUpdate.h
//  GRNForceUpdate
//
//  Created by Zamani Kord David on 18/04/2016.
//  Copyright © 2016 Guarana Technologies inc. All rights reserved.
//

#define EnvAppStore @"AS"
#define EnvTestFlight @"TF"
#define EnvCrashlytics @"CL"
#define EnvEnterprise @"EP"

#import "GRNDefaultScreenVC.h"

@interface ForceUpdate : NSObject

/**
 *  Get GRNDefaultScreenVC initialized with the project launchscreen.
 *
 *  @param installationUrl      The url to download and install the update
 *  @param environment          The environment target
 *
 *  @return UIViewController loaded
 */
+ (UIViewController *)getViewController:(NSString *)installationUrl environment:(NSString *)environment;

/**
 *  Check if the current build is outdated.
 *
 *  @param minVersion   The minimal version to run the app
 *  @param buildNumber  The minimal build number to run the app
 *  @param environment  The environment target
 *
 *  @return YES if the build is outdated
 */
+ (BOOL)isBuildOutdated:(NSString *)minVersion buildNumber:(NSString *)buildNumber environment:(NSString *)environment;

@end
