/*:
 > # IMPORTANT: To use **Rx.playground**:
 1. Open **Rx.xcworkspace**.
 1. Build the **RxSwift-macOS** scheme (**Product** → **Build**).
 1. Open **Rx** playground in the **Project navigator**.
 1. Show the Debug Area (**View** → **Debug Area** → **Show Debug Area**).
 */
import RxSwift
/*:
 # Try Yourself
 
 It's time to play with Rx 🎉
 */
playgroundShouldContinueIndefinitely()

example("Try yourself") {
  // let disposeBag = DisposeBag()
  _ = Observable.just("Hello, RxSwift!")
    .debug("Observable")
    .subscribe()
    // .disposed(by: disposeBag) // If dispose bag is used instead, sequence will terminate on scope exit
}

let myFirstObservable = Observable<Int>.create{ observer in
    observer.on(.next(1))
    observer.on(.next(2))
    observer.on(.next(3))
    observer.on(.completed)
    return Disposables.create()
}

let subscription = myFirstObservable.subscribe{ event in
    switch event {
        case .next(let element):
            print(element)
        case .error(let error):
            print(error)
        case .completed:
            print("completed")
    }
}
