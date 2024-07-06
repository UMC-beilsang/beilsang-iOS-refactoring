//
//  ChallengeListViewController.swift
//  beilsang
//
//  Created by 곽은채 on 1/26/24.
//

import SnapKit
import UIKit
import Kingfisher
import SCLAlertView

// [홈] 챌린지 리스트
// 홈 메인 화면에서 카테고리를 누른 경우
class ChallengeListViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - properties
    // 전체 화면 scrollview
    let fullScrollView = UIScrollView()
    let fullContentView = UIView()
    
    var pointAlertViewResponder: SCLAlertViewResponder? = nil
    
    //포인트 없음 팝업
    lazy var pointAlert: SCLAlertView = {
        
        let apperance = SCLAlertView.SCLAppearance(
            kWindowWidth: 342, kWindowHeight : 272,
            kTitleFont: UIFont(name: "NotoSansKR-SemiBold", size: 18)!,
            kTextFont: UIFont(name: "NotoSansKR-Regular", size: 14)!,
            kButtonFont: UIFont(name: "NotoSansKR-Medium", size: 14)!,
            showCloseButton: false,
            showCircularIcon: false,
            dynamicAnimatorActive: false
        )
        let alert = SCLAlertView(appearance: apperance)
        
        return alert
    }()
    
    lazy var pointAlertSubView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        return view
    }()
    
    lazy var pointAlertLabel: UILabel = {
        let view = UILabel()
        view.text = "챌린지를 만들 수 있는 최소 포인트가 부족해요🤔 \n 다른 챌린지에 참여하고 포인트를 쌓아봐요!"
        view.font = UIFont(name: "NotoSansKR-Medium", size: 12)
        view.numberOfLines = 2
        view.textColor = .beTextInfo
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        
        return view
    }()
    
    lazy var pointBox: UIView = {
        let view = UIView()
        view.backgroundColor = .beBgSub
        view.layer.cornerRadius = 4
        return view
    }()
    
    lazy var pointLabel1: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "현재 포인트"
        label.font = UIFont(name: "NotoSansKR-Medium", size: 12)
        label.textColor = .beTextInfo
        return label
    }()
    
    lazy var pointLabel2: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "NotoSansKR-Regular", size: 11)
        label.text = ""
        label.textColor = .beTextInfo
        return label
    }()
    
    lazy var pointAlertCloseButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .beBgSub
        button.setTitleColor(.beTextEx, for: .normal)
        button.setTitle("닫기", for: .normal)
        button.titleLabel?.font = UIFont(name: "NotoSansKR-Medium", size: 14)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        return button
    }()
    
    lazy var pointAlertHomeButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .beScPurple600
        button.setTitleColor(.white, for: .normal)
        button.setTitle("홈으로", for: .normal)
        button.titleLabel?.font = UIFont(name: "NotoSansKR-Medium", size: 14)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(home), for: .touchUpInside)
        return button
    }()
    
    // topview - navigation
    lazy var navigationButton: UIBarButtonItem = {
        let view = UIBarButtonItem(image: UIImage(named: "icon-navigation"), style: .plain, target: self, action: #selector(tabBarButtonTapped))
        view.tintColor = .beIconDef
        
        return view
    }()
    
    // topview - 레이블
    var categoryLabelText: String?
    lazy var categoryLabel: UILabel = {
        let view = UILabel()
        
        view.text = categoryLabelText
        view.font = UIFont(name: "NotoSansKR-Medium", size: 20)
        view.textColor = .beTextDef
        view.textAlignment = .center
        
        return view
    }()
    
    // 네비게이션 오른쪽 버튼 두 개
    lazy var topRightView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    // topview - plus
    lazy var plusButton: UIButton = {
        let view = UIButton()
        
        view.setImage(UIImage(named: "icon_plus"), for: .normal)
        view.addTarget(self, action: #selector(plusButtonClicked), for: .touchUpInside)
        view.tintColor = .beIconDef
        
        return view
    }()
    
    // topview - search
    lazy var searchButton: UIButton = {
        let view = UIButton()
        
        view.setImage(UIImage(named: "icon-search"), for: .normal)
        view.addTarget(self, action: #selector(searchButtonClicked), for: .touchUpInside)
        view.tintColor = .beIconDef
        
        return view
    }()
    
    // topview - border
    lazy var topViewBorder: UIView = {
        let view = UIView()
        
        view.backgroundColor = .beBorderDis
        
        return view
    }()
    
    // 챌린지 진행 팁
    lazy var challengeTipButton: UIButton = {
        let view = UIButton()
        
        view.setImage(UIImage(named: "challengeListBanner"), for: .normal)
        view.addTarget(self, action: #selector(challengeTipButtonClicked), for: .touchUpInside)
        
        return view
    }()
    
    // 챌린지 리스트 콜렉션 뷰
    lazy var challengeCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var challengeData : [ChallengeCategoryData] = []
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setChallenges()
        setupAttribute()
        setCollectionView()
    }
    
    // MARK: - actions
    // 네비게이션 아이템 누르면 뒤(홈 메인화면)으로 가기
    @objc func tabBarButtonTapped() {
        print("뒤로 가기")
        navigationController?.popViewController(animated: true)
    }
    
    @objc func plusButtonClicked() {
        print("플러스 버튼")
        checkPoint()
    }
    
    @objc func searchButtonClicked() {
        print("검색")
        let searchVC = SearchViewController()
        searchVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @objc func challengeTipButtonClicked() {
        let challengeTipVC = ChallengeTipViewController()
        challengeTipVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(challengeTipVC, animated: true)
    }
    
    @objc func close(){
        pointAlertViewResponder?.close()
    }
    
    @objc func home(){
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate, let window = sceneDelegate.window {
            let mainVC = TabBarViewController()
            UIView.transition(with: window, duration: 1.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = mainVC
            }, completion: nil)
        }
        pointAlertViewResponder?.close()
    }

}

// MARK: - Layout
extension ChallengeListViewController {
    
    func setupAttribute() {
        setFullScrollView()
        setAddViews()
        setLayout()
        setNavigationBar()
    }
    
    func setFullScrollView() {
        fullScrollView.showsVerticalScrollIndicator = true
        fullScrollView.delegate = self
    }
    
    func setNavigationBar() {
        let rightBarButtons = UIBarButtonItem(customView: topRightView)
        navigationItem.titleView = categoryLabel
        navigationItem.leftBarButtonItem = navigationButton
        navigationItem.rightBarButtonItem = rightBarButtons
    }
    
    func setAddViews() {
        [plusButton, searchButton].forEach { view in
            topRightView.addSubview(view)
        }
        
        view.addSubview(fullScrollView)
        
        fullScrollView.addSubview(fullContentView)
        
        [topViewBorder, challengeTipButton, challengeCollectionView].forEach { view in
            fullContentView.addSubview(view)
        }
        
        pointAlert.customSubview = pointAlertSubView
        [pointAlertLabel, pointAlertCloseButton, pointAlertHomeButton, pointBox, pointLabel1, pointLabel2].forEach { view in
            pointAlertSubView.addSubview(view)
        }
    }
    
    func setLayout() {
        topRightView.snp.makeConstraints { make in
            make.width.equalTo(64)
            make.height.equalTo(24)
        }
        
        plusButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        searchButton.snp.makeConstraints { make in
            make.leading.equalTo(plusButton.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        fullScrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.leading.trailing.equalToSuperview()
        }
        
        fullContentView.snp.makeConstraints { make in
            make.edges.equalTo(fullScrollView.contentLayoutGuide)
            make.width.equalTo(fullScrollView.frameLayoutGuide)
            make.height.equalTo(1000)
        }
        
        topViewBorder.snp.makeConstraints { make in
            make.top.equalTo(fullScrollView.snp.top)
            make.width.equalTo(fullScrollView.snp.width)
            make.height.equalTo(1)
        }
        
        challengeTipButton.snp.makeConstraints { make in
            make.top.equalTo(topViewBorder.snp.bottom).offset(17)
            make.leading.equalTo(fullScrollView.snp.leading).offset(16)
            make.trailing.equalTo(fullScrollView.snp.trailing).offset(-16)
            make.height.equalTo(challengeTipButton.snp.width).multipliedBy(0.279)
        }
        
        challengeCollectionView.snp.makeConstraints { make in
            make.top.equalTo(challengeTipButton.snp.bottom).offset(24)
            make.leading.equalTo(fullScrollView.snp.leading)
            make.trailing.equalTo(fullScrollView.snp.trailing)
            make.bottom.equalTo(fullScrollView.snp.bottom)
        }
        
        // 포인트 팝업
        pointAlertSubView.snp.makeConstraints{ make in
            make.width.equalTo(318)
            make.height.equalTo(200)
        }
        
        pointBox.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.height.equalTo(64)
            make.centerX.equalTo(pointAlertSubView.snp.centerX)
            make.top.equalToSuperview()
        }
        
        pointLabel1.snp.makeConstraints { make in
            make.top.equalTo(pointBox.snp.top).offset(14)
            make.centerX.equalToSuperview()
        }
        
        pointLabel2.snp.makeConstraints { make in
            make.top.equalTo(pointLabel1.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        pointAlertLabel.snp.makeConstraints { make in
            make.top.equalTo(pointBox.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        
        pointAlertCloseButton.snp.makeConstraints { make in
            make.width.equalTo(156)
            make.height.equalTo(48)
            make.trailing.equalTo(pointAlertSubView.snp.centerX).offset(-3)
            make.top.equalTo(pointAlertLabel.snp.bottom).offset(28)
        }
        
        pointAlertHomeButton.snp.makeConstraints { make in
            make.width.equalTo(156)
            make.height.equalTo(48)
            make.leading.equalTo(pointAlertSubView.snp.centerX).offset(3)
            make.centerY.equalTo(pointAlertCloseButton)
        }
    }
}

// MARK: - 카테고리별 챌린지 리스트 api 세팅
extension ChallengeListViewController {
    func setChallenges() {
        if categoryLabelText == "전체" {
            print("전체")
            ChallengeService.shared.challengeCategoriesAll { response in
                self.setChallengesList(response.data!.challenges)
                self.fullContentViewHeightUpdate()
            }
        } else if categoryLabelText == "참여중" {
            print("참여중")
            ChallengeService.shared.challengeCategoriesEnrolled { response in
                self.setChallengesList(response.data!.challenges.challenges)
                self.fullContentViewHeightUpdate()
            }
        } else {
            print("카테고리")
            let category = CategoryConverter.shared.convertToEnglish(categoryLabelText ?? "")
            ChallengeService.shared.challengeCategories(categoryName: category ?? "") { response in
                self.setChallengesList(response.data!.challenges)
                self.fullContentViewHeightUpdate()
            }
        }
    }
    
    public func checkPoint() {
        MyPageService.shared.getPoint(baseEndPoint: .mypage, addPath: "/points"){
            response in
            if response.data.total < 100 {
                self.pointAlertUp()
                self.pointLabel2.text = String(response.data.total)
            }
            else{
                let registerChallengeVC = RegisterFirstViewController()
                registerChallengeVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(registerChallengeVC, animated: true)
            }
        }
    }
    
    func pointAlertUp() {
        pointAlertViewResponder = pointAlert.showInfo("포인트 부족")
    }
    
    //fullScrollView 높이 업데이트
    private func fullContentViewHeightUpdate() {
        let baseHeight = 180 // 기본 높이
        let itemHeight = 140 // 각 셀의 높이
        let spacing = 24 // 셀 간 간격
        var totalHeight = baseHeight // 전체 높이는 기본 높이로 시작

        if challengeData.count > 0 {
            // 셀의 총 높이 계산 (셀 개수 * 셀 높이)
            // 셀 사이 간격 추가 (셀 개수 - 1) * 간격
            totalHeight += (itemHeight * challengeData.count) + ((challengeData.count - 1) * spacing)
        }

        self.fullContentView.snp.updateConstraints { make in
            make.height.equalTo(totalHeight)
        }

        self.view.layoutIfNeeded()
    }

    
    @MainActor
    private func setChallengesList(_ response: [ChallengeCategoryData]) {
        self.challengeData = response
        self.challengeCollectionView.reloadData()
    }
}

// MARK: - collectionView setting(챌린지 리스트)
extension ChallengeListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // 콜렉션뷰 세팅
    func setCollectionView() {
        challengeCollectionView.delegate = self
        challengeCollectionView.dataSource = self
        challengeCollectionView.register(ChallengeListCollectionViewCell.self, forCellWithReuseIdentifier: ChallengeListCollectionViewCell.identifier)
    }
    
    // 셀 개수 설정
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return challengeData.count
    }
    
    // 셀 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChallengeListCollectionViewCell.identifier, for: indexPath) as?
                ChallengeListCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.challengeListChallengeId = challengeData[indexPath.row].challengeId
        
        let url = URL(string: challengeData[indexPath.row].imageUrl!)
        cell.challengeImage.kf.setImage(with: url)
        cell.challengeNameLabel.text = challengeData[indexPath.row].title
        cell.makerNickname.text = challengeData[indexPath.row].hostName
        cell.buttonLabel.text = "참여 인원 \(challengeData[indexPath.row].attendeeCount)명"
        
        return cell
    }
    
    // 셀 크기 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 32
        
        return CGSize(width: width , height: 140)
    }
    
    // 셀 선택시 액션
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ChallengeListCollectionViewCell
        let challengeId = cell.challengeListChallengeId!
        
        ChallengeService.shared.challengeEnrolled(EnrollChallengeId: challengeId) { response in
            let isEnrolled = response.data.isEnrolled
            
            if isEnrolled {
                let nextVC = JoinChallengeViewController()
                nextVC.joinChallengeId = challengeId
                nextVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(nextVC, animated: true)
            } else {
                let nextVC = ChallengeDetailViewController()
                nextVC.detailChallengeId = challengeId
                nextVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        }
    }
    
    //셀 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 24 
    }
}
