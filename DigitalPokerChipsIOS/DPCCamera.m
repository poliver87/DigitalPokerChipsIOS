//
//  DPCCamera.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 4/04/14.
//
//

#import "DPCCamera.h"
#import "CCDirector.h"
#import "DPCGame.h"

@interface DPCCamera () {
    float zoomMargin;
    float panMargin;
    float maxCameraDelta;
    
    float zoomLast;
    float yLast;
    float xLast;
    float yDest;
    float xDest;
    float zoomDest;
}
@end

@implementation DPCCamera

-(id) init {
    if (self = [super init]) {
        self.updateNeeded=true;
        CGSize screenSize=[[CCDirector sharedDirector] viewSize];
        zoomMargin=1/screenSize.width;
        panMargin=MAX(1,screenSize.height*0.003f);
        maxCameraDelta=(int) (screenSize.height*0.05f);
        CCLOG(@"zoomMargin: %f",zoomMargin);
    }
    return self;
}

-(void)setToPosition:(DPCCameraPosition*)cameraPosition {
    self.updateNeeded=true;
    x=cameraPosition.x;
    y=cameraPosition.y;
    zoom=cameraPosition.zoom;
    animationState=ANIM_NONE;
    [[[DPCGame sharedGame] getWorldLayer] cameraAtDestination];
}

-(void) sendToPosition:(DPCCameraPosition*)destPosition {
    if (fabsf(destPosition.zoom-zoom)>destPosition.zoom*zoomMargin&&
        (fabsf(destPosition.x-x)>panMargin||fabsf(destPosition.y-y)>panMargin)) {
        [self zoomAndPanTo:destPosition];
    } else if (fabsf(destPosition.zoom-zoom)>destPosition.zoom*zoomMargin) {
        [self zoomTo:destPosition];
    } else if (fabsf(destPosition.x-x)>panMargin||fabsf(destPosition.y-y)>panMargin) {
        [self panTo:destPosition];
    }
}

-(void) zoomTo:(DPCCameraPosition*)destPosition {
    animationState=ANIM_ZOOMING;
    zoomLast=zoom;
    zoomDest=destPosition.zoom;
}

-(void) panTo:(DPCCameraPosition*)destPosition {
    animationState=ANIM_PANNING;
    yLast=y;
    xLast=x;
    yDest=(int) destPosition.y;
    xDest=(int) destPosition.x;
}

-(void) zoomAndPanTo:(DPCCameraPosition*)destPosition {
    animationState=ANIM_ZOOMING_AND_PANNING;
    zoomLast=zoom;
    yLast=y;
    xLast=x;
    yDest=(int) destPosition.y;
    xDest=(int) destPosition.x;
    zoomDest=destPosition.zoom;
}

-(void) animate:(CCTime)delta {
    if (animationState==ANIM_ZOOMING) {
        float deltaZoom=delta*4.0f*(zoom-zoomDest);
        if (deltaZoom<-0.03f) {
            deltaZoom=-0.03f;
        } else if (deltaZoom>0.03f) {
            deltaZoom=0.03f;
        }
        zoom=zoom-deltaZoom;
        if (fabsf(zoom-zoomDest)<zoomDest*zoomMargin) {
            animationState=ANIM_NONE;
               [[[DPCGame sharedGame] getWorldLayer] cameraAtDestination];
        }
        self.updateNeeded=true;
    } else if (animationState==ANIM_PANNING) {
        float deltaY=delta*4.0f*(y-yDest);
        if (deltaY<-1*maxCameraDelta) {
            deltaY=-1*maxCameraDelta;
        } else if (deltaY>maxCameraDelta) {
            deltaY=maxCameraDelta;
        }
        y=y-deltaY;
        float travelRatio_=(y-yLast)/(yDest-yLast);
        x=x+travelRatio_*(xDest-xLast);
        if (fabsf(y-yDest)<panMargin&&
           fabsf(x-xDest)<panMargin) {
            animationState=ANIM_NONE;
            [[[DPCGame sharedGame] getWorldLayer] cameraAtDestination];
        }
        self.updateNeeded=true;
    } else if (animationState==ANIM_ZOOMING_AND_PANNING) {
        float deltaZoom=delta*4.0f*(zoom-zoomDest);
        if (deltaZoom<-0.03f) {
            deltaZoom=-0.03f;
        } else if (deltaZoom>0.03f) {
            deltaZoom=0.03f;
        }
        zoom=zoom-deltaZoom;
        float travelRatio=(zoomDest/zoom)*fabsf(zoom-zoomLast)/fabsf(zoomDest-zoomLast);
        y=travelRatio*(yDest-yLast)+yLast;
        x=travelRatio*(xDest-xLast)+xLast;
        if (fabsf(zoom-zoomDest)<zoomDest*zoomMargin&&
            fabsf(y-yDest)<panMargin&&
            fabsf(x-xDest)<panMargin) {
            animationState=ANIM_NONE;
            [[[DPCGame sharedGame] getWorldLayer] cameraAtDestination];
        }
        self.updateNeeded=true;
    }
}


-(void) updateLayer:(CCNode*)layer {
    self.updateNeeded=false;
    layer.scale=zoom;
    CGSize screenSize=[[CCDirector sharedDirector] viewSize];
    float xLayer=screenSize.width*0.5f-zoom*x;
    float yLayer=screenSize.height*0.5f-zoom*y;
    layer.position=CGPointMake(xLayer,yLayer);
}

-(CGPoint)convertScreenToWorld:(CGPoint)screenPoint {
    CGSize screenSize=[[CCDirector sharedDirector] viewSize];
    float newX=(screenPoint.x-screenSize.width*0.5f)/zoom+x;
    float newY=(screenPoint.y-screenSize.height*0.5f)/zoom+y;
    return CGPointMake(newX,newY);
}

+(float) getScreenTopInWorld:(DPCCameraPosition*)pos {
    CGSize screenSize=[[CCDirector sharedDirector] viewSize];
    return pos.y+(screenSize.height*0.5f)/pos.zoom;
}

@end
