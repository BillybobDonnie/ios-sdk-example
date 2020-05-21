/*
 * ViewController.m
 * ChartboostExampleApp
 *
 * Copyright (c) 2013 Chartboost. All rights reserved.
 */

#import "ViewController.h"
#import <Chartboost/Chartboost.h>
#import <Chartboost/CBAnalytics.h>
#import <Chartboost/CHBInterstitial.h>
#import <Chartboost/CHBRewarded.h>
#import <Chartboost/CHBBanner.h>

@interface ViewController () <CHBInterstitialDelegate, CHBRewardedDelegate, CHBBannerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong) CHBInterstitial *interstitial;
@property (nonatomic, strong) CHBRewarded *rewarded;
@property (nonatomic, strong) CHBBanner *banner;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.interstitial = [[CHBInterstitial alloc] initWithLocation:CBLocationDefault delegate:self];
    self.rewarded = [[CHBRewarded alloc] initWithLocation:CBLocationDefault delegate:self];
    self.banner = [[CHBBanner alloc] initWithSize:CHBBannerSizeStandard location:CBLocationDefault delegate:self];
}

- (IBAction)cacheInterstitial:(id)sender {
    // If the interstitial is not cached didShowAd:error: will be called with an error.
    [self.interstitial cache];
}

- (IBAction)showInterstitial:(id)sender {
    [self.interstitial showFromViewController:self];
}

- (IBAction)cacheRewarded:(id)sender {
    [self.rewarded cache];
}

- (IBAction)showRewarded:(id)sender {
    // We can let showFromViewController: fail for not-cached ads as we do in cacheInterstitial:, or preemtively check against the isCached property before calling it:
    if (self.rewarded.isCached) {
        [self.rewarded showFromViewController:self];
    } else {
        [self log:@"Cache a rewarded ad before showing it"];
    }
}

- (IBAction)showSupport:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://answers.chartboost.com"]];
}

- (IBAction)showBanner:(id)sender {
    if (!self.banner.superview) {
        [self layoutBanner];
    }
    [self.banner showFromViewController:self];
}

- (void)layoutBanner {
    [self.view addSubview:self.banner];
    self.banner.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutAnchor *bottomContainerAnchor = self.view.bottomAnchor;
    if (@available(iOS 11.0, *)) {
        bottomContainerAnchor = self.view.safeAreaLayoutGuide.bottomAnchor;
    }
    [NSLayoutConstraint activateConstraints:@[[self.banner.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
                                              [self.banner.bottomAnchor constraintEqualToAnchor:bottomContainerAnchor]]];
}

- (void)log:(NSString *)message
{
    NSLog(@"%@", message);
    self.textView.text = [NSString stringWithFormat:@"%@\n%@", self.textView.text, message];
}

// MARK: - CHBAdDelegate

- (void)didCacheAd:(CHBCacheEvent *)event error:(nullable CHBCacheError *)error {
    [self log:[NSString stringWithFormat:@"didCacheAd: %@ %@", [event.ad class], [self statusWithError:error]]];
}

- (void)willShowAd:(CHBShowEvent *)event error:(nullable CHBShowError *)error {
    [self log:[NSString stringWithFormat:@"willShowAd: %@ %@", [event.ad class], [self statusWithError:error]]];
}

- (void)didShowAd:(CHBShowEvent *)event error:(nullable CHBShowError *)error {
    [self log:[NSString stringWithFormat:@"didShowAd: %@ %@", [event.ad class], [self statusWithError:error]]];
}

- (BOOL)shouldConfirmClick:(CHBClickEvent *)event confirmationHandler:(void(^)(BOOL))confirmationHandler {
    [self log:[NSString stringWithFormat:@"shouldConfirmClick: %@", [event.ad class]]];
    return NO;
}

- (void)didClickAd:(CHBClickEvent *)event error:(nullable CHBClickError *)error {
    [self log:[NSString stringWithFormat:@"didClickAd: %@ %@", [event.ad class], [self statusWithError:error]]];
}

- (void)didFinishHandlingClick:(CHBClickEvent *)event error:(nullable CHBClickError *)error {
    [self log:[NSString stringWithFormat:@"didFinishHandlingClick: %@ %@", [event.ad class], [self statusWithError:error]]];
}

- (NSString *)statusWithError:(id)error
{
    return error ? [NSString stringWithFormat:@"FAILED (%@)", error] : @"SUCCESS";
}

// MARK: - CHBInterstitialDelegate

- (void)didDismissAd:(CHBDismissEvent *)event {
    [self log:[NSString stringWithFormat:@"didDismissAd: %@", [event.ad class]]];
}

// MARK: - CHBRewardedDelegate

- (void)didEarnReward:(CHBRewardEvent *)event {
    [self log:[NSString stringWithFormat:@"didEarnReward: %ld", (long)event.reward]];
}

@end