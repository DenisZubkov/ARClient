//
//  ActionViewController.swift
//  ARLoad
//
//  Created by Dennis Zubkoff on 06.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//

import UIKit
import MobileCoreServices
import QuickLookThumbnailing

class ActionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var usdzModel: USDZModel?
    
    
    // MARK: - Custom Methods
    @objc func imageUpdated() {
        DispatchQueue.main.async {
            if let usdzModel = self.usdzModel {
                self.imageView.image = usdzModel.image
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(imageUpdated),
            name: USDZModel.imageUpdatedNotification,
            object: nil
        )
        // Get the item[s] we're handling from the extension context.
        
        // For example, look for an image and place it into an image view.
        // Replace this with something appropriate for the type[s] your extension supports.
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
                                do {
                                    let data = try Data(contentsOf: usdzURL)
                                    let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                                    let fileName = NSString(string: usdzURL.path).lastPathComponent
                                    let fileURL = DocumentDirURL.appendingPathComponent(fileName)
                                    do {
                                        try data.write(to: fileURL)
                                        self.usdzModel = USDZModel(url: fileURL)
                                        print("Ok")
                                    } catch {
                                        print("Bad")
                                    }
                                } catch {
                                    print("No Data")
                                }
                                
                                
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

    @IBAction func saveBarButton() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
    
    @IBAction func cancelBarButton() {
         self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
    
}
