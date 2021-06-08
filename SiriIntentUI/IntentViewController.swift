//
//  IntentViewController.swift
//  SiriIntentUI
//
//  Created by orangeboy on 2021/3/19.
//

import IntentsUI
import SwiftUI

// As an example, this extension's Info.plist has been configured to handle interactions for INSendMessageIntent.
// You will want to replace this or add other intents as appropriate.
// The intents whose interactions you wish to handle must be declared in the extension's Info.plist.

// You can test this example integration by saying things to Siri like:
// "Send a message using <myApp>"

class IntentViewController: UIViewController, INUIHostedViewControlling {
    
    @IBOutlet var contentView: UIView!

    @IBOutlet weak var speedAndTime: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
    @AppStorage("lastDate", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var lastDate: String = "无"
    
    @AppStorage("lastSpeed", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var lastSpeed: String = "无"
    
    @AppStorage("lastCostTime", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var lastCostTime: String = "无"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
        
    // MARK: - INUIHostedViewControlling
    
    // Prepare your view controller for the interaction to handle.
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
        // Do configuration here, including preparing views and calculating a desired size for presentation.
        
        let size = CGSize(width: 320, height: 120)

        contentView.backgroundColor = UIColor.init(white: 100, alpha: 0)
        
        speedAndTime.text = "\(lastSpeed) 米每秒 / \(lastCostTime)"
        date.text = lastDate
    
        completion(true, parameters, size)
    }
    
    var desiredSize: CGSize {
        return self.extensionContext!.hostedViewMaximumAllowedSize
    }
    
}
