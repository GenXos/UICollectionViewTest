//
//  ViewController.swift
//  UICollectionViewTest
//
//  Created by Todd Fields on 2016-05-08.
//  Copyright © 2016 Skullgate Studios. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var images_cache = [String: UIImage]()
    var images = [String]()
    let link = "http://www.kaleidosblog.com/tutorial/get_images.php"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        layout.itemSize = CGSizeMake(120, 120)
        self.collectionView.setCollectionViewLayout(layout, animated: true)
        
        get_json()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    internal func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return images.count
    }
    
    internal func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: CellClass = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CellClass
        
        if(images_cache[images[indexPath.row]] != nil) {
            cell.imageView.image = images_cache[images[indexPath.row]]
        } else {
            load_image(images[indexPath.row], imageView: cell.imageView)
        }
        
        return cell
    }
    
    internal func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func load_image(link: String, imageView: UIImageView) {
        
        let url: NSURL = NSURL(string: link)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.timeoutInterval = 10
        
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response where error == nil else {
                
                return
            }
            
            var image = UIImage(data: data!)
            
            if (image != nil) {
                
                func set_image() {
                    self.images_cache[link] = image
                    imageView.image = image
                }
                
                dispatch_async(dispatch_get_main_queue(), set_image)
            }
            
        }
        
        task.resume()
    }
    
    func extract_json_data(data: NSString) {
        
        let jsonData: NSData = data.dataUsingEncoding(NSASCIIStringEncoding)!
        
        let json: AnyObject?
        
        do {
            json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
        } catch {
            print("error")
            return
        }
        
        guard let images_array = json! as? NSArray else {
            print("error")
            return
        }
        
        for var j = 0; j < images_array.count; ++j {
            images.append(images_array[j] as! String)
        }
        
        dispatch_async(dispatch_get_main_queue(), refresh)
    }
    
    func refresh() {
        self.collectionView.reloadData()
    }
    
    func get_json() {
        
        let url: NSURL = NSURL(string: link)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.timeoutInterval = 10
        
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            
            guard let _:NSData = data, let _: NSURLResponse = response where error == nil else {
                
                return
            }
            
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
            self.extract_json_data(dataString!)
        }
        
        task.resume()
    }


}

