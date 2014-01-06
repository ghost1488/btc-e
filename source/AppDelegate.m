
#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary
        dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BTCe-Config" ofType:@"plist"]]];
    
    [self setupStatusItem];
    [self getUnreadEntries:nil];
    
    NSTimeInterval ti = [[NSUserDefaults standardUserDefaults] doubleForKey:@"BTCEInterval"];
    [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(getUnreadEntries:) userInfo:nil repeats:YES];
}

- (void)setupStatusItem
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.title = @"";
    self.statusItem.highlightMode = YES;
    [self setupMenu];
}

- (void)setupMenu
{
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
    self.statusItem.menu = menu;
}

- (void)getUnreadEntries:(id)sender
{
    static double prev = 0.0;
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://btc-e.com/api/2/%@/ticker",
                                       [[NSUserDefaults standardUserDefaults] stringForKey:@"BTCECurrency"]]];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:URL]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (data && !error) {
             NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
             NSDictionary *ticker = [dict objectForKey:@"ticker"];
             NSNumber *last = [ticker objectForKey: @"last"];
             double cost = [last doubleValue];
             self.statusItem.title = [NSString stringWithFormat:@"%@ %.2lf", (cost < prev) ? @"▼" : @"▲", cost];
             prev = cost;
         } else {
             NSLog(@"Error: %@", [error localizedDescription]);
         }
     }];
    
}

- (void)terminate:(id)sender
{
    [[NSApplication sharedApplication] terminate:self.statusItem.menu];
}

@end
