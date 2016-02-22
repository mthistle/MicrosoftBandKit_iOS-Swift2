//
//  ViewController.swift
//  BSwiftHeartRate
//
//  Created by Mark Thistle on 2/18/16.
//  Copyright © 2016 NewThistle, LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MSBClientManagerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var txtOutput: UITextView!
    @IBOutlet weak var hrLabel: UILabel!
    @IBOutlet weak var startHRSensorButton: UIButton!
    var client: MSBClient?
    private var clientManager = MSBClientManager.sharedManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Setup View
        markSampleReady(false)
        self.txtOutput.delegate = self
        var insets = txtOutput.textContainerInset
        insets.top = 20
        insets.bottom = 20
        txtOutput.textContainerInset = insets
        
        // Setup Band
        clientManager.delegate = self
        if let band = clientManager.attachedClients().first as! MSBClient? {
            self.client = band
            clientManager.connectClient(client)
            output("Please wait. Connecting to Band <\(client!.name)>")
        } else {
            output("Failed! No Bands attached.")
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func didTapStartHRSensorButton(sender: AnyObject) {
        markSampleReady(false)
        if let client = self.client {
            if client.sensorManager.heartRateUserConsent() == MSBUserConsent.Granted {
                startHeartRateUpdates()
            } else {
                output("Requesting user consent for accessing HeartRate...")
                client.sensorManager.requestHRUserConsentWithCompletion( { (userConsent: Bool, error: NSError!) -> Void in
                    if userConsent {
                        self.startHeartRateUpdates()
                    } else {
                        self.sampleDidCompleteWithOutput("User consent declined.")
                    }
                })
            }
        }
    }
    
    func startHeartRateUpdates() {
        output("Starting Heart Rate updates...")
        if let client = self.client {
            do {
                try client.sensorManager.startHeartRateUpdatesToQueue(nil, withHandler: { (heartRateData: MSBSensorHeartRateData!, error: NSError!) in
                    self.hrLabel.text = NSString(format: "Heart Rate: %3u %@",
                        heartRateData.heartRate,
                        heartRateData.quality == MSBSensorHeartRateQuality.Acquiring ? "Acquiring" : "Locked") as String
                })
                self.performSelector(Selector("stopHeartRateUpdates"), withObject: nil, afterDelay: 60)
            } catch let error as NSError {
                output("startHeartRateUpdatesToQueue failed: \(error.description)")
            }
        } else {
            output("Client not connected, can not start heart rate updates")
        }
    }
    
    func stopHeartRateUpdates() {
        if let client = self.client {
            do {
                try client.sensorManager.stopHeartRateUpdatesErrorRef()
            } catch let error as NSError {
                output("stopHeartRateUpdatesErrorRef failed: \(error.description)")
            }
            sampleDidCompleteWithOutput("Heart Rate updates stopped...")
        }
    }
    
    // MARK - Helper methods
    func sampleDidCompleteWithOutput(output: String) {
        self.output(output)
        markSampleReady(true)
    }
    
    func markSampleReady(ready: Bool) {
        self.startHRSensorButton.enabled = ready
        self.startHRSensorButton.alpha = ready ? 1.0 : 0.2
    }
    
    func output(message: String) {
        self.txtOutput.text = String("\(self.txtOutput.text)\n\(message)")
        self.txtOutput.layoutIfNeeded()
        if (self.txtOutput.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
            self.txtOutput.scrollRangeToVisible(NSRange.init(location: self.txtOutput.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) - 1, length: 1))
        }
    }
    
    // MARK - UITextViewDelegate
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return false
    }
    
    // MARK - MSBClientManagerDelegate
    func clientManager(clientManager: MSBClientManager!, clientDidConnect client: MSBClient!) {
        markSampleReady(true)
        output("Band <\(client.name)>connected.")
    }
    
    func clientManager(clientManager: MSBClientManager!, clientDidDisconnect client: MSBClient!) {
        markSampleReady(false)
        output(")Band <\(client.name)>disconnected.")
    }
    
    func clientManager(clientManager: MSBClientManager!, client: MSBClient!, didFailToConnectWithError error: NSError!) {
        output("Failed to connect to Band <\(client.name)>.")
        output(error.description)
    }

}

