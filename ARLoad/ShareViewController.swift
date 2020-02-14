//
//  ShareViewController.swift
//  ARLoad
//
//  Created by Dennis Zubkoff on 08.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import CoreData

class ShareViewController: SLComposeServiceViewController {

    
    private var urlString: String?
    private var textString: String?
    let store = CoreDataStack.store
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var imageFound = false
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! {
                if provider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                    // This is an image. We'll load it, then place it in our image view.
                    provider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil, completionHandler: { (usdzURL, error) in
                        OperationQueue.main.addOperation {
                            if let usdzURL = usdzURL as? URL {
                                var alert: UIAlertController!
                                let filename = NSString(string: usdzURL.path).lastPathComponent
                                guard filename.contains(".usdz") else {
                                    alert = UIAlertController(title: "Неверный формат",
                                                              message: "По адресу \(usdzURL.absoluteString) нет USDZ файла",
                                        preferredStyle: .alert)
                                    
                                    let cancelAction = UIAlertAction(title: "OK", style: .destructive) { (action) in
                                        self.cancelBarButton()
                                    }
                                    alert.addAction(cancelAction)
                                    self.present(alert, animated: true)
                                    return
                                }
                                self.urlString = usdzURL.absoluteString
                                self.placeholder = "Ввведите название для объекта:"
                                //self.textView.text = usdzURL.lastPathComponent
                            }
                        }
                    })
                    imageFound = true
                    break
                }
            }
            
            if (imageFound) {
                // We only handle one image, so stop looking for more.
                break
            }
        }
    }
    
    @IBAction func cancelBarButton() {
         self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        guard let urlString = urlString,
            let url = URL(string: urlString) else { return }
        do {
            let data = try Data(contentsOf: url)
            let filename = url.lastPathComponent
            let comment = self.textView.text ?? "No comment"
            let name = filename.replacingOccurrences(of: ".usdz", with: "")
            store.storeLoadObject(name: name, url: url, data: data, date: Date(), filename: filename, comment: comment)
        } catch {
            print("No Data")
        }
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
