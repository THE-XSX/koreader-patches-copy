# 原始代码：由 Reddit 用户 [hundredpercentcocoa](https://www.reddit.com/user/hundredpercentcocoa/) 创建

# KOReader 阅读摘要与锁屏增强用户补丁 (Book Receipt & Lockscreen Patch)

[中文说明与手把手教程](#-中文说明与手把手教程) | [English Guide](#-english-guide--step-by-step-tutorial)

---

## 🇨🇳 中文说明与手把手教程

本仓库包含并深度维护适用于 KOReader 的全功能阅读摘要补丁 **`2-book-receipt-shortcut-and-lockscreen.lua`**。

该补丁将墨水屏锁屏与画报提升为具有现代美感与艺术排版的 **【阅读摘要卡片 (Book Receipt Card)】**，并支持快捷键/手势一键呼出预览。

---

### ✨ 核心功能亮点

#### 🎨 1. 6 大现代美学排版矩阵
- **瑞士平面网格 (`Swiss Grid`)**：左右双栏对比，黑底白字自适应比例与 100% 贯穿式伸展。
- **极客黑底终端 (`Terminal`)**：全黑背景 + 像素级进度条 + 白字终端极客风。
- **极简金句海报 (`Quote Poster`)**：巨型双引号 + 划线金句展示 + 极简名言排版。
- **复古阅读票根 (`Ticket Stub`)**：票头、裁剪虚线、ADMITTED 盖印感与矢量像素条形码。
- **图书封面优先 (`Cover First`)**：突出高精图书封面，呈现大图优雅排版。
- **日式禅意极简 (`Japanese Zen`)**：圆环百分比 Badge + 日期 + 沉静阅读标语。

#### 🖼️ 2. 【卡片外观装饰】全套自定义控制
- **卡片边框**：支持 **【无边框】/【细边框】/【粗边框】**（默认全局去外层边框）。
- **框内纸质背景色**：支持 **【淡灰色 (默认 238 级纸张质感)】/【柔灰色】/【纯白色】**，与屏外纯白底色形成质感悬浮对比。
- **3D 立体悬浮阴影**：支持一键开启 **`10px` 深灰 3D 悬浮阴影**，赋予卡片逼真的纸张厚重感。

#### 📐 3. 卡片尺寸与全屏渲染自适应
- **默认模式 (Default)**：60% 屏幕宽高，四周留有优雅纯白外留白 (`Outer Margin`)。
- **全屏模式 (Fullscreen)**：100% 屏幕宽 x 100% 屏幕高，瑞士网格上下 100% 贯穿屏高。
- **手动自定义模式 (Custom)**：支持 `30% - 100%` 任意比例自由调节。
- **54px 呼吸感内部安全留白**：在满屏状态下保持 `54px` 内部防护边距，所有文字、章节、引文、进度条与线条绝对不贴靠屏框。

#### ⚡ 4. 矢量条码与底层稳定性保障
- **矢量条码引擎**：自适应卡片宽度的 72%，像素级精准渲染黑白条块，永不出界或模糊。
- **LuaJIT 突破**：重构常量表与作用域，突破 60 Upvalues 编译器硬限制，消除崩溃风险。
- **方向保护**：自动识别屏幕长短边，彻底防止设备休眠时发生 90 度侧翻。

---

### 📖 手把手安装与设置教程

#### 📥 第一步：安装补丁文件
1. 下载补丁文件 [`2-book-receipt-shortcut-and-lockscreen.lua`](file:///c:/Users/14893/Downloads/patches/2-book-receipt-shortcut-and-lockscreen.lua)。
2. 打开阅读器设备的存储目录，找到 KOReader 的 **用户补丁文件夹**（若不存在 `patches` 文件夹请自行新建）：
   - **路径**：`koreader/patches/2-book-receipt-shortcut-and-lockscreen.lua`
3. 将下载的文件复制并粘贴进 `koreader/patches/` 目录。
4. **重启 KOReader**（或在设置中选择重新加载 Lua 脚本）。

---

#### ⚙️ 第二步：找到设置入口与激活方式

补丁支持 **锁屏画报** 与 **快捷弹窗** 两种使用形态（可同时启用）：

##### 途径 A：设置为设备的【休眠锁屏 / 屏保画报】
1. 点击屏幕顶栏，唤出 KOReader **主菜单**。
2. 依次点击导航路径：
   ```text
   顶部主菜单 -> ⚙️ 设置 (Settings) -> 屏保 (Screensaver) -> 壁纸 (Wallpaper)
   ```
3. 在【壁纸】列表中找到并勾选：**【在休眠屏幕显示阅读摘要】(Show book receipt on sleep screen)**。
4. 勾选激活后，其下方会自动解锁并出现专用的设置入口：
   ```text
   👉 【阅读摘要设置】(Book receipt settings)
   ```

##### 途径 B：绑定【手势 / 按键 / 悬浮球】一键快捷预览
1. 点击屏幕顶栏唤出 KOReader **主菜单**。
2. 依次点击导航路径：
   ```text
   顶部主菜单 -> ⚙️ 设置 (Settings) -> 手势 (Gestures) 或 按键 (Key bindings) / Tap Menu
   ```
3. 选择您习惯的触发方式（例如：`双指下滑`、`角落划动`、`物理按键长按` 或 `Tap Menu 悬浮按键`）。
4. 在动作分配列表中找到动作：**【阅读摘要】(Book receipt)** 并保存绑定。
5. 在阅读任何书籍时，只需触发该手势/按键，即可随时弹窗预览当前书本的摘要卡片；**按任意按键或轻触屏幕即可关闭**。

---

#### 🎛️ 第三步：详细调节项与功能参数说明

在 **【⚙️ 设置】->【屏保】->【壁纸】->【阅读摘要设置】** 中，可以针对卡片样式与展示内容进行精细化调节：

#### 1️⃣ 显示风格 (`Style`)
提供 6 种完全不同的现代美学排版主题：
- **瑞士网格 (`Swiss grid`)**：默认推荐。左右双栏对比，贯穿式分隔线，现代设计感最强。
- **黑底终端 (`Terminal`)**：全黑高对比度背景，像素风格进度条，极客终端风。
- **极简金句海报 (`Quote poster`)**：巨型双引号装饰，突出展示本书划线高亮金句。
- **阅读票根 (`Ticket stub`)**：模拟真实小票/电影票根，带剪切虚线、ADMITTED 印章感与矢量像素条形码。
- **封面主导 (`Cover first`)**：大图突出呈现图书封面，适配高质量封面书籍。
- **日式留白 (`Japanese minimal`)**：日式极简风，圆环百分比 Badge + 日期 + 沉静阅读标语。

#### 2️⃣ 卡片尺寸比例 (`Card width mode`)
控制卡片在屏幕上的所占宽度：
- **默认比例 (`Default ratio`)**：60% 屏幕宽度，四周保留优雅的纯白悬浮边距 (`Outer Margin`)。
- **全屏 (`Fullscreen`)**：卡片 100% 满屏贯穿（保持 54px 内部呼吸留白，文字不靠屏框）。
- **手动设置比例 (`Custom ratio`)**：点击后弹出数字输入框，可自由输入 `0.30` 到 `1.00` 之间的比例值（例如输入 `0.65` 或 `65` 即表示 65% 屏幕宽度）。

#### 3️⃣ 卡片外观装饰 (`Card appearance`)
控制卡片的质感与 3D 浮雕效果：
- **卡片外边框 (`Card border`)**：
  - `无边框 (默认)`：去外框极简风格。
  - `细线边框` / `粗线边框`：为悬浮卡片加上清晰轮廓线。
- **框内背景颜色 (`Card background color`)**：
  - `淡灰色 (默认)`：238 级纸张质感，推荐使用，能与屏外的纯白底色形成立体的对比。
  - `纯白色`：框内与框外同为纯白。
  - `浅灰色`：更深的灰色对比。
- **卡片立体阴影 (`Card drop shadow`)**：
  - 勾选 `开启投射阴影` 即可为中央卡片增加 `10px` 柔和深灰 3D 悬浮阴影，营造拟真纸片厚重感。

#### 4️⃣ 屏保背景 (`Background`)
控制整屏屏保的最底层背景：
- **白色背景 (`White fill`)**：默认纯白背景。
- **透明 (`Transparent`)**：保留当前阅读书籍页面为底图。
- **黑色背景 (`Black fill`)**：全黑背景。
- **随机图片 (`Random image`)** / **书籍封面 (`Book cover`)**：以指定图片作为全屏底层图。
- **背景图片显示方式 (`Placement`)**：（仅在选择图片背景时激活）可选择 `适应屏幕` / `拉伸填满` / `居中不缩放`。

#### 5️⃣ 展示信息条目 (`Display items`)
可逐项勾选开启或关闭卡片上展示的细粒度数据组件：
- **书名 (`Book title`)** / **作者 (`Author`)** / **封面 (`Cover`)**
- **当前章节 (`Current chapter`)** / **页码数 (`Page count`)** / **阅读百分比 (`Reading percentage`)** / **进度条 (`Progress bar`)**
- **本章剩余时间 (`Chapter time left`)** / **全书剩余时间 (`Book time left`)**
- **累计阅读时间 (`Total time spent`)** / **今日阅读时间 (`Time spent today`)**
- **电量 (`Battery level`)** / **当前时间 (`Current time`)**
- **高亮划线金句 (`Highlights & annotations`)**：自动调出书籍中最新/随机高亮摘录。
- **自定义屏保消息 (`Custom screensaver message`)**：展示个性化签名或阅读标语。

---

## 🇬🇧 English Guide & Step-by-Step Tutorial

This repository provides **`2-book-receipt-shortcut-and-lockscreen.lua`**, an advanced user patch for KOReader that transforms sleep cover and QuickLook overlays into customizable, aesthetically striking **Book Receipt Cards**.

---

### ✨ Key Features

- **6 Aesthetic Card Styles**: Swiss Grid, Terminal, Quote Poster, Ticket Stub, Cover First, and Japanese Zen.
- **Appearance Decorator Controls**: Card borders (None / Thin / Thick), paper background tones (Light Gray / Soft Gray / Pure White), and 3D paper drop shadows.
- **Card Ratio Modes**: Default (60% floating paper card with outer margins), Fullscreen (100% edge-to-edge coverage), and Custom ratio (30%-100%).
- **54px Inner Breathing Margin**: Prevents text and divider lines from hugging device bezels.
- **Vector Barcode Engine**: Pixel-accurate vector barcode bounded cleanly within 72% card width.
- **LuaJIT & Metamethod Protection**: Optimizes upvalue counts below compiler limits and prevents cdata metamethod crashes.

---

### 📖 Step-by-Step Setup & Configuration Guide

#### 📥 Step 1: Install the Patch
1. Download [`2-book-receipt-shortcut-and-lockscreen.lua`](file:///c:/Users/14893/Downloads/patches/2-book-receipt-shortcut-and-lockscreen.lua).
2. Copy the file into your KOReader user patches directory (create the `patches` folder if it doesn't exist):
   - **Path**: `koreader/patches/2-book-receipt-shortcut-and-lockscreen.lua`
3. Restart KOReader or reload Lua scripts.

---

#### ⚙️ Step 2: Settings Location & Activation Methods

##### Method A: Set as Sleep Screen / Lockscreen Wallpaper
1. Tap the top bar to open KOReader **Main Menu**.
2. Navigate to:
   ```text
   Main Menu -> ⚙️ Settings -> Screensaver -> Wallpaper
   ```
3. Check the option: **【Show book receipt on sleep screen】**.
4. Once checked, the dedicated configuration menu will be unlocked below:
   ```text
   👉 【Book receipt settings】
   ```

##### Method B: Bind Gesture / Key / Tap Menu for Quick Look Overlay
1. Tap the top bar to open KOReader **Main Menu**.
2. Navigate to:
   ```text
   Main Menu -> ⚙️ Settings -> Gestures (or Key bindings / Tap Menu)
   ```
3. Choose your preferred gesture (e.g., Two-finger swipe down, Corner swipe, Key hold).
4. Assign the action: **【Book receipt】**.
5. Trigger your gesture while reading to display the floating card pop-up anytime. Press any key or tap the screen to dismiss.

---

#### 🎛️ Step 3: Detailed Configuration Options

Inside **【Settings】->【Screensaver】->【Wallpaper】->【Book receipt settings】**:

1. **Display Style (`Style`)**:
   - `Swiss grid`: Dual-column layout with strong structural dividers (Default).
   - `Terminal`: Pitch-black high-contrast geek style with pixelated progress bar.
   - `Quote poster`: Giant quote marks focusing on book highlights.
   - `Ticket stub`: Movie/event ticket feel with dashed tear lines and vector barcode.
   - `Cover first`: Emphasizes high-res book covers.
   - `Japanese minimal`: Zen style with circle percentage badge and reading motto.
2. **Card Width Mode (`Card width mode`)**:
   - `Default ratio`: 60% floating paper width with outer white margins.
   - `Fullscreen`: 100% screen width and height.
   - `Custom ratio`: Input numbers from `0.30` to `1.00` (e.g., `0.65` for 65% width).
3. **Card Appearance (`Card appearance`)**:
   - `Card border`: None (Default) / Thin / Thick.
   - `Card background color`: Light gray (Default 238 paper texture) / Pure white / Soft gray.
   - `Card drop shadow`: Toggle `Enable drop shadow` for realistic 3D paper drop shadow.
4. **Background (`Background`)**:
   - Choose screen background fill: `White fill`, `Transparent`, `Black fill`, `Random image`, or `Book cover`.
5. **Display Items (`Display items`)**:
   - Granularly toggle items: Title, Author, Cover, Chapter, Page Count, Percentage, Progress Bar, Time Left, Total/Today Reading Time, Battery, Clock, Highlights, and Custom Message.