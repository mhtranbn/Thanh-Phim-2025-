//
//  MovieSingleton.swift
//  HtmlParser
//
//  Created by DoHai on 3/22/15.
//  Copyright (c) 2015 dohai2105. All rights reserved.
//

import Foundation
private let _SingletonASharedInstance = MovieSingleton()

class MovieSingleton {
    var currentMovieType: String!
    
    init () {
        println("Will run to this line")
    }
    
    class var sharedInstance : MovieSingleton {
        return _SingletonASharedInstance
    }
    
    func decompileMovieHdViet(id:String, token: String , ep: String) -> String{
        var url = "movieid=\(id)&accesstokenkey=\(token)&ep=\(ep)"
        var byteArray = [UInt8]()
        for char in url.utf8{
            byteArray += [char]
        }
        var nsData = NSData(bytes: byteArray, length: byteArray.count)
        
        var stb = nsData.base64EncodedStringWithOptions(nil)
        stb = "\(stb)anDroidhdv1et20130924"
        var finalSign = stb.MD5String()
        println("\(url)&sign=\(finalSign.lowercaseString)")
        return "\(url)&sign=\(finalSign.lowercaseString)"
    }

 }