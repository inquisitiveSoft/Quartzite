@class AJKTabBarItem;


@protocol AJKTabBarDelegate

- (BOOL)tabBar:(AJKTabBar *)tabBar shouldSelectTab:(AJKTabBarItem *)tabBarItem;
- (BOOL)tabBar:(AJKTabBar *)tabBar didSelectTab:(AJKTabBarItem *)tabBarItem;

// Removing Identifier Items
- (BOOL)tabBar:(AJKTabBar *)tabBar shouldRemoveTab:(NSString *)identifier;
- (void)tabBar:(AJKTabBar *)tabBar didRemoveItemForIdentifier:(NSString *)identifier;

@end