//
//  ZHAlertView.m
//  Test
//
//  Created by do1 do1 on 12-10-25.
//  Copyright (c) 2012年. All rights reserved.
//

#import "ZHAlertView.h"

#import "ZHButton.h"

////////////////////////////////////////////////////

@interface ZHAlertWindow : UIWindow {
	UIWindow *_previousKeyWindow;
	UIView *_dimView;
	NSMutableArray *_alertViews;
}

@property (nonatomic, retain) UIWindow *previousKeyWindow;
@property (nonatomic, readonly) UIView *dimView;
@property (nonatomic, readonly) NSMutableArray *alertViews;

+ (void)pushAlertView:(ZHAlertView *)alertView;
+ (void)popAlertView;

@end

////////////////////////////////////////////////////

static ZHAlertWindow *alertWindow = nil;

@implementation ZHAlertWindow

@synthesize previousKeyWindow = _previousKeyWindow;
@synthesize dimView = _dimView;
@synthesize alertViews = _alertViews;

- (id)init
{
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	self = [super initWithFrame:screenBounds];
	if (self) {
		self.windowLevel = UIWindowLevelAlert;
		//previous key window
		self.previousKeyWindow = [[UIApplication sharedApplication] keyWindow];
		//dim view
		UIView *dimView = [[UIView alloc] initWithFrame:self.bounds];
		_dimView = [dimView retain];
		dimView.backgroundColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.5f];
		dimView.userInteractionEnabled = YES;
		[self addSubview:dimView];
		[dimView release];
		//alert views
		NSMutableArray *alertViews = [[NSMutableArray alloc] init];
		_alertViews = [alertViews retain];
		[alertViews release];
	}
	return self;
}

- (void)dealloc
{
	[_previousKeyWindow release];
	[_dimView release];
	[_alertViews release];
	[super dealloc];
}

+ (void)pushAlertView:(ZHAlertView *)alertView
{
	if (!alertWindow) {
		NSLog(@"******************* create alert window *******************");
		alertWindow = [[ZHAlertWindow alloc] init];
		[alertWindow makeKeyAndVisible];
	}
	
	if ([alertWindow.alertViews count] > 0) {
		UIView *visibleAlertView = [alertWindow.alertViews lastObject];
		[visibleAlertView removeFromSuperview];
	}
	
	[alertWindow addSubview:alertView];
	[alertWindow.alertViews addObject:alertView];
}

+ (void)popAlertView
{
	if (alertWindow) {
		ZHAlertView *visibleAlertView = [alertWindow.alertViews lastObject];
		[visibleAlertView removeFromSuperview];
		[alertWindow.alertViews removeObject:visibleAlertView];
		
		if ([alertWindow.alertViews count] == 0) {
			[alertWindow.previousKeyWindow makeKeyWindow];
			[alertWindow release];
			alertWindow = nil;
			NSLog(@"******************* destroy alert window *******************");
		} else {
			UIView *lastVisibleAlertView = [alertWindow.alertViews lastObject];
			[alertWindow addSubview:lastVisibleAlertView];
		}
	}
}

+ (void)setDimViewAlpha:(CGFloat)alpha
{
	if (alertWindow) {
		alertWindow.dimView.alpha = alpha;
	}
}

@end

//////////////////////////////////////////


@interface ZHAlertView ()

@end

@implementation ZHAlertView

@synthesize delegate = _delegate;

- (id)init
{
	self = [super init];
	if (self) {
		_visible = NO;
		
		CGFloat const defaultWidth = 280.0f;
		CGFloat const defaultHeight = 200.0f;
		self.frame = CGRectMake(0, 0, defaultWidth, defaultHeight);
		super.backgroundColor = [UIColor clearColor];
		[self setNeedsDisplay];
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter addObserver:self selector:@selector(deviceOrientationDidChange)
								   name:UIDeviceOrientationDidChangeNotification object:nil];
		[notificationCenter addObserver:self selector:@selector(keyboardDidShow:) 
								   name:UIKeyboardWillShowNotification object:nil];
		[notificationCenter addObserver:self selector:@selector(keyboardDidHide:) 
								   name:UIKeyboardWillHideNotification object:nil];
		[notificationCenter addObserver:self selector:@selector(keyboardDidChangeFrame:) 
								   name:UIKeyboardDidChangeFrameNotification object:nil];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		_visible = NO;
		
		self.frame = frame;
		super.backgroundColor = [UIColor clearColor];
		[self setNeedsDisplay];
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter addObserver:self
							   selector:@selector(deviceOrientationDidChange)
								   name:UIDeviceOrientationDidChangeNotification
								 object:nil];
	}
	return self;
}

- (id)initWithTitle:(NSString *)title 
			message:(NSString *)message
	  okButtonTitle:(NSString *)okButtonTitle
{
	self = [self init];
	if (self) {
		self.message = message;
		UIFont *textFont = [UIFont systemFontOfSize:16.0f];
		CGSize textSize = [_message sizeWithFont:textFont
							   constrainedToSize:CGSizeMake(self.bounds.size.width - 30.0f, MAXFLOAT)
								   lineBreakMode:UILineBreakModeWordWrap];
		[self setFrame:CGRectMake(0, 0, 280.0f, textSize.height + 40.0f + 45.0f)];
		
		ZHButton *button = [[ZHButton alloc] initWithFrame:
							CGRectMake(self.bounds.size.width / 2.0f - 45.0f,
									   self.bounds.size.height - 50.0f, 80.0f, 42.0f)];
		[button setBackgroundColor:[UIColor colorWithRed:12.0f/255.0f
												   green:107.0f/255.0f
													blue:45.0f/255.0f
												   alpha:1.0f]];
		[button setTextColor:[UIColor whiteColor]];
		[button addTarget:self action:@selector(okButtonClicked:) 
		 forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:button];
		[button release];
	}
	return self;
}

- (id)initWithTitle:(NSString *)title 
			message:(NSString *)message 
		   delegate:(id<ZHAlertViewDelegate>)delegate 
  cancelButtonTitle:(NSString *)cancelButtonTitle 
	  okButtonTitle:(NSString *)okButtonTitle
{
	self = [self init];
	if (self) {
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)setFrame:(CGRect)frame
{
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	CGFloat width = frame.size.width;
	CGFloat height = frame.size.height;
	super.frame = CGRectMake((screenBounds.size.width - width) / 2.0f,
							(screenBounds.size.height - height) / 2.0f,
							width,
							height);
	[self setNeedsDisplay];
}

- (void)setMessage:(NSString *)message
{
	if (_message != message) {
		[_message release];
		_message = [message copy];
		[self setNeedsDisplay];
	}
}

- (NSString *)message
{
	return _message;
}

- (void)deviceOrientationDidChange
{
	[self changeOrientation:YES];
}

- (void)changeOrientation:(BOOL)animated
{
	UIDeviceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.3f];
	}
	
	[self setTransform:[self transformForOrientation:orientation]];
	
	if (animated) {
		[UIView commitAnimations];
	}
}

- (CGAffineTransform)transformForOrientation:(UIDeviceOrientation)orientation
{
	CGAffineTransform transform;
	switch (orientation) {
		case UIDeviceOrientationPortrait:
			transform = CGAffineTransformMakeRotation(M_PI_2 * 0);
			break;
		case UIDeviceOrientationPortraitUpsideDown:
			transform = CGAffineTransformMakeRotation(M_PI_2 * 2);
			break;
		case UIDeviceOrientationLandscapeLeft: 
			transform = CGAffineTransformMakeRotation(M_PI_2 * 1);
			break;
		case UIDeviceOrientationLandscapeRight: 
			transform = CGAffineTransformMakeRotation(M_PI_2 * 3);
			break;
		default:
			transform = CGAffineTransformIdentity; 
			break;
	}
	return transform;
}

- (void)okButtonClicked:(id)sender
{
	[self dismiss];
}

- (void)drawRect:(CGRect)rect
{
	CGFloat const radius = 10.0f;
	CGFloat const shadowWidth = 5.0f;
	CGContextRef context = UIGraphicsGetCurrentContext();
	//
	CGRect backgroundRect = CGRectMake(rect.origin.x + shadowWidth, 
									   rect.origin.y + shadowWidth,
									   rect.size.width - shadowWidth * 2,
									   rect.size.height - shadowWidth * 2);
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, backgroundRect.origin.x + radius, backgroundRect.origin.y);
	CGPathAddArcToPoint(path, NULL, 
						backgroundRect.origin.x + backgroundRect.size.width, 
						backgroundRect.origin.y, 
						backgroundRect.origin.x + backgroundRect.size.width, 
						backgroundRect.origin.y + radius,
						radius);
	CGPathAddArcToPoint(path, NULL,
						backgroundRect.origin.x + backgroundRect.size.width,
						backgroundRect.origin.y + backgroundRect.size.height,
						backgroundRect.origin.x + backgroundRect.size.width - radius,
						backgroundRect.origin.y + backgroundRect.size.height,
						radius);
	CGPathAddArcToPoint(path, NULL,
						backgroundRect.origin.x,
						backgroundRect.origin.y + backgroundRect.size.height,
						backgroundRect.origin.x,
						backgroundRect.origin.y + backgroundRect.size.height - radius,
						radius);
	CGPathAddArcToPoint(path, NULL, 
						backgroundRect.origin.x,
						backgroundRect.origin.y,
						backgroundRect.origin.x + radius,
						backgroundRect.origin.y, 
						radius);
	CGPathCloseSubpath(path);
	
	// Draw shadow
	CGContextAddPath(context, path);
	CGContextSetShadow(context, CGSizeMake(0, 3), shadowWidth);
	CGFloat red, green, blue, alpha;
	[self getRed:&red green:&green blue:&blue alpha:&alpha from:backgroundColor];
	CGContextSetRGBFillColor(context, red, green, blue, alpha);
	CGContextFillPath(context);
	
	//draw border
	if(_borderColor) {
		CGFloat r, g, b, a;
		[self getRed:&r green:&g blue:&b alpha:&a from:_borderColor];
		CGContextSetRGBStrokeColor(context, r, g, b, a);
		CGContextAddPath(context, path);
		CGContextDrawPath(context, kCGPathStroke);
	}
	
	//end
	CGPathRelease(path);
	
	//draw text
	UIFont *textFont = [UIFont systemFontOfSize:16.0f];
	CGSize textSize = [_message sizeWithFont:textFont
						   constrainedToSize:CGSizeMake(backgroundRect.size.width - 20.0f, MAXFLOAT)
							   lineBreakMode:UILineBreakModeWordWrap];
	[textColor set];
	[_message drawInRect:CGRectMake(backgroundRect.origin.x + 10.0f,
									backgroundRect.origin.y + 10.0f,
									textSize.width,
									textSize.height)
				withFont:textFont
		   lineBreakMode:UILineBreakModeWordWrap
			   alignment:UITextAlignmentCenter];
}

- (void)getRed:(CGFloat *)red green:(CGFloat *)green 
		  blue:(CGFloat *)blue alpha:(CGFloat *)alpha from:(UIColor *)color
{
	int numComponents = CGColorGetNumberOfComponents([color CGColor]);
	const CGFloat *components = CGColorGetComponents([color CGColor]);
	if (numComponents == 2) {
		*red = components[0];
		*green = components[0];
		*blue = components[0];
		*alpha = components[1];
	}
	else if (numComponents == 4) {
		*red = components[0];
		*green = components[1];
		*blue = components[2];
		*alpha = components[3];
	}
}

- (void)setBorderColor:(UIColor *)borderColor
{
	if (_borderColor != borderColor) {
		[_borderColor release];
		_borderColor = [borderColor retain];
		[self setNeedsDisplay];
	}
}

- (UIColor *)borderColor
{
	return _borderColor;
}

- (void)setBackgroundColor:(UIColor *)bgColor
{
	if (backgroundColor != bgColor) {
		[backgroundColor release];
		backgroundColor = [bgColor retain];
		[self setNeedsDisplay];
	}
}

- (UIColor *)backgroundColor
{
	return backgroundColor;
}

- (void)setTextColor:(UIColor *)txtColor
{
	if (textColor != txtColor) {
		[textColor release];
		textColor = [txtColor retain];
		[self setNeedsDisplay];
	}
}

- (UIColor *)textColor
{
	return textColor;
}

- (void)show
{
	[self showWithAnimation:ZHAlertViewShowAnimationPop];
}

- (void)showWithAnimation:(ZHAlertViewShowAnimation)animation
{
	if (_visible) {
		return;
	}
	
	[ZHAlertWindow pushAlertView:self];
	_visible = YES;

	[self changeOrientation:NO];
	
	//animation
	if (animation == ZHAlertViewShowAnimationPop) {
		UIDeviceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
		CGAffineTransform transform0 = [self transformForOrientation:orientation];
		// start a little smaller
		self.alpha = 0.0f;
		self.transform = CGAffineTransformScale(transform0, 0.75f, 0.75f);
	
		// animate to a bigger size
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(popAnimationDidStop:finished:context:)];
		[UIView setAnimationDuration:0.15f];
		self.alpha = 1.0f;
		self.transform = CGAffineTransformScale(transform0, 1.1f, 1.1f);
		[UIView commitAnimations];
	} else if (animation == ZHAlertViewShowAnimationDrop) {
		UIDeviceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
		CGAffineTransform transform0 = [self transformForOrientation:orientation];
		//prepare
		CGFloat yOffset = - self.frame.origin.y - self.frame.size.height;
		CGAffineTransform transform1 = CGAffineTransformTranslate(transform0, 0.0f, yOffset);
		self.transform = CGAffineTransformScale(transform1, 0.3f, 0.3f);
		
		//begin animation
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDuration:0.4f];
		self.transform = transform0;
		[UIView commitAnimations];
	} else if (animation == ZHAlertViewShowAnimationSlide) {
		UIDeviceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
		CGAffineTransform transform0 = [self transformForOrientation:orientation];
		//prepare
		self.alpha = 0.0f;
		self.transform = CGAffineTransformTranslate(transform0, 0.0f, -10.0f);
		
		//animation begin
		[UIView beginAnimations:nil context:nil];
		self.alpha = 1.0f;
		self.transform = transform0;
		[UIView commitAnimations];
	}
}

- (void)popAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	UIDeviceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	CGAffineTransform transform0 = [self transformForOrientation:orientation];
    // at the end set to normal size
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.1f];
	self.transform = transform0;
	[UIView commitAnimations];
}

- (void)dismiss
{
	[self dismissWithAnimation:ZHAlertViewDismissAnimationDrop];
}

- (void)dismissWithAnimation:(ZHAlertViewDismissAnimation)animationType {
	if (!_visible) {
		return;
	}
	
	if (animationType == ZHAlertViewDismissAnimationNone) {
		[self finaliseDismiss];
	} else if (animationType == ZHAlertViewDismissAnimationDrop) {
		UIDeviceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
		CGAffineTransform transform0 = [self transformForOrientation:orientation];
		//
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		[UIView setAnimationDuration:0.7f];
		//dimView.alpha = 0.0f;
		[ZHAlertWindow setDimViewAlpha:0.0f];
		CGAffineTransform transform1 = CGAffineTransformTranslate(transform0, 0.0f, 400);
		self.transform = CGAffineTransformRotate(transform1, -M_PI_4 / 2.0f);
		[UIView commitAnimations];
	} else if (animationType == ZHAlertViewDismissAnimationSlide) {
		UIDeviceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
		CGAffineTransform transform0 = [self transformForOrientation:orientation];
		//animate
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5f];
		//dimView.alpha = 0.0f;
		[ZHAlertWindow setDimViewAlpha:0.0f];
		self.alpha = 0.0f;
		self.transform = CGAffineTransformTranslate(transform0, 0.0f, 10.0f);
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		[UIView commitAnimations];
	}
}

- (void)finaliseDismiss 
{
	[ZHAlertWindow popAlertView];
	_visible = NO;
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[self finaliseDismiss];
}

#pragma mark - keyboard notifications

- (void)keyboardDidShow:(NSDictionary *)userInfo
{
	NSLog(@"keyboard did show with userInfo: \n%@", userInfo);
	UIView *firstResponder = nil;
	for (UIView *subview in self.subviews) {
		if ([subview isFirstResponder]) {
			firstResponder = subview;
			break;
		}
	}
	
	if (firstResponder && [firstResponder isKindOfClass:[UITextField class]]) {
		CGRect frame = firstResponder.frame;
		CGFloat toTop = self.frame.origin.y + frame.origin.y + frame.size.height;
		CGFloat const keyboardHeight = 264.0f;
		[self move:(keyboardHeight - toTop) duration:0.25f];
	}
}

- (void)keyboardDidHide:(NSDictionary *)userInfo
{
	[self moveBack:0.25f];
}

- (void)keyboardDidChangeFrame:(NSDictionary *)userInfo
{
}

- (void)move:(CGFloat)offset duration:(NSTimeInterval)duration
{
	UIDeviceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	CGAffineTransform transform0 = [self transformForOrientation:orientation];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:duration];
	self.transform = CGAffineTransformTranslate(transform0, 0, offset);
	[UIView commitAnimations];
}

- (void)moveBack:(NSTimeInterval)duration
{
	UIDeviceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	CGAffineTransform transform0 = [self transformForOrientation:orientation];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:duration];
	self.transform = transform0;
	[UIView commitAnimations];
}

@end
