//
//  ViewController.swift
//  MemeMe1.0
//
//  Created by Prabhjot on 22/09/16.
//  Copyright (c) 2016 Prabhjot. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var botText: UITextField!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setTextAttribut(botText, str : " BOTTOM ")
        setTextAttribut(topText, str: " TOP ")

    }
    
    override var prefersStatusBarHidden : Bool {
        return true     // status bar should be hidden
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Check if Camera is available
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        // Subscribe to KB notification
        subscribeToKeyboardNotifications()
        shareButton.isEnabled = imagePickerView.image != nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Don't forget to unsubscribe to KB notification
        unsubscribeFromKeyboardNotifications()
    }
    
    /* KeyBoard method */
    
    //Add an observer for KB notification
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)) , name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)) , name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    //Remove thoses observer
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if botText.isFirstResponder {
            view.frame.origin.y = getKeyboardHeight(notification) * (-1)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
            view.frame.origin.y = 0
    }
    
    // Get KB height to move the User View
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    /* Action to Album/Photo Button */
    func pickAnImageFromSource(_ source: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
        
    }
    
    //From Album Library
    @IBAction func pickAnImageFromAlbum(_ sender: AnyObject) {
        pickAnImageFromSource(.photoLibrary)
    }
    
    //From Photo App
    @IBAction func pickAnImageFromPhoto(_ sender: AnyObject) {
         pickAnImageFromSource(.camera)
    }
    
    /* Method for textField attributs && control */
    
    //Attributes for styling the text in the text fields
    let memeTextAttribues = [
        NSStrokeColorAttributeName : UIColor.black,
        NSForegroundColorAttributeName : UIColor.white,
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 38)!,
        NSStrokeWidthAttributeName : NSNumber(value: -3.0)
    ]
    
    //General method to set both textField attributs
    func setTextAttribut(_ textField : UITextField, str : String) {
        textField.delegate = self
        textField.text = str
        textField.defaultTextAttributes = memeTextAttribues
        textField.textAlignment = .center
        textField.borderStyle = .none
    }
    
    //Erase the default text when editing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == " TOP " || textField.text == " BOTTOM " {
            textField.text = ""
        }
    }
    
    //Function that allows the user to use the return key to escape from the text input
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /* Delegate method from imagePickerController */
    
    //Func to pass the selected image to the imageVC
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    //Func to cancel selection
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    /* Meme method */
    
    func generateMemedImage() -> UIImage
    {
        toolBar.isHidden = true
        navBar.isHidden = true
        
        //Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        toolBar.isHidden = false
        navBar.isHidden = false
        
        return memedImage
    }
    
    
    func save() {
        let memedImage = generateMemedImage()
        //Create the meme
        _ = Meme(topText: topText.text!, botText: botText.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
    }
    
    @IBAction func shareMeme(_ sender: AnyObject) {
        let memedImage = generateMemedImage()
        
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = { activity, completed, items, error in
            if completed {
                //Save the image
                self.save()
                //Dismiss the view controller
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        present(activityViewController, animated: true, completion: nil)
        
    }
}

