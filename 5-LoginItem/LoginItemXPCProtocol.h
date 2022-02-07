//
//  LoginItemXPCProtocol.h
//  LoginItem
//
//  Created by Alkenso (Vladimir Vashurkin) on 14.05.2021.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@protocol DAELoginItemProtocol

- (void)retrieveVersionWithReply:(void(^)(NSString *const version))reply;

@end

NS_ASSUME_NONNULL_END
