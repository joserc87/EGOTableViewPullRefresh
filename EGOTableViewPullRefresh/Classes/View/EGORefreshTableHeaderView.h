//
//  EGORefreshTableHeaderView.h
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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum{
	EGOOPullRefreshPulling = 0,
	EGOOPullRefreshNormal,
	EGOOPullRefreshLoading,
} EGOPullRefreshState;

@protocol EGORefreshTableHeaderDelegate;
/**
 * Cocoa control for the pull-to-refresh view.
 *
 * To use this control:
 *
 * 1. Create an object of EGORefreshTableHeaderView.
 * 2. Add this object as a subview of your UITableView object.
 * 3. Implement the protocol EGORefreshTableHeaderDelegate in your class
 * (for example, in your UITableViewController class).
 * 4. Assign a object of this class as the delegate of the control.
 */
@interface EGORefreshTableHeaderView : UIView {
	id _delegate;
	EGOPullRefreshState _state;
    
	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	CALayer *_arrowImage;
	UIActivityIndicatorView *_activityView;
}
/** The delegate, implementing the EGORefreshTableHeaderDelegate */
@property(nonatomic,assign) id delegate;

#pragma mark - Customization

/** The color of the text */
@property(nonatomic,retain) UIColor *textColor;
/** Use shadow in the text? */
@property(nonatomic, assign) BOOL textShadowEnabled;
/** Shadow color of the text*/
@property(nonatomic, retain) UIColor *textShadowColor;
/** The image used for the arrow */
@property(nonatomic,retain) NSString *arrowImagePath;
/** The position of the arrow, in x */
@property(nonatomic, assign) CGFloat arrowXPosition;
/** The position of the activity indicator, in x */
@property(nonatomic, assign) CGFloat activityXPosition;

/**
 * Asks the view to refresh the date
 */
- (void)refreshLastUpdatedDate;

/**
 * Tell the view that the containing scroll view did scroll
 * @param scrollView The containing scroll view
 */
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;

/**
 * Tell the view that the user finished dragging the containing scroll view
 * @param scrollView The containing scroll view
 */
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;

/**
 * Tell the view that the model has been updated, so the control can go back to the normal state
 * @param scrollView The containing scroll view
 */
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

@end


/**
 * Delegate for the class EGORefreshTableHeaderView.
 */
@protocol EGORefreshTableHeaderDelegate

/**
 * Tells the delegate that the user triggered the refresh
 * @param view The control
 * @note This method is mandatory
 */
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view;

/**
 * Ask the delegate if the model is being updated
 * @param view The control
 * @note This method is mandatory
 */
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view;
@optional

/**
 * Ask the delegate for the date of the last modification
 * @param view The control
 * @note This method is optional
 */
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view;

@end
