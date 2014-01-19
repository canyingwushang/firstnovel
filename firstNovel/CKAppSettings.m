//
//  CKAppSettings.m
//  firstNovel
//
//  Created by 张超 on 1/19/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import "CKAppSettings.h"
#import "CKFileManager.h"

@implementation CKAppSettings

+ (CKAppSettings *)sharedInstance
{
    static CKAppSettings *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CKAppSettings alloc] init];
    });
    return instance;
}

- (id)init
{
	self = [super init];
	if (self)
	{
        [self readAppSettings];
	}
    
	return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)readAppSettings
{
    _isFirstLaunchAfterUpdate = NO;
    _launchTimes = 1;
    
    NSMutableDictionary *newDataDict = [NSMutableDictionary dictionary];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[CKFileManager sharedInstance] getAppSettingsFile]])
    {
        NSDictionary *appSettingsDict = [NSDictionary dictionaryWithContentsOfFile:[[CKFileManager sharedInstance] getAppSettingsFile]];
        if (appSettingsDict != nil)
        {
            [newDataDict setDictionary:appSettingsDict];
            
            NSArray *keys = [appSettingsDict allKeys];
            for (NSString *key in keys)
            {
                id value = [appSettingsDict objectForKey:key];
                if ([key isEqualToString:APPSETTINGS_LASTVERSION])
                {
                    _lastVersion = [(NSString *)value retain];
                }
                else if ([key isEqualToString:APPSETTINGS_LAUNCHTIMES])
                {
                    _launchTimes = [(NSNumber *)value unsignedIntegerValue];
                }
            }
        }
    }
    
    NSDictionary *info =[[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [info objectForKey:@"CFBundleVersion"];
    if (_lastVersion != nil && [currentVersion isEqualToString:_lastVersion])
    {
        _isFirstLaunchAfterUpdate = NO;
    }
    else
    {
        _isFirstLaunchAfterUpdate = YES;
        _launchTimes = 1;
        [newDataDict setObject:currentVersion forKey:APPSETTINGS_LASTVERSION];
    }
    
    [newDataDict setObject:[NSNumber numberWithLong:_launchTimes + 1] forKey:APPSETTINGS_LAUNCHTIMES];
    
    [newDataDict writeToFile:[[CKFileManager sharedInstance] getAppSettingsFile] atomically:YES];
}

- (void)saveAppSettingWithKey:(NSString *)akey Value:(id)anObject
{
    NSMutableDictionary *appsettingsDict = nil;
    NSString * appSettingsFile = [[CKFileManager sharedInstance] getAppSettingsFile];
	if ([[NSFileManager defaultManager] fileExistsAtPath:appSettingsFile])
	{
		appsettingsDict = [[NSMutableDictionary alloc] initWithContentsOfFile:appSettingsFile];
    }
    else
    {
        appsettingsDict = [[NSMutableDictionary alloc] init];
    }
    DICTIONARY_SET_OBJECT_FOR_KEY(appsettingsDict, anObject, akey);
    [appsettingsDict writeToFile:appSettingsFile atomically:YES];
	RELEASE_SET_NIL(appsettingsDict);
}

- (void)saveAppSettingWithDict:(NSDictionary *)aDict
{
    NSMutableDictionary *appsettingsDict = nil;
    NSString * appSettingsFile = [[CKFileManager sharedInstance] getAppSettingsFile];
	if ([[NSFileManager defaultManager] fileExistsAtPath:appSettingsFile])
	{
		appsettingsDict = [[NSMutableDictionary alloc] initWithContentsOfFile:appSettingsFile];
    }
    else
    {
        appsettingsDict = [[NSMutableDictionary alloc] init];
    }
    [appsettingsDict addEntriesFromDictionary:aDict];
    [appsettingsDict writeToFile:appSettingsFile atomically:YES];
	RELEASE_SET_NIL(appsettingsDict);
}

@end