//
//  NetworkAuthViewController.swift
//  On The Map
//
//  Created by Jack Ngai on 10/1/16.
//  Copyright © 2016 Jack Ngai. All rights reserved.
//

import UIKit

// MARK: - TMDBAuthViewController: UIViewController

class NetworkAuthViewController: UIViewController {
    
    // MARK: Properties
    
    var urlRequest: NSURLRequest? = nil
    var requestToken: String? = nil
    var completionHandlerForView: ((success: Bool, errorString: String?) -> Void)? = nil
    
    // MARK: Outlets
    
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        
        navigationItem.title = "TheMovieDB Auth"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(cancelAuth))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let urlRequest = urlRequest {
            webView.loadRequest(urlRequest)
        }
    }
    
    // MARK: Cancel Auth Flow
    
    func cancelAuth() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - TMDBAuthViewController: UIWebViewDelegate

extension NetworkAuthViewController: UIWebViewDelegate {
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        //Original
       // if webView.request!.URL!.absoluteString == "\(Constants.AuthorizationURL)\(requestToken!)/allow" {
        
        //Modified because Constants.AuthorizationURL was deleted because it doesn't seem like we need it
           if webView.request!.URL!.absoluteString == "\(requestToken!)/allow" {
            dismissViewControllerAnimated(true) {
                self.completionHandlerForView!(success: true, errorString: nil)
            }
        }
    }
}