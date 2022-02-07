//
//  Shared.h
//  PrivilegedHelperDemo
//
//  Created by Alkenso (Vladimir Vashurkin) on 21.04.2021.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

NSString *const kPrivilegedHelperLabel = @"com.daemonology.DemoHelper";
NSString *const kPrivilegedHelperMachName = @"com.daemonology.demohelper.packager.xpc";


typedef void(^DAEInstallPackageCompletion)(const BOOL);

@protocol DAEPrivilegedOperations
- (void)installPackage:(NSURL *const)package completion:(DAEInstallPackageCompletion)completion;
@end

NS_ASSUME_NONNULL_END
