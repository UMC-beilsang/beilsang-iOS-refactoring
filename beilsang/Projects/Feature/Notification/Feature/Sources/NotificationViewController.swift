//
//  NotificationViewController.swift
//  beilsang
//
//  Created by 강희진 on 2/7/24.
//

import UIKit
import SnapKit

class NotificationViewController: UIViewController {
    // MARK: - Properties

    // 전체 화면 scrollview
    let fullScrollView = UIScrollView()
    let fullContentView = UIView()
    var notiData : [NotificationDataModel] = []
    
    lazy var notiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 48
        layout.minimumLineSpacing = 48
        layout.itemSize = CGSize(width: self.view.frame.width - 56, height: 58)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return view
    }()
    
    lazy var menu: UIMenu = {
        let notiOff = UIAction(
            title: "알림 끄기",
            image: nil,
            identifier: nil,
            discoverabilityTitle: nil,
            attributes: [],
            state: .off,
            handler: { [weak self] _ in
                self?.notiOff()
            })
        
        return UIMenu(title: "", options: [], children: [notiOff])
    }()
    
    lazy var noNotiLabel: UILabel = {
        let view = UILabel()
        view.text = "새로운 소식이 없습니다"
        view.font = UIFont(name: "NotoSansKR-Medium", size: 16)
        view.numberOfLines = 0
        view.textColor = .beTextEx
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        
        return view
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        notificationDataRequest()
        setupAttribute()
        setNavigationBar()
        viewConstraint()
    }

}
extension NotificationViewController {
    func setupAttribute() {
        setFullScrollView()
        setLayout()
        setCollectionView()
        setScrollViewLayout()
    }

    func setFullScrollView() {
        fullScrollView.delegate = self
        //스크롤 안움직이게 설정
        fullScrollView.isScrollEnabled = false
        //스크롤 안보이게 설정
        fullScrollView.showsVerticalScrollIndicator = false
    }

    func setLayout() {
        view.addSubview(fullScrollView)
        fullScrollView.addSubview(fullContentView)
        addView()
    }
    func setScrollViewLayout(){
        fullScrollView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        fullContentView.snp.makeConstraints { make in
            make.edges.equalTo(fullScrollView.contentLayoutGuide)
            make.width.equalTo(fullScrollView.frameLayoutGuide)
            make.height.equalTo(1056)
        }
    }
    // addSubview() 메서드 모음
    func addView() {
        // foreach문을 사용해서 클로저 형태로 작성
        [notiCollectionView, noNotiLabel].forEach{ view in fullContentView.addSubview(view)}

    }

    //snp 설정
    func viewConstraint(){
        notiCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(28)
            make.trailing.equalToSuperview().offset(-28)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        noNotiLabel.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(75)
            make.centerX.equalToSuperview()
        }
    }
    
   
}
// MARK: - 네비게이션 바 커스텀
extension NotificationViewController{
    private func setNavigationBar() {
        self.navigationItem.titleView = attributeTitleView()

        // 백 버튼 설정
        setBackButton()
    }
    private func attributeTitleView() -> UIView {
        // title 설정
        let label = UILabel()
        let lightText: NSMutableAttributedString =
            NSMutableAttributedString(string: "알림",attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont(name: "NotoSansKR-SemiBold", size: 20)!])
        let naviTitle: NSMutableAttributedString
            = lightText
        label.attributedText = naviTitle

        return label
    }
    // 백버튼 커스텀
    func setBackButton() {
        let leftBarButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-navigation")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(tabBarButtonTapped))
        // 기존 barbutton이미지 이용할 때 -> (barButtonSystemItem: ., target: self, action: #selector(tabBarButtonTapped))
        leftBarButton.tintColor = .black

        let rightBarButton: UIBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(named: "icon-meatballs")?.withRenderingMode(.alwaysTemplate), target: self, action: nil, menu: menu)
        rightBarButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    // 백버튼 액션
    @objc func tabBarButtonTapped() {
        print("뒤로 가기")
        navigationController?.popViewController(animated: true)
    }
    
    func notiOff() {
        UIApplication.shared.unregisterForRemoteNotifications()
        print("알림이 꺼졌습니다.")
    }
}
// MARK: - collectionView setting(카테고리)
extension NotificationViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    // collectionView, delegate, datasorce 설정
    func setCollectionView() {
        [notiCollectionView].forEach { view in
            view.delegate = self
            view.dataSource = self
        }

        //Cell 등록
        notiCollectionView.register(NotificationCollectionViewCell.self, forCellWithReuseIdentifier: NotificationCollectionViewCell.identifier)
    }
    // section 개수 설정
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    // cell 개수 설정
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case notiCollectionView:
            return notiData.count
        default:
            return 0
        }
    }

    // cell 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView{
        case notiCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NotificationCollectionViewCell.identifier, for: indexPath) as?
                    NotificationCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.challengeId = notiData[indexPath.row].challengeId
            cell.notificationId = notiData[indexPath.row].notificationId
            cell.titleLabel.text = notiData[indexPath.row].title
            cell.contentLabel.text = notiData[indexPath.row].contents
            let timeData = notiData[indexPath.row].time
            let convertedData = DateConverter.shared.convertNotification(from: timeData)
            cell.timeLabel.text = convertedData
            
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }

    // cell 선택시 액션
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView{
        case notiCollectionView:
            let cell = collectionView.cellForItem(at: indexPath) as! NotificationCollectionViewCell
            let challengeId = cell.challengeId
            //타이틀 따라 나눠야 될 것 같긴 함
            
            let nextVC = JoinChallengeViewController()
            nextVC.joinChallengeId = challengeId
            nextVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(nextVC, animated: true)

        default:
            return
        }
    }
}

//MARK: - Netword
extension NotificationViewController {
    func notificationDataRequest() {
        NotificationService.shared.getNotificationData{ response in
            self.setNotification(response.data ?? [])
            print(response)
        }
    }
    
    @MainActor
    private func setNotification(_ response: [NotificationDataModel]) {
        self.notiData = response
        if (notiData.count == 0) {
            noNotiLabel.isHidden = false
            notiCollectionView.isHidden = true
        
        }
        else {
            noNotiLabel.isHidden = true
            notiCollectionView.isHidden = false
            self.notiCollectionView.reloadData()
        }
    }
    
    
}
