//
//  MyChallengeFeedViewController.swift
//  beilsang
//
//  Created by 강희진 on 2/1/24.
//

import UIKit
import SwiftUI
import SnapKit
import Kingfisher


class MyChallengeFeedViewController: UIViewController, UIScrollViewDelegate {
    // MARK: - Properties
    
    // 전체 화면 scrollview
    let fullScrollView = UIScrollView()
    let fullContentView = UIView()
    let menuList = ["참여중", "등록한", "완료됨"]
    
    var selectedMenu : String = "참여중" // 0: 참여중, 1: 등록한, 2: 완료됨
    var selectedCategory = "다회용컵" //0:다회용컵, ..., 8: 재활용
    
    var cellList : [FeedModel] = []
    
    var joinList = [[FeedModel]](repeating: Array(), count: 9)
    var enrollList = [[FeedModel]](repeating: Array(), count: 9)
    var finishList = [[FeedModel]](repeating: Array(), count: 9)
    
    
    
    lazy var menuCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.estimatedItemSize = .zero
        layout.itemSize = CGSize(width: (self.view.frame.width-22-32)/3, height: 40)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return view
    }()
    
    //메뉴 하단 회색 바
    lazy var menuUnderLine: UIView = {
        let view = UIView()
        view.backgroundColor = .beBgDiv
        return view
    }()
    
    // categoriesView - 셀
    let categoryDataList = CategoryKeyword.data[1...]
    lazy var categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 72, height: 72)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        return view
    }()
    
    lazy var categoryUnderLine: UIView = {
        let view = UIView()
        view.backgroundColor = .beBgSub
        return view
    }()
    
    lazy var challengeFeedBoxCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: (self.view.frame.width-44)/2, height: 140)
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.isScrollEnabled = true
        return view
    }()
    lazy var challengeFeedLabel : UILabel = {
        let label = UILabel()
        label.text = "나의 챌린지 피드"
        label.textColor = .black
        label.font = UIFont(name: "NotoSansKR-Medium", size: 16)
        return label
    }()
    
    lazy var feedDetailCollectionView: UICollectionView = {
        let layout = self.makeFlowLayout()
        layout.configuration.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.isHidden = true
        return view
    }()
    
    lazy var noFeedLabel: UILabel = {
        let view = UILabel()
        
        view.text = "인증한 피드가 없어요 🤔"
        view.textAlignment = .center
        view.textColor = .beTextInfo
        view.font = UIFont(name: "Noto Sans KR", size: 12)
        
        return view
    }()
    
    lazy var joinChallengeButton: UIButton = {
        let view = UIButton()
        
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.beBgDiv.cgColor
        view.setTitle("인증하러 가기", for: .normal)
        view.setTitleColor(.beTextDef, for: .normal)
        view.titleLabel?.font = UIFont(name: "Noto Sans KR", size: 14)
        view.contentHorizontalAlignment = .center
        view.layer.cornerRadius = 20
        view.addTarget(self, action: #selector(challengeButtonClicked), for: .touchUpInside)
        
        return view
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setFeedList()
        setupAttribute()
        setCollectionView()
        setNavigationBar()
        viewConstraint()
    }
}
extension MyChallengeFeedViewController {
    
    func setupAttribute() {
        setFullScrollView()
        setLayout()
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
        //상단부
        [menuCollectionView, menuUnderLine, categoryCollectionView, categoryUnderLine, challengeFeedBoxCollectionView, challengeFeedLabel, feedDetailCollectionView].forEach{ view in fullContentView.addSubview(view)}
    }
    
    //snp 설정
    func viewConstraint(){
        menuCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(40)
        }
        menuUnderLine.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(menuCollectionView.snp.bottom)
            make.leading.equalToSuperview()
        }
        categoryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(menuCollectionView.snp.bottom).offset(30)
            make.height.equalTo(72)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        categoryUnderLine.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(8)
            make.top.equalTo(categoryCollectionView.snp.bottom).offset(24)
            make.leading.equalToSuperview()
        }
        challengeFeedLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryUnderLine.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(16)
        }
        challengeFeedBoxCollectionView.snp.makeConstraints { make in
            make.top.equalTo(challengeFeedLabel.snp.bottom).offset(12)
            make.leading.equalTo(challengeFeedLabel)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        feedDetailCollectionView.snp.makeConstraints { make in
            make.top.equalTo(challengeFeedBoxCollectionView)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
}
// MARK: - 네비게이션 바 커스텀
extension MyChallengeFeedViewController{
    private func setNavigationBar() {
        self.navigationItem.titleView = attributeTitleView()
        
        // 백 버튼 설정
        setBackButton()
    }
    private func attributeTitleView() -> UIView {
        // title 설정
        let label = UILabel()
        let lightText: NSMutableAttributedString =
            NSMutableAttributedString(string: "나의 챌린지 피드",attributes: [
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
        leftBarButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    // 백버튼 액션
    @objc func tabBarButtonTapped() {
        print("뒤로 가기")
        navigationController?.popViewController(animated: true)
    }
    
    @objc func challengeButtonClicked() {
        print("인증하러 가기")
        
        let labelText = "참여중"
        let challengeListVC = ChallengeListViewController()
        challengeListVC.categoryLabelText = labelText
        challengeListVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(challengeListVC, animated: true)
    }
}
// MARK: - collectionView setting(카테고리)
extension MyChallengeFeedViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    // collectionView, delegate, datasorce 설정
    func setCollectionView() {
        [menuCollectionView, categoryCollectionView, challengeFeedBoxCollectionView, feedDetailCollectionView].forEach { view in
            view.delegate = self
            view.dataSource = self
        }
        
        //Cell 등록
        menuCollectionView.register(ChallengeMenuCollectionViewCell.self, forCellWithReuseIdentifier: ChallengeMenuCollectionViewCell.identifier)
        categoryCollectionView.register(MyPageCategoryCollectionViewCell.self, forCellWithReuseIdentifier: MyPageCategoryCollectionViewCell.identifier)
        challengeFeedBoxCollectionView.register(MyChallengeFeedCollectionViewCell.self, forCellWithReuseIdentifier: MyChallengeFeedCollectionViewCell.identifier)
        feedDetailCollectionView.register(FeedDetailCollectionViewCell.self, forCellWithReuseIdentifier: FeedDetailCollectionViewCell.identifier)
        // 컬렉션 뷰 첫 화면 선택
        setFirstIndexIsSelected()
        
        categoryCollectionView.showsHorizontalScrollIndicator = false
    }
    // section 개수 설정
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    // cell 개수 설정
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case menuCollectionView:
            return menuList.count
        case categoryCollectionView:
            return categoryDataList.count
        case challengeFeedBoxCollectionView:
            return cellList.count
        case feedDetailCollectionView:
            return 1
        default:
            return 0
        }
    }
    
    // cell 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView{
        case menuCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChallengeMenuCollectionViewCell.identifier, for: indexPath) as?
                    ChallengeMenuCollectionViewCell else {
                return UICollectionViewCell()
            }
            let target = menuList[indexPath.row]
            cell.menuLabel.text = target
            
            return cell
        case categoryCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyPageCategoryCollectionViewCell.identifier, for: indexPath) as?
                    MyPageCategoryCollectionViewCell else {
                return UICollectionViewCell()
            }
            let target = categoryDataList[indexPath.row+1]
            let img = UIImage(named: "\(target.image).svg")
            cell.keywordImage.image = img
            cell.keywordLabel.text = target.title
            
            return cell
        case challengeFeedBoxCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyChallengeFeedCollectionViewCell.identifier, for: indexPath) as?
                    MyChallengeFeedCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.feedId = cellList[indexPath.row].feedId
            
            let url = URL(string: self.cellList[indexPath.row].feedUrl)
            cell.challengeFeed.kf.setImage(with: url)
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
    
    // cell 선택시 액션
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView{
        case menuCollectionView:
            let cell = collectionView.cellForItem(at: indexPath) as! ChallengeMenuCollectionViewCell
            selectedMenu = cell.menuLabel.text ?? ""
            print(cell.menuLabel.text ?? "")
            let challengeListVC = ChallengeListViewController()
            challengeListVC.categoryLabelText = selectedMenu
            didTapButton()
            setFeedList() // request 요청
        case categoryCollectionView:
            let cell = collectionView.cellForItem(at: indexPath) as! MyPageCategoryCollectionViewCell
            didTapButton()
            selectedCategory = cell.keywordLabel.text ?? ""
            setFeedList() // request 요청
        case challengeFeedBoxCollectionView:
            let cell = collectionView.cellForItem(at: indexPath) as! MyChallengeFeedCollectionViewCell
            feedDetailCollectionView.isHidden = false
            
            self.showFeedDetail(feedId: cell.feedId!, feedImage: cell.challengeFeed.image!)
        default:
            return
        }
    }
    
    // collectionCell 첫 화면 설정
    func setFirstIndexIsSelected() {
        let selectedIndexPath = IndexPath(item: 0, section: 0)
        menuCollectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .bottom) // 0번째 Index로
        categoryCollectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .bottom) // 0번째 Index로
    }
    
    // 섹션 별 크기 설정을 위한 함수
    // challengeBoxCollectionView layout 커스텀
    private func makeFlowLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { section, ev -> NSCollectionLayoutSection? in
            
            return makeChallengeFeedDetailSectionLayout()
        }
        // 전체가 아닐 때의 medal 섹션
        func makeChallengeFeedDetailSectionLayout() -> NSCollectionLayoutSection? {
            // item
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            /// 아이템들이 들어갈 Group 설정
            /// groupSize 설정
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            // section
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 16,
                bottom: 0,
                trailing: 16)
            
            return section
        }
    }
}
// MARK: - function
extension MyChallengeFeedViewController {
    // 피드 상세정보 보기 request
    private func showFeedDetail(feedId: Int, feedImage: UIImage){
        let feedCell = feedDetailCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as! FeedDetailCollectionViewCell
        
        MyPageService.shared.getMyPageFeedDetail(baseEndPoint: .feeds, addPath: "/\(String(describing: feedId))") {response in
            feedCell.reviewContent.text = response.data.review
            if response.data.day > 3{
                feedCell.dateLabel.text = response.data.uploadDate
            } else {
                feedCell.dateLabel.text = "\(response.data.day)일 전"
            }
            feedCell.feedImage.image = feedImage
            feedCell.titleTag.text = "#\(response.data.challengeTitle)"
            feedCell.categoryTag.text = "#\(response.data.category)"
            feedCell.nicknameLabel.text = response.data.nickName
            if let imageUrl = response.data.profileImage {
                let url = URL(string: response.data.profileImage!)
                feedCell.profileImage.kf.setImage(with: url)
            }
            if response.data.like {
                feedCell.heartButton.setImage(UIImage(named: "iconamoon_fullheart-bold"), for: .normal)
            }
        }
    }
    private func setFeedList(){
        let categoryIndex = changeCategoryToInt(category: selectedCategory)-1
        if selectedMenu == "참여중"{
            //api에서 data를 받아오지 않았다면
            if joinList[categoryIndex].isEmpty{
                joinList[categoryIndex] = requestFeedList()
            } else {
                self.cellList = joinList[categoryIndex]
                challengeFeedBoxCollectionView.reloadData()
            }
        } else if selectedMenu == "등록한"{
            if enrollList[categoryIndex].isEmpty{
                enrollList[categoryIndex] = requestFeedList()
            } else{
                self.cellList = enrollList[categoryIndex]
                challengeFeedBoxCollectionView.reloadData()
            }
        } else {
            if finishList[categoryIndex].isEmpty{
                finishList[categoryIndex] = requestFeedList()
            } else{
                self.cellList = finishList[categoryIndex]
                challengeFeedBoxCollectionView.reloadData()
            }
        }
    }
    
    private func requestFeedList() -> [FeedModel]{
        var requestList : [FeedModel] = []
        MyPageService.shared.getFeedList(baseEndPoint: .feeds, addPath: "/\(selectedMenu)/\(selectedCategory)"){response in
            requestList = self.reloadFeedList(response.data.feeds ?? [])
            
            if requestList.count == 0 {
                self.showNoFeedView()
            }
            else {
                self.challengeFeedBoxCollectionView.isHidden = false
                self.noFeedLabel.isHidden = true
                self.joinChallengeButton.isHidden = true
            }
        }
        
        
        
        return requestList
    }
    @MainActor
    private func reloadFeedList(_ list: [FeedModel]) -> [FeedModel]{
        cellList = list
        challengeFeedBoxCollectionView.reloadData()
        return list
    }
    func changeCategoryToInt(category: String) -> Int{
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
            return 0
        }
    }
}


extension MyChallengeFeedViewController: CustomFeedCellDelegate {
    func didTapRecommendButton(id: Int) {} // 다른 컨트롤러에서 이용하는 것
    
    func didTapReportButton() {} // 다른 컨트롤러에서 이용하는 것
    
    func didTapButton() {
        feedDetailCollectionView.isHidden = true
    }
}

extension MyChallengeFeedViewController {
    func showNoFeedView() {
        challengeFeedBoxCollectionView.isHidden = true
        fullContentView.addSubview(noFeedLabel)
        fullContentView.addSubview(joinChallengeButton)
        
        noFeedLabel.snp.makeConstraints { make in
            make.top.equalTo(challengeFeedLabel.snp.bottom).offset(48)
            make.centerX.equalToSuperview()
        }
        
        joinChallengeButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(noFeedLabel.snp.bottom).offset(12)
            make.width.equalTo(240)
            make.height.equalTo(40)
        }
        noFeedLabel.isHidden = false
        joinChallengeButton.isHidden = false
    }
}
