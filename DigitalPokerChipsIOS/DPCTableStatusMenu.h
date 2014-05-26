//
//  DPCTableStatusMenu.h
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 23/04/14.
//
//

#import <Foundation/Foundation.h>
#import "DPCSprite.h"
#import "DPCTextLabel.h"

@interface DPCTableStatusMenu : CCNode

@property NSString* nudgeName;
@property DPCSprite* background;
@property (nonatomic) DPCTextLabel* tableName;
@property DPCSprite* handle;
@property DPCSprite* leaveButton;
@property DPCTextLabel* leaveButtonLabel;
@property DPCSprite* bellButton;
@property CCNode* playerList;

-(void)setDimensions:(CGSize)screenSize;
-(void)setPositions:(CGSize)screenSize;
-(void)animate:(float)delta;
-(void)show;
-(void)remove;
-(void)disappear;
-(void)open;
-(void)close;
-(BOOL)menuShouldOpen;
-(void)syncStatusMenu:(NSArray*)playerList;
-(void)enableNudge:(NSString*)hostName;
-(void)disableNudge;
-(void)touchDragged:(CGPoint)touchPoint;

@end
