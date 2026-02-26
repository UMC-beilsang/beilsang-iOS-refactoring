
<h1 align="center">
  <br>
  <img width="2048" height="546" alt="banner" src="https://github.com/user-attachments/assets/4ebd1f72-8710-4da1-864b-c5eff7d6d289" />
  <br>
  Beilsang
  <br>
</h1>

<h4 align="center">
  환경 실천을 함께하는 에코 챌린지 플랫폼
</h4>

<div align="center">
  <img src="https://github.com/user-attachments/assets/69993785-fce1-4bcf-97ac-b531868f346a" width="500"/>
</div>

<h5 align="center">
  UIKit → SwiftUI 전면 리팩토링 | Clean Architecture 모듈화
</h5>

<p align="center">
  <a href="#-프로젝트-소개">프로젝트 소개</a> •
  <a href="#-작업-내용">작업 내용</a> •
  <a href="#-technical-highlights">Technical Highlights</a> •
  <a href="#-tech-stack">Tech Stack</a>
</p>

<div align="center">

| <img src="https://github.com/30isdead.png" width="100px"/><br/>**박세영** | <img src="https://github.com/BE1아이디.png" width="100px"/><br/>**강희진** | <img src="https://github.com/BE2아이디.png" width="100px"/><br/>**윤종석** | <img src="https://github.com/PM아이디.png" width="100px"/><br/>**최서영** | **고하늘** |
| :---: | :---: | :---: | :---: | :---: |
| `iOS Developer` | `Backend` | `Backend` | `PM` | `Designer` |
| iOS 앱 개발 | 서버 개발 | 서버 개발 | 프로젝트 관리 | UI/UX |

</div>

<br>

---

<br>

## 📱 프로젝트 소개

일상에서 실천하는 작은 환경보호(텀블러 사용, 플로깅, 분리수거)를 혼자가 아닌 **함께** 이어갈 수 있도록 돕는 커뮤니티 기반 챌린지 앱입니다.

<div align="center">
  <img src="https://github.com/user-attachments/assets/1a13b69b-f49c-486b-a741-c896e343bedb" width="250"/>
  <img src="https://github.com/user-attachments/assets/d36dbab8-21a2-46d4-83bb-b9f2df6784cf" width="250"/>
  <img src="https://github.com/user-attachments/assets/495eacb0-45bd-488c-a866-8aefb98600e8" width="250"/>
</div>
<div align="center">
  <img src="https://github.com/user-attachments/assets/926cd5bd-c435-4b75-8dba-5cbce99e36b1" width="250"/>
  <img src="https://github.com/user-attachments/assets/7d9e8710-773c-4167-a7d7-9479e40ad241" width="250"/>
</div>

<br>

## 🔨 작업 내용

### 레거시 코드베이스 전면 리팩토링
기존 UIKit 기반 모놀리식 구조를 **SwiftUI + Clean Architecture**로 완전히 재구축

**주요 개선**
- 🏗️ **모듈화**: Tuist 기반 4-Layer 아키텍처 구축 (Core/Domain/Feature/Shared)
- ♻️ **마이그레이션**: UIKit → SwiftUI 전환 (-9,083 lines)
- 🧪 **테스트 용이성**: Protocol 기반 추상화
- 📐 **아키텍처**: Clean Architecture + MVVM + Repository Pattern

<br>

## 🎯 Technical Highlights

### 1. 🚀 Tuist Example App - Feature 독립 개발

> **전체 앱 빌드 없이 Feature만 실행**

```swift
@main
struct AuthExampleApp: App {
    var body: some Scene {
        SignUpView(container: authContainer)
    }
}
```

**효과**
- 빌드 시간 **90% 단축**
- UI 수정 즉시 확인
- 독립 테스트 환경

---

### 2. 🔗 Protocol Navigation - 모듈 간 통신

> **Feature 간 직접 의존 없이 화면 전환**

#### 문제
모듈화하면 Feature 간 직접 import 불가 (순환 참조)

#### 해결
```
Discover ──┐
MyPage ────┼─→ [Protocol] ←── Challenge (구현)
           │   (Shared)
```

```swift
// NavigationShared - Protocol 정의
protocol ChallengeCoordinatable {
    func showChallengeDetail(id: Int)
}

// Discover - 사용 (Challenge import 없음!)
router.challengeCoordinator?.showChallengeDetail(id: 123)
```

**효과**
- ✅ 순환 참조 방지
- ✅ Feature 독립 빌드
- ✅ Mock으로 테스트 용이

---

### 3. 💉 DI Container - 의존성 중앙 관리

> **Feature는 구현체 몰라도 됨**

```swift
class AuthContainer {
    lazy var signUpUseCase: SignUpUseCaseProtocol = {
        SignUpUseCase(repository: authRepository)
    }()
}

// View는 Container에서 받기만
SignUpView(container: authContainer)
```

**효과**
- Domain 변경해도 Feature 재컴파일 불필요
- Mock Container로 테스트 간편

<br>

## 🛠 Tech Stack

### Architecture
```
Feature → Domain → Core
           ↓
        Shared
```

<div align="center">

| Layer | Description | Technologies |
|:---:|:---|:---:|
| **Feature** | UI & Presentation | SwiftUI, Combine |
| **Domain** | Business Logic | Repository, UseCase |
| **Core** | Infrastructure | Alamofire, Keychain |
| **Shared** | Common Modules | DesignSystem, Models |

</div>

**Design Pattern**
- Clean Architecture
- MVVM + Repository Pattern
- Coordinator Pattern

**iOS**
- SwiftUI + Combine
- Async/Await
- Keychain Services

**Tools**
- Tuist (모듈화)
- Alamofire
- Kakao/Apple SDK

<br>

## 📂 Module Structure

```
App
├─ 🔧 Core               인프라 레이어
│   ├─ NetworkCore       API 통신, 토큰 관리
│   └─ StorageCore       Keychain 저장소
│
├─ 💼 Domain             비즈니스 로직
│   ├─ AuthDomain        인증/회원가입
│   ├─ ChallengeDomain   챌린지 CRUD
│   ├─ UserDomain        프로필 관리
│   └─ NotificationDomain 알림
│
├─ 🎨 Feature            UI 레이어 (SwiftUI)
│   ├─ Auth              로그인/회원가입
│   ├─ Challenge         챌린지 목록/상세/검색
│   ├─ Discover          추천 피드
│   ├─ MyPage            마이페이지
│   └─ Notification      알림
│
└─ 🔗 Shared             공통 모듈
    ├─ DesignSystem      Colors, Fonts, Assets
    ├─ UIComponents      재사용 컴포넌트
    ├─ Models            공통 모델
    └─ Navigation        라우팅
```

<br>

## 📊 리팩토링 결과

<div align="center">

### **-9,083 lines**
(21,970 삭제 / 12,887 추가)

| 개선 항목 | 세부 내용 |
|:---:|:---|
| 🔄 마이그레이션 | UIKit → SwiftUI 전환 |
| 🏗️ 아키텍처 | 모놀리식 → 4-Layer 모듈화 |
| ⚡️ 빌드 | Feature 독립 빌드 가능 |
| 🧪 테스트 | Protocol 기반 Mock 주입 |

</div>
