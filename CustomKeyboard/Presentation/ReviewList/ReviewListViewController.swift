//
//  ReviewListViewController.swift
//  CustomKeyboard
//
//  Created by oyat on 2022/07/13.
//

import UIKit

class ReviewListViewController: UIViewController {
    
    // MARK: - Properties
    private var reviewDatas: [ReviewType] = []
    private var collectionView: UICollectionView! = nil
    private let reviewTextFieldStack = UIStackView()
    private let profileImageView = UIImageView()
    private let reviewTextView = UITextView()
    private let reviewPostButton = UIButton()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        configureUI()
        addTapGesture()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Methods
extension ReviewListViewController {
    private func fetchData() {
        NetworkManager.shared.fetchReview { result in
            switch result {
            case .success(let result):
                self.reviewDatas = result.data
                
                DispatchQueue.main.async { [unowned self] in
                    collectionView.reloadData()
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func postData() {
        NetworkManager.shared.postReview(message: reviewTextView.text) { result in
            switch result {
            case .success(let result):
                print(result)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func addTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        self.reviewTextView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func convertDateTime(createdAtTime: String) -> String {
        
        //TODO : 날짜 비교해서 보여주는 것 아직 안함
        // 댓글을 작성한 시간이 1시간 이내일 경우 분 단위로 표시,
        // 하루 이내일 경우 시간 단위로 표시
        // 하루 이상일 경우 년월일만 표시
        
        //Date형식 설정
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        //2021-10-29T02:14:10.135Z
        
        //String을 Date형식으로 바꿔주기
        let createdAtDateTime = dateFormatter.date(from: createdAtTime)
        
        //바꿔줄 원하는 날짜 형식 설정
        let myDataFormatter = DateFormatter()
        myDataFormatter.dateFormat = "yyyy년 MM월 dd일"
        myDataFormatter.locale = Locale(identifier: "ko_KR")
        
        //Date를 설정해둔 날짜 형식의 String으로 바꿔주기
        let convertCreatedAtStringTime = myDataFormatter.string(from: createdAtDateTime!)
        return convertCreatedAtStringTime
    }
}

// MARK: - Objc Methods
extension ReviewListViewController {
    @objc func didTapView() {
        let vc = ReviewWriteView(inputField: reviewTextView)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapWriteButton() {
        postData()
    }
}

// MARK: - ConfigureUI
extension ReviewListViewController {
    private func configureUI() {
        view.backgroundColor = .systemBackground
        title = "CustomKeyboard"
        configureAttribute()
        configureStackView()
        configureCollectionViewLayout()
    }
    
    private func configureAttribute() {
        
        //스택뷰
        reviewTextFieldStack.axis = .horizontal
        reviewTextFieldStack.spacing = 10
        reviewTextFieldStack.translatesAutoresizingMaskIntoConstraints = false
        
        //프로필이미지뷰
        let imageIcon = UIImage(systemName: "person.crop.circle")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        profileImageView.image = imageIcon
        
        //텍스트뷰
        reviewTextView.text = "이 테마가 마음에 드시나요?"
        reviewTextView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 5, right: 5)
        reviewTextView.font = UIFont.boldSystemFont(ofSize: 16)
        reviewTextView.layer.cornerRadius = 15
        reviewTextView.backgroundColor = .systemGray6
        
        //버튼
        reviewPostButton.configuration = UIButton.Configuration.tinted()
        reviewPostButton.configuration?.title = "작성"
        reviewPostButton.addTarget(self, action: #selector(didTapWriteButton) , for: .touchUpInside)
    }
    
    private func configureStackView() {
        view.addSubview(reviewTextFieldStack)
        NSLayoutConstraint.activate([
            reviewTextFieldStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            reviewTextFieldStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            reviewTextFieldStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            reviewTextFieldStack.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.1)
        ])
        
        reviewTextFieldStack.addArrangedSubview(profileImageView)
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1),
            profileImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1),
        ])
        
        reviewTextFieldStack.addArrangedSubview(reviewTextView)
        reviewTextFieldStack.addArrangedSubview(reviewPostButton)
        
    }
    
    private func configureCollectionViewLayout() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.dataSource = self
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.register(ReviewListCell.self, forCellWithReuseIdentifier: ReviewListCell.identifier)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        //아이템
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(0.2))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        //그룹
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(0.3))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                     subitem: item, count: 1)
        
        //섹션
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        //레이아웃
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
}

// MARK: - CollectionView DataSource
extension ReviewListViewController: UICollectionViewDataSource {
    
    //각 세션에 들어가는 아이템 갯수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("셀 갯수:", reviewDatas.count)
        return reviewDatas.count
    }
    
    //셀에 대한 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewListCell.identifier, for: indexPath) as? ReviewListCell else {
            return ReviewListCell()
        }
        
        guard let url = URL(string: self.reviewDatas[indexPath.row].user.profileImage) else {
            return ReviewListCell()
        }
        
        let index = indexPath.row
        cell.backgroundColor = .systemBackground
        
        cell.profileImage.load(url: url)
        
        cell.userNameLabel.text = reviewDatas[index].user.userName
        cell.contentsLabel.text = reviewDatas[index].content
        cell.timeLabel.text = convertDateTime(createdAtTime: reviewDatas[index].createdAt)
        
        return cell
    }
    
}
