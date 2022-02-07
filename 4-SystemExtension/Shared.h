#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

NSString *const kSEXTBundleID = @"com.daemonology.HostApp.SEXTDemo";
NSString *const kDevelopmentTeam = @(DEVELOPMENT_TEAM);

typedef void(^DAEPingReply)(pid_t pid, NSString* version);

@protocol DAESEXTOperations
- (void)pingWithReply:(DAEPingReply)reply;
@end

static NSString * GetSEXTMachName()
{
    NSString *const prefix = kDevelopmentTeam.length > 0 ? kDevelopmentTeam : @"endpoint-security";
    return [NSString stringWithFormat:@"%@.%@.xpc", prefix, kSEXTBundleID];
}

NS_ASSUME_NONNULL_END
