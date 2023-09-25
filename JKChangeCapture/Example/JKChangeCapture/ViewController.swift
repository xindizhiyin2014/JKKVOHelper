//
//  ViewController.swift
//  JKChangeCapture
//
//  Created by jack on 2023/9/25.
//

import Foundation
import UIKit
import SnapKit
import RxSwift

class ViewController:UIViewController {
    var viewModel = PublishSubjectViewModel()
    let disposeBag = DisposeBag()
    var age = 10
    var num = 1
    private lazy var btn1:UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("PublishSubject测试", for: .normal)
        btn.backgroundColor = .blue
        btn.addTarget(self, action: #selector(btnClicked1), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(btn1)
        btn1.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 100, height: 30))
        }
        addObservers()
    }
    
    
    func addObservers() {
        
        viewModel.observe(key: "age") { value in
            print("aaa \(value)")
        }.disposed(by: disposeBag)

//        viewModel.observe(key: "age",of:Int.self) { value in
//            debugLog("age aaa \(value)")
//        }.disposed(by: disposeBag)
        
//        viewModel.observe(key: "age") { subject in
//            return subject.skip(1)
//        } block: { value in
//            print("age aaa \(value)")
//        }.disposed(by: disposeBag)
//
//        viewModel.observe(key: "age") { subject in
//            return subject.skip(2)
//        } block: { value in
//            print("age bbb \(value)")
//        }.disposed(by: disposeBag)

        
//        viewModel.observe(key: "age", of: Int.self) { value, oldValue in
//            debugLog("aaa \(value)")
//            debugLog("bbb \(oldValue)")
//        }.disposed(by: disposeBag)
        
//        viewModel.observe(key: "age", of: Int.self) { subject in
//           return subject.skip(1)
//        } detailBlock: { value, oldValue in
//
//            debugLog("aaa \(value)")
//            debugLog("bbb \(oldValue)")
//        }.disposed(by: disposeBag)
        
//        viewModel.observe(keys: ["age","num"]) { message in
//            print("aaa key: \(message?.key), value:\(message?.value), oldValue: \(message?.oldValue)")
//        }.disposed(by: disposeBag)
//
//
//        viewModel.observe(keys: ["age","num"]) { subject, key in
//            return subject.skip(2)
//        } block: { message in
//            print("bbb key: \(message?.key), value:\(message?.value), oldValue: \(message?.oldValue)")
//        }.disposed(by: disposeBag)




        
        
    }
    
    
    @objc  private func btnClicked1() {
        viewModel.age = age
        age += 1
        viewModel.num = age

        
      }
      
    
    
}
