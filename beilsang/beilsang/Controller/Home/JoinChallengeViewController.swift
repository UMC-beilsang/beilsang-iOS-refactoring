//
//  JoinChallengeViewController.swift
//  beilsang
//
//  Created by Seyoung on 7/6/24.
//

import UIKit
import SnapKit
import SCLAlertView
import SafariServices
import Kingfisher

class JoinChallengeViewController: UIViewController {
    
    //MARK: - Properties
    var joinChallengeId : Int? = nil
    var challengeDetailData : ChallengeDetailData? = nil
    var challengeFeedData : [ChallengeJoinFeedData] = []
    var challengeFeedDetailData : MyPageFeedDetailData? = nil
    var challengeGuideData : [String] = []
    var challengeProgressRate: Double? = nil
    
    var collectionViewHeight : Constraint?
    var alertViewResponder: SCLAlertViewResponder? = nil
    
    let imageConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
    
    //Navigation Bar
    lazy var navigationButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "icon-navigation"), style: .plain, target: self, action: #selector(navigationButtonClicked))
        button.tintColor = .beIconDef
        
        return button
    }()
    
    lazy var navigationBarMenu: UIMenu = {
        let menuAction = UIAction(title: "신고하기", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off) { action in
            self.alertViewResponder = self.reportAlert.showInfo("해당 챌린지 신고하기")
        }
        
        return UIMenu(title: "", options: [], children: [menuAction])
    }()
    
    lazy var navigationChallengeLabel: UILabel = {
        let view = UILabel()
        view.text = "챌린지"
        view.font = UIFont(name: "NotoSansKR-Medium", size: 20)
        view.textColor = .beTextDef
        view.textAlignment = .center
        
        return view
    }()
    
    //View
    let verticalScrollView = UIScrollView()
    let verticalContentView = UIView()
    
    lazy var representImageView : UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var challengeTitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "NotoSansKR-SemiBold", size: 20)
        view.numberOfLines = 0
        view.textColor = .beTextDef
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        
        return view
    }()
    
    lazy var challengeJoinPeopleNumLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .beBgSub
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        view.font = UIFont(name: "NotoSansKR-Medium", size: 12)
        view.numberOfLines = 0
        view.textColor = .beNavy500
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        
        return view
    }()
    
    lazy var challengeWriterLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "NotoSansKR-Medium", size: 14)
        view.numberOfLines = 0
        view.textColor = .beTextEx
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        
        return view
    }()
    
    lazy var challengeMadeDateLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "NotoSansKR-Medium", size: 14)
        view.numberOfLines = 0
        view.textColor = .beTextEx
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        
        return view
    }()
    
    lazy var divideLine: UIView = {
        let view = UIView()
        view.backgroundColor = .beTextEx
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    //challenge Category
    lazy var challengeCategoryView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.beBorderDis.cgColor
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var challengeCategoryIcon: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "NotoSansKR-Medium", size: 16)
        view.numberOfLines = 0
        view.textColor = .beTextDef
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        
        return view
    }()
    
    lazy var challengeCategoryLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "NotoSansKR-Medium", size: 16)
        view.numberOfLines = 0
        view.textColor = .beTextDef
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        
        return view
    }()
    
    //progressView
    lazy var progressTitleLabel: UILabel = {
        let view = UILabel()
        view.text = "진행도"
        view.font = UIFont(name: "NotoSansKR-Medium", size: 14)
        view.numberOfLines = 0
        view.textColor = .beTextInfo
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        
        return view
    }()
    
    lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = .beBgSub
        view.progressTintColor = .beScPurple400
        view.clipsToBounds = true
        view.subviews[1].clipsToBounds = true
        view.layer.cornerRadius = 8
        view.subviews[1].layer.cornerRadius = 8
        view.setProgress(0.25, animated: true)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    //challenge Period
    lazy var challengePeriodView: UIView = {
        let view = UIView()
        view.backgroundColor = .beBgSub
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var challengePeriodIconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "challengePeriod")
        
        return view
    }()
    
    lazy var challengePeriodTitleLabel: UILabel = {
        let view = UILabel()
        view.text = "실천 기간"
        view.font = UIFont(name: "NotoSansKR-Medium", size: 14)
        view.numberOfLines = 0
        view.textColor = .beTextSub
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        
        return view
    }()
    
    lazy var challengePeriodLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "NotoSansKR-Regular", size: 12)
        view.numberOfLines = 0
        view.textColor = .beTextSub
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        
        return view
    }()
    
    //divider
    lazy var divider1: UIView = {
        let view = UIView()
        view.backgroundColor = .beBgSub
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    //galleryView
    let galleryView = UIView()
    
    lazy var galleryTitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name:"NotoSansKR-Medium", size: 18)
        view.numberOfLines = 0
        view.text = "인증 갤러리 🙌"
        view.textColor = .beTextDef
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        
        return view
    }()
    
    lazy var gallerySubTitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name:"NotoSansKR-Regular", size: 12)
        view.numberOfLines = 0
        view.text = "함께하는 챌린저들의 이야기를 봐볼까요? 🤩"
        view.textColor = .beTextEx
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        
        return view
    }()
    
    lazy var galleryCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.isScrollEnabled = false
        
        return collectionView
    }()
    
    //피드 세부
    let feedDetailView = UIView()
    
    lazy var feedDetailCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
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
    
    lazy var noFeedLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name:"NotoSansKR-Regular", size: 12)
        view.numberOfLines = 0
        view.textColor = .beTextInfo
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        
        return view
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
    
    //divider
    lazy var divider2: UIView = {
        let view = UIView()
        view.backgroundColor = .beBgSub
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    //detailView
    lazy var detailTitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "NotoSansKR-SemiBold", size: 14)
        view.text = "세부 설명"
        view.numberOfLines = 0
        view.textColor = .beTextSub
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        
        return view
    }()
    
    lazy var detailView: UIView = {
        let view = UIView()
        view.backgroundColor = .beBgSub
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var detailLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "NotoSansKR-Medium", size: 14)
        view.numberOfLines = 0
        view.textColor = .beTextDef
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        
        return view
    }()
    
    //cautionView
    lazy var cautionTitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "NotoSansKR-SemiBold", size: 14)
        view.text = "챌린지 유의사항"
        view.numberOfLines = 0
        view.textColor = .beTextSub
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        
        return view
    }()
    
    lazy var cautionSubTitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "NotoSansKR-Regular", size: 12)
        view.text = "아래 챌린지 모범 인증 사진을 확인해 보세요!"
        view.numberOfLines = 0
        view.textColor = .beTextInfo
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        
        return view
    }()
    
    lazy var cautionView: UIView = {
        let view = UIView()
        view.backgroundColor = .beBgSub
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var cautionCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CautionCollectionViewCell.self, forCellWithReuseIdentifier: CautionCollectionViewCell.identifier)
        collectionView.backgroundColor = .beBgSub
        return collectionView
    }()
    
    lazy var cautionImageView: UIImageView = {
        let view = UIImageView()
        
        return view
    }()
    
    lazy var divider3: UIView = {
        let view = UIView()
        view.backgroundColor = .beBgSub
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var pointExpTitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "NotoSansKR-SemiBold", size: 14)
        view.text = "보상 포인트 안내"
        view.numberOfLines = 0
        view.textColor = .beTextSub
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        
        return view
    }()
    
    lazy var pointExpView: UIView = {
        let view = UIView()
        view.backgroundColor = .beBgSub
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var pointImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "pointImage")
        
        return view
    }()
    
    lazy var pointExpLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "NotoSansKR-Medium", size: 12)
        view.text = "보상 포인트 안내"
        view.numberOfLines = 0
        view.textColor = .beTextInfo
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        
        return view
    }()
    
    lazy var pointExpSmallLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "NotoSansKR-SemiBold", size: 14)
        view.text = "성공한 챌린저와 함께 포인트를 나누어 지급"
        view.numberOfLines = 0
        view.textColor = .beCta
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        
        return view
    }()
    
    //bottomView
    lazy var bottomView: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor.beTextDef.cgColor
        view.layer.masksToBounds = false
        view.layer.shadowOffset = CGSize(width: 4, height: 4)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 1
        view.backgroundColor = .beBgSub
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var bottomBookMarkButton: UIButton = {
        let view = UIButton()
        let image = UIImage(systemName: "star", withConfiguration: imageConfig)
        let selectedImage = UIImage(systemName: "star.fill", withConfiguration: imageConfig)
        
        view.setImage(image, for: .normal)
        view.setImage(selectedImage, for: .selected)
        view.tintColor = .beScPurple600
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addTarget(self, action: #selector(bookMarkButtonTapped), for: .touchDown)
        return view
    }()
    
    lazy var bottomBookMarkLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "NotoSansKR-Regular", size: 14)
        view.numberOfLines = 0
        view.textColor = .beTextDef
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        
        return view
    }()
    
    lazy var bottomProofButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .beScPurple400
        button.setTitle("인증하기", for: .normal)
        button.setTitleColor(.beTextWhite, for: .normal)
        button.titleLabel?.font = UIFont(name: "NotoSansKR-Medium", size: 16)
        button.layer.cornerRadius = 8
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(proofButtonTapped), for: .touchDown)
        
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
        view.text = "해당 챌린지의 신고 사유가 무엇인가요? \n 하단 링크를 통해 알려 주세요!"
        view.font = UIFont(name: "NotoSansKR-Medium", size: 12)
        view.numberOfLines = 2
        view.textColor = .beTextInfo
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
        view.text = "🌳 현재 진행도는 70%입니다!"
        view.textColor = .white
        view.font = UIFont(name: "NotoSansKR-Medium", size: 16)
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        view.textAlignment = .center
        view.backgroundColor = .beTextDef.withAlphaComponent(0.8)
        view.isHidden = false
        
        return view
    }()
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        UISetup()
        
        setChallengeData()
        setFeedData()
        setChallengeGuide()
        setCollectionView()
    }
    
    //MARK: - Actions
    @objc func navigationButtonClicked() {
        print("챌린지 작성 취소")
        navigationController?.popViewController(animated: true)
    }
    
    @objc func proofButtonTapped(_ sender: UIButton) {
        print("챌린지 인증 버튼 클릭")
        
        let challengeId = joinChallengeId
        let certifyVC = RegisterCertifyViewController()
        certifyVC.reviewChallengeId = challengeId
        certifyVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(certifyVC, animated: true)
    }
    
    @objc func reportLabelButtonTapped() {
        print("피드 신고 버튼 클릭")
        alertViewResponder = reportAlert.showInfo("챌린지 인증 신고하기")
    }
    
    @objc func bookMarkButtonTapped() {
        if bottomBookMarkButton.isSelected {
            deleteBookmark()
        } else {
            postBookmark()
        }
    }
    
    @objc func reportButtonTapped() {
        let reportUrl = NSURL(string: "https://moaform.com/q/dcQIJc")
        let reportSafariView: SFSafariViewController = SFSafariViewController(url: reportUrl! as URL)
        self.present(reportSafariView, animated: true, completion: nil)
        alertViewResponder?.close()
    }
    
    @objc func close(){
        alertViewResponder?.close()
    }
    
    @objc func exitButtonTapped(_ sender: UIButton) {
        print("exitButton Tapped")
    }
    
    @objc func homeButtonTapped(_ sender: UIButton) {
    
    }
    
    func showFeedDetail(feedId: Int, feedImage: UIImage) {
        setDetailFeedLayout()
        setFeedDetailData(feedId: feedId, feedImage: feedImage)
    }
    
    // MARK: - UI Setup
    func UISetup() {
        setNavigationBar()
        setLayout()
    }
    
    private func setNavigationBar() {
        let menuButton: UIBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(named: "icon-meatballs"), target: self, action: nil, menu: navigationBarMenu)
        menuButton.tintColor = .beIconDef
        
        navigationItem.titleView = challengeTitleLabel
        navigationItem.leftBarButtonItem = navigationButton
        navigationItem.rightBarButtonItem = menuButton
    }
    
    private func setLayout() {
        setViewLayout()
        setReportAlertLayout()
    }
}

//MARK: - SetLayout
extension JoinChallengeViewController {
    private func setViewLayout() {
        view.addSubview(verticalScrollView)
        view.addSubview(bottomView)
        
        verticalScrollView.addSubview(verticalContentView)
        
        [representImageView, challengeTitleLabel, challengeJoinPeopleNumLabel, challengeWriterLabel, divideLine, challengeMadeDateLabel, challengeCategoryView, progressTitleLabel, progressView, challengePeriodView, divider1, galleryTitleLabel, gallerySubTitleLabel, galleryView, divider2, detailTitleLabel, detailView, cautionTitleLabel, cautionSubTitleLabel, cautionView, cautionImageView, divider3, pointExpTitleLabel, pointExpView].forEach{view in verticalContentView.addSubview(view)}
        
        challengeCategoryView.addSubview(challengeCategoryIcon)
        challengeCategoryView.addSubview(challengeCategoryLabel)
        
        challengePeriodView.addSubview(challengePeriodIconImageView)
        challengePeriodView.addSubview(challengePeriodTitleLabel)
        challengePeriodView.addSubview(challengePeriodLabel)
        
        //gallery
        [galleryCollectionView].forEach{view in galleryView.addSubview(view)}
        
        feedDetailView.addSubview(feedDetailCollectionView)
        feedDetailView.addSubview(reportLabelButton)
        
        //Detail
        detailView.addSubview(detailLabel)
        
        //Caution
        cautionView.addSubview(cautionCollectionView)
        
        //Point
        [pointImageView, pointExpLabel, pointExpSmallLabel].forEach{view in pointExpView.addSubview(view)}
        
        //bottomView
        [bottomBookMarkLabel, bottomBookMarkButton, bottomProofButton].forEach{view in bottomView.addSubview(view)}
        
        view.backgroundColor = .beBgDef
        
        let height = UIScreen.main.bounds.height
        let width = UIScreen.main.bounds.width
        
        bottomView.snp.makeConstraints{ make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(height * 0.1)
        }
        
        verticalScrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }
        
        //verticalContentView
        verticalContentView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(verticalScrollView.contentLayoutGuide)
            make.width.equalTo(verticalScrollView.frameLayoutGuide)
            make.height.equalTo(1100)
        }
        
        representImageView.snp.makeConstraints{ make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.width.equalTo(width)
            make.height.equalTo(240)
        }
        
        challengeTitleLabel.snp.makeConstraints{ make in
            make.top.equalTo(representImageView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
        }
        
        challengeJoinPeopleNumLabel.snp.makeConstraints{ make in
            make.centerY.equalTo(challengeTitleLabel)
            make.trailing.equalToSuperview().offset(-16)
            make.width.equalTo(86)
            make.height.equalTo(24)
        }
        
        challengeWriterLabel.snp.makeConstraints{ make in
            make.top.equalTo(challengeTitleLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
        }
        
        divideLine.snp.makeConstraints{ make in
            make.centerY.equalTo(challengeWriterLabel)
            make.leading.equalTo(challengeWriterLabel.snp.trailing).offset(8)
            make.height.equalTo(18)
            make.width.equalTo(0.75)
        }
        
        challengeMadeDateLabel.snp.makeConstraints{ make in
            make.centerY.equalTo(challengeWriterLabel)
            make.leading.equalTo(divideLine.snp.trailing).offset(8)
        }
        
        challengeCategoryView.snp.makeConstraints{ make in
            make.top.equalTo(challengeWriterLabel.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(40)
        }
        
        progressTitleLabel.snp.makeConstraints{ make in
            make.top.equalTo(challengeCategoryView.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(16)
        }
        
        progressView.snp.makeConstraints{ make in
            make.centerY.equalTo(progressTitleLabel)
            make.leading.equalTo(progressTitleLabel.snp.trailing).offset(24)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(16)
        }
        
        challengePeriodView.snp.makeConstraints{ make in
            make.top.equalTo(progressTitleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(72)
        }
        
        divider1.snp.makeConstraints{ make in
            make.top.equalTo(challengePeriodView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(8)
        }
        
        galleryView.snp.makeConstraints{ make in
            make.top.equalTo(divider1.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(400)
        }
        
        divider2.snp.makeConstraints{ make in
            make.top.equalTo(galleryView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(8)
        }
        
        detailTitleLabel.snp.makeConstraints{ make in
            make.top.equalTo(divider2.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
        }
        
        detailView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(140)
        }
        
        detailLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.top.equalToSuperview().offset(19)
        }
        
        cautionTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(detailView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
        }
        
        cautionSubTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(cautionTitleLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(16)
        }
        
        cautionView.snp.makeConstraints { make in
            make.top.equalTo(detailView.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(cautionCollectionView.snp.bottom).offset(19)
        }
        
        cautionCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(19)
            make.trailing.equalToSuperview().offset(-19)
            collectionViewHeight = make.height.equalTo(0).constraint
        }
        
        cautionImageView.snp.makeConstraints{ make in
            make.top.equalTo(cautionView.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(200)
        }
        
        divider3.snp.makeConstraints{ make in
            make.top.equalTo(cautionImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(8)
        }
        
        pointExpTitleLabel.snp.makeConstraints{ make in
            make.top.equalTo(divider2.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
        }
        
        pointExpView.snp.makeConstraints{ make in
            make.top.equalTo(pointExpTitleLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(110)
        }
        
        pointImageView.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(14)
        }
        
        pointExpLabel.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.top.equalTo(pointImageView.snp.bottom).offset(8)
        }
        
        pointExpSmallLabel.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(pointExpView.snp.bottom).offset(-14)
        }
        
        challengeCategoryIcon.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        
        challengeCategoryLabel.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
        }
        
        challengePeriodIconImageView.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(19)
            make.width.height.equalTo(20)
        }
        
        challengePeriodTitleLabel.snp.makeConstraints{ make in
            make.centerY.equalTo(challengePeriodIconImageView)
            make.leading.equalTo(challengePeriodIconImageView.snp.trailing).offset(4)
        }
        
        challengePeriodLabel.snp.makeConstraints{ make in
            make.bottom.equalToSuperview().offset(-14)
            make.leading.equalToSuperview().offset(19)
        }
        
        galleryTitleLabel.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(26)
        }
        
        gallerySubTitleLabel.snp.makeConstraints{ make in
            make.top.equalTo(galleryTitleLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(17)
        }
        
        galleryCollectionView.snp.makeConstraints{ make in
            make.top.equalTo(gallerySubTitleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(300)
        }
        
        bottomBookMarkButton.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(height * 0.018)
            make.leading.equalToSuperview().offset(28)
            make.height.width.equalTo(30)
        }
        
        bottomBookMarkLabel.snp.makeConstraints{ make in
            make.top.equalTo(bottomBookMarkButton.snp.bottom)
            make.centerX.equalTo(bottomBookMarkButton)
        }
        
        bottomProofButton.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-32)
            make.width.equalTo(width * 0.41)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    private func setReportAlertLayout() {
        //report Popup
        reportAlert.customSubview = reportSubView
        [reportLabel, reportCancelButton, reportButton].forEach{view in reportSubView.addSubview(view)}
        
        //신고하기 팝업
        reportSubView.snp.makeConstraints{ make in
            make.width.equalTo(318)
            make.height.equalTo(120)
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
            make.bottom.equalTo(reportCancelButton.snp.top).offset(-28)
            make.centerX.equalTo(reportSubView)
        }
    }
}

//MARK: - UpdateLayout
extension JoinChallengeViewController {
    //피드 개수 레이아웃 업데이트
    private func setFeedLayout(feedCount: Int) {
        if feedCount == 0 {
            noFeedButton.isHidden = false
            noFeedLabel.isHidden = false
            galleryCollectionView.isHidden = true
        } else {
            noFeedButton.isHidden = true
            noFeedLabel.isHidden = true
            galleryCollectionView.isHidden = false
            setupFeedView(feedCount: feedCount)
        }
        
        updateGalleryViewConstraints(feedCount: feedCount)
        view.layoutIfNeeded()
    }

    private func setupNoFeedView() {
        [noFeedLabel, noFeedButton].forEach{view in galleryView.addSubview(view)}
        noFeedLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(48)
            make.centerX.equalToSuperview()
            make.height.equalTo(17)
        }
        
        noFeedButton.snp.makeConstraints { make in
            make.top.equalTo(noFeedLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(75)
            make.trailing.equalToSuperview().offset(-75)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-84)
        }
    }

    private func setupFeedView(feedCount: Int) {
        let collectionViewHeight = feedCount <= 2 ? 140 : 300
        galleryCollectionView.snp.updateConstraints { make in
            make.height.equalTo(collectionViewHeight)
        }
    }

    private func updateGalleryViewConstraints(feedCount: Int) {
        let galleryViewHeight: Int
        if feedCount == 0 {
            galleryViewHeight = 224
        } else if feedCount <= 2 {
            galleryViewHeight = 240
        } else {
            galleryViewHeight = 400
        }
        
        galleryView.snp.updateConstraints { make in
            make.height.equalTo(galleryViewHeight)
        }
    }
    
    //피드 세부내용 레이아웃 업데이트
    private func setDetailFeedLayout() {
        if feedDetailView.superview == nil {
            setupFeedDetailView()
        }
        updateFeedDetailViewVisibility()
        updateGalleryViewConstraints()
        view.layoutIfNeeded()
    }
    
    private func setupFeedDetailView() {
        galleryView.addSubview(feedDetailView)
        
        feedDetailView.snp.makeConstraints { make in
            make.top.equalTo(gallerySubTitleLabel).offset(20)
            make.height.equalTo(700)
            make.leading.trailing.equalToSuperview()
        }
        
        feedDetailCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(648)
        }
        
        reportLabelButton.snp.makeConstraints { make in
            make.top.equalTo(feedDetailCollectionView.snp.bottom).offset(12)
            make.trailing.equalToSuperview()
        }
    }
    
    private func updateFeedDetailViewVisibility() {
        galleryCollectionView.isHidden = true
        feedDetailView.isHidden = false
    }

    private func updateGalleryViewConstraints() {
        galleryView.snp.updateConstraints { make in
            make.height.equalTo(806)
        }
    }
    
    //주의사항 컬렉션뷰 높이 업데이트
    func setChallengeGuide() {
        ChallengeService.shared.challengeGuide(guideChallengeId: joinChallengeId ?? 0) { response in
            let url = URL(string: response.data.certImage)
            self.cautionImageView.kf.setImage(with: url)
            self.challengeGuideData = response.data.challengeNoteList
            self.cautionCollectionView.reloadData()
            
            let height = (self.challengeGuideData.count * 18) + ((self.challengeGuideData.count) * 8)
            self.collectionViewHeight?.update(offset: height)
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    //challengePeriodLabel 컬러 변경
    private func updatePeriodLabel(weekCountText: String, sessionCountText: Int, startDateText: String) {
        let fullText = "시작일(\(startDateText))로부터 \(weekCountText) 동안 \(sessionCountText)회 진행"
        
        let attributedText = NSMutableAttributedString(string: fullText)
        
        let range = (fullText as NSString).range(of: "\(weekCountText) 동안 \(sessionCountText)회")
        
        attributedText.addAttribute(.foregroundColor, value: UIColor.beCta, range: range)
        
        let font = UIFont(name: "NotoSansKR-Medium", size: 12)
        attributedText.addAttribute(.font, value: font!, range: range)
        
        challengePeriodLabel.attributedText = attributedText
    }
}

//MARK: - Network
extension JoinChallengeViewController {
    //참여중 챌린지 세팅
    @MainActor
    func setChallengeData() {
        guard let joinChallengeId = joinChallengeId else {
            print("Error: joinChallengeId is nil")
            return
        }
        
        ChallengeService.shared.challengeDetail(detailChallengeId: joinChallengeId) { [weak self] response in
            guard let self = self else { return }
            self.updateUI(with: response.data)
        }
    }

    private func updateUI(with data: ChallengeDetailData) {
        self.challengeDetailData = data
        
        let representURL = URL(string: data.imageUrl ?? "")
        self.representImageView.kf.setImage(with: representURL)
        self.challengeTitleLabel.text = data.title
        self.challengeJoinPeopleNumLabel.text = "\(data.attendeeCount)명 참여중"
        self.challengeWriterLabel.text = data.hostName
        self.challengeMadeDateLabel.text = data.createdDate
        
        let categoryIcon = CategoryConverter.shared.convertToIcon(data.category)
        self.challengeCategoryIcon.text = categoryIcon
        
        let categoryText = CategoryConverter.shared.convertToKorean(data.category)
        self.challengeCategoryLabel.text = categoryText
        
        if let startDate = DateConverter.shared.convertJoin(from: data.startDate) {
            self.challengeStartDateCheck(date: data.startDate)
            let period = PeriodConverter.shared.convertToKorean(data.period) ?? ""
            self.updatePeriodLabel(weekCountText: period, sessionCountText: data.totalGoalDay, startDateText: startDate)
        }
        
        self.bottomBookMarkButton.isSelected = data.like
        self.bottomBookMarkLabel.text = String(data.likes)
        
        self.toastLabel.text = "📆 챌린지가 \(data.dday)일 뒤 시작됩니다!"
        
        self.updateNoFeedLabel(startDate: data.startDate)
    }

    private func updateNoFeedLabel(startDate: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = dateFormatter.date(from: startDate) {
            let today = Date()
            let result = date.compare(today)
            self.noFeedLabel.text = result == .orderedAscending
                ? "아직 챌린지가 시작되지 않았어요👀"
                : "아직 인증 피드가 없어요👀"
        }
    }
    
    //피드 세팅
    func setFeedData() {
        guard let joinChallengeId = joinChallengeId else {
            print("Error: joinChallengeId is nil")
            return
        }
        
        ChallengeService.shared.challengeFeed(joinFeedChallengeId: joinChallengeId) { [weak self] response in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let feeds = response.data?.feeds {
                    self.challengeFeedData = feeds
                    self.setFeedLayout(feedCount: feeds.count)
                } else {
                    print("Failed to fetch challenge feed: No data available")
                    self.setFeedLayout(feedCount: 0)
                }
            }
        }
    }
    
    //피드 세부 화면 세팅
    func setFeedDetailData(feedId: Int, feedImage: UIImage) {
        MyPageService.shared.getMyPageFeedDetail(baseEndPoint: .feeds, addPath: "/\(feedId)") { [weak self] response in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.updateFeedDetailUI(with: response.data, feedImage: feedImage)
            }
        }
    }
    
    private func updateFeedDetailUI(with data : MyPageFeedDetailData, feedImage: UIImage) {
        guard let cell = feedDetailCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? FeedDetailCollectionViewCell else { return }
        
        cell.reviewContent.text = data.review
        cell.dateLabel.text = data.day > 3 ? data.uploadDate : "\(data.day)일 전"
        cell.feedImage.image = feedImage
        cell.titleTag.text = "#\(data.challengeTitle)"
        cell.categoryTag.text = "#\(data.category)"
        cell.nicknameLabel.text = data.nickName
        
        if let imageUrlString = data.profileImage, let url = URL(string: imageUrlString) {
            cell.profileImage.kf.setImage(with: url)
        }
        
        cell.heartButton.setImage(UIImage(named: data.like ? "iconamoon_fullheart-bold" : "iconamoon_heart-bold"), for: .normal)
    }
    
    //Update ProgressRate

    
    //BookMark
    func postBookmark() {
        ChallengeService.shared.challengeBookmarkPost(likeChallengeId: joinChallengeId ?? 0) { response in
            print("Post BookMark - \(response)")
            
            ChallengeService.shared.challengeDetail(detailChallengeId: self.joinChallengeId ?? 0) { response in
                self.challengeDetailData = response.data
                
                self.bottomBookMarkButton.isSelected = response.data.like // 북마크 했는지 여부
                self.bottomBookMarkLabel.text = String(response.data.likes) // 북마크 수
            }
        }
    }
    
    func deleteBookmark() {
        ChallengeService.shared.challengeBookmarkDelete(dislikeChallengeId: joinChallengeId ?? 0) { response in
            print("Delete BookMark - \(response)")
            
            ChallengeService.shared.challengeDetail(detailChallengeId: self.joinChallengeId ?? 0) { response in
                self.challengeDetailData = response.data
                
                self.bottomBookMarkButton.isSelected = response.data.like // 북마크 했는지 여부
                self.bottomBookMarkLabel.text = String(response.data.likes) // 북마크 수
            }
        }
    }
    
    //Subfunc
    func challengeStartDateCheck(date: String) {
        let check = checkDate(with: date)
        
        if check {
            bottomProofButton.isEnabled = true
            bottomProofButton.backgroundColor = .beScPurple600
        } else {
            bottomProofButton.isEnabled = false
            bottomProofButton.backgroundColor = .beScPurple400
        }
    }
    
    func checkDate(with dateString: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: dateString) {
            let today = Date()
            let result = date.compare(today)
            return result == .orderedSame || result == .orderedAscending
        } else {
            print("날짜 변환에 실패했습니다.")
            return false
        }
    }
}

//MARK: - CollectionView Setting
extension JoinChallengeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func setCollectionView() {
        [galleryCollectionView, feedDetailCollectionView].forEach { view in
            view.delegate = self
            view.dataSource = self
        }
        
        //Cell 등록
        galleryCollectionView.register(GalleryCollectionViewCell.self, forCellWithReuseIdentifier: GalleryCollectionViewCell.identifier)
        feedDetailCollectionView.register(FeedDetailCollectionViewCell.self, forCellWithReuseIdentifier: FeedDetailCollectionViewCell.identifier)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case galleryCollectionView:
            return challengeFeedData.count
        case feedDetailCollectionView:
            return 1
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case galleryCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCollectionViewCell.identifier, for: indexPath) as?
                    GalleryCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let url = URL(string: challengeFeedData[indexPath.row].feedUrl)
            cell.galleryImage.kf.setImage(with: url)
            
            return cell
        case feedDetailCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedDetailCollectionViewCell.identifier, for: indexPath) as?
                    FeedDetailCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.delegate = self
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case galleryCollectionView:
            let width = (UIScreen.main.bounds.width - 48) / 2
            
            return CGSize(width: width, height: 140)
        case feedDetailCollectionView:
            let detailWidth = UIScreen.main.bounds.width - 32
            
            return CGSize(width: detailWidth, height: 647)
        default:
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == galleryCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as! GalleryCollectionViewCell
            feedDetailCollectionView.isHidden = false
            reportLabelButton.isHidden = false
            
            self.showFeedDetail(feedId: cell.feedId ?? 0, feedImage: cell.galleryImage.image!)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == galleryCollectionView {
            return 16 // 행 혹은 열 사이의 최소 간격
        }
        return 0
    }
}
    
//MARK: - Protocol
extension JoinChallengeViewController : CustomFeedCellDelegate {
    func didTapRecommendButton(id: Int) {}
    
    func didTapReportButton() {}
    
    func didTapButton() {
        feedDetailCollectionView.isHidden = true
    }
}
