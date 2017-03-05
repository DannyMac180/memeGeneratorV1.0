//
//  ViewController.swift
//  memeGenerator v 1.0
//
//  Created by Daniel McAteer on 2/12/17.
//  Copyright © 2017 Daniel McAteer. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var memeImage: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    let memeTextAttributes:[String:Any] = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -3.0
    ]
    
    func prepareText(_ textField: UITextField) {
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Set initial text for both textfields
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
        prepareText(topTextField)
        prepareText(bottomTextField)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        subscribeToKeyboardNotifications()
        shareButton.isEnabled = memeImage.image != nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = -getKeyBoardHeight(notification)
        }
    }
    func getKeyBoardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        return keyboardSize.cgRectValue.height
    }
    
    func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func presentImagePicker(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func presentImageFromCamera(_ sender: Any) {
        presentImagePicker(sourceType: .camera)
    }

    
    @IBAction func pickImageFromAlbum(_ sender: Any) {
        presentImagePicker(sourceType: .savedPhotosAlbum)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            memeImage.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
        
        if topTextField.text == "TOP" {
            textField.text = ""
        } else if bottomTextField.text == "BOTTOM" {
            textField.text = ""
        } else {
            return
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func generateMemedImage() -> UIImage {
        topToolbar.isHidden = true
        bottomToolbar.isHidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        topToolbar.isHidden = false
        bottomToolbar.isHidden = false
        
        return memedImage
        
    }
    
    func save() {
        let memedImage = generateMemedImage()
        
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: memeImage.image!, memedImage: memedImage)
        
        topTextField.isHidden = true
        bottomTextField.isHidden = true
    }
    
    @IBAction func shareImage(_ sender: Any) {
        
        let memedImage = generateMemedImage()
        let memeActivityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        present(memeActivityViewController, animated: true, completion: nil)
        
        memeActivityViewController.completionWithItemsHandler = { activity, completed, items, error in
            if completed {
                //Save the image
                self.save()
                //Dismiss the view controller
                self.dismiss(animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    @IBAction func cancel() {
        shareButton.isEnabled = false
        topTextField.isHidden = false
        bottomTextField.isHidden = false
        memeImage.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
    }
}
