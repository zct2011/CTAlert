//
//  ZHAlertView.h
//  Test
//
//  Created by zct on 12-10-25.
//  Copyright (c) 2012年. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 * show animation
 */
typedef enum {
	ZHAlertViewShowAnimationNone = 0,
	ZHAlertViewShowAnimationPop,
	ZHAlertViewShowAnimationDrop,
	ZHAlertViewShowAnimationSlide
} ZHAlertViewShowAnimation;

/*
 * dismiss animation
 */
typedef enum {
	ZHAlertViewDismissAnimationNone = 0,
	ZHAlertViewDismissAnimationDrop,
	ZHAlertViewDismissAnimationSlide
} ZHAlertViewDismissAnimation;


@protocol ZHAlertViewDelegate;
@interface ZHAlertView : UIView {
@private
	id<ZHAlertViewDelegate> _delegate;
	NSString *_message;
	UIColor *_borderColor;
	UIColor *backgroundColor;
	UIColor *textColor;
	BOOL _visible;
}

@property (nonatomic, assign) id<ZHAlertViewDelegate> delegate;
@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, copy) NSString *message;

- (id)initWithTitle:(NSString *)title 
			message:(NSString *)message
	  okButtonTitle:(NSString *)okButtonTitle;
- (id)initWithTitle:(NSString *)title 
			message:(NSString *)message 
		   delegate:(id<ZHAlertViewDelegate>)delegate 
  cancelButtonTitle:(NSString *)cancelButtonTitle 
	  okButtonTitle:(NSString *)okButtonTitle;

- (void)show;
- (void)showWithAnimation:(ZHAlertViewShowAnimation)animation;
- (void)dismiss;
- (void)dismissWithAnimation:(ZHAlertViewDismissAnimation)animationType;

@end

/////////////////////////////////////////////////

@protocol ZHAlertViewDelegate <NSObject>

@optional
- (void)didOkButtonClicked:(ZHAlertView *)alert;
- (void)didCancelButtonClicked:(ZHAlertView *)alert;

@end
