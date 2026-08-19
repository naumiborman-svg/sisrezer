# Chiriboga（Godot 复刻）

[chiriboga.cronbach.com](https://chiriboga.cronbach.com) 的 Godot 4.7 客户端。菜单和教程对齐原站 **DrBo6 Solo Mode**（`drbo6/chiriboga`）。规则权威是 vendored 的 JS 引擎（`chiriboga-engine/`，749 张已实现卡牌）和可选的 [mtgred/netrunner](https://github.com/mtgred/netrunner) Clojure 引擎（`lein run` :1042，2065 张牌）。Gauntlet 的商店 / hack / perks 由 Node host 按 `gauntletConfig` 驱动，对局仍进 Chiriboga JS。

启动：

```bash
./clojure-bridge/apply.sh /path/to/mtgred-netrunner   # 然后在该目录 lein run → :1042
./chiriboga-bridge/start.sh    # Node + jsdom，默认 http://127.0.0.1:1043
godot --path .
```

标题菜单对齐原站：QUICK GAME、CUSTOM GAME、GAUNTLET（Aesop 商店 / hack / fight）、TUTORIAL 1–8、ACHIEVEMENTS、SETTINGS、CREDITS。Jinteki 活着时 Quick/Custom/教程 7–8 用官方预组（`jinteki.preconstructed`，2065 张牌）；Gauntlet 和教程 1–6 用 `chiriboga-engine/`。

引擎 GPL-3.0，源码在 `chiriboga-engine/`。卡图为 NSG CC BY-ND。

## Solo Mode 覆盖（相对 drbo6/chiriboga 实测规模）

| 层 | 仓库规模 | Godot 复刻怎么跑 |
| --- | --- | --- |
| 规则引擎 | `phase.js` 2147 · `mechanics.js` 2012 · `runcalculator.js` 1414 · `checks.js` 568 · `utility.js` 4273（~10.4k） | 原文件在 `chiriboga-engine/`，Node+jsdom host `:1043` 执行，不重写成 GDScript |
| AI | `ai_corp.js` 3409 · `ai_runner.js` 2890（6.3k） | 同上，对局里 Corp/Runner AI 仍是原脚本 |
| 渲染 | `cardrenderer.js` 2494 · `particlesystems.js` 430（不含 pixi） | Headless dummy Pixi；Godot CRT 画文字局面，不移植 Pixi |
| 交互 | `command.js` 1041 · `init.js` 2634 · `decks.js` 958 · `config.js` 437（~5k） | Host 调 `Init` / `ExecuteChosen`；Godot 按钮映射 `command` |
| PHP Solo Mode | `index.php` 2525 · `engine.php` 684 · `decklauncher.php` 2429 · `gauntlet.php` 4956（10.6k） | 菜单对齐 `index.php`；perk 应用从 `engine.php` 抽到 `chiriboga-bridge/gauntlet-perks.js`；Gauntlet 商店/hack/fight 在 `gauntlet-hub.js`（`gauntletConfig`）；完整可视化组卡器仍只在 `decklauncher.php` |
| 样式 | `style.css` 3.8k | Godot CRT 主题，不加载该 CSS |
| 卡牌数据 | `sets/` 13 文件 ~940KB；引擎实现 **749** 张（NSG 全池元数据 2394；Jinteki 导出 2065） | 13 个 set 文件原样加载；`carddata.json` 749 |
| 预组 | `precons/` 71 套 ~3k 行 | Host catalog 暴露全部 71 套 |

Godot 客户端本身是 CRT 壳：`chiriboga_title.gd` / `chiriboga_board.gd` / `chiriboga_client.gd`。规则和 AI 不在 GDScript 里重写。

---

# Jinteki (Godot)

[mtgred/netrunner](https://github.com/mtgred/netrunner) 的 Godot 4.7 客户端（标题里 **LEGACY JINTEKI**）。两条规则路径：

1. **离线 GDScript**：System Gateway **Beginner** 教学套牌，打到 **6** 议程分。卡图来自 [NoahTheDuke/netrunner-data](https://github.com/NoahTheDuke/netrunner-data) / NetrunnerDB。这是可玩的核心循环，不是 2000+ 张牌的完整规则。
2. **完整 Clojure 引擎**：本机跑 Jinteki（`lein run`，默认 `http://127.0.0.1:1042`）。Godot 通过 `/godot/*` JSON 桥把每一条动作交给 JVM 上的 `process-action`。卡牌效果以 Clojure 源码为准。

桥接补丁在 `clojure-bridge/`，用 `./clojure-bridge/apply.sh` 装进 mtgred/netrunner 源码树后重启服务器。

Quick / Custom / Tutorial 7–8 在 Jinteki 活着时走 **mtgred/netrunner**（2065 张牌、官方预组对阵）。Tutorial 1–6 和 Gauntlet（含商店 / hack / perks）仍用 Chiriboga JS。

## 运行要求

| 项 | 要求 |
| --- | --- |
| 引擎 | **Godot 4.7.x 标准版**（`config_version=5`，features `4.7`）。不要用 Godot 3，不要用 .NET / Mono 版 |
| 渲染 | Compatibility（`gl_compatibility`），不需要 Vulkan / Forward+ 独显 |
| 窗口 | 1280×720 起，可拉伸 |
| 系统 | Windows 10+、Linux x86_64，或 macOS 11+（Apple Silicon）/ 10.15+（Intel） |
| 磁盘 | 工程包约 18 MB；macOS 应用包约 68 MB；再留几十 MB 给 `.godot` 导入缓存 |
| 网络 | 离线 GDScript 模式不需要。完整 Clojure 模式需要本机 Jinteki（`http://127.0.0.1:1042`） |
| 其它 | 离线模式不需要 Java。Clojure 模式需要 Java 21、Leiningen、Mongo，以及已经 `lein fetch` 的卡牌库 |

三种打开方式：

```bash
# 1) 工程目录（编辑器 Import project.godot 后）
godot --path /解压后的目录

# 2) 资源包（同一份 4.7 标准编辑器）
godot --main-pack Jinteki.pck

# 3) macOS：双击 Jinteki.app（若被拦截：xattr -cr Jinteki.app）
```

本仓库里直接跑：`godot --path .`。重新导出需要本机已安装 **4.7.1 export templates**（含 `macos.zip`）。

## Godot 4 工程包（编辑器可载入）

用 **Godot 4.7**（标准版，非 Mono）打开：

1. 解压 `Jinteki-godot4-project.zip`
2. Godot → **Import**，选里面的 `project.godot`
3. 或：`godot --path /解压后的目录`

同版本编辑器也可直接载入导出包：

```bash
godot --main-pack Jinteki.pck
```

重新打包：

```bash
./scripts/export_godot4.sh
```

## macOS 下载包

Intel 和 Apple Silicon 通用 zip（未公证，Gatekeeper 会拦一次）：

```bash
# 本机有 Godot 4.7.1 导出模板时
./scripts/export_macos.sh
```

在 Mac 上：

1. 解压 `Jinteki-macos-universal.zip`
2. 若提示无法打开：在终端执行 `xattr -cr Jinteki.app`，或右键 **打开**
3. 双击 `Jinteki.app`

标题界面（Chiriboga 里 **LEGACY JINTEKI**，或直接开 `res://scenes/title.tscn`）：

- **PLAY** — 官方预组（Gateway / Worlds / Classique，来自 `jinteki.preconstructed`）
- **CARDS** — 2065 张牌浏览器（`data/jinteki/cards.json`，从 mtgred `data/cards.edn` 导出）
- **Play full Clojure engine** — 连本机 `lein run` :1042，规则走 `process-action`
- **Play Godot engine** — 同一套官方套牌在 GDScript 里打（费用 / 冰强度 / Gain credits / End the run 等印字效果；身份和复杂能力仍以 Clojure 为准）
- **Offline beginner** — 原来的 System Gateway 教学 AI

重新导出牌库：

```bash
python3 scripts/export_jinteki_data.py /path/to/netrunner data/jinteki
```

右侧按钮是当前合法动作。Clojure 模式的动作列表由服务器的 `actions` 字段给出。

完整引擎启动：

```bash
./clojure-bridge/apply.sh /path/to/netrunner
# 在 netrunner 目录：lein fetch && lein run
# Godot 默认连 http://127.0.0.1:1042 ，可用环境变量 JINTEKI_URL 覆盖
```

## 已实现

- 起始 5 信用、Corp 3 点击、Runner 4 点击、起始手牌 5、Corp 强制抽 1
- 基本动作、安装 / 激活 / 推进 / 打分
- Run：接近冰、激活、遭遇、破冰（Cleaver / Unity / Carmen / Mayfly）、subroutine、成功接触
- 偷议程、R&D 抽空 Runner 胜、净伤害闷杀 Corp 胜
- System Gateway 入门套牌里的经济、冰、破冰与议程效果

## 测试

```bash
godot --headless --path . --import --quit
godot --headless --path . -s res://tests/smoke.gd
godot --headless --path . -s res://tests/rules.gd
godot --headless --path . -s res://tests/ai_battle.gd
godot --headless --path . -s res://tests/jinteki_godot.gd
godot --headless --path . -s res://tests/clojure_bridge.gd   # 无 Jinteki 时打印 SKIP
godot --headless --path . -s res://tests/chiriboga_bridge.gd  # 无 Chiriboga host 时打印 SKIP
```
