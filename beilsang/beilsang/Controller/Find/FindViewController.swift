//
//  FindNewViewController.swift
//  beilsang
//
//  Created by Seyoung on 8/3/24.
//

import UIKit
import SnapKit
import SafariServices
import SCLAlertView
import Kingfisher

class FindViewController: UIViewController {
    
    // MARK: - Properties
    // 명예의 전당 전체 카테고리 리스트
    let hofCategoryList = CategoryKeyword.find
    
    // 현재 명예의 전당 카테고리
    var hofCategory : String = "다회용컵"
    
    // 카테고리별 챌린지 리스트 - 2차원 배열
    var hofChallengeDict: [Int: [ChallengeModel]] = [:]
    
    // 피드 전체 카테고리 리스트
    let feedCategoryList = CategoryKeyword.data
    
    // 현재 피드 카페고리
    var feedCategory : String = "전체"
    
    // 카테고리별 피드 리스트 - 2차원 배열
    var feedDict : [Int: [FeedModel]] = [:]
    
    // 현재 페이지
    var pageNumber = [Int](repeating: 0, count: 10)
    
    // 팝업
    var alertViewResponder: SCLAlertViewResponder? = nil
    
    
    // View
    let fullScrollView = UIScrollView()
    let fullContentView = UIView()
    
    lazy var searchBar: UIButton = {
        let view = UIButton()
        view.titleLabel?.font = UIFont(name: "NotoSansKR-Medium", size: 14)
        view.setTitleColor(.beTextSub, for: .normal)
        view.setTitle("누구나 즐길 수 있는 대중교통 챌린지! 🚌", for: .normal)
        view.backgroundColor = .beBgSub
        view.layer.cornerRadius = 24
        view.addTarget(self, action: #selector(searchBarTapped), for: .touchUpInside)
        return view
    }()
    
    lazy var searchIcon: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon-search")
        return view
    }()
    
    
    // 명예의 전당
    lazy var hofChallengeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "명예의 전당 챌린지 모음집 💾"
        label.font = UIFont(name: "NotoSansKR-SemiBold", size: 18)
        label.textColor = .black
        return label
    }()
    
    lazy var hofChallengeCategoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return view
    }()
    
    lazy var hofChallengeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.itemSize = CGSize(width: 160, height: 160)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.decelerationRate = .fast
        return view
    }()
    
    lazy var hofScrollIndicator: ScrollIndicatorView = {
        let view = ScrollIndicatorView()
        return view
    }()
    
    // 카테고리별 피드
    lazy var feedTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "카테고리별 챌린지 피드"
        label.font = UIFont(name: "NotoSansKR-SemiBold", size: 18)
        label.textColor = .black
        return label
    }()
    
    lazy var feedCategoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 72, height: 72)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        return view
    }()
    
    lazy var feedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 173, height: 140)
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.isScrollEnabled = true
        return view
    }()
    
    lazy var feedDetailView: UIView = {
        let view = UIView()
        view.backgroundColor = .beBgDef
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var feedDetailCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.isScrollEnabled = false
        
        return collectionView
    }()
    
    lazy var reportLabelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.isEnabled = true
        button.setTitle("신고하기", for: .normal)
        button.setTitleColor(.beTextEx, for: .normal)
        button.titleLabel?.font = UIFont(name: "NotoSansKR-Regular", size: 11)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(reportLabelButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    lazy var moreFeedButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        
        // Button style
        configuration.background.backgroundColor = .white
        configuration.background.strokeColor = UIColor.beBgDiv
        configuration.background.strokeWidth = 1
        configuration.background.cornerRadius = 20
        
        // Image
        configuration.image = UIImage(named: "Vector 10")
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 10
        
        // Title
        configuration.title = "\(feedCategory) 챌린지 더보기"
        configuration.baseForegroundColor = .black
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont(name: "NotoSansKR-Medium", size: 14)
            return outgoing
        }
        
        // Button
        let button = UIButton(configuration: configuration, primaryAction: nil)
        button.addAction(UIAction { _ in
            self.showMoreFeed()
        }, for: .touchUpInside)
        
        return button
    }()
    
    lazy var noHofChallengeLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name:"NotoSansKR-Regular", size: 12)
        view.numberOfLines = 0
        view.textColor = .beTextInfo
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        view.text = "명예의 전당에 올라간 챌린지가 없어요 👀"
        
        return view
    }()
    
    lazy var noFeedLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name:"NotoSansKR-Regular", size: 12)
        view.numberOfLines = 0
        view.textColor = .beTextInfo
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        view.text = "해당 카테고리에 표시할 피드가 없어요👀"
        
        return view
    }()
    
    lazy var noHofChallengeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .beBgDef
        button.setTitle("챌린지 만들러 가기", for: .normal)
        button.setTitleColor(.beTextDef, for: .normal)
        button.titleLabel?.font = UIFont(name: "NotoSansKR-Medium", size: 14)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.beBorderDis.cgColor
        button.layer.cornerRadius = 20
        button.isEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(homeButtonTapped), for: .touchDown)
        
        return button
    }()
    
    lazy var noFeedButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .beBgDef
        button.setTitle("홈으로 돌아가기", for: .normal)
        button.setTitleColor(.beTextDef, for: .normal)
        button.titleLabel?.font = UIFont(name: "NotoSansKR-Medium", size: 14)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.beBorderDis.cgColor
        button.layer.cornerRadius = 20
        button.isEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(homeButtonTapped), for: .touchDown)
        
        return button
    }()
    
    //report Popup
    lazy var reportAlert: SCLAlertView = {
        let apperance = SCLAlertView.SCLAppearance(
            kWindowWidth: 342, kWindowHeight : 184,
            kTitleFont: UIFont(name: "NotoSansKR-SemiBold", size: 18)!,
            showCloseButton: false,
            showCircularIcon: false,
            dynamicAnimatorActive: false
        )
        let alert = SCLAlertView(appearance: apperance)
        
        return alert
    }()
    
    lazy var reportSubView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        return view
    }()
    
    lazy var reportLabel: UILabel = {
        let view = UILabel()
        view.text = "해당 피드의 신고 사유가 무엇인가요?\n하단 링크를 통해 알려 주세요"
        view.font = UIFont(name: "NotoSansKR-Medium", size: 12)
        view.numberOfLines = 2
        view.textColor = .beTextInfo
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        
        return view
    }()
        
    lazy var reportUnderLabel: UILabel = {
        let view = UILabel()
        view.text = "신고하기를 누를시 외부 링크로 연결됩니다"
        view.font = UIFont(name: "NotoSansKR-Regular", size: 11)
        view.numberOfLines = 2
        view.textColor = .beTextEx
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        
        return view
    }()
    
    lazy var reportCancelButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .beBgSub
        button.setTitleColor(.beTextEx, for: .normal)
        button.setTitle("취소", for: .normal)
        button.titleLabel?.font = UIFont(name: "NotoSansKR-Medium", size: 14)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        return button
    }()
    
    lazy var reportButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .beScPurple600
        button.setTitleColor(.white, for: .normal)
        button.setTitle("신고하기", for: .normal)
        button.titleLabel?.font = UIFont(name: "NotoSansKR-Medium", size: 14)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //toastPopUp
    lazy var toastLabel : UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.font = UIFont(name: "NotoSansKR-Medium", size: 16)
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        view.textAlignment = .center
        view.backgroundColor = .beTextDef.withAlphaComponent(0.8)
        view.isHidden = false
        view.text = "더보기할 챌린지가 없습니다!🥹"
        
        return view
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        UISetup()
        setCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setFirstIndexIsSelected()
        setHofIndicator()
    }
    
    //MARK: - Actions
    @objc func searchBarTapped() {
        print("SearchBarTapped")
        let searchVC = SearchViewController()
        searchVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @objc func showMoreFeed() {
        let categoryIndex = changeFeedCategoryToInt(category: feedCategory)
        
        requestFeedList(forCategory: categoryIndex) { [weak self] list in
            guard let self = self else { return }
            self.feedDict[categoryIndex]?.append(contentsOf: list)
            
            // UI 업데이트
            DispatchQueue.main.async {
                self.feedCollectionView.reloadData()
                self.updateFeedCollectionViewHeight()
                
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func reportButtonTapped() {
        let reportUrl = NSURL(string: "https://moaform.com/q/DJ7VuN")
        let reportSafariView: SFSafariViewController = SFSafariViewController(url: reportUrl! as URL)
        self.present(reportSafariView, animated: true, completion: nil)
        alertViewResponder?.close()
    }
    
    @objc func close(){
        alertViewResponder?.close()
    }
    
    @objc func homeButtonTapped(_ sender: UIButton) {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate, let window = sceneDelegate.window {
            let mainVC = TabBarViewController()
            UIView.transition(with: window, duration: 1.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = mainVC
            }, completion: nil)
        }
    }
    
    @objc func reportLabelButtonTapped() {
        print("report Label Button Tapped")
        alertViewResponder = reportAlert.showInfo("챌린지 인증 신고하기")
    }
    
    @objc func tabBarButtonTapped() {
        print("알림버튼")
        let notificationVC = NotificationViewController()
        notificationVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(notificationVC, animated: true)
    }
    
    //MARK: - UI Setup
    func UISetup() {
        setNavigationBar()
        setLayout()
    }
    
    private func setNavigationBar() {
        self.navigationItem.titleView = attributeTitleView()
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.white
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        setBackButton()
    }
    
    private func setLayout() {
        hofChallengeCollectionView.isHidden = false
        hofScrollIndicator.isHidden = false
        feedCollectionView.isHidden = false
        feedDetailView.isHidden = true
        noFeedLabel.isHidden = true
        noFeedButton.isHidden = true
        noHofChallengeLabel.isHidden = true
        noHofChallengeButton.isHidden = true
        
        setViewLayout()
        setReportAlertLayout()
    }
}

//MARK: - SetLayout
extension FindViewController {
    private func attributeTitleView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
        titleLabel.text = "발견"
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont(name: "NotoSansKR-SemiBold", size: 22)
        view.addSubview(titleLabel)
          
        return view
    }
    
    func setBackButton() {
        let notiButton = UIBarButtonItem(image: UIImage(named: "iconamoon_notification-bold")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(tabBarButtonTapped))
        notiButton.tintColor = .black
        self.navigationItem.rightBarButtonItem = notiButton
    }
    
    private func setViewLayout() {
        view.addSubview(fullScrollView)
        fullScrollView.addSubview(fullContentView)
        
        [searchBar, searchIcon, hofChallengeTitleLabel, hofChallengeCategoryCollectionView, hofChallengeCollectionView, hofScrollIndicator, feedTitleLabel, feedCategoryCollectionView, feedCollectionView, feedDetailView, moreFeedButton, noHofChallengeLabel, noFeedLabel, noHofChallengeButton,noFeedButton].forEach{view in fullContentView.addSubview(view)}
        
        feedDetailView.addSubview(feedDetailCollectionView)
        feedDetailView.addSubview(reportLabelButton)
        
        view.backgroundColor = .beBgDef
        
        let height = UIScreen.main.bounds.height
        let width = UIScreen.main.bounds.width
        
        fullScrollView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        fullContentView.snp.makeConstraints { make in
            make.edges.equalTo(fullScrollView.contentLayoutGuide)
            make.width.equalTo(fullScrollView.frameLayoutGuide)
            make.bottom.equalTo(moreFeedButton.snp.bottom).offset(48)
        }
        
        searchBar.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(24)
        }
        
        searchIcon.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.centerY.equalTo(searchBar)
            make.leading.equalTo(searchBar).offset(20)
        }
        
        hofChallengeTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(searchBar)
            make.top.equalTo(searchBar.snp.bottom).offset(29)
        }
        
        hofChallengeCategoryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(hofChallengeTitleLabel.snp.bottom).offset(12)
            make.leading.equalTo(searchBar)
            make.trailing.equalToSuperview()
            make.height.equalTo(28)
        }
        
        hofChallengeCollectionView.snp.makeConstraints { make in
            make.top.equalTo(hofChallengeCategoryCollectionView.snp.bottom).offset(16)
            make.leading.trailing.equalTo(hofChallengeCategoryCollectionView)
            make.height.equalTo(160)
        }
        
        hofScrollIndicator.snp.makeConstraints { make in
            make.top.equalTo(hofChallengeCollectionView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalTo(4)
        }
        
        noHofChallengeLabel.snp.makeConstraints { make in
            make.top.equalTo(hofChallengeCategoryCollectionView.snp.bottom).offset(84)
            make.centerX.equalToSuperview()
        }
        
        noHofChallengeButton.snp.makeConstraints { make in
            make.top.equalTo(noHofChallengeLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(240)
        }
        
        feedTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(hofScrollIndicator.snp.bottom).offset(40)
            make.leading.equalToSuperview().offset(16)
        }
        
        feedCategoryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(feedTitleLabel.snp.bottom).offset(12)
            make.height.equalTo(72)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        feedCollectionView.snp.makeConstraints { make in
            make.top.equalTo(feedCategoryCollectionView.snp.bottom).offset(16)
            make.leading.equalTo(feedCategoryCollectionView)
            make.trailing.equalToSuperview().offset(-16)
            // 임시
            make.height.equalTo(300)
        }
        
        noFeedLabel.snp.makeConstraints { make in
            make.top.equalTo(feedCategoryCollectionView.snp.bottom).offset(104)
            make.centerX.equalToSuperview()
        }
        
        noFeedButton.snp.makeConstraints { make in
            make.top.equalTo(noFeedLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(240)
        }
        
        feedDetailView.snp.makeConstraints { make in
            make.top.equalTo(feedCollectionView.snp.top)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(800)
        }
        
        feedDetailCollectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(664)
        }
        
        reportLabelButton.snp.makeConstraints { make in
            make.top.equalTo(feedDetailCollectionView.snp.bottom).offset(12)
            make.trailing.equalToSuperview()
        }
        
        moreFeedButton.snp.makeConstraints { make in
            make.top.equalTo(feedCollectionView.snp.bottom).offset(48)
            make.centerX.equalToSuperview()
            make.width.equalTo(240)
            make.height.equalTo(40)
        }
    }
    
    private func setReportAlertLayout() {
        reportAlert.customSubview = reportSubView
        [reportLabel, reportUnderLabel, reportCancelButton, reportButton].forEach { view in
            reportSubView.addSubview(view)
        }
        
        reportSubView.snp.makeConstraints { make in
            make.width.equalTo(318)
            make.height.equalTo(160)
        }
        
        reportCancelButton.snp.makeConstraints{ make in
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview().offset(-6)
            make.height.equalTo(48)
            make.trailing.equalTo(reportSubView.snp.centerX).offset(-3)
        }
        
        reportButton.snp.makeConstraints{ make in
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-6)
            make.height.equalTo(48)
            make.leading.equalTo(reportSubView.snp.centerX).offset(3)
        }
        
        reportLabel.snp.makeConstraints{ make in
            make.bottom.equalTo(reportCancelButton.snp.top).offset(-68)
            make.centerX.equalToSuperview()
        }
        
        reportUnderLabel.snp.makeConstraints { make in
            make.bottom.equalTo(reportCancelButton.snp.top).offset(-28)
            make.centerX.equalToSuperview()
        }
    }
}

//MARK: - UpdateLayout
extension FindViewController {
    private func setupNoHofChallengeView() {
        hofChallengeCollectionView.isHidden = true
        hofScrollIndicator.isHidden = true
        noHofChallengeLabel.isHidden = false
        noHofChallengeButton.isHidden = false
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    private func setupNoFeedView() {
        feedCollectionView.isHidden = true
        noFeedLabel.isHidden = false
        noFeedButton.isHidden = false
        moreFeedButton.isHidden = true
        feedDetailView.isHidden = true
        
        feedCollectionView.snp.remakeConstraints { make in
            make.top.equalTo(feedCategoryCollectionView.snp.bottom).offset(16)
            make.leading.equalTo(feedCategoryCollectionView)
            make.trailing.equalToSuperview().offset(-16)
            // 임시
            make.height.equalTo(140)
        }
        
        self.feedCollectionView.reloadData()
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    private func setupHofChallengeView() {
        // challenge개수대로리턴하면되기냏.... 필ㅇ없을지도
    }
    
    private func updateFeedCollectionViewHeight() {
        let categoryIndex = changeFeedCategoryToInt(category: feedCategory)
        let itemCount = feedDict[categoryIndex]?.count ?? 0
        
        // 행의 수를 계산하여 높이를 결정
        let rows = ceil(Double(itemCount) / 2.0)
        let itemHeight: CGFloat = 140
        let spacing: CGFloat = 12
        
        // 높이 계산
        let newHeight: CGFloat
        if itemCount <= 2 {
            newHeight = (itemHeight * CGFloat(rows)) + spacing // 간격 없이 두 줄만 표시
        } else if itemCount <= 4 {
            newHeight = (itemHeight * CGFloat(rows)) + (spacing * CGFloat(rows - 1)) // 간격 추가
        } else {
            newHeight = (itemHeight * CGFloat(rows)) + (spacing * (CGFloat(rows) - 1)) // 일반적인 높이 계산
        }
        
        // 컬렉션 뷰 높이 및 레이아웃 업데이트
        feedCollectionView.snp.remakeConstraints { make in
            make.top.equalTo(feedCategoryCollectionView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(newHeight)
        }
        
        // UI 갱신을 위한 지연 작업
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    private func showToast() {
        // 이미 toastLabel이 뷰에 추가되어 있다면, 중복으로 추가하지 않음
        if toastLabel.superview != nil {
            return
        }
        
        self.toastLabel.alpha = 1.0
        self.view.addSubview(toastLabel)
        
        toastLabel.snp.makeConstraints { make in
            make.top.equalTo(moreFeedButton.snp.top)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(44)
        }
        
        UIView.animate(withDuration: 1.5, delay: 1, options: .curveEaseOut, animations: {
            self.toastLabel.alpha = 0.0
        }, completion: { [weak self] isCompleted in
            self?.toastLabel.removeFromSuperview()
        })
    }
}

//MARK: - Network
extension FindViewController {
    @MainActor
    private func setHofChallengeData() {
        // 카테고리 인덱스를 구하고, 컬렉션 뷰를 일시적으로 숨김
        hofChallengeCollectionView.isHidden = true
        let categoryIndex = changeHofCategoryToInt(category: hofCategory)
        
        // 기존 데이터를 비우기 전에 컬렉션 뷰를 비우고 업데이트
        hofChallengeDict[categoryIndex] = []
        hofChallengeCollectionView.reloadData()
        
        // 새로운 데이터 요청 후 UI 업데이트
        requestHofChallengeList(forCategory: categoryIndex) { [weak self] list in
            guard let self = self else { return }
            DispatchQueue.main.async {
                print("로딩된 데이터: \(list.count) 개")
                
                if list.isEmpty {
                    // 데이터가 비어 있는 경우 NoChallengeView 설정
                    self.setupNoHofChallengeView()
                } else {
                    // 새 데이터로 업데이트 및 컬렉션 뷰 재로드
                    self.hofChallengeDict[categoryIndex] = list
                    self.hofChallengeCollectionView.reloadData()
                    self.hofChallengeCollectionView.isHidden = false
                    self.hofScrollIndicator.isHidden = false
                    self.noHofChallengeLabel.isHidden = true
                    self.noHofChallengeButton.isHidden = true
                }
                
                // 레이아웃 강제 갱신
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func setFeedData() {
        feedCollectionView.isHidden = true
        let categoryIndex = changeFeedCategoryToInt(category: feedCategory) // hofCategory -> feedCategory로 변경
        
        feedDict[categoryIndex] = []
        pageNumber[categoryIndex] = 1 // 페이지 번호 초기화
        feedCollectionView.reloadData()
        
        requestFeedList(forCategory: categoryIndex) { [weak self] list in
            guard let self = self else { return }
            print(list)
            DispatchQueue.main.async {
                if list.isEmpty {
                    self.setupNoFeedView()
                } else {
                    // 새 데이터로 업데이트 및 컬렉션 뷰 재로드
                    self.feedDict[categoryIndex]?.append(contentsOf: list)
                    self.feedCollectionView.reloadData()
                    self.feedCollectionView.isHidden = false
                    self.noFeedLabel.isHidden = true
                    self.noFeedButton.isHidden = true
                    self.moreFeedButton.isHidden = false
                    
                    // 컬렉션 뷰 높이 업데이트
                    self.updateFeedCollectionViewHeight()
                }
            }
        }
    }
    
    private func requestHofChallengeList(forCategory categoryIndex: Int, completion: @escaping ([ChallengeModel]) -> Void) {
        MyPageService.shared.getChallengeList(baseEndPoint: .challenges, addPath: "/famous/\(hofCategory)") { response in
            let list = response.data.challenges ?? []
            completion(list)
        }
    }
    
    private func requestFeedList(forCategory categoryIndex: Int, completion: @escaping ([FeedModel]) -> Void) {
        MyPageService.shared.getFeedList(baseEndPoint: .feeds, addPath: "/category/\(feedCategory)?page=\(pageNumber[categoryIndex])") { response in
            let list = response.data.feeds ?? []
            
            print(list.isEmpty)
            print(self.moreFeedButton.isHidden)
            DispatchQueue.main.async {
                if !list.isEmpty {
                    self.pageNumber[categoryIndex] += 1
                } else if list.isEmpty && self.pageNumber[categoryIndex] > 1 {
                    self.showToast()
                    print("gg")
                }
                completion(list)
            }
        }
    }
    
    func showFeedDetail(feedId: Int, feedImage: UIImage) {
        guard let feedCell = feedDetailCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? FeedDetailCollectionViewCell else {
            return
        }

        MyPageService.shared.getMyPageFeedDetail(baseEndPoint: .feeds, addPath: "/\(String(describing: feedId))") { response in
            DispatchQueue.main.async {
                feedCell.reviewContent.text = response.data.review
                if response.data.day > 3 {
                    feedCell.dateLabel.text = response.data.uploadDate
                } else {
                    feedCell.dateLabel.text = "\(response.data.day)일 전"
                }
                feedCell.feedImage.image = feedImage
                feedCell.titleTag.text = "#\(response.data.challengeTitle)"
                feedCell.categoryTag.text = "#\(response.data.category)"
                feedCell.nicknameLabel.text = response.data.nickName
                if let imageUrl = response.data.profileImage, let url = URL(string: imageUrl) {
                    feedCell.profileImage.kf.setImage(with: url)
                } else {
                    feedCell.profileImage.image = UIImage(named: "Mask group")
                }
                feedCell.heartButton.setImage(UIImage(named: response.data.like ? "iconamoon_fullheart-bold" : "iconamoon_heart"), for: .normal)
            }
        }
    }
    
    private func changeHofCategoryToInt(category: String) -> Int{
        switch category{
        case CategoryKeyword.find[0].title: return 0
        case CategoryKeyword.find[1].title: return 1
        case CategoryKeyword.find[2].title: return 2
        case CategoryKeyword.find[3].title: return 3
        case CategoryKeyword.find[4].title: return 4
        case CategoryKeyword.find[5].title: return 5
        case CategoryKeyword.find[6].title: return 6
        case CategoryKeyword.find[7].title: return 7
        case CategoryKeyword.find[8].title: return 8
        default:
            return -1
        }
    }
    
    private func changeFeedCategoryToInt(category: String) -> Int{
        switch category{
        case CategoryKeyword.data[0].title: return 0
        case CategoryKeyword.data[1].title: return 1
        case CategoryKeyword.data[2].title: return 2
        case CategoryKeyword.data[3].title: return 3
        case CategoryKeyword.data[4].title: return 4
        case CategoryKeyword.data[5].title: return 5
        case CategoryKeyword.data[6].title: return 6
        case CategoryKeyword.data[7].title: return 7
        case CategoryKeyword.data[8].title: return 8
        case CategoryKeyword.data[9].title: return 9
        default:
            return -1
        }
    }
}

// MARK: - CollectionView Setting
extension FindViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // collectionView, delegate, datasorce
    private func setCollectionView() {
        [hofChallengeCategoryCollectionView,
         hofChallengeCollectionView,
         feedCategoryCollectionView,
         feedCollectionView,
         feedDetailCollectionView].forEach { view in
            view.delegate = self
            view.dataSource = self
        }
        
        hofChallengeCategoryCollectionView.register(hofChallengeCategoryCollectionViewCell.self, forCellWithReuseIdentifier: hofChallengeCategoryCollectionViewCell.identifier)
        
        hofChallengeCollectionView.register(hofChallengeCollectionViewCell.self, forCellWithReuseIdentifier: hofChallengeCollectionViewCell.identifier)
        
        feedCategoryCollectionView.register(MyPageCategoryCollectionViewCell.self, forCellWithReuseIdentifier: MyPageCategoryCollectionViewCell.identifier)
        
        feedCollectionView.register(MyChallengeFeedCollectionViewCell.self, forCellWithReuseIdentifier: MyChallengeFeedCollectionViewCell.identifier)
        
        feedDetailCollectionView.register(FeedDetailCollectionViewCell.self, forCellWithReuseIdentifier: FeedDetailCollectionViewCell.identifier)
        
        // 수평 스크롤바 제거
        [hofChallengeCategoryCollectionView, hofChallengeCollectionView, feedCategoryCollectionView].forEach { view in
            view.showsHorizontalScrollIndicator = false
        }
        
        // 수직 스크롤바 제거
        [feedCollectionView].forEach { view in
            view.showsVerticalScrollIndicator = false
        }
        
        feedCollectionView.isScrollEnabled = false
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Cell 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case hofChallengeCategoryCollectionView:
            return hofCategoryList.count
        case hofChallengeCollectionView:
            return hofChallengeDict[changeHofCategoryToInt(category: hofCategory) ]?.count ?? 0
        case feedCategoryCollectionView:
            return feedCategoryList.count
        case feedCollectionView:
            return feedDict[changeFeedCategoryToInt(category: feedCategory)]?.count ?? 0
        case feedDetailCollectionView:
            return 1
        default:
            return 0
        }
    }
    
    // Cell 크기
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case hofChallengeCategoryCollectionView:
            // Dynamic size of the Cell
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: hofChallengeCategoryCollectionViewCell.identifier, for: indexPath) as?
                    hofChallengeCategoryCollectionViewCell else {
                return .zero
            }
            let target = hofCategoryList[indexPath.row]
            cell.categoryLabel.text = "\(target.image) \(target.title)"
            cell.categoryLabel.sizeToFit()
            return CGSize(width: cell.categoryLabel.frame.width + 20, height: 28)
        case hofChallengeCollectionView:
            return  CGSize(width: 160, height: 160)
        case feedCategoryCollectionView:
            return  CGSize(width: 72, height: 72)
        case feedCollectionView:
            return  CGSize(width: (self.view.frame.width-44)/2, height: 140)
        case feedDetailCollectionView:
            let detailWidth = UIScreen.main.bounds.width - 32
            return CGSize(width: detailWidth, height: 647)
        default:
            return CGSize(width: 0, height: 0)
        }
    }
    
    // Cell 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
                
        case hofChallengeCategoryCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: hofChallengeCategoryCollectionViewCell.identifier, for: indexPath) as? hofChallengeCategoryCollectionViewCell else {
                return UICollectionViewCell()
            }
            let target = hofCategoryList[indexPath.row]
            cell.categoryLabel.text = "\(target.image) \(target.title)"
            cell.categoryLabel.sizeToFit()
            return cell
                
        case hofChallengeCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: hofChallengeCollectionViewCell.identifier, for: indexPath) as? hofChallengeCollectionViewCell else {
                return UICollectionViewCell()
            }
                
            let categoryIndex = changeHofCategoryToInt(category: hofCategory)
            guard categoryIndex != -1, let challenges = hofChallengeDict[categoryIndex], indexPath.row < challenges.count else {
                return UICollectionViewCell()
            }
                
            let target = challenges[indexPath.row]
            cell.challengeNameLabel.text = target.title
            if let url = URL(string: target.imageUrl) {
                cell.challengeImage.kf.setImage(with: url)
            }
            cell.numOfPeopleLabel.text = "참여인원 \(target.attendeeCount)명"
            cell.challengeId = target.challengeId
                
            return cell
                
        case feedCategoryCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyPageCategoryCollectionViewCell.identifier, for: indexPath) as? MyPageCategoryCollectionViewCell else {
                return UICollectionViewCell()
            }
            let target = feedCategoryList[indexPath.row]
            let img = UIImage(named: "\(target.image).svg")
            cell.keywordImage.image = img
            cell.keywordLabel.text = target.title
                
            return cell
                
        case feedCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyChallengeFeedCollectionViewCell.identifier, for: indexPath) as? MyChallengeFeedCollectionViewCell else {
                return UICollectionViewCell()
            }
            let categoryInt = changeFeedCategoryToInt(category: feedCategory)
            if let feedArray = feedDict[categoryInt] {
                // 배열에서 indexPath.row에 해당하는 원소를 타겟으로 지정
                let target = feedArray[indexPath.row]
                cell.feedId = target.feedId
                let url = URL(string: target.feedUrl)
                cell.challengeFeed.kf.setImage(with: url)
            } else {
                print("해당 카테고리에 대한 데이터가 없습니다.")
            }
            return cell  // 이 부분에 return이 누락되어 있었음
            
        case feedDetailCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedDetailCollectionViewCell.identifier, for: indexPath) as? FeedDetailCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.delegate = self
            return cell
                
        default:
            return UICollectionViewCell()
        }
    }
    
    // Cell 선택 시 액션
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView{
        case hofChallengeCategoryCollectionView:
            let cell = collectionView.cellForItem(at: indexPath) as! hofChallengeCategoryCollectionViewCell
            
            let str = cell.categoryLabel.text!
            let startIndex = str.index(str.startIndex, offsetBy: 2) // 문자열의 세 번째 문자의 인덱스
            let substring = str[startIndex...]
            hofCategory = String(substring)
            print(hofCategory)
            
            setHofChallengeData()
            
        case hofChallengeCollectionView:
            let cell = collectionView.cellForItem(at: indexPath) as! hofChallengeCollectionViewCell
            let challengeId = cell.challengeId
            
            ChallengeService.shared.challengeDetail(detailChallengeId: challengeId) { [weak self] response in
                guard let self = self else { return }

                // achieveRate가 nil인 경우와 값이 있는 경우를 구분
                if response.data.achieveRate != nil {
                    // achieveRate가 nil이 아니고 0 또는 그 이상의 값을 가지는 경우
                    let nextVC = JoinChallengeViewController()
                    nextVC.joinChallengeId = challengeId
                    nextVC.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(nextVC, animated: true)
                } else {
                    // achieveRate가 nil인 경우
                    let nextVC = ChallengeDetailViewController()
                    nextVC.detailChallengeId = challengeId
                    nextVC.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
            }
            
        case feedCategoryCollectionView:
            let cell = collectionView.cellForItem(at: indexPath) as! MyPageCategoryCollectionViewCell
            
            feedCategory = cell.keywordLabel.text!
            
            moreFeedButton.setTitle("\(feedCategory) 챌린지 더보기", for: .normal)
            
            setFeedData()
            
        case feedCollectionView:
            guard let cell = collectionView.cellForItem(at: indexPath) as? MyChallengeFeedCollectionViewCell else {
                return
            }
            feedDetailView.isHidden = false
            
            guard let feedCell = feedDetailCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? FeedDetailCollectionViewCell else {
                return
            }
            
            // Check if the image is available and assign it
            if let feedImage = cell.challengeFeed.image {
                feedCell.feedImage.image = feedImage
            } else {
                feedCell.feedImage.image = UIImage(named: "Mask group")
            }
            
            feedCell.feedId = cell.feedId!
            
            // Show feed details
            self.showFeedDetail(feedId: cell.feedId!, feedImage: feedCell.feedImage.image!)
            
            // UI adjustment after ensuring the data is set
            fullContentView.bringSubviewToFront(feedDetailView)
            feedDetailCollectionView.isHidden = false
            
            feedDetailView.snp.remakeConstraints { make in
                make.top.equalTo(feedCollectionView.snp.top)
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
                make.height.equalTo(1200)
            }
            
            fullContentView.snp.remakeConstraints { make in
                make.edges.equalTo(fullScrollView.contentLayoutGuide)
                make.width.equalTo(fullScrollView.frameLayoutGuide)
                make.bottom.equalTo(feedDetailView.snp.bottom).offset(-420)
            }
            
            view.layoutIfNeeded()
            view.setNeedsLayout()
            
        default:
            return
        }
    }
    
    private func setFirstIndexIsSelected() {
        let selectedIndexPath = IndexPath(item: 0, section: 0)
        
        // 첫 번째 항목 선택
        hofChallengeCategoryCollectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .bottom)
        feedCategoryCollectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .bottom)
        
        // 선택 후 데이터를 로드
        setHofChallengeData()
        setFeedData()
        
        // 레이아웃 강제 갱신
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
}

//MARK: - Scroll Setting
extension FindViewController: UIScrollViewDelegate {
    // 스크롤 설정 - horizontal 스크롤
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if hofChallengeCollectionView == scrollView {
            let scroll = scrollView.contentOffset.x + scrollView.contentInset.left
            let width = scrollView.contentSize.width + scrollView.contentInset.left + scrollView.contentInset.right
            let scrollRatio = scroll / width
            self.hofScrollIndicator.leftOffsetRatio = scrollRatio
        }
    }
    
    private func setHofIndicator() {
        let allWidth = self.hofChallengeCollectionView.contentSize.width + self.hofChallengeCollectionView.contentInset.left + self.hofChallengeCollectionView.contentInset.right
        let showingWidth = self.hofChallengeCollectionView.bounds.width
        
        if allWidth > 0 {
            // 움직일 scroll 길이 설정
            self.hofScrollIndicator.widthRatio = showingWidth / allWidth
        } else {
            // allWidth가 0일 경우, 스크롤바가 전체를 차지하도록 설정
            self.hofScrollIndicator.widthRatio = 1
        }
        
        self.hofScrollIndicator.layoutIfNeeded()
    }
}

//MARK: - Protocol
extension FindViewController : CustomFeedCellDelegate {
    func didTapRecommendButton(id: Int) {}
    
    func didTapReportButton() {}
    
    func didTapButton() {
        feedDetailView.isHidden = true
        fullContentView.sendSubviewToBack(feedDetailView)
        fullContentView.snp.remakeConstraints { make in
            make.edges.equalTo(fullScrollView.contentLayoutGuide)
            make.width.equalTo(fullScrollView.frameLayoutGuide)
            make.bottom.equalTo(moreFeedButton.snp.bottom).offset(48)
        }
        
        view.layoutIfNeeded()
        view.setNeedsLayout()
    }
}

