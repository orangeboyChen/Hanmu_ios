//
//  HanmuShortcutController.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/19.
//

import Foundation
import UIKit
import Intents
import IntentsUI
import SwiftUI

class SiriShortcutViewController: UIViewController {
    var shortcut: ShortcutManager.Shortcut?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSiriButton(to: view)
    }
    
    func addSiriButton(to view: UIView) {
        #if !targetEnvironment(macCatalyst)
        let button = INUIAddVoiceShortcutButton(style: .automaticOutline)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        view.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: button.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: button.trailingAnchor).isActive = true
        setupShortcut(to: button)
        #endif
    }
    
    func setupShortcut(to button: INUIAddVoiceShortcutButton?) {
        if let shortcut = shortcut {
            button?.shortcut = INShortcut(intent: shortcut.intent)
            button?.delegate = self
        }
    }
}

extension SiriShortcutViewController: INUIAddVoiceShortcutViewControllerDelegate {
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension SiriShortcutViewController: INUIAddVoiceShortcutButtonDelegate {
    func present(_ addVoiceShortcutViewController: INUIAddVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        addVoiceShortcutViewController.delegate = self
        addVoiceShortcutViewController.modalPresentationStyle = .formSheet
        present(addVoiceShortcutViewController, animated: true, completion: nil)
    }
    func present(_ editVoiceShortcutViewController: INUIEditVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        editVoiceShortcutViewController.delegate = self
        editVoiceShortcutViewController.modalPresentationStyle = .formSheet
        present(editVoiceShortcutViewController, animated: true, completion: nil)
    }
}

extension SiriShortcutViewController: INUIEditVoiceShortcutViewControllerDelegate {
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        controller.dismiss(animated: true, completion: nil)
    }
    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

struct SiriButtonView: UIViewControllerRepresentable {
    var shortcut: ShortcutManager.Shortcut
    
    func makeUIViewController(context: Context) -> SiriShortcutViewController {
        let controller = SiriShortcutViewController()
        controller.shortcut = shortcut
        return controller
    }
    
    func updateUIViewController(_ uiViewController: SiriShortcutViewController, context: Context) {
        
    }
}

@available(iOS 12.0, *)
public final class ShortcutManager {
    // MARK: Properties
    
    /// A shared shortcut manager.
    public static let shared = ShortcutManager()
    
    func donate(_ intent: INIntent, id: String? = nil) {
        // create a Siri interaction from our intent
        let interaction = INInteraction(intent: intent, response: nil)
        if let id = id {
            interaction.groupIdentifier = id
        }
        
        // donate it to the system
        interaction.donate { error in
            // if there was an error, print it out
            if let error = error {
                print(error)
            }
        }
        
        if let shortcut = INShortcut(intent: intent) {
            let relevantShortcut = INRelevantShortcut(shortcut: shortcut)
            INRelevantShortcutStore.default.setRelevantShortcuts([relevantShortcut]) { error in
                if let error = error {
                    print("Error setting relevant shortcuts: \(error)")
                }
            }
        }
    }
    
    /**
     This enum specifies the different intents available in our app and their various properties for the `INIntent`.
     Replace this with your own shortcuts.
     */
    public enum Shortcut {
        case yourIntent
        
        var defaultsKey: String {
            switch self {
            case .yourIntent: return "帮我跑汉姆"
            }
        }
        
        var intent: INIntent {
            var intent: INIntent
            switch self {
            case . yourIntent:
                intent = RunIntent()
            }
            intent.suggestedInvocationPhrase = suggestedInvocationPhrase
            return intent
        }
        
        var suggestedInvocationPhrase: String {
            switch self {
            case .yourIntent: return "帮我跑汉姆"
            }
        }
        
        var formattedString: String {
            switch self {
            case .yourIntent: return "跑汉姆"
            }
        }
        
        
        
        func donate() {
            // create a Siri interaction from our intent
            let interaction = INInteraction(intent: self.intent, response: nil)
            
            // donate it to the system
            interaction.donate { error in
                // if there was an error, print it out
                if let error = error {
                    print(error)
                }
            }
            
            
            if let shortcut = INShortcut(intent: intent) {
                let relevantShortcut = INRelevantShortcut(shortcut: shortcut)
                INRelevantShortcutStore.default.setRelevantShortcuts([relevantShortcut]) { error in
                    if let error = error {
                        print("Error setting relevant shortcuts: \(error)")
                    }
                }
            }
            
        }
    }
}
