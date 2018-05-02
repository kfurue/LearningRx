//
//  ViewController.swift
//  reactive
//
//  Created by Kazuhiro Furue on 2018/04/16.
//  Copyright © 2018年 Kazuhiro Furue. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {
    let searchField = UITextField()
    let totalCountLabel = UILabel()
    let reposLabel = UILabel()
    let disposeBag = DisposeBag()

    struct GithubRepository {
        let name:String
        let startCount:Int
        init(dictionary:[String:Any]){
            name = dictionary["full_name"] as! String
            startCount = dictionary["stargazers_count"] as! Int
        }
    }
    struct SearchResult {
        let repos:[GithubRepository]
        let totalCount:Int
        init?(response:Any){
            guard let response = response as? [String:Any],
                let reposDictionaries = response["items"] as? [[String:Any]],
                let count = response["total_count"] as? Int
                else { return nil }

            repos = reposDictionaries.compactMap{ GithubRepository(dictionary: $0) }
            totalCount = count
        }
    }

    func searchRepos(keyword:String) -> Observable<SearchResult?> {
        let endPoint = "https://api.github.com"
        let path = "/search/repositories"
        let query = "?q=\(keyword)"
        let url = URL(string: endPoint + path + query)!
        let request = URLRequest(url: url)
        return URLSession.shared
            .rx.json(request: request)
            .map{ SearchResult(response: $0) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupSubviews()
        bind()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupSubviews() {
        searchField.frame = CGRect(x: 10, y: 50, width: 300, height: 20)
        totalCountLabel.frame = CGRect(x: 10, y: 80, width: 300, height: 20)
        reposLabel.frame = CGRect(x: 10, y: 100, width: 300, height: 400)

        searchField.borderStyle = .roundedRect
        reposLabel.numberOfLines = 0
        searchField.keyboardType = .alphabet

        view.addSubview(searchField)
        view.addSubview(totalCountLabel)
        view.addSubview(reposLabel)
    }

    func bind() {
        let result:Observable<SearchResult?> = searchField.rx.text
            .orEmpty
            .asObservable()
            .skip(1)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMap {
                self.searchRepos(keyword: $0).observeOn(MainScheduler.instance)
                .catchErrorJustReturn(nil)
            }.share(replay: 1)

        let foundRepos:Observable<String> = result.map {
            let repos = $0?.repos ?? [GithubRepository]()
            return repos.reduce("", {
                $0 + "\($1.name)(\($1.startCount)) \n"
            })
        }

        let foundCount:Observable<String> = result.map {
            let count = $0?.totalCount ?? 0
            return "TotalCount: \(count)"
        }

        foundRepos
            .bind(to: reposLabel.rx.text)
            .disposed(by: disposeBag)

        foundCount
        .startWith("Input Repository Name")
            .bind(to: totalCountLabel.rx.text)
            .disposed(by: disposeBag)
    }
}

