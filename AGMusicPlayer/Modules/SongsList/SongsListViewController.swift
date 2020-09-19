import Foundation
import RxCocoa
import RxSwift
import UIKit

class SongsListViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableViewSongs: UITableView!
    
    var presenter: SongsListPresenter?
    var bundle: [String: Any] = [:]
    var delegate: ViewControllerResultDelegate?
    private var disposeBag = DisposeBag()
    fileprivate var isLoading = BehaviorRelay(value: false)
    
    fileprivate var arrSongs: [ResultData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let delegate = bundle[Constants.BundleConstants.delegate] as? ViewControllerResultDelegate {
            self.delegate = delegate
        }
        self.initSetUp()
    }
    
    func initSetUp() {
        self.initNavBar()
        self.initRxBindings()
        self.initTableViewSetUp()
        self.searchBar.delegate = self
    }
    
    func initNavBar() {
        self.title = "Songs"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "song"), style: .plain, target: self, action: #selector(self.handleSongs))
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        initViews()
        initData()
    }
    
    /// Function to initialize view components
    private func initViews() {
    }
    
    /// Function to call data or perform navigation action on viewWillAppear
    private func initData() {
    }
    
    func initTableViewSetUp() {
        self.tableViewSongs.delegate = self
        self.tableViewSongs.dataSource = self
        self.tableViewSongs.register(UINib(nibName: "SongsTVCell", bundle: nil), forCellReuseIdentifier: "SongsTVCell")
    }
    
    @objc private func handleSongs() {
        let bundle = [
            Constants.BundleConstants.resultData: self.arrSongs
        ]
        self.presenter?.navigateTo(destination: Destination.multiSongPlayer, bundle: bundle)
    }
    
    /// Function to initialize Rx for views and variables
    private func initRxBindings() {
        isLoading
            .asObservable()
            .bind { status in
                if status {
                    AppDelegate.startLoading()
                } else {
                    AppDelegate.finishLoading()
                }
        }
        .disposed(by: disposeBag)
    }
}

extension SongsListViewController: ViewControllerResultDelegate {
    func viewControllerResultBundle(bundle: [String : Any]) {
        
    }
}

extension SongsListViewController {
    
    func searchByQuerySuccessWithResponse(response: Any) {
        isLoading.accept(false)
        if let apiResponse = response as? SongsResponse {
            self.arrSongs.removeAll()
            self.arrSongs = apiResponse.results ?? []
            self.tableViewSongs.reloadData()
        } else if let apiResponse = response as? ErrorResponse {
            let msg = apiResponse.error?.message ?? ""
            AppDelegate.showToast(message: msg)
        }
    }
    
    func searchByQueryFailureWithError(error: Error) {
        isLoading.accept(false)
        AppDelegate.showToast(message: error.localizedDescription)
    }
}

extension SongsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongsTVCell", for: indexPath) as! SongsTVCell
        if let coverImage = self.arrSongs[indexPath.item].artworkUrl100 {
            cell.songCoverImage.sd_setImage(with: URL(string: coverImage), placeholderImage: nil, options:.refreshCached)
        }
        cell.songTitleLabel.text = self.arrSongs[indexPath.item].trackName ?? ""
        cell.songSubTitleLabel.text = self.arrSongs[indexPath.item].artistName ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bundle = [
            Constants.BundleConstants.songData: self.arrSongs[indexPath.item]
        ]
        self.presenter?.navigateTo(destination: Destination.singleSongPlayer, bundle: bundle)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension SongsListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        if (self.searchBar.text?.count)! > 0 {
            self.isLoading.accept(true)
            let param = self.presenter?.getSearchParam(searchQuery: self.searchBar.text ?? "")
            self.presenter?.searchByQuery(parameters: param!)
        }
    }
}
