//
//  Meme.swift
//  Save Memes
//  MemeMe
//
//  Created by Venkata Palakodety on 8/22/15.
//  Copyright (c) 2015 Venkata Palakodety. All rights reserved.
//

import UIKit

class Meme {
    /// Top Text Field's Text
    var top = ""
    /// Bottom Text Field's Text
    var bottom = ""
    /// Meme's Background Image
    var image = UIImage()
    /// The composited text and image that can be shared
    var memedImage = UIImage()
    
    
    /**
    Constructor function that sets the member variables
    
    :param: top The text on top of the meme
    :param: bottom The text on bottom of the meme
    :param: image  Background image of Meme
    :param: memedImage The composited image and text
    */
    init(top: String, bottom: String, image: UIImage, memedImage: UIImage) {
        self.top = top
        self.bottom = bottom
        self.image = image
        self.memedImage = memedImage
    }
    
    //Save meme
    func save() {
        Meme.getStorage().memes.append(self)
    }
    
    /**
    Get the object where the meme array is stored
    
    :returns: The object that holds the memes
    */
    class func getStorage() -> AppDelegate {
        let object = UIApplication.sharedApplication().delegate
        return object as! AppDelegate
    }
}