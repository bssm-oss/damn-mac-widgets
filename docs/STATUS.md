# damn-macos-widgets — 작업 정리

> Tiny macOS widgets for people who hate opening apps.

Mac 전용 데스크탑 위젯 팩. 앱을 열지 않아도 바로 보이는 glanceable productivity hub.

---

## 프로젝트 성격

| 원칙 | 설명 |
|------|------|
| **Glanceable** | 앱을 열지 않고 한눈에 확인 |
| **Local-first** | 로그인 없음, 데이터는 Mac에만 저장 |
| **Lightweight** | 가볍고 빠른 네이티브 유틸 |
| **Menu bar hub** | Dock 앱이 아니라 메뉴바에서 설정/관리 |

범용 SaaS가 아니라, **작업환경 빈 공간에 박아두는 작고 짜증나게 유용한 macOS 위젯팩**.

---

## 네이밍

- **프로젝트명:** `damn-macos-widgets` (`widgets` 복수)
- **로컬 폴더:** `damn-mac-widgets`
- **번들 ID:** `dev.justn.damn-macos-widgets`
- **실행 바이너리:** `DamnMacOSWidgets`

---

## 기술 스택

- **언어:** Swift 6
- **UI:** SwiftUI + AppKit (`NSPanel`)
- **빌드:** Swift Package Manager
- **최소 OS:** macOS 14 Sonoma
- **앱 형태:** 메뉴바 전용 (`LSUIElement` — Dock 아이콘 없음)

---

## 지금까지 만든 것

### 2026-06-08 — 초기 스캐폴드

프로젝트를 빈 워크스페이스에서 Swift/SwiftUI 네이티브 macOS 앱으로 부트스트랩함.

### 2026-06-08 — 2차 정리

초기 스캐폴드 이후, 위젯 본체와 보조 기능을 더 채워서 현재는 메뉴바 허브 + 6개 위젯 + 테스트가 동작하는 상태다.

#### 프로젝트 파일

```
damn-mac-widgets/
├── Package.swift
├── Info.plist              # LSUIElement, 번들 메타
├── README.md
├── LICENSE                 # MIT
├── .gitignore
├── scripts/
│   └── package-app         # .app bundle + signing helper
└── Sources/DamnMacOSWidgets/
    ├── App/
    │   ├── DamnMacOSWidgetsApp.swift   # @main, MenuBarExtra
    │   └── MenuBarHubView.swift        # 메뉴바 설정 패널
    ├── Core/
    │   ├── WidgetKind.swift            # 위젯 종류, 모델, AppState
    │   ├── WidgetManager.swift         # show/hide, 상태, 패널 관리
    │   ├── WidgetPanel.swift           # 플로팅 NSPanel
    │   ├── LaunchAtLoginService.swift  # SMAppService 래퍼
    │   ├── CalendarService.swift       # EventKit fetch
    │   ├── GitHubService.swift         # gh CLI notification fetch
    │   └── CommandRunner.swift         # 외부 커맨드 실행
    ├── Widgets/
    │   ├── WidgetChrome.swift          # 공통 위젯 크롬 (vibrancy)
    │   ├── NowWidgetView.swift
    │   ├── TodoWidgetView.swift
    │   ├── NoteWidgetView.swift
    │   ├── FocusWidgetView.swift
    │   ├── CalendarWidgetView.swift
    │   └── GitHubWidgetView.swift
    └── Storage/
        └── LocalStore.swift            # JSON persistence
Tests/DamnMacOSWidgetsTests/
└── DamnMacOSWidgetsTests.swift         # LocalStore / Focus / WidgetManager tests
```

#### 구현된 기능

1. **메뉴바 허브**
   - 위젯별 on/off 토글
   - Show All / Hide All
   - Launch at login 토글
   - Quit

2. **플로팅 위젯 창**
   - `NSPanel` + `.floating` level
   - 바탕화면 위에 떠 있음 (Notification Center 위젯 아님)
   - 드래그로 이동, 위치 저장
   - `ultraThinMaterial` + 라운드 코너 UI

3. **동작하는 위젯 6개**

   | 위젯 | 기능 |
   |------|------|
   | **Now** | 지금 하고 있는 작업 한 줄~몇 줄 입력 |
   | **Todo** | 할 일 추가 / 완료 토글 / 삭제 |
   | **Note** | 빠른 메모 (TextEditor) |
   | **Focus** | 25분 기준 포커스 타이머 |
   | **Calendar** | EventKit 기반 upcoming event 목록 |
   | **GitHub** | `gh` CLI 기반 unread notification 요약 |

4. **로컬 저장**
   - 경로: `~/Library/Application Support/damn-macos-widgets/state.json`
   - 저장 내용: 위젯 on/off, 창 위치/크기, Now/Todo/Note 데이터
   - 300ms debounce 후 atomic write

5. **자동화 테스트**
   - `LocalStore` round-trip
   - `FocusTimerState` 전이
   - `WidgetManager` 상태 변경

6. **로그인 실행**
   - `SMAppService.mainApp` 기반 launch at login 토글
   - preference를 로컬 상태에 저장하고 시스템 상태를 동기화

7. **앱 패키징**
   - `scripts/package-app`
   - `.build/package/DamnMacOSWidgets.app` 생성
   - `CODE_SIGN_IDENTITY`가 있으면 실서명, 없으면 ad hoc signing

8. **첫 실행 기본값**
   - Now 위젯만 켜진 상태
   - 위젯 창은 화면 우측 상단 근처에 stagger 배치

#### 아직 없는 것

- `.app` 번들 패키징 및 코드 서명
- 위젯 리사이즈
- GitHub remote / git init
- UI test

---

## 아키텍처 요약

```
MenuBarExtra (허브)
       │
       ▼
WidgetManager ──► LocalStore (state.json)
       │
       ├── WidgetPanel (Now)      ──► NowWidgetView
       ├── WidgetPanel (Todo)     ──► TodoWidgetView
       ├── WidgetPanel (Note)     ──► NoteWidgetView
       ├── WidgetPanel (Focus)    ──► FocusWidgetView
       ├── WidgetPanel (Calendar) ──► CalendarWidgetView
       └── WidgetPanel (GitHub)    ──► GitHubWidgetView
```

- **WidgetKind:** 위젯 enum + `AppState` / `TodoItem` 모델
- **WidgetManager:** `@MainActor ObservableObject`, 패널 생명주기 + CRUD
- **WidgetPanel:** borderless `NSPanel`, `NSHostingView`로 SwiftUI embed
- **WidgetChrome:** 위젯 공통 헤더 + material background
- **External services:** `SMAppService` launch-at-login, EventKit calendar fetch, `gh`-backed GitHub notifications

---

## 위젯 로드맵

| 위젯 | 상태 | 설명 |
|------|------|------|
| Now | ✅ 동작 | 지금 하고 있는 작업 |
| Todo | ✅ 동작 | 간단한 할 일 |
| Note | ✅ 동작 | 빠른 메모 |
| Focus | ✅ 동작 | 집중 상태 / 타이머 |
| Calendar | ✅ 동작 | EventKit 일정 |
| GitHub | ✅ 동작 | 이슈 / PR / 잔디 / 알림 |

---

## 실행 방법

### Xcode (권장)

```bash
cd damn-mac-widgets
open Package.swift
```

Scheme `DamnMacOSWidgets` → Run (⌘R)  
메뉴바 오른쪽 **격자 아이콘** 클릭.

### 터미널

```bash
swift build
.build/debug/DamnMacOSWidgets
```

### 빌드 확인만

```bash
swift build
```

---

## 테스트 방법

자동 테스트 suite가 추가됨. `swift test`로 확인하고, Mac에서는 아래 수동 체크를 같이 보면 된다.

### 기본 체크

- [ ] Dock 아이콘 없음
- [ ] 메뉴바 격자 아이콘 표시
- [ ] 첫 실행 시 Now 위젯 1개 표시
- [ ] Now / Todo / Note 토글 동작
- [ ] Show All / Hide All 동작
- [ ] 위젯 드래그 이동

### 위젯별

- **Now:** 텍스트 입력
- **Todo:** 추가 / 완료 / 삭제
- **Note:** 여러 줄 메모
- **Focus:** 시작 / 일시정지 / 리셋
- **Calendar:** 접근 허용 후 upcoming event 확인
- **GitHub:** `gh auth login` 상태에서 notification 목록 확인

### 저장 확인

1. 내용 입력 + 위치 이동
2. Quit 후 재실행
3. 데이터·위치·on/off 상태 유지 확인

```bash
cat ~/Library/Application\ Support/damn-macos-widgets/state.json
```

### 초기화 (첫 실행 상태로)

```bash
killall DamnMacOSWidgets 2>/dev/null
rm -rf ~/Library/Application\ Support/damn-macos-widgets
```

### 프로세스 확인

```bash
.build/debug/DamnMacOSWidgets &
sleep 2
pgrep -lf DamnMacOSWidgets
killall DamnMacOSWidgets
```

---

## 개발 중 알아둔 것

1. **SPM + Info.plist:** `Resources/` 안에 두면 forbidden. 루트 `Info.plist` + linker `-sectcreate` 사용.
2. **부트스트랩 타이밍:** `WidgetManager.init`에서 바로 `NSPanel` 만들면 크래시(exit 134). `Task { @MainActor in bootstrap() }`로 앱 기동 후 패널 생성.
3. **메뉴바 앱:** `NSApplication.shared.setActivationPolicy(.accessory)` 필요.
4. **SwiftUI 갱신:** `@Published appState`는 struct 전체 재할당해야 view 업데이트 reliably 반영.

---

## 다음에 할 수 있는 것

1. `.app` 번들 + 코드 서명
2. 위젯 리사이즈
3. git init + remote push
4. UI test
