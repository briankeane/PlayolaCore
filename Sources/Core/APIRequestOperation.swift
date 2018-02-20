//
//  APIRequestOperation.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 2/17/18.
//  Copyright © 2018 Brian D Keane. All rights reserved.
//

import Alamofire

class APIRequestOperation: PlayolaOperation
{
    private let urlString:String
    private let headers:HTTPHeaders?
    private let parameters:Parameters?
    private let method:HTTPMethod
    
    var response:DataResponse<Any>?
    
    init(urlString:String, method:HTTPMethod, headers:HTTPHeaders?=nil, parameters:Parameters?=nil)
    {
        self.urlString = urlString
        self.method = method
        self.headers = headers
        self.parameters = parameters
    }
    
    override func main() {
        guard (self.isCancelled == false) else {
            self.finish(true)
            return
        }
        self.executing(true)
        
        let encoding:ParameterEncoding = self.method == .get ? URLEncoding.default : JSONEncoding.default

        Alamofire.request(self.urlString,
                          method: self.method, parameters: self.parameters,
                          encoding: encoding,
                     headers: self.headers)
        .responseJSON
        {
            (response) -> Void in
            self.response = response
            self.executing(false)
            self.finish(true)
        }
    }
}
