//
//  AppDelegate.m
//  GoogleTransit
//
//  Created by Simon Maddox on 20/09/2012.
//  Copyright (c) 2012 Simon Maddox. All rights reserved.
//

#import "AppDelegate.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

@property (nonatomic, strong) NSString *currentSource;
@property (nonatomic, strong) NSString *currentDestination;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
	
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	
    return YES;
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
	[self.locationManager startUpdatingLocation];
}

- (void) applicationWillResignActive:(UIApplication *)application
{
	[self.locationManager stopUpdatingLocation];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	if ([MKDirectionsRequest isDirectionsRequestURL:url]){
		
		self.currentSource = nil;
		self.currentDestination = nil;
		
		MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] initWithContentsOfURL:url];
		
		if (!directionsRequest.source.isCurrentLocation){
			self.currentSource = [NSString stringWithFormat:@"%f,%f", directionsRequest.source.placemark.location.coordinate.latitude,
					  directionsRequest.source.placemark.location.coordinate.longitude];
		} else if (self.currentLocation){
			self.currentSource = [NSString stringWithFormat:@"%f,%f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude];
		}
		
		if (!directionsRequest.destination.isCurrentLocation){
			self.currentDestination = [NSString stringWithFormat:@"%f,%f", directionsRequest.destination.placemark.location.coordinate.latitude,
						   directionsRequest.destination.placemark.location.coordinate.longitude];
		} else if (self.currentLocation){
			self.currentDestination = [NSString stringWithFormat:@"%f,%f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude];
		}
		
		if (self.currentSource && self.currentDestination){
			[self openTransitDirections];
		}
		
		return YES;
	}
	return NO;
}

- (void) openTransitDirections
{
	if (self.currentSource && self.currentDestination){
		NSString *directionsURLString = [NSString stringWithFormat:@"https://maps.google.com/maps?f=d&source=s_d&saddr=%@&daddr=%@&hl=en&vps=3&jsv=432b&vpsrc=0&gl=us&dirflg=r&ttype=now&noexp=0&noal=0&sort=def&mra=atm&ie=UTF8&ui=maps_mini",
										 self.currentSource, self.currentDestination];
		
		NSURL *directionsURL = [NSURL URLWithString:directionsURLString];
		
		self.currentSource = nil;
		self.currentDestination = nil;
		
		[self openURL:directionsURL];
	}
}

- (void) openURL:(NSURL *)url
{
	[[UIApplication sharedApplication] openURL:url];
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations
{
	self.currentLocation = [locations lastObject];
	[self openTransitDirections];
}

@end
