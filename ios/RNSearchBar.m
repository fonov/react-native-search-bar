#import "RNSearchBar.h"

#import <React/UIView+React.h>
#import <React/RCTEventDispatcher.h>

@interface RNSearchBar() <UISearchBarDelegate>

@end

@implementation RNSearchBar
{
    RCTEventDispatcher *_eventDispatcher;
    NSInteger _nativeEventCount;
    NSTimer *_timer;
    CGFloat horizontalOffsetCenter;
    CGFloat currentHorizontalOffset;
    CGFloat animationDuration;
    CGFloat animationPartLength;
    CGFloat timerInterval;
}

RCT_NOT_IMPLEMENTED(-initWithFrame:(CGRect)frame)
RCT_NOT_IMPLEMENTED(-initWithCoder:(NSCoder *)aDecoder)

- (instancetype)initWithEventDispatcher:(RCTEventDispatcher *)eventDispatcher
{
    timerInterval = 1.0/60;
    
    if ((self = [super initWithFrame:CGRectMake(0, 0, 1000, 44)])) {
        _eventDispatcher = eventDispatcher;
        self.delegate = self;
    }
    
    return self;
}

- (void) searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [_eventDispatcher sendTextEventWithType:RCTTextEventTypeBlur
                                   reactTag:self.reactTag
                                       text:searchBar.text
                                        key:nil
                                 eventCount:_nativeEventCount];
    
    if ([self.text length] == 0) {
        [self startAnimationToCenter];
    }
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self setShowsCancelButton:self._jsShowsCancelButton animated:YES];
    
    
    [_eventDispatcher sendTextEventWithType:RCTTextEventTypeFocus
                                   reactTag:self.reactTag
                                       text:searchBar.text
                                        key:nil
                                 eventCount:_nativeEventCount];
    
    if ([self.text length] == 0) {
        [self startAnimationToLeft];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    _nativeEventCount++;
    
    [_eventDispatcher sendTextEventWithType:RCTTextEventTypeChange
                                   reactTag:self.reactTag
                                       text:searchText
                                        key:nil
                                 eventCount:_nativeEventCount];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.onSearchButtonPress(@{
                               @"target": self.reactTag,
                               @"button": @"search",
                               @"searchText": searchBar.text
                               });
    
    if ([self.text length] == 0) {
        [self startAnimationToCenter];
    }
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.text = @"";
    [self resignFirstResponder];
    [self setShowsCancelButton:NO animated:YES];
    
    self.onCancelButtonPress(@{});
    
    [self startAnimationToCenter];
}

- (void)startAnimationToLeft;
{
    if (_timer != nil) {
        return;
    }
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:timerInterval
    target:self
    selector:@selector(animationToLeft)
    userInfo:nil
    repeats:YES];
    
    currentHorizontalOffset = [self positionAdjustmentForSearchBarIcon: UISearchBarIconSearch].horizontal;
}

- (void)animationToLeft;
{
    currentHorizontalOffset -= animationPartLength;
    
    if (currentHorizontalOffset < 0) {
        currentHorizontalOffset = 0;
        [_timer invalidate];
        _timer = nil;
    }
    
    [self setPositionAdjustment: UIOffsetMake(currentHorizontalOffset,0) forSearchBarIcon: UISearchBarIconSearch];
}

- (void)startAnimationToCenter;
{
    if (_timer != nil) {
        return;
    }
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:timerInterval
    target:self
    selector:@selector(animationToCenter)
    userInfo:nil
    repeats:YES];
    
    currentHorizontalOffset = [self positionAdjustmentForSearchBarIcon: UISearchBarIconSearch].horizontal;
}

- (void)animationToCenter;
{
    currentHorizontalOffset += animationPartLength;
    
    if (currentHorizontalOffset > horizontalOffsetCenter) {
        currentHorizontalOffset = horizontalOffsetCenter;
        [_timer invalidate];
        _timer = nil;
    }
    
    [self setPositionAdjustment: UIOffsetMake(currentHorizontalOffset,0) forSearchBarIcon: UISearchBarIconSearch];
}

- (void)reactSetFrame:(CGRect)frame
{
  [super reactSetFrame:frame];
    
    horizontalOffsetCenter = [self positionAdjustmentForSearchBarIcon: UISearchBarIconSearch].horizontal;
    
    animationPartLength = horizontalOffsetCenter/(animationDuration ? animationDuration : 0.21)/60;
}

@end
