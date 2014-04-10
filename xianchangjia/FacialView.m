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
            [button setFrame:CGRectMake(0+y*size.width,i*size.height,42, 42)];
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
    NSArray *emjArray = @[@"[微笑]",@"[撇嘴]",@"[色]@",@"[发呆]",@"[墨镜]",@"[哭]",@"[羞]@",@"[闭嘴]",@"[睡]",@"[大哭]",@"[尴尬]",@"[发怒]",@"[调皮]",@"[呲牙]",@"[惊讶]",@"[难过]",@"[酷]",@"[汗]",@"[抓狂]",@"[吐] ",@"[笑]",@"[快乐]",@"[奇]",@"[傲]",@"[饿]",@"[累]",@"[吓]",@"[汗]",@"[高兴]",@"[闲]",@"[努力]",@"[骂]",@"[疑问]",@"[秘密]",@"[乱]",@"[疯]",@"[哀]",@"[鬼]",@"[打击]",@"[bye]",@"[汗]",@"[抠]",@"[鼓掌]",@"[糟糕]",@"[恶搞]",@"[什么]",@"[什么]",@"[累]",@"[看]",@"[难过]",@"[难过]",@"[坏]",@"[亲]",@"[吓]",@"[可怜]",@"[刀]",@"[水果]",@"[酒]",@"[篮球]",@"[乒乓]",@"[咖啡]",@"[美食]",@"[动物]",@"[鲜花]",@"[枯]",@"[唇]",@"[爱]",@"[分手]",@"[生日]",@"[电]",@"[炸弹]",@"[刀]",@"[足球]",@"[虫]",@"[臭]",@"[月亮]",@"[太阳]",@"[礼物]",@"[伙伴]",@"[赞]",@"[差]",@"[握手]",@"[优]",@"[恭]",@"[勾]",@"[顶]",@"[坏]",@"[爱]",@"[不]",@"[好的]",@"[爱]",@"[吻]",@"[跳]",@"[怕]",@"[尖叫]",@"[圈]",@"[拜]",@"[回头]",@"[跳]",@"[天使]",@"[激动]",@"[舞]",@"[吻]",@"[瑜伽]",@"[太极]"];
    if (delegate) {
        NSString * name;
        if (emjArray.count>bt.tag) {
            name = emjArray[bt.tag];
        }else{
            name = @"[微笑]";
        }

        //        NSString * name =  [NSString stringWithFormat:@"%d",bt.tag];
//        [[GlobalData sharedGlobalData] facImageNameWithIndex:(bt.tag)];
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
