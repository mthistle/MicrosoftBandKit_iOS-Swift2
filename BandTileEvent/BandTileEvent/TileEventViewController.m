/*---------------------------------------------------------------------------------------------------
 *
 * Copyright (c) Microsoft Corporation All rights reserved.
 *
 * MIT License:
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 * associated documentation files (the  "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial
 * portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED ""AS IS"", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
 * NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * ------------------------------------------------------------------------------------------------*/

#import "TileEventViewController.h"
#import "BandClientController.h"

@interface TileEventViewController ()<UITextViewDelegate>
@property (nonatomic, weak) BandClientController *client;
@end

@implementation TileEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Setup View
    [self markSampleReady:NO];
    self.txtOutput.delegate = self;
    UIEdgeInsets insets = [self.txtOutput textContainerInset];
    insets.top = 20;
    insets.bottom = 20;
    [self.txtOutput setTextContainerInset:insets];
    
    [self output:[NSString stringWithFormat:@"Please wait. Connecting to Band <%@>", self.client.name]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapRegisterTileEventsButton:(id)sender
{
    [self markSampleReady:NO];
    [self output:@"Creating tile..."];
    
    NSError *error = nil;
    if (![client addTileToBand: &error])
    {
        if (error)
        {
            [self output:@"%@", error];
        }
    }
}

#pragma mark - Helper methods

- (void)sampleDidCompleteWithOutput:(NSString *)output
{
    [self output:output];
    [self output:@"Sample Completed."];
    [self output:@"You can run the sample again or remove sample Tile via Microsoft Health App."];
    [self markSampleReady:YES];
}

- (void)markSampleReady:(BOOL)ready
{
    self.registerTileEventsButton.enabled = ready;
    self.registerTileEventsButton.alpha = ready ? 1.0 : 0.2;
}

- (void)output:(NSString *)message
{
    if (message)
    {
        self.txtOutput.text = [NSString stringWithFormat:@"%@\n%@", self.txtOutput.text, message];
        [self.txtOutput layoutIfNeeded];
        if (self.txtOutput.text.length > 0)
        {
            [self.txtOutput scrollRangeToVisible:NSMakeRange(self.txtOutput.text.length - 1, 1)];
        }
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}

@end
