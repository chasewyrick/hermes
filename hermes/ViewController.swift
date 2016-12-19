//
//  ViewController.swift
//  mach_portal
//
//  Created by Ian Beer on 11/27/16.
//  Copyright © 2016 Ian Beer. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    @IBOutlet weak var ipAddressLabel: UILabel!
    
    @IBOutlet weak var jailbreakButton: UIButton!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let addr = getWiFiAddress() {
            ipAddressLabel.text = addr
        } else {
           
            let alert = UIAlertController(title: "Error", message: "You need to be connected to WiFi. Close then connect", preferredStyle: UIAlertControllerStyle.alert)
            self.present(alert, animated: true, completion: nil)
        }

        
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            jb_go();
        })
        
    }
    
    
    @IBAction func didTapJailbreak(sender : AnyObject!) {
        
        jailbreakButton.isEnabled = false
        jailbreakButton.setTitle("Sit tight", for: .normal)
        progressView.isHidden = false
        progressView.progress = 0.2
        
  

        
        
        
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var addr = interface.ifa_addr.pointee
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
}

