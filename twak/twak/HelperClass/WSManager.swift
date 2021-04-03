//
//  WSManager.swift
//  IMS Wave
//
//  Created by Archana on 14/11/18.
//  Copyright © 2018 Wishtree. All rights reserved.
//

import Foundation
import UIKit
/// web API call manager
class WSManager: NSObject {
    
    let baseUrl =  "https://api.github.com/users?since=" //
    let detailUrl = "https://api.github.com/users/"
    
    static let shared = WSManager()
    lazy var cache: URLCache = {
        let diskCacheURL = FilePathManager.getcatchDirectory()
        let cache = URLCache(memoryCapacity: 100_000_000, diskCapacity: 1_000_000_000, directory: diskCacheURL)
        return cache
    }()
    
    // Custom URLSession that uses our cache
    lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.urlCache = cache
        return URLSession(configuration: config)
    }()
    
    enum ExicutionError: Error {
        case retry, httpError
    }
    /**
     download image from remote url
     - Parameter imageUrlString: remote url of image
     pNum: product number
     completion:completion block to return success
     */
    func downloadImage(_ urlRequest: URLRequest, foruser uId: String, completion: @escaping(Result<Data, ExicutionError>) -> Void) {
        
        
        if NetworkManager.sharedInstance.reachability.connection != .unavailable {
            // DispatchQueue.global(qos: .background).async {
            self.session.downloadTask(with: urlRequest, completionHandler: { temUrl, response, error in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let temUrl = temUrl, error == nil,
                    let data = try? Data(contentsOf: temUrl, options: [.mappedIfSafe])
                
                else {
                    
                    completion(.failure(.httpError))
                    return }
                self.cache.storeCachedResponse(CachedURLResponse(response: httpURLResponse, data: data), for: urlRequest)
                // if FilePathManager.moveFile(uId, fromUrl: temUrl) {
                completion(.success(data))
                return
                // }
            }).resume()
            //   }
        } else{
            completion(.failure(.retry))
        }
    }
    
    
    
    func load(_ url: URL, completion: @escaping((Result<Data, ExicutionError>) -> Void)) {
        if NetworkManager.sharedInstance.reachability.connection != .unavailable {
            URLSession(configuration: URLSessionConfiguration.default).dataTask(with: url) { data, response, error in
                if let data = data {
                    completion(.success(data))
                } else if error != nil{
                    completion(.failure(.httpError))
                }
            }.resume()
        } else{
            completion(.failure(.retry))
        }
    }
    
}
