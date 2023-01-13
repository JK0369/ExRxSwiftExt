//
//  ViewController.swift
//  ExRxSwiftExt
//
//  Created by 김종권 on 2023/01/13.
//

import UIKit
import RxSwift
import RxSwiftExt

class ViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retry()
    }
    
    private func unwrap() {
        let observable = Observable.of(Int?(1),2,nil,4,5)
        
        // before
        observable
            .compactMap { $0 }
            .debug()
            .subscribe()
            .disposed(by: disposeBag)
        
        // after
        observable
            .unwrap()
            .debug()
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func pairwise() {
        let observable =  Observable.of(true, false)
        
        // before x
        
        // after
        observable
            .pairwise()
            .map { $0 == $1 }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func retry() {
        let observable = Observable<Int>.error(NSError(domain: "error", code: 1))
        
        // .immediate: 즉시 반복
        observable
            .retry(.immediate(maxCount: 2))
            .debug()
            .subscribe()
            .disposed(by: disposeBag)
        
        // .delayed: n초 후 반복
        observable
            .retry(.delayed(maxCount: 2, time: 3)) // 3초 후 한번 더 시도
            .debug()
            .subscribe()
            .disposed(by: disposeBag)
        
        // .customTimerDelayed: retry 시간 커스텀 + 클로저
        observable
            .retry(.customTimerDelayed(maxCount: 2, delayCalculator: { count in
                return .seconds(3)
            }))
            .debug()
            .subscribe()
            .disposed(by: disposeBag)
        
        // .exponentialDelayed: 지수 증가 (시간 - initial^mutiplier)
        observable
            .retry(.exponentialDelayed(maxCount: 2, initial: 3, multiplier: 2)) // 9초 후 한번 더 시도
            .debug()
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func ignore() {
        let observable = Observable.of(-1,1,2,3,4,5)
        
        // before
        observable
            .filter { $0 != -1 && $0 != 1 }
            .debug()
            .subscribe()
            .disposed(by: disposeBag)
        
        // after
        observable
            .ignore(-1, 1)
            .debug()
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func mapToVoid() {
        let observable = Observable.just(1)
        
        // before
        observable
            .map { _ in () }
            .subscribe()
            .disposed(by: disposeBag)
        
        // after
        observable
            .mapTo(())
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func count() {
        let observable = Observable.of(1,2,3,4,5)
        
        // before
        var count = 0
        observable
            .filter { $0 % 2 == 0 }
            .do(onNext: { _ in count += 1 })
            .subscribe()
                .disposed(by: disposeBag)
                
                // after
                observable
                .count { $0 % 2 == 0 }
                .subscribe()
                .disposed(by: disposeBag)
    }
    
    private func toggle() {
        let observable = Observable.just(false)
        
        // before
        observable
            .map { !$0 }
            .subscribe()
            .disposed(by: disposeBag)
        
        // after
        observable
            .not()
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func and() {
        let observable =  Observable.of(true, false)
        
        // before
        observable
            .pairwise()
            .map { $0 == $1 }
            .subscribe()
            .disposed(by: disposeBag)
        
        // after
        observable
            .and()
            .debug()
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func catchErrorJustComplete() {
        let observable = Observable<Int>.error(NSError(domain: "error", code: 1))
        
        // before
        observable
            .catch { error in
                    .empty() // empty를 방출하면 onComplete도 방출
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        // after
        observable
            .catchErrorJustComplete()
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func filterMap() {
        let observable = Observable.of(1,2,3,4,5,6)
        
        // before
        observable
            .filter { $0 % 2 == 0 }
            .map { $0 + 10 }
            .subscribe()
            .disposed(by: disposeBag)
        
        // after
        observable
            .filterMap { $0 % 2 == 0 ? .map($0 + 10) : .ignore }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func fromAsync() {
        // closure 메소드를 observable로 표현하는 방법
        // 인수는 Observable에서 받고, 클로저는 subscribe 블록에서 처리
        func someAsynchronousService(arg1: String, arg2: Int, completionHandler: (String) -> Void) {
        }
        
        // 1. 함수 이름을 fromAsync안에 삽입
        // 2. 파라미터는 뒤에 괄호로 추가
        // 3. 함수의 클로저는 subscribe안에서 처리
        Observable
            .fromAsync(someAsynchronousService)("jake", 0)
            .subscribe(onNext: { string in
                print(string)
            })
            .disposed(by: disposeBag)
    }
    
    private func partition() {
        let observable = Observable.of(1,2,3,4,5)
        
        let (evens, odds) = observable.partition { $0 % 2 == 0}
        
        evens
            .subscribe()
            .disposed(by: disposeBag)
        
        odds
            .subscribe()
            .disposed(by: disposeBag)
    }
}
