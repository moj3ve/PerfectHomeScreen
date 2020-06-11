@interface SBIconProgressView: UIView
@property(nonatomic, strong) UILabel *_Nullable progressLabel;
@property(nonatomic, strong) UIView *_Nullable progressBar;
@property(nonatomic, assign) double displayedFraction;
@end

@interface SBFolderController
- (void)_closeFolderTimerFired;
- (BOOL)isOpen;
@end

@interface SBHIconManager: NSObject
- (SBFolderController *_Nullable)openedFolderController;
@end

@interface SBApplicationIcon: NSObject
- (NSString *_Nullable)applicationBundleID;
@end

@interface SBIconListGridLayoutConfiguration
@property(nonatomic, assign) NSString *_Nullable location;
- (NSString *_Nullable)findLocation;
@end

@interface SBHIconViewContextMenuWrapperViewController : UIViewController
@end

@interface _UICutoutShadowView : UIView
@end

@interface SBIconImageView: UIImageView
@end

@interface SBDockView: UIView
@end

@interface SBIconView: UIView
- (id)applicationBundleIdentifier;
- (id)applicationBundleIdentifierForShortcuts;
@end

@interface SBSApplicationShortcutItem: NSObject
- (void)setLocalizedTitle:(NSString *)arg1;
- (NSString *)localizedTitle;
- (void)setLocalizedSubtitle:(NSString *)arg1;
- (void)setBundleIdentifierToLaunch:(NSString *)arg1;
@property(nonatomic, retain) NSString *type;
@end

@interface SBWallpaperEffectView : UIView
@property(nonatomic, strong) UIView *blurView;
@end

@interface SBFolderIconImageView: SBIconImageView
- (SBWallpaperEffectView*)backgroundView;
@end

@interface SBFolderBackgroundView : UIView
@end

@interface SBFolderTitleTextField : UITextField
@end

@interface SBIconListPageControl : UIView
@end