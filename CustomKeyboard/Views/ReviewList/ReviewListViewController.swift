//
//  ViewController.swift
//  CustomKeyboard
//

import UIKit

class ReviewListViewController: UIViewController {

    private var dataList = ModelData()
    private var headerText = ""
    
    private lazy var activityIndicator = UIActivityIndicatorView(style: .large)

    private var reviewTableView: UITableView = {
        let reviewTableView = UITableView()
        reviewTableView.sectionHeaderTopPadding = 0
        reviewTableView.separatorInset.left = 16
        reviewTableView.separatorInset.right = 16
        reviewTableView.register(ReviewTableViewCell.self, forCellReuseIdentifier: "Cell")
        reviewTableView.register(ReviewListHeaderView.self, forHeaderFooterViewReuseIdentifier: "headerCell")
        return reviewTableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        setIndicatorUI()
        setNavigationLayout()
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        activityIndicator.startAnimating()
        getData()
    }
    
    private func setNavigationLayout() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        navigationItem.title = "ReviewList"
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setLayout() {
        view.backgroundColor = .white
        view.addSubview(reviewTableView)
        
        reviewTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            reviewTableView.topAnchor.constraint(equalTo: view.topAnchor),
            reviewTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            reviewTableView.widthAnchor.constraint(equalTo: view.widthAnchor),
            reviewTableView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func setIndicatorUI() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func getData() {
        API.shared.get { [self] result in
            switch result {
            case .success(let data):
                dataList = data
                DispatchQueue.main.async {
                    self.reviewTableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            case .failure(let error as NetworkError):
                switch error {
                case .decodeError:
                    let decodedErrorAlert = UIAlertController(title: "알림", message: "데이터를 불러오는데 실패했습니다.", preferredStyle: .alert)
                    decodedErrorAlert.addAction(UIAlertAction(title: "확인", style: .default))
                    present(decodedErrorAlert, animated: true)
                default:
                    break
                }
            case .failure(_):
                break
            }
        }
    }
}

extension ReviewListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ReviewTableViewCell else { return UITableViewCell()}
        let reviewData = dataList.data[indexPath.row]
        cell.fetchDataFromTableView(data: reviewData)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerCell") as? ReviewListHeaderView else { return UITableViewHeaderFooterView()}
        headerCell.delegate = self
        headerCell.fetchReviewDataToTextField(reviewTextData: headerText)
        return headerCell
    }
}

extension ReviewListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
}

extension ReviewListViewController: PresentButtonSelectable {
    
    func presentButtonStatus() {
        let createReviewVC = CreateReviewViewController()
        createReviewVC.delegate = self
        createReviewVC.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(createReviewVC, animated: true)
    }
}

extension ReviewListViewController: ReviewTextReceivable {
    
    func  hangulKeyboardText(text: String) {
        headerText = text
        reviewTableView.reloadData()
    }
}
