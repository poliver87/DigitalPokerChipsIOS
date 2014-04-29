//
//  DPCLeaveTableDialog.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 19/04/14.
//
//

#import "DPCLeaveTableDialog.h"
#import "DPCTextFactory.h"

@implementation DPCLeaveTableDialog

static const NSString* TITLE_STRING=@"Do you want to leave ";

-(id)init {
    if (self=[super init]) {
        _titleLabel=[DPCTextLabel node];
        [self addChild:_titleLabel];
        _okButton=[DPCSprite DPCSpriteWithFile:@"ok_button.png"];
        [self addChild:_okButton];
        _cancelButton=[DPCSprite DPCSpriteWithFile:@"cancel_button.png"];
        [self addChild:_cancelButton];
    }
    return self;
}

-(void) setRadiusX:(int)radiusX radiusY:(int)radiusY {
    [super setRadiusX:radiusX radiusY:radiusY];
    _titleLabel.string=[NSString stringWithFormat:@"%@ LONGNAME!?",TITLE_STRING];
    _titleLabel.fontSize=[DPCTextFactory getMaxTextSize:_titleLabel width:(int)(radiusX*1.7f) height:(int)(radiusY*0.4f)];
    _titleLabel.string=@"";
    [_okButton setRadiusX:radiusY*0.15f radiusY:radiusY*0.15f];
    [_cancelButton setRadiusX:radiusY*0.15f radiusY:radiusY*0.15f];
}

-(void) setPosition:(CGPoint)position {
    [super setPosition:position];
    [_titleLabel setPosition:ccp(0,self.yWindowRadius*0.86f)];
    [_okButton setPosition:ccp(self.xWindowRadius*0.78f,-self.yWindowRadius*0.78f)];
    [_cancelButton setPosition:ccp(-self.xWindowRadius*0.78f,-self.yWindowRadius*0.78f)];
}

-(void)setOpacity:(CGFloat)opacity {
    [super setOpacity:opacity];
    _titleLabel.opacity=opacity;
    _okButton.opacity=opacity;
    _cancelButton.opacity=opacity;
}

-(void)start {
    [super start];
    [_titleLabel fadeIn];
    [_okButton fadeIn];
    _okButton.touchable=YES;
    [_cancelButton fadeIn];
    _cancelButton.touchable=YES;
}

-(void)stop {
    [super stop];
    [_titleLabel fadeOut];
    [_okButton fadeOut];
    _okButton.touchable=NO;
    [_cancelButton fadeOut];
    _cancelButton.touchable=NO;
}

-(void)disappear {
    _titleLabel.opacity=0;
    _okButton.opacity=0;
    _okButton.touchable=NO;
    _cancelButton.opacity=0;
    _cancelButton.touchable=NO;
}

-(void) setTableName:(NSString*)tableName {
    _titleLabel.string=[NSString stringWithFormat:@"%@ %@?",TITLE_STRING,tableName];
}

-(void)animate:(float)delta {
    [super animate:delta];
    [_titleLabel animate:delta];
    [_okButton animate:delta];
    [_cancelButton animate:delta];
}

@end
