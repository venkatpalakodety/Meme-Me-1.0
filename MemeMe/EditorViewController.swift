//
//  EditorViewController.swift
//  Provide methods to create a Meme and Share it from the device.
//  MemeMe
//
//  Created by Venkata Palakodety on 8/21/15.
//  Copyright (c) 2015 Venkata Palakodety. All rights reserved.
//

import UIKit


class EditorViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate{
    
    // Declare outlets for the view elements
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var activityButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    // Declare Placeholders for text
    let topPlaceholderText = "TOP"
    let bottomPlaceholderText = "BOTTOM"
    var currentTextField: UITextField?
    
    // Setup view attributes when the view loads.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup font for Meme Text Fields
        let memeTextAttributes = [
            NSStrokeColorAttributeName: UIColor(red: 0, green: 0, blue: 0, alpha: 1),
            NSForegroundColorAttributeName: UIColor(red: 1, green: 1, blue: 1, alpha: 1),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -3
        ]
        
        // Setup the attributes for Meme Text Fields
        topText.defaultTextAttributes = memeTextAttributes
        bottomText.defaultTextAttributes = memeTextAttributes
        topText.textAlignment = NSTextAlignment.Center
        bottomText.textAlignment = NSTextAlignment.Center
        
        // Assign the textfield delagtes to self, because our view controller is extending the UITextFieldDelegate.
        topText.delegate = self
        bottomText.delegate = self
        
        // Enabe the camera only if it's supported by iOS Version.
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        // Disable the Activity Button
        activityButton.enabled = false
        
        // Disable the Cancel Button
        cancelButton.enabled = false
        
    }
    
    // Subsribe to Keyboard Notifications when the view appears
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    // Unsubscribe from Keyboard Notifications when the view disappears
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // Hide Status Bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    /* Start TextField Methods*/
    func textFieldDidBeginEditing(textField: UITextField) {
        hidePlaceholderText(textField)
        currentTextField = textField
        
        // Enable Cancel Button
        cancelButton.enabled = true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        showPlaceholderText(textField)
        currentTextField = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // Enable the Cancel Button
        cancelButton.enabled = true
        
        textField.resignFirstResponder()
        return true
    }
    
    private func hidePlaceholderText(textField: UITextField) {
        if textField == topText && textField.text! == topPlaceholderText {
            textField.text = ""
        }
        if textField == bottomText && textField.text! == bottomPlaceholderText {
            textField.text = ""
        }
    }
    
    private func showPlaceholderText(textField: UITextField) {
        if textField == topText && textField.text! == "" {
            textField.text = topPlaceholderText
        }
        if textField == bottomText && textField.text! == "" {
            textField.text = bottomPlaceholderText
        }
    }
    /* End TextField Methods */
    
    /* Start Keyboard Methods */
    // Subscribe to Keyboard Notifications
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // Unsubscribe from Keyboard Notifications, when not needed
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // Make sure the view shifts up when the keyboard is displayed
    func keyboardWillShow(notification: NSNotification) {
        if let textField = currentTextField {
            if textField == bottomText {
                self.view.frame.origin.y -= getKeyboardHeight(notification)
            }
        }
    }
    
    // Get Keyboard Height in order to compute how much we need to shift the view up
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    /* End Keyboard Methods */
    
    @IBAction func didPressActivity(sender: UIBarButtonItem) {
        let image = generateMemedImage()
        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activity.completionWithItemsHandler = { (type: String!, completed: Bool, returnedItems: [AnyObject]!, error: NSError!) in
            if completed {
                var backgroundImage = self.memeImageView.image == nil ? UIImage() : self.memeImageView.image
                
                // Create a meme object and save it
                var meme = Meme(
                    top: self.topText.text,
                    bottom: self.bottomText.text,
                    image: backgroundImage!,
                    memedImage: image
                )
                meme.save()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        presentViewController(activity, animated: true, completion: nil)
    }
    
    // Create a composited Meme image
    private func generateMemedImage() -> UIImage {
        // Hide the toolbar and the navbar
        hideToolbarAndNavBar()
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show the toolbar and the navbar
        showToolbarAndNavBar()
        
        return memedImage
    }
    
    // Hide Toolbar and NavBar
    private func hideToolbarAndNavBar() {
        navBar.hidden = true
        bottomToolbar.hidden = true
    }
    
    // Show Toolbar and NavBar
    private func showToolbarAndNavBar() {
        navBar.hidden = false
        bottomToolbar.hidden = false
    }
    
    // Reset view elements to normal when cancel button is pressed
    @IBAction func didPressCancel(sender: UIBarButtonItem) {
        // Reset text of text fields to placeholder text and remove image
        topText.text = topPlaceholderText
        bottomText.text = bottomPlaceholderText
        memeImageView.image = nil
        
        // Disable the Activity Button
        activityButton.enabled = false
        
        // Disable the Cancel Button
        cancelButton.enabled = false
        
    }
    
    // Show Photo Album for the user to pick an image
    @IBAction func didPressAlbum(sender: UIBarButtonItem) {
        let picker = UIImagePickerController()
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    
    // Show the Camera, so the user can click a picture.
    @IBAction func didPressCamera(sender: UIBarButtonItem) {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    
    // Delegate for Picking an Image
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            memeImageView.image = image
            memeImageView.contentMode = UIViewContentMode.ScaleAspectFit
            
            // Enable the Activity Button
            activityButton.enabled = true
            
            // Enable the Cancel Button
            cancelButton.enabled = true
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
