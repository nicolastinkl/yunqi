//
//  FacialView.m
//  KeyBoardTest
//
//  Created by wangqiulei on 11-8-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FacialView.h"
#import "UIView+Additon.h"
#import "DataHelper.h"
#import "GlobalData.h"

@implementation FacialView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) { 
    }
    return self;
}

-(void)loadFacialView:(int)page size:(CGSize)size
{
   	//row number
	for (int i=0; i<3; i++) {
		//column numer
		for (int y=0; y<7; y++) {
            
			UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundColor:[UIColor clearColor]];
            [button setFrame:CGRectMake(0+y*size.width,i*size.height,24, 24)];
            //Expression_100
            int index = (i*7 + y +(page*21));
            index += 1;
            NSString * name = [NSString stringWithFormat:@"Expression_%d",index];// [[GlobalData sharedGlobalData] facImageNameWithIndex:(i + y*3 +(page*21))];
            [button setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
            button.tag = index;
			[button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:button];
		}
	}
}

-(void)selected:(UIButton*)bt
{
    if (delegate) {
        NSString * name =  [NSString stringWithFormat:@"%d",bt.tag];//[[GlobalData sharedGlobalData] facImageNameWithIndex:(bt.tag)];
//        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(selectedFacialView:) object:name];
//        [self performSelector:@selector(selectedFacialView:) withObject:name afterDelay:0.3];
        [delegate selectedFacialView:name];
    }
}

-(void)selectedFacialView:(NSString*)name
{
    [delegate selectedFacialView:name];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/ 
@end
