//
//  Alamofire+Synchronous.swift
//  XM_Infor
//
//  Created by Jeremy Wang on 19/09/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import Alamofire

extension DataRequest {
    
    /// Wait for the request to finish then return the response value.
    ///
    /// - Returns: The response.
    public func response() -> DefaultDataResponse {
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: DefaultDataResponse!
        
        self.response(queue: DispatchQueue.global(qos: .default)) { response in
            
            result = response
            semaphore.signal()
            
        }
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return result
    }
    
    /// Wait for the request to finish then return the response value.
    ///
    /// - Parameter responseSerializer: The response serializer responsible for serializing the request, response, and data.
    /// - Returns: The response.
    public func response<T: DataResponseSerializerProtocol>(responseSerializer: T) -> DataResponse<T.SerializedObject> {
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: DataResponse<T.SerializedObject>!
        
        self.response(queue: DispatchQueue.global(qos: .default), responseSerializer: responseSerializer) { response in
            
            result = response
            semaphore.signal()
            
        }
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return result
    }
    
    /// Wait for the request to finish then return the response value.
    ///
    /// - Returns: The response.
    public func responseData() -> DataResponse<Data> {
        return response(responseSerializer: DataRequest.dataResponseSerializer())
    }

    /// Wait for the request to finish then return the response value.
    ///
    /// - Parameter options: The JSON serialization reading options. `.AllowFragments` by default.
    /// - Returns: The response.
    public func responseJSON(options: JSONSerialization.ReadingOptions = .allowFragments) -> DataResponse<Any> {
        return response(responseSerializer: DataRequest.jsonResponseSerializer(options: options))
    }
    
    /// Wait for the request to finish then return the response value.
    ///
    /// - Parameter encoding: The string encoding. If `nil`, the string encoding will be determined from the server response, falling back to the default HTTP default character set, ISO-8859-1.
    /// - Returns: The response.
    public func responseString(encoding: String.Encoding? = nil) -> DataResponse<String> {
        return response(responseSerializer: DataRequest.stringResponseSerializer(encoding: encoding))
    }
    
    /// Wait for the request to finish then return the response value.
    ///
    /// - Parameter options: The property list reading options. Defaults to `[]`.
    /// - Returns: The response.
    public func responsePropertyList(options: PropertyListSerialization.ReadOptions = PropertyListSerialization.ReadOptions()) -> DataResponse<Any> {
        return response(responseSerializer: DataRequest.propertyListResponseSerializer(options: options))
    }
}

