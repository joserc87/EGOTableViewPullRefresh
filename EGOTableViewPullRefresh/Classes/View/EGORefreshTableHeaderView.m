//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGORefreshTableHeaderView.h"

#define DEFAULT_BACKGROUND_COLOR    [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
#define DEFAULT_TEXT_COLOR          [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define DEFAULT_TEXT_SHADOW_COLOR   [UIColor colorWithWhite:0.9f alpha:1.0f]
#define DEFAULT_ARROW_POS_X         25.0f
#define DEFAULT_ARROW_IMAGE         "grayArrow"
#define DEFAULT_ACTIVITY_POS_X      25.0f

#define FLIP_ANIMATION_DURATION     0.18f


@interface EGORefreshTableHeaderView (Private)
- (void)setState:(EGOPullRefreshState)aState;
@end

@implementation EGORefreshTableHeaderView

@synthesize delegate=__delegate;
@synthesize textColor = _textColor;
@synthesize arrowImagePath = _arrowImagePath;
@synthesize arrowXPosition = _arrowXPosition;
@synthesize activityXPosition = _activityXPosition;

#pragma mark - Properties

/**************************************************************************************************/
/**************************************************************************************************/

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    _lastUpdatedLabel.textColor = textColor;
    _statusLabel.textColor = textColor;
    [textColor retain];
}

/**************************************************************************************************/
/**************************************************************************************************/

- (void)setTextShadowEnabled:(BOOL)textShadowEnabled
{
    _textShadowEnabled = textShadowEnabled;
    if (_textShadowEnabled){
        _lastUpdatedLabel.shadowOffset = CGSizeMake(1.0f, 0.0f);
        _statusLabel.shadowOffset = CGSizeMake(1.0f, 0.0f);
    }else{
        _lastUpdatedLabel.shadowOffset = CGSizeMake(0.0f, 0.0f);
        _statusLabel.shadowOffset = CGSizeMake(0.0f, 0.0f);
    }
}

/**************************************************************************************************/
/**************************************************************************************************/

- (void)setTextShadowColor:(UIColor *)textShadowColor
{
    _textShadowColor = textShadowColor;
    _lastUpdatedLabel.shadowColor = textShadowColor;
    _statusLabel.shadowColor = textShadowColor;
    [textShadowColor retain];
}

/**************************************************************************************************/
/**************************************************************************************************/

- (void)setArrowImagePath:(NSString *)arrowImagePath
{
    _arrowImagePath = arrowImagePath;
    _arrowImage.contents = (id)[UIImage imageNamed:arrowImagePath].CGImage;
    [arrowImagePath retain];
}

/**************************************************************************************************/
/**************************************************************************************************/

- (void)setArrowXPosition:(CGFloat)arrowXPosition
{
    _arrowXPosition = arrowXPosition;
    _arrowImage.frame = CGRectMake(arrowXPosition, self.frame.size.height - 65.0f, 30.0f, 55.0f);
}

/**************************************************************************************************/
/**************************************************************************************************/

- (void)setActivityXPosition:(CGFloat)activityXPosition
{
    _activityXPosition = activityXPosition;
    _activityView.frame = CGRectMake(activityXPosition, self.frame.size.height - 38.0f, 20.0f, 20.0f);
}

/**************************************************************************************************/
/**************************************************************************************************/

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:12.0f];
		
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_lastUpdatedLabel=label;
		[label release];
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont boldSystemFontOfSize:13.0f];
        
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;
		[label release];
        
		CALayer *layer = [CALayer layer];
		layer.contentsGravity = kCAGravityResizeAspect;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:layer];
		_arrowImage=layer;
		
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		[self addSubview:view];
		_activityView = view;
		[view release];
		
        // Default setup
        self.backgroundColor = DEFAULT_BACKGROUND_COLOR;
		self.textColor = DEFAULT_TEXT_COLOR;
        self.textShadowEnabled = YES;
        self.textShadowColor = DEFAULT_TEXT_SHADOW_COLOR;
        self.arrowXPosition = DEFAULT_ARROW_POS_X;
        self.arrowImagePath = @DEFAULT_ARROW_IMAGE;
        self.activityXPosition = DEFAULT_ACTIVITY_POS_X;
        
		[self setState:EGOOPullRefreshNormal];
		
    }
	
    return self;
	
}

/**************************************************************************************************/
/**************************************************************************************************/

#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate
{
	
	if ([__delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
		
		NSDate *date = [__delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setAMSymbol:NSLocalizedString(@"AM", @"Time")];
		[formatter setPMSymbol:NSLocalizedString(@"PM", @"Time")];
		[formatter setDateFormat:@"MM/dd/yyyy hh:mm:a"];
		_lastUpdatedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Last Updated: %@", nil), [formatter stringFromDate:date]];
		[[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		//[formatter release];
		
	} else {
		
		_lastUpdatedLabel.text = nil;
		
	}
    
}

/**************************************************************************************************/
/**************************************************************************************************/

- (void)setState:(EGOPullRefreshState)aState
{
	
	switch (aState) {
		case EGOOPullRefreshPulling:
			
			_statusLabel.text = NSLocalizedString(@"Release to refresh...", @"Release to refresh status");
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			
			break;
		case EGOOPullRefreshNormal:
			
			if (_state == EGOOPullRefreshPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			
			_statusLabel.text = NSLocalizedString(@"Pull down to refresh...", @"Pull down to refresh status");
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
            if (_state == EGOOPullRefreshLoading)
                [self refreshLastUpdatedDate];
			
			break;
		case EGOOPullRefreshLoading:
			
			_statusLabel.text = NSLocalizedString(@"Loading...", @"Loading Status");
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			_arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
	_state = aState;
}

/**************************************************************************************************/
/**************************************************************************************************/

#pragma mark -
#pragma mark ScrollView Methods

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView
{
	
	if (_state == EGOOPullRefreshLoading) {
		
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, 60);
		scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
		
	} else if (scrollView.isDragging) {
		
		BOOL _loading = NO;
		if ([__delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
			_loading = [__delegate egoRefreshTableHeaderDataSourceIsLoading:self];
		}
		
		if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_loading) {
			[self setState:EGOOPullRefreshNormal];
		} else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_loading) {
			[self setState:EGOOPullRefreshPulling];
		}
		
		if (scrollView.contentInset.top != 0) {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
		
	}
	
}

/**************************************************************************************************/
/**************************************************************************************************/

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView
{
	
	BOOL _loading = NO;
	if ([__delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
		_loading = [__delegate egoRefreshTableHeaderDataSourceIsLoading:self];
	}
	
	if (scrollView.contentOffset.y <= - 65.0f && !_loading) {
		
		[self setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
		
        if ([__delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
			[__delegate egoRefreshTableHeaderDidTriggerRefresh:self];
		}
	}
	
}

/**************************************************************************************************/
/**************************************************************************************************/

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView
{
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[self setState:EGOOPullRefreshNormal];
    
}

/**************************************************************************************************/
/**************************************************************************************************/

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	__delegate=nil;
	_activityView = nil;
	_statusLabel = nil;
	_arrowImage = nil;
	_lastUpdatedLabel = nil;
    [_textColor release];
    [_textShadowColor release];
    [_arrowImagePath release];
    [super dealloc];
}

/**************************************************************************************************/
/**************************************************************************************************/

@end
