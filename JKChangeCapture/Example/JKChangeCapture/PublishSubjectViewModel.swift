//
//  PublishSubjectViewModel.swift
//  SwiftProject
//
//  Created by jack on 2023/9/20.
//

import Foundation
import RxSwift
import JKChangeCapture

struct PublishSubjectViewModel:JKChangeCaptureProtocol {
    var publishObjectMap: [String : RxSwift.PublishSubject<JKPublistMessage>]?
    
    var age:Int = 0 {
        didSet {
//          postMessage(key: "age", value: age)
            postMessage(key: "age", value: age, oldValue: oldValue)
        }
    }
    
    var num:Int = 0 {
        didSet {
            postMessage(key: "num", value: num, oldValue: oldValue)
        }
    }
    
    
    
    
    
}
