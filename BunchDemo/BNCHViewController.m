//
//  BNCHViewController.m
//  SampleApp
//
//  Created by Igor Parfenov on 09.02.14.
//  Copyright (c) 2014 Bunch. All rights reserved.
//

#import "BNCHViewController.h"
#import "BNCHAdvertViewController.h"
#import <BNCHBunchManager.h>
#import <AudioToolbox/AudioToolbox.h>

@interface BNCHViewController () <BNCHBunchManagerDelegate, UIAlertViewDelegate>
{
    BNCHBunchManager    *_bunchManager;
    BOOL                _isBunching;
    NSString            *_contentURL;

    //окно для отображения сообщения о выходе из региона
    UIAlertView         *_alertsViewOutside;
    //окно для отображения сообщения о входе в регион
    UIAlertView         *_alertsViewInside;
    //тут сохраняем регион в который вошли
    BNCHBunchRegion     *_regionForAlert;

}

@end

@implementation BNCHViewController

@synthesize startButton         = _startButton;
@synthesize actionNameLabel     = _actionNameLabel;


- (void)viewDidLoad
{
    NSLog(@"%@", NSStringFromSelector(_cmd));

    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UIImage *startButtonImageNormal = [UIImage imageNamed:@"ActionButtonCallNormal"];
    UIImage *startButtonImageHighlighted = [UIImage imageNamed:@"ActionButtonCallActive"];
    [_startButton setImage:startButtonImageNormal forState:UIControlStateNormal];
    [_startButton setImage:startButtonImageHighlighted forState:UIControlStateHighlighted];
    
    _isBunching = NO;
    _bunchManager = [[BNCHBunchManager alloc]init];
    [_bunchManager setDelegate:self];
    
    _alertsViewInside = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Отмена" otherButtonTitles:@"Посмотреть",  nil];
    _alertsViewOutside = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"ОК" otherButtonTitles:nil];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onStart:(id)sender
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    _isBunching = !_isBunching;
    _isBunching ? [self startBunching] : [self stopBunching];
}

- (void)startBunching
{
    BNCHBunchRegion *region = [[BNCHBunchRegion alloc]initRegionWithIdentifier:@"BunchSampleApp"];
    region.notifyEntryStateOnDisplay = YES;
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;

    [_bunchManager startMonitoringForRegion:region];
    [_bunchManager startRangingBunchesInRegion:region];
    
    //меняем отображение кнопки
    UIImage *startButtonImageBunching = [UIImage imageNamed:@"actionButtonActive"];
    [_startButton setImage:startButtonImageBunching forState:UIControlStateNormal];
    
    //меняем надпись
    [_actionNameLabel setText:@"Bunching..."];
}

- (void)stopBunching
{
    BNCHBunchRegion *region = [[BNCHBunchRegion alloc]initRegionWithIdentifier:@"BunchSampleApp"];
    
    [_bunchManager stopMonitoringForRegion:region];
    [_bunchManager stopRangingBunchesInRegion:region];

    //меняем отображение кнопки
    UIImage *startButtonImageNormal = [UIImage imageNamed:@"ActionButtonCallNormal"];
    [_startButton setImage:startButtonImageNormal forState:UIControlStateNormal];
    
    //меняем надпись
    [_actionNameLabel setText:@"Найти акцию"];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"onAdvert"]){
        assert( [segue.destinationViewController isKindOfClass:[BNCHAdvertViewController class]] );

        NSLog(@"%@URL to load:%@", NSStringFromSelector(_cmd),_contentURL);

        BNCHAdvertViewController* destinationViewController = segue.destinationViewController;
        [destinationViewController setUrlToLoad:_contentURL];
    }
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"%@%ld", NSStringFromSelector(_cmd), (long)buttonIndex);

    //если нажали кнопку "Show" то загружаем страничку с контентом
    if(buttonIndex == 1){
        if(_regionForAlert){
            [_bunchManager requestContentForRegion:_regionForAlert];
        }
    }
}

#pragma mark BNCHBunchManagerDelegate
//отработка событий по входу и выходу из региона
-(void)bunchManager:(BNCHBunchManager *)manager didEnterRegion:(BNCHBunchRegion *)region
{
    NSLog(@"%@%@", NSStringFromSelector(_cmd), region);
}

-(void)bunchManager:(BNCHBunchManager *)manager didExitRegion:(BNCHBunchRegion *)region
{
    NSLog(@"%@%@", NSStringFromSelector(_cmd), region);

    AudioServicesPlaySystemSound(1007);
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    [notification setSoundName:UILocalNotificationDefaultSoundName];
    
    notification.alertBody = @"Спасибо, что зашли в наш магазин! Приходите еще!";
    _regionForAlert = nil;
    [_alertsViewInside dismissWithClickedButtonIndex:0 animated:NO];
    [_alertsViewOutside setTitle:notification.alertBody];
    [_alertsViewOutside show];
        
    //отправляем алерт, который отобразится на экране если приложение в бэкграунде
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

-(void)bunchManager:(BNCHBunchManager *)manager didDetermineState:(CLRegionState)state
          forRegion:(BNCHBunchRegion *)region
{
    NSLog(@"%@:%@", NSStringFromSelector(_cmd), region);

    if(state == CLRegionStateInside){
        AudioServicesPlaySystemSound(1007);
        
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        
        [notification setSoundName:UILocalNotificationDefaultSoundName];
        
        notification.alertBody = @"Добро пожаловать в наш магазин!";
        _regionForAlert = region;
        [_alertsViewOutside dismissWithClickedButtonIndex:0 animated:NO];
        [_alertsViewInside setTitle:notification.alertBody];
        [_alertsViewInside setMessage:@"У нас есть специальная скида для Вас!"];
        [_alertsViewInside show];
        
        //отправляем алерт, который отобразится на экране если приложение в бэкграунде
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

//получение контента, привязанного к метке
- (void)bunchManager:(BNCHBunchManager *)manager didReceiveContent:(NSData *)data forRegion:(BNCHBunchRegion*)region withError:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSLog(@"%@data:%@", NSStringFromSelector(_cmd),data);
    NSLog(@"%@region:%@", NSStringFromSelector(_cmd),region);
    NSLog(@"%@error:%@", NSStringFromSelector(_cmd),error);
    
    if(!error)
    {
        _contentURL = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self performSegueWithIdentifier:@"onAdvert" sender:self];
    }
}

//обработка ошибок
-(void)bunchManager:(BNCHBunchManager *)manager rangingBunchesDidFailForRegion:(BNCHBunchRegion *)region withError:(NSError *)error
{
    NSLog(@"%@%@ error: %@", NSStringFromSelector(_cmd), region, error);
}

-(void)bunchManager:(BNCHBunchManager *)manager monitoringDidFailForRegion:(BNCHBunchRegion *)region withError:(NSError *)error
{
    NSLog(@"%@%@ error: %@", NSStringFromSelector(_cmd), region, error);
}



@end
