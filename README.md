# Cat Logic Mansion iOS 原型

这是 `Cat Logic Mansion` 的 SwiftUI + SpriteKit MVP 原型工程。

## 当前已完成

- SwiftUI App 入口
- 主菜单入口
- SwiftUI 承载 SpriteKit 游戏棋盘
- JSON 关卡加载
- 20 个关卡 JSON 已打包进 App bundle
- 滑动移动
- 点击相邻格移动
- 墙体阻挡
- 出口通关判断
- 鱼干收集
- 钥匙与锁定出口
- 箱子推动
- 按钮触发门与桥
- 撤销一步
- 步数统计
- 重置关卡
- 游戏内图标式撤销与重置 HUD
- 通关结算与三星评价
- 关卡解锁与 UserDefaults 存档
- 音效与音乐开关持久化
- 原创程序化音效与背景音乐播放
- 第一版原创程序化视觉素材与 SpriteKit 纹理渲染
- 第一轮视觉 QA 截图记录
- 箱子压住按钮时的渲染层级与 pressed 状态优化
- 英文、简体中文、繁体中文本地化
- SwiftPM 核心规则单元测试，核心代码覆盖率超过 90%
- 关卡 JSON 结构校验命令行工具
- 自动通关解法搜索命令行工具

## 工程路径

```text
CatLogicMansion/
  CatLogicMansion.xcodeproj
  CatLogicMansion/
    App/
    Game/
    Models/
    Services/
    GameData/
    en.lproj/
    zh-Hans.lproj/
    zh-Hant.lproj/
```

## 运行方式

用 Xcode 打开：

```bash
open CatLogicMansion.xcodeproj
```

选择 iPhone Simulator 后运行 `CatLogicMansion` scheme。

命令行构建：

```bash
xcodebuild -project CatLogicMansion.xcodeproj \
  -scheme CatLogicMansion \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  build CODE_SIGNING_ALLOWED=NO
```

## 当前 Demo 范围

当前 SpriteKit 负责渲染和输入，核心玩法规则由 `GameEngine` 承担：

- 地图渲染
- 玩家移动
- 墙体碰撞
- 到达出口通关
- 收集物拾取
- 钥匙解锁出口
- 箱子推动
- 按钮开门、开桥
- 撤销与重置
- 结算星级

第 1 到第 20 关已可加载、渲染并使用同一套核心规则运行。关卡选择、游戏内关卡菜单和下一关跳转已改为读取各章节 `index.json`，当前包含 Chapter 1 全 15 关与 Chapter 2 前 5 关。

## 下一步建议

1. 对第 16 到第 20 关做一次人工试玩复核，重点记录真实完成步数、软锁风险、教程可读性和节奏问题。
2. 为 Chapter 2 增加书房/地毯视觉主题，让它与 Chapter 1 在画面上明显区分。
3. 继续扩展 Chapter 2 到 30 关，优先扩展箱子、按钮、门、桥的组合，再考虑镜子光线。
4. 为 60 关首发内容建立关卡编辑、截图、校验和求解的固定流程。

## 测试与覆盖率

运行核心规则单元测试：

```bash
swift test
```

运行覆盖率测试：

```bash
swift test --enable-code-coverage
xcrun llvm-cov report .build/arm64-apple-macosx/debug/CatLogicMansionCorePackageTests.xctest/Contents/MacOS/CatLogicMansionCorePackageTests \
  -instr-profile .build/arm64-apple-macosx/debug/codecov/default.profdata \
  -ignore-filename-regex='Tests|PackageTests'
```

当前核心代码覆盖率：

- Line coverage: 94.74%
- Function coverage: 92.94%

## 关卡校验

运行关卡 JSON 结构校验：

```bash
swift run validate-levels
```

当前 20 个索引关卡均通过结构校验。人工试玩记录见 `docs/LEVEL_QA.md`。

## 自动解法校验

运行自动通关搜索：

```bash
swift run solve-levels
```

当前 20 个索引关卡均存在通关路线和 3 星路线。工具会同时打印最快通关路线与 3 星路线；部分关卡的最快通关路线不是 3 星，因为它会跳过可选收集物。

第 5 到第 10 关已做第一轮加难：箱子、按钮、桥、门、钥匙和路线规划在三星路线中承担更明确的作用。
第 5 到第 10 关已通过脚本化模拟器三星回放，截图证据位于 `docs/level_qa/scripted_replay/contact_sheet.png`。
第 11 到第 15 关补齐 Chapter 1，并已调高为第一章压轴段：最短三星路线为 34 到 46 步，测试会阻止这些关卡回退到低于 32 步的过短三星路线，并验证三星路线必须使用关卡里出现的机制道具。脚本化模拟器三星回放截图证据位于 `docs/level_qa/chapter_01_15/contact_sheet.png`。
第 16 到第 20 关已进入 Chapter 2：继续使用箱子、按钮、门、桥和钥匙组合，作为天鹅绒图书馆机制扩展的第一批关卡。

## 音频素材

当前音效与背景音乐位于：

```text
CatLogicMansion/GameData/Audio/
```

音频由 `Tools/GenerateAudio/generate_audio.py` 程序化生成，不使用第三方采样。授权与来源说明见 `docs/AUDIO_LICENSE.md`。

## 视觉素材

当前第一版游戏纹理位于：

```text
CatLogicMansion/GameData/Art/
```

视觉素材由 `Tools/GenerateArt/generate_art.py` 程序化生成，不使用第三方图片。授权与来源说明见 `docs/ART_LICENSE.md`。
视觉 QA 记录见 `docs/visual_qa/VISUAL_QA.md`。
