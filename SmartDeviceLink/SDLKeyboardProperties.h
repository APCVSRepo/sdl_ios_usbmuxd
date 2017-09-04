//  SDLKeyboardProperties.h
//

#import "SDLRPCMessage.h"

@class SDLLanguage;
@class SDLKeyboardLayout;
@class SDLKeypressMode;


@interface SDLKeyboardProperties : SDLRPCStruct {
}

- (instancetype)init;
- (instancetype)initWithDictionary:(NSMutableDictionary *)dict;

// TODO: (Alex M.)[2016-12-1] Add missing generic
- (instancetype)initWithLanguage:(SDLLanguage *)language layout:(SDLKeyboardLayout *)layout keypressMode:(SDLKeypressMode *)keypressMode limitedCharacterList:(NSArray *)limitedCharacterList autoCompleteText:(NSString *)autoCompleteText;

@property (strong) SDLLanguage *language;
@property (strong) SDLKeyboardLayout *keyboardLayout;
@property (strong) SDLKeypressMode *keypressMode;
@property (strong) NSMutableArray *limitedCharacterList;
@property (strong) NSString *autoCompleteText;

@end
