#import "PerfectHomeScreen13.h"

#define IS_iPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

// ------------------------------ DETAILED DOWNLOAD BAR WHILE DOWNLOADING APPS ------------------------------

// ORIGINAL TWEAK @shepgoba: https://github.com/shepgoba/DownloadBar13

%group progressBarWhenDownloadingGroup

	%hook SBIconProgressView

	%property (nonatomic, strong) UILabel *progressLabel;
	%property (nonatomic, strong) UIView *progressBar;

	- (void)setFrame: (CGRect)arg1
	{
		%orig;
		if (arg1.size.width != 0)
		{
			self.progressBar.frame = CGRectMake(0, self.frame.size.height * (1 - self.displayedFraction), self.frame.size.width, self.frame.size.height * self.displayedFraction);
			self.progressLabel.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 + 18);
		}
	}

	- (id)initWithFrame: (CGRect)arg1
	{
		if ((self = %orig))
		{
			self.progressBar = [[UIView alloc] init];
			self.progressBar.backgroundColor = [UIColor systemBlueColor];
			self.progressBar.layer.cornerRadius = 13;
			self.progressBar.alpha = 0.6;

			self.progressLabel = [[UILabel alloc] init];
			self.progressLabel.font = [UIFont boldSystemFontOfSize: 14];
			self.progressLabel.textAlignment = NSTextAlignmentCenter;
			self.progressLabel.textColor = [UIColor whiteColor];
			self.progressLabel.text = @"0%%";

			[self addSubview: self.progressBar];
			[self addSubview: self.progressLabel];
		}
		return self;
	}

	- (void)setDisplayedFraction: (double)arg1
	{
		%orig;

		self.progressLabel.text = [NSString stringWithFormat: @"%i%%", (int)(arg1 * 100)];
		[self.progressLabel sizeToFit];
	}

	- (void)_drawPieWithCenter: (CGPoint)arg1
	{
		self.progressBar.frame = CGRectMake(0, self.frame.size.height * (1 - self.displayedFraction), self.frame.size.width, self.frame.size.height * self.displayedFraction);
		self.progressLabel.center = CGPointMake(arg1.x, arg1.y + 18);
	}

	- (void)_drawOutgoingCircleWithCenter: (CGPoint)arg1
	{

	}

	- (void)_drawIncomingCircleWithCenter: (CGPoint)arg1
	{

	}

	%end

%end

// ------------------------------ AUTO CLOSE FOLDERS ------------------------------

%group autoCloseFoldersGroup

	%hook SBHIconManager

	- (void)iconTapped: (id)arg1
	{
		if([self openedFolderController] && [[self openedFolderController] isOpen]) [[self openedFolderController] _closeFolderTimerFired];
		
		%orig;
	}

	%end

%end

// ------------------------------ HIDE APP ICONS ------------------------------

%group hideAppIconsGroup

// ORIGINAL TWEAK @menushka: https://github.com/menushka/HideYourApps

	%hook SBIconListModel

	- (id)insertIcon: (SBApplicationIcon*)icon atIndex: (unsigned long long*)arg2 options: (unsigned long long)arg3
	{
		if([SparkAppList doesIdentifier: @"com.johnzaro.perfecthomescreen13prefs.hiddenApps" andKey: @"hiddenApps" containBundleIdentifier: [icon applicationBundleID]])
			return nil;
		else return %orig;
	}

	- (BOOL)addIcon: (SBApplicationIcon*)icon asDirty: (BOOL)arg2
	{
		if([SparkAppList doesIdentifier: @"com.johnzaro.perfecthomescreen13prefs.hiddenApps" andKey: @"hiddenApps" containBundleIdentifier: [icon applicationBundleID]]) 
			return nil;
		else return %orig;
	}

	%end

%end

// ------------------------------ HIDE APP LABEL ------------------------------

%group hideAppLabelsGroup

	%hook SBIconLegibilityLabelView

	- (void)setHidden: (BOOL)arg1
	{
		%orig(YES);
	}

	%end

%end

// ------------------------------ HIDE UPDATED APP BLUE DOT ------------------------------

%group hideBlueDotGroup

	%hook SBIconView

	- (BOOL)allowsLabelAccessoryView
	{
		return NO;
	}

	%end

%end

// ------------------------------ HIDE SHARE OPTION IN 3D TOUCH MENU ------------------------------

%group hideShareAppShortcutGroup

	%hook SBIconView

	- (void)setApplicationShortcutItems: (NSArray *)arg1
	{
		NSMutableArray *newShortcuts = [[NSMutableArray alloc] init];
		for(SBSApplicationShortcutItem *shortcut in arg1)
		{
			if([shortcut.type isEqual: @"com.apple.springboardhome.application-shortcut-item.share"])
				continue;
			else [newShortcuts addObject: shortcut];
		}

		%orig(newShortcuts);
	}

	%end

%end

// ------------------------------ CUSTOM HOME SCREEN LAYOUT ------------------------------

%group customHomeScreenLayoutGroup

// Idea For The "findLocation" Method @KritantaDev: https://github.com/KritantaDev/HomePlus

	%hook SBIconListGridLayoutConfiguration

	%property (nonatomic, assign) NSString *location;

	%new
	- (NSString*)findLocation
	{
		if(self.location) return self.location;
		else
		{
			NSUInteger rows = MSHookIvar<NSUInteger>(self, "_numberOfPortraitRows");
			NSUInteger columns = MSHookIvar<NSUInteger>(self, "_numberOfPortraitColumns");
			
			if(rows == 1) self.location = @"Dock";
			else if(rows == 3 && columns == 3 || rows == 4 && columns == 4) self.location = @"Folder";
			else self.location = @"Home";
		}
		return self.location;
	}

	- (NSUInteger)numberOfPortraitRows
	{
		[self findLocation];
		
		if([self.location isEqualToString: @"Folder"] && customFolderRowsEnabled)
			return customFolderRows;
		else if([self.location isEqualToString: @"Home"] && customHomeScreenRowsEnabled)
			return customHomeScreenRows;

		return %orig;
	}

	- (NSUInteger)numberOfLandscapeRows
	{
		[self findLocation];
		
		if([self.location isEqualToString: @"Folder"] && customFolderRowsEnabled)
			return customFolderRows;
		else if([self.location isEqualToString: @"Home"] && customHomeScreenRowsEnabled)
			return customHomeScreenRows;

		return %orig;
	}

	- (NSUInteger)numberOfPortraitColumns
	{
		[self findLocation];
		
		if([self.location isEqualToString: @"Dock"] && customDockColumnsEnabled && !IS_iPAD)
			return customDockColumns;
		else if([self.location isEqualToString: @"Folder"] && customFolderColumnsEnabled)
			return customFolderColumns;
		else if([self.location isEqualToString: @"Home"] && customHomeScreenColumnsEnabled)
			return customHomeScreenColumns;
		
		return %orig;
	}

	- (NSUInteger)numberOfLandscapeColumns
	{
		[self findLocation];
		
		if([self.location isEqualToString: @"Dock"] && customDockColumnsEnabled && !IS_iPAD)
			return customDockColumns;
		else if([self.location isEqualToString: @"Folder"] && customFolderColumnsEnabled)
			return customFolderColumns;
		else if([self.location isEqualToString: @"Home"] && customHomeScreenColumnsEnabled)
			return customHomeScreenColumns;
		
		return %orig;
	}

	-(UIEdgeInsets)portraitLayoutInsets
	{
		[self findLocation];
		UIEdgeInsets x = %orig;
		
		if([self.location isEqualToString: @"Folder"] && (customFolderRowsEnabled || customFolderColumnsEnabled))
		{
			if(!IS_iPAD && (customFolderRows > 3 || customFolderColumns > 3)) return UIEdgeInsetsMake(x.top - 15, x.left - 15, x.bottom - 15, x.right - 15);
		}
		else if([self.location isEqualToString: @"Home"] && !IS_iPAD && (customHomeScreenRowsEnabled || customHomeScreenColumnsEnabled))
		{
			if(customHomeScreenRows > 6 || customHomeScreenColumns > 4) return UIEdgeInsetsMake(x.top - 20, x.left - 15, x.bottom - 40, x.right - 15);
		}
		return x;
	}

	%end

	%hook SBIconListView 

	- (NSUInteger)maximumIconCount
	{
		return customHomeScreenRows * customHomeScreenColumns;
	}

	%end

%end

%ctor
{
	@autoreleasepool
	{
		pref = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.perfecthomescreen13prefs"];
		[pref registerDefaults:
		@{
			@"hideAppLabels": @NO,
			@"hideBlueDot": @NO,
			@"progressBarWhenDownloading": @NO,
			@"hideAppIcons": @NO,
			@"autoCloseFolders": @NO,
			@"hideShareAppShortcut": @NO,
			@"customHomeScreenLayoutEnabled": @NO,
			@"customHomeScreenRowsEnabled": @NO,
			@"customHomeScreenColumnsEnabled": @NO,
			@"customFolderRowsEnabled": @NO,
			@"customFolderColumnsEnabled": @NO,
			@"customDockColumnsEnabled": @NO,
			@"customHomeScreenRows": @6,
			@"customHomeScreenColumns": @4,
			@"customFolderRows": @3,
			@"customFolderColumns": @3,
			@"customDockColumns": @4
    	}];

		hideAppLabels = [pref boolForKey: @"hideAppLabels"];
		hideBlueDot = [pref boolForKey: @"hideBlueDot"];
		progressBarWhenDownloading = [pref boolForKey: @"progressBarWhenDownloading"];
		hideAppIcons = [pref boolForKey: @"hideAppIcons"];
		autoCloseFolders = [pref boolForKey: @"autoCloseFolders"];
		hideShareAppShortcut = [pref boolForKey: @"hideShareAppShortcut"];

		if(hideAppLabels) %init(hideAppLabelsGroup);
		if(hideBlueDot) %init(hideBlueDotGroup);
		if(progressBarWhenDownloading) %init(progressBarWhenDownloadingGroup);
		if(hideAppIcons) %init(hideAppIconsGroup);
		if(autoCloseFolders) %init(autoCloseFoldersGroup);
		if(hideShareAppShortcut) %init(hideShareAppShortcutGroup);

		customHomeScreenLayoutEnabled = [pref boolForKey: @"customHomeScreenLayoutEnabled"];
		if(customHomeScreenLayoutEnabled)
		{
			customHomeScreenRowsEnabled = [pref boolForKey: @"customHomeScreenRowsEnabled"];
			customHomeScreenColumnsEnabled = [pref boolForKey: @"customHomeScreenColumnsEnabled"];
			customFolderRowsEnabled = [pref boolForKey: @"customFolderRowsEnabled"];
			customFolderColumnsEnabled = [pref boolForKey: @"customFolderColumnsEnabled"];
			customDockColumnsEnabled = [pref boolForKey: @"customDockColumnsEnabled"];

			customHomeScreenRows = [pref unsignedIntegerForKey: @"customHomeScreenRows"];
			customHomeScreenColumns = [pref unsignedIntegerForKey: @"customHomeScreenColumns"];
			customFolderRows = [pref unsignedIntegerForKey: @"customFolderRows"];
			customFolderColumns = [pref unsignedIntegerForKey: @"customFolderColumns"];
			customDockColumns = [pref unsignedIntegerForKey: @"customDockColumns"];

			%init(customHomeScreenLayoutGroup);
		}
	}
}
