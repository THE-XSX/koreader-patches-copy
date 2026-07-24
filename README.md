# KOReader 阅读摘要与锁屏增强用户补丁 (Book Receipt & Lockscreen Patch)

[中文说明](#-中文说明) | [English Description](#-english-description)

---

## 🇨🇳 中文说明

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

### 📥 安装与使用方法

1. 下载仓库中的 [`2-book-receipt-shortcut-and-lockscreen.lua`](file:///c:/Users/14893/Downloads/patches/2-book-receipt-shortcut-and-lockscreen.lua)。
2. 将脚本文件复制到您设备中 KOReader 的用户补丁目录下：
   - 路径通常为：`koreader/patches/2-book-receipt-shortcut-and-lockscreen.lua`
3. 重启 KOReader。
4. 在 KOReader 的顶部菜单或设置中，即可看到 **【Book Receipt】** 及其外观设置选项；也可在手势/按键设置中绑定一键唤出阅读摘要卡片。

---

## 🇬🇧 English Description

This repository provides **`2-book-receipt-shortcut-and-lockscreen.lua`**, an advanced user patch for KOReader that transforms sleep cover and QuickLook overlays into stunning, customizable **Book Receipt Cards**.

---

### ✨ Key Features

- **6 Aesthetic Card Styles**: Swiss Grid, Terminal, Quote Poster, Ticket Stub, Cover First, and Japanese Zen.
- **Appearance Decorator Controls**: Card borders (None / Thin / Thick), paper background tones (Light Gray / Soft Gray / Pure White), and 3D paper drop shadows.
- **Card Ratio Modes**: Default (60% floating paper card with outer white margins), Fullscreen (100% edge-to-edge coverage), and Custom ratio (30%-100%).
- **54px Inner Breathing Margin**: Prevents text and divider lines from hugging device bezels.
- **Vector Barcode Engine**: Pixel-accurate vector barcode bounded cleanly within 72% card width.
- **LuaJIT & Metamethod Protection**: Optimizes upvalue counts below compiler limits and prevents cdata metamethod crashes.

---

### 📥 Installation

1. Copy `2-book-receipt-shortcut-and-lockscreen.lua` into your KOReader patches directory (`koreader/patches/`).
2. Restart KOReader to load the patch.
3. Access configuration submenus or assign a gesture shortcut to display the Book Receipt card anytime.