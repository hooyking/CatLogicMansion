# Cat Logic Mansion 游戏设计文档

## 1. 项目概述

### 1.1 游戏名称

`Cat Logic Mansion`

### 1.2 游戏类型

竖屏 2D 单机逻辑解谜游戏。

### 1.3 目标平台

- iOS
- iPadOS

### 1.4 技术方向

- UI：SwiftUI
- 游戏场景：SpriteKit
- 关卡配置：JSON
- 存档：UserDefaults，后续可升级为 SwiftData
- 多语言：Apple 原生 `Localizable.xcstrings`

### 1.5 商业模式

- App Store 买断制下载
- 不接入广告
- 不接入内购
- 不接入订阅
- 支持离线游玩

### 1.6 首发语言

首发支持三种语言：

- 英文：`en`
- 简体中文：`zh-Hans`
- 繁体中文：`zh-Hant`

所有用户可见文案必须走本地化 key，不允许在 SwiftUI 页面、SpriteKit 场景、弹窗、按钮、结算页中硬编码文案。

---

## 2. 产品定位

### 2.1 一句话定位

一款以猫咪探索神秘豪宅为主题的买断制离线逻辑解谜游戏，玩家通过推箱子、踩机关、拿钥匙、反射光线等方式解开每个房间的谜题。

### 2.2 核心卖点

- 可爱猫咪主角
- 温暖童话豪宅风格
- 无广告、无内购、无订阅
- 纯离线游玩
- 手工设计关卡
- 每关 1 到 3 分钟
- 适合通勤、睡前、碎片时间游玩
- 支持 iPhone 与 iPad
- 支持英文、简体中文、繁体中文

### 2.3 目标用户

- 喜欢单机解谜游戏的玩家
- 讨厌广告和内购干扰的买断制用户
- 喜欢猫、宠物、温暖治愈画风的用户
- 喜欢短关卡、轻策略、逻辑推理的手机玩家
- 海外 iOS 付费游戏用户

### 2.4 竞品参考

参考方向不是直接复制玩法，而是学习它们的产品完成度、关卡节奏和买断制体验：

- `Monument Valley`：精致视觉与短关卡节奏
- `Baba Is You`：规则变化带来的逻辑深度
- `The Room`：房间探索与机关感
- `A Good Snowman Is Hard To Build`：可爱主题与推理结合
- `Lara Croft GO`：格子地图与关卡推进

---

## 3. 游戏世界观

### 3.1 背景设定

一只名叫 Miso 的小猫误入一座会移动房间的古老豪宅。豪宅中每个房间都藏着机关、钥匙、谜题和记忆碎片。玩家需要帮助 Miso 解开房间谜题，逐步探索豪宅深处，找到回家的路。

### 3.2 美术基调

- 温暖
- 精致
- 童话感
- 轻微神秘感
- 不恐怖
- 不血腥
- 不暗黑

### 3.3 章节主题

首发版本建议 4 个章节，每章 15 关，共 60 关。

| 章节 | 英文名 | 中文名 | 主题 | 核心机制 |
|---|---|---|---|---|
| Chapter 1 | The Dusty Foyer | 尘封门厅 | 豪宅入口 | 移动、墙体、出口 |
| Chapter 2 | The Velvet Library | 天鹅绒图书馆 | 书房与地毯 | 推箱子、按钮、门 |
| Chapter 3 | The Moonlit Gallery | 月光画廊 | 镜子与光线 | 镜子、光线、光门 |
| Chapter 4 | The Clockwork Attic | 发条阁楼 | 齿轮与机关 | 多机关组合 |

后续更新可扩展：

- Chapter 5：The Greenhouse
- Chapter 6：The Hidden Ballroom
- Chapter 7：The Star Observatory

---

## 4. 核心玩法

### 4.1 基础操作

游戏采用竖屏格子地图。

玩家可通过以下方式控制猫移动：

- 滑动：上、下、左、右
- 点击相邻格子：移动一步
- iPad 可支持键盘方向键，作为后续增强能力

每次移动都是一步，谜题以“格子 + 状态变化”为核心。

### 4.2 通关目标

每关目标是让猫到达出口门。

关卡内可能存在可选收集物：

- 鱼干
- 铃铛
- 记忆碎片

收集物用于增加完成度，不影响主线通关。

### 4.3 关卡评价

每关最多 3 星：

- 1 星：到达出口
- 2 星：到达出口并收集全部鱼干
- 3 星：到达出口、收集全部鱼干，并在目标步数内完成

评价只用于挑战，不阻塞玩家推进主线。

### 4.4 失败条件

首发版本不设计强失败条件，避免挫败感过强。

玩家可以随时：

- 撤销一步
- 重置关卡
- 返回关卡选择

后续章节可加入轻度失败机制，例如地刺、限步挑战、移动幽灵猫，但 MVP 阶段不优先实现。

---

## 5. 机制设计

### 5.1 地板

普通可行走格子。

属性：

- 可站立
- 可推动物体通过
- 可放置道具

### 5.2 墙体

不可通过格子。

属性：

- 阻挡猫
- 阻挡箱子
- 阻挡光线

### 5.3 出口门

关卡终点。

状态：

- locked
- opened

打开方式：

- 拿到钥匙
- 按钮触发
- 光线照射

### 5.4 钥匙

猫经过钥匙格子后自动拾取。

规则：

- 一把钥匙可打开指定门
- 也可设计为任意钥匙打开任意普通门
- MVP 阶段建议使用“一把钥匙打开一扇门”的简单规则

### 5.5 箱子

可推动物体。

规则：

- 猫只能从一个方向推动箱子
- 箱子后方必须是可进入格子
- 箱子可以压住按钮
- 箱子不能被拉回

### 5.6 压力按钮

被猫或箱子踩住时触发。

规则：

- 猫离开后按钮恢复
- 箱子压住时按钮保持触发
- 按钮可控制门、桥、机关

### 5.7 镜子

用于反射光线。

规则：

- 镜子可被推动
- 镜子有方向
- 光线遇到镜子后按方向反射
- 光线照到光门开关时打开光门

MVP 阶段可先不实现镜子，第二阶段加入。

### 5.8 可移动家具

家具类似箱子，但部分家具有特殊形状。

示例：

- 单格椅子
- 双格沙发
- 可旋转书架

首发版本建议只做单格家具，避免关卡编辑复杂度过高。

---

## 6. 关卡设计规范

### 6.1 地图尺寸

建议初始尺寸：

- iPhone：`6x8`、`7x9`
- iPad：可显示更宽视野，但关卡逻辑不改变

不要在首发版本使用过大地图。手机上谜题应一屏可见，减少滚动和缩放。

### 6.2 关卡时长

- 教学关：30 秒到 1 分钟
- 普通关：1 到 3 分钟
- 挑战关：3 到 5 分钟

### 6.3 难度曲线

每次只引入一个新机制。

推荐节奏：

1. 新机制教学
2. 简单应用
3. 与旧机制组合
4. 稍复杂变化
5. 小型综合关

### 6.4 教学方式

不使用大段文字说明，优先通过关卡布局自然教学。

必要提示使用本地化短句：

- `tutorial.swipe_to_move`
- `tutorial.push_box`
- `tutorial.step_on_button`
- `tutorial.collect_key`

### 6.5 关卡命名

关卡内部使用稳定 ID，展示名称走本地化。

示例：

- `level.001.name`
- `level.002.name`
- `chapter.foyer.title`

---

## 7. 首批 MVP 关卡规划

MVP 先做 10 关，用于验证技术链路、手感、美术和关卡配置。

| 关卡 | 名称 key | 目标 | 引入机制 |
|---|---|---|---|
| 1 | `level.001.name` | 走到出口 | 移动、出口 |
| 2 | `level.002.name` | 绕过墙体 | 墙体 |
| 3 | `level.003.name` | 收集鱼干后出口 | 收集物 |
| 4 | `level.004.name` | 拿钥匙开门 | 钥匙、门 |
| 5 | `level.005.name` | 推箱子清路 | 箱子 |
| 6 | `level.006.name` | 箱子压按钮开门 | 按钮 |
| 7 | `level.007.name` | 猫临时踩按钮 | 临时触发 |
| 8 | `level.008.name` | 箱子与钥匙组合 | 组合谜题 |
| 9 | `level.009.name` | 最短步数挑战 | 步数评价 |
| 10 | `level.010.name` | 第一章综合关 | 综合测试 |

---

## 8. 关卡 JSON 设计

### 8.1 文件结构

```text
Resources/
  Levels/
    chapter_01/
      level_001.json
      level_002.json
      level_003.json
```

### 8.2 示例关卡

```json
{
  "id": "level_001",
  "chapterId": "chapter_01",
  "nameKey": "level.001.name",
  "width": 6,
  "height": 8,
  "targetSteps": 12,
  "player": {
    "x": 1,
    "y": 6,
    "direction": "up"
  },
  "exit": {
    "x": 4,
    "y": 1,
    "locked": false
  },
  "tiles": [
    "######",
    "#....#",
    "#....#",
    "#....#",
    "#....#",
    "#....#",
    "#....#",
    "######"
  ],
  "objects": [
    {
      "type": "collectible",
      "subtype": "fish",
      "x": 2,
      "y": 3
    }
  ]
}
```

### 8.3 坐标规则

- 左上角为 `(0, 0)`
- x 向右递增
- y 向下递增
- JSON 中 `#` 表示墙体
- JSON 中 `.` 表示地板

---

## 9. SwiftUI 与 SpriteKit 界面设计

### 9.1 页面结构

SwiftUI 负责 App 外层 UI：

- 启动页
- 主菜单
- 章节选择
- 关卡选择
- 设置页
- 语言设置页
- 游戏内图标 HUD
- 通关结算页

SpriteKit 负责游戏棋盘：

- 地图渲染
- 角色移动
- 机关动画
- 碰撞规则
- 光线效果
- 粒子效果

### 9.2 推荐界面

```text
MainMenuView
ChapterSelectView
LevelSelectView
GameContainerView
SettingsView
LanguageSettingsView
ResultView
```

### 9.3 GameContainerView

`GameContainerView` 使用 SwiftUI 承载 `SpriteView`，并叠加 HUD。

HUD 内容：

- 当前关卡
- 步数
- 撤销按钮
- 重置按钮
- 暂停按钮

### 9.4 响应式适配

- iPhone：竖屏优先，游戏棋盘居中
- iPad：棋盘居中，左右可展示关卡信息或装饰区域
- 不强制横屏
- 所有 UI 使用 SwiftUI 自适应布局

---

## 10. 多语言规范

### 10.1 使用方案

使用 Apple 原生 String Catalog：

```text
Localizable.xcstrings
```

首发语言：

- `en`
- `zh-Hans`
- `zh-Hant`

### 10.2 key 命名规则

使用模块前缀：

```text
app.name
menu.play
menu.settings
settings.language
settings.sound
chapter.foyer.title
level.001.name
tutorial.swipe_to_move
result.completed
result.steps
result.next_level
```

### 10.3 示例文案

| key | en | zh-Hans | zh-Hant |
|---|---|---|---|
| `app.name` | Cat Logic Mansion | 猫咪逻辑豪宅 | 貓咪邏輯豪宅 |
| `menu.play` | Play | 开始游戏 | 開始遊戲 |
| `menu.settings` | Settings | 设置 | 設定 |
| `settings.language` | Language | 语言 | 語言 |
| `settings.sound` | Sound | 音效 | 音效 |
| `result.completed` | Room Cleared | 房间已解开 | 房間已解開 |
| `result.next_level` | Next Room | 下一房间 | 下一房間 |

### 10.4 禁止项

- 禁止 SwiftUI 中直接写用户可见英文或中文
- 禁止 SpriteKit label 直接写用户可见英文或中文
- 禁止弹窗、按钮、错误提示硬编码
- 允许内部 ID、日志 tag、资源名使用英文

---

## 11. 美术资源规划

### 11.1 角色资源

主角猫 Miso：

- idle_front
- idle_back
- idle_left
- idle_right
- walk_front
- walk_back
- walk_left
- walk_right
- push_front
- push_back
- push_left
- push_right
- happy
- confused

### 11.2 地图资源

- wood_floor
- carpet_floor
- marble_floor
- wall_wood
- wall_stone
- door_closed
- door_open
- locked_door
- stairs

### 11.3 机关资源

- box
- button_off
- button_on
- key_gold
- mirror_slash
- mirror_backslash
- light_beam
- light_receiver_off
- light_receiver_on

### 11.4 收集物资源

- fish_treat
- bell
- memory_fragment

### 11.5 UI 资源

- app_icon
- main_menu_background
- chapter_card_foyer
- chapter_card_library
- chapter_card_gallery
- chapter_card_attic
- level_star_empty
- level_star_filled
- button_primary
- button_secondary

### 11.6 风格要求

- 2D 插画或精致像素均可
- 首版建议使用 2D 插画风，方便 App Store 截图表现
- 颜色温暖，主色为奶油黄、深木棕、猫咪橘、月光蓝
- 角色边缘清晰，适合小屏幕识别

---

## 12. 音效与音乐

### 12.1 音乐

- 主菜单：温暖钢琴与轻弦乐
- 游戏中：低存在感环境音乐
- 章节变化：不同房间主题轻微变化

### 12.2 音效

- 猫移动
- 推箱子
- 拾取钥匙
- 拾取鱼干
- 按钮触发
- 门打开
- 通关
- 撤销
- 重置

音效必须短、轻、不刺耳。

---

## 13. 存档设计

### 13.1 需要保存的数据

- 已解锁章节
- 已解锁关卡
- 每关最高星级
- 每关最少步数
- 已收集记忆碎片
- 音效开关
- 音乐开关
- 当前语言

### 13.2 数据结构示例

```swift
struct LevelProgress: Codable {
    let levelId: String
    let stars: Int
    let bestSteps: Int
    let collectedAllItems: Bool
}
```

MVP 阶段可使用 `UserDefaults` 保存 JSON 字符串。正式版如果数据增加，再迁移到 SwiftData。

---

## 14. 首发版本范围

### 14.1 MVP 版本

目标：验证游戏能玩、好玩、能扩展。

包含：

- 主菜单
- 设置页
- 关卡选择
- 10 个关卡
- 移动
- 墙体
- 出口
- 鱼干收集
- 钥匙和门
- 箱子
- 按钮
- 步数统计
- 撤销一步
- 重置关卡
- 通关结算
- 英文、简体中文、繁体中文

### 14.2 首发 1.0

目标：达到 App Store 买断制发布品质。

包含：

- 4 个章节
- 60 个关卡
- 三星评价
- 章节插画
- 基础剧情文本
- 完整音效
- 背景音乐
- iPhone 与 iPad 适配
- App Store 截图素材
- 隐私政策
- 完整本地化

---

## 15. 开发里程碑

### Milestone 1：原型验证

目标：10 关可玩。

任务：

- 创建 SwiftUI 项目
- 接入 SpriteKit
- 实现 JSON 关卡加载
- 实现格子地图渲染
- 实现猫移动
- 实现墙体阻挡
- 实现出口通关

### Milestone 2：基础谜题

目标：形成核心玩法闭环。

任务：

- 实现钥匙和门
- 实现箱子
- 实现按钮
- 实现收集物
- 实现步数统计
- 实现重置关卡
- 实现撤销一步

### Milestone 3：产品界面

目标：从启动到通关完整体验。

任务：

- 主菜单
- 章节选择
- 关卡选择
- 设置页
- 语言切换
- 通关结算
- 存档

### Milestone 4：内容扩展

目标：制作首发内容。

任务：

- 完成 60 个关卡
- 制作章节插画
- 完成美术资源
- 完成音效音乐
- 完成本地化

### Milestone 5：上架准备

目标：准备 App Store 发布。

任务：

- App Icon
- App Store 截图
- 宣传文案
- 隐私政策
- TestFlight 测试
- 崩溃修复
- 性能优化

---

## 16. 风险与规避

### 16.1 关卡不好玩

风险：机制实现了，但谜题缺少乐趣。

规避：

- 先做 10 关试玩
- 找真实玩家测试
- 每关只保留一个明确解法亮点
- 删除拖时间、不聪明的关卡

### 16.2 美术成本过高

风险：豪宅主题需要大量房间资源。

规避：

- 先做统一 tile set
- 章节通过颜色和装饰变化区分
- 不为每关画独立背景

### 16.3 内容量过大

风险：个人开发者难以一次做 100 关。

规避：

- MVP 10 关
- 1.0 做 60 关
- 后续免费更新章节

### 16.4 买断制转化弱

风险：用户不愿意付费下载。

规避：

- App Store 截图必须展示精致画面和无广告无内购
- 价格从 `$1.99` 起步
- 宣传文案强调 premium offline puzzle
- 做短视频展示 10 秒解谜过程

---

## 17. App Store 页面建议

### 17.1 英文标题

`Cat Logic Mansion`

### 17.2 副标题

`Cozy Offline Puzzle Rooms`

### 17.3 关键词方向

```text
cat,puzzle,logic,mansion,offline,cozy,brain,room,maze,box
```

### 17.4 英文短描述

Guide a clever cat through a cozy mansion full of handcrafted logic puzzles. No ads. No in-app purchases. Play offline anytime.

### 17.5 中文短描述

帮助聪明的小猫探索神秘豪宅，解开一个个手工设计的逻辑房间。无广告，无内购，可离线游玩。

---

## 18. 下一步执行建议

当前项目已经完成 10 个 MVP 关卡 JSON、SwiftUI + SpriteKit 可玩原型、核心规则单元测试、关卡结构校验和自动通关解法搜索。下一步不再是创建 Demo，而是把 MVP 从“技术可跑”推进到“关卡可发布”。

建议下一步按以下顺序执行：

1. 使用 `swift run validate-levels` 和 `swift run solve-levels` 作为每次改关卡后的自动门禁。
2. 把第 1 到第 10 关已确认的三星路线和试玩观察沉淀到 QA 记录中。
3. 在模拟器上继续记录真实完成步数、可读性问题、软锁风险和是否需要教程提示。
4. 保持游戏局内无暂停按钮，继续以图标 HUD、关卡选择和重置/撤销形成轻量操作闭环。
5. 继续迭代第一版原创程序化纹理，优先检查猫、地板、墙、出口、箱子、钥匙、按钮、桥、鱼干这批核心资源的可读性。
6. 在第 1 章机制稳定后，再扩展 Chapter 2 的推箱子、按钮、门组合关卡。
