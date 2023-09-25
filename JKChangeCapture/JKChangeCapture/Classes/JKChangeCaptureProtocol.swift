//
//  JKChangeCaptureProtocol.swift
//  SwiftProject
//
//  Created by jack on 2023/9/20.
//

import Foundation
import RxSwift

public struct JKPublistMessage{
    public let key:String
    public let value:Any?
    public let oldValue:Any?
    
    init(key: String, value: Any?, oldValue:Any? = nil) {
        self.key = key
        self.value = value
        self.oldValue = oldValue
    }
}

fileprivate let changeCaptureLock:NSRecursiveLock = NSRecursiveLock()

public protocol JKChangeCaptureProtocol {
    var publishObjectMap:[String:PublishSubject<JKPublistMessage>]?{set get}
    mutating func postMessage(key:String,value:Any?, oldValue:Any?)
    mutating func observe<T>(key:String, of type:T.Type, onSubject:((_ subject:Observable<JKPublistMessage>)->Observable<JKPublistMessage>)?, block: @escaping ((_ value:T?)->Void)) ->Disposable
    mutating func observe<T>(key:String, of type:T.Type, onSubject:((_ subject:Observable<JKPublistMessage>)->Observable<JKPublistMessage>)?, detailBlock: @escaping ((_ value:T?,_ oldValue:T?)->Void)) ->Disposable
    mutating func observe(keys:[String], onSubject:((_ subject:Observable<JKPublistMessage>, _ key:String)->Observable<JKPublistMessage>)?, block:@escaping (_ message:JKPublistMessage?) -> Void) -> Disposable
}

private extension PublishSubject {
    func handleOnSubject(subject:Observable<JKPublistMessage>,
                         onSubject:((_ subject:Observable<JKPublistMessage>)->Observable<JKPublistMessage>)?) -> Observable<JKPublistMessage> {
        if onSubject != nil {
            return onSubject!(subject)
        }
        return subject
    }
    
    func handleOnSubject(subject:Observable<JKPublistMessage>,
                         key:String,
                         onSubject:((_ subject:Observable<JKPublistMessage>, _ key:String)->Observable<JKPublistMessage>)?) -> Observable<JKPublistMessage> {
        if onSubject != nil {
            return onSubject!(subject,key)
        }
        return subject
    }
}

public extension JKChangeCaptureProtocol {
     
    private mutating func publishObject(with key:String) -> PublishSubject<JKPublistMessage>{
        defer {
            changeCaptureLock.unlock()
        }
        changeCaptureLock.lock()
        if publishObjectMap == nil {
            self.publishObjectMap = [String:PublishSubject<JKPublistMessage>]()
        }
        if publishObjectMap![key] == nil {
            publishObjectMap![key] = PublishSubject<JKPublistMessage>()
        }
        return publishObjectMap![key]!
    }

    mutating func postMessage(key:String,value:Any?, oldValue:Any? = nil) {
        changeCaptureLock.lock()
        let publishtObject = publishObjectMap?[key]
        changeCaptureLock.unlock()
        publishtObject?.onNext(JKPublistMessage(key: key, value: value, oldValue:oldValue))
    }
    
    mutating func observe<T>(key:String, of type:T.Type = Any.self, onSubject:((_ subject:Observable<JKPublistMessage>)->Observable<JKPublistMessage>)? = nil, block: @escaping ((_ value:T?)->Void)) ->Disposable {
        let publishtObject = publishObject(with: key)
        return publishtObject.handleOnSubject(subject: publishtObject, onSubject: onSubject).subscribe { e in
            guard let element = e.element else {
                return
            }
            if element.key == key {
                block(element.value as? T)
            }
        }
    }
    
    mutating func observe<T>(key:String, of type:T.Type = Any.self, onSubject:((_ subject:Observable<JKPublistMessage>)->Observable<JKPublistMessage>)? = nil, detailBlock: @escaping ((_ value:T?,_ oldValue:T?)->Void)) ->Disposable {
        let publishtObject = publishObject(with: key)
        return publishtObject.handleOnSubject(subject: publishtObject, onSubject: onSubject).subscribe { e in
            guard let element = e.element else {
                return
            }
            if element.key == key {
                detailBlock(element.value as? T, element.oldValue as? T)
            }
        }
    }
    
    mutating func observe(keys:[String], onSubject:((_ subject:Observable<JKPublistMessage>, _ key:String)->Observable<JKPublistMessage>)? = nil, block:@escaping (_ message:JKPublistMessage?) -> Void) -> Disposable {
        var publishObjects = [(key:String,PublishSubject<JKPublistMessage>)]()
        var disposes = [Disposable]()
        for key in keys {
            let publishtObject = publishObject(with: key)
            publishObjects.append((key,publishtObject))
        }
    
        return Observable<JKPublistMessage>.create { observer in
            for (key, publishtObject) in publishObjects {
                let dispose = publishtObject.handleOnSubject(subject: publishtObject, key: key, onSubject: onSubject).subscribe({e in
                    observer.on(e)
                })
                disposes.append(dispose)
            }
            return Disposables.create {
                for dispose in disposes {
                    dispose.dispose()
                }
            }
       }.subscribe({ e in
           block(e.element)
       })
        
    }
    
    
}
