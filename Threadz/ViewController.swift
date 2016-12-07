//
//  ViewController.swift
//  Threadz
//
//  Created by Jake on 12/7/16.
//  Copyright © 2016 Jake Mor. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	var statusLabel: UILabel!
	var titlesLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		// status label
		statusLabel = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.size.width/2 - 15, height: view.frame.size.height))
		statusLabel.text = "Waiting..."
		statusLabel.textAlignment = .left
		statusLabel.lineBreakMode = .byWordWrapping
		statusLabel.numberOfLines = 0
		view.addSubview(statusLabel)
		
		// titles label
		titlesLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 + 5, y: 0, width: view.frame.size.width/2 - 15, height: view.frame.size.height))
		titlesLabel.text = "ORIGINAL ORDER"
		titlesLabel.textAlignment = .left
		titlesLabel.lineBreakMode = .byWordWrapping
		titlesLabel.numberOfLines = 0
		view.addSubview(titlesLabel)
		
		// some hacker news story ids
		let topStoryIDs = [ 13122669, 13122339, 13122790, 13120872, 13121402, 13121399, 13122253, 13122330, 13120794, 13121878]
		
		
		getStoryTitlesAsync(topStoryIDs: topStoryIDs) {
			
			
			
			titles in
			
			print("// Callback printing titles")
			
			for t in titles.sorted() {
				print(t)
				self.titlesLabel.text = "\(self.titlesLabel.text!)\n\(t)"
			}
			
		}
		
	}
	
	
	// gets all titles of storys with given IDS. Callback is called on main thread
	func getStoryTitlesAsync(topStoryIDs: [Int], completion: @escaping ([String])->()) {
		
		// create group
		let group = DispatchGroup()
		
		// mutable, not threadsafe
		var titles = [String]()
		
		print("// starting in order, because its a serial queue")
	
		for (i,id) in topStoryIDs.enumerated() {
			
			// enter
			group.enter()
			
			getStoryTitle(id: id, completion: { title in
				
				
				let t = "\(i + 1) - \(title)"
				
				
				print("[ finished job \(i) ]")
				
				// go to main queue bc titles is mutable
				// also update ui
				DispatchQueue.main.async {
					self.statusLabel.text = "\(self.statusLabel.text!)\nfinished job \(i)"
					titles.append(t)
				}
				
				// leave
				group.leave()
			})
			
			print("[ started job \(i) ]")
			
		}
		
		print("// finishing out of order, because its async")
		statusLabel.text = "ORDER OF COMPLETION"
	
		group.notify(queue: DispatchQueue.main, execute: {
			print("// all done, executing callback on main queue")
			
			completion(titles)
		})
		
	}
	
	// gets title of one story, given id
	
	func getStoryTitle(id: Int, completion: @escaping (String)->()) {
		guard let url = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json") else {
			return
		}
		
		let urlRequest = URLRequest(url: url)
		
		// set up session
		let config = URLSessionConfiguration.default
		let session = URLSession(configuration: config)
		
		// make request
		let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
			
			if let e = error {
				print(e)
				return
			}
			
			do {
				
				guard let d = data else {
					return
				}
				
				if let parsed = try JSONSerialization.jsonObject(with: d, options: .allowFragments) as? [String:Any] {
					if let t = parsed["title"] as? String {
						completion(t)
					}
				}
				
				
				
			} catch let error as NSError {
				print(error)
			}
			
		})
		task.resume()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
}

