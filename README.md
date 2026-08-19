# Chiriboga（Godot 复刻）

[chiriboga.cronbach.com](https://chiriboga.cronbach.com) 的 Godot 4.7 客户端。规则权威是 **Chiriboga JS 引擎**（bobtheuberfish + DrBo6 Solo Mode），Godot 只做 CRT 菜单和桌面。

启动：

```bash
./chiriboga-bridge/start.sh    # Node + jsdom，默认 http://127.0.0.1:1043
godot --path .
```

标题菜单对齐原站：QUICK GAME、CUSTOM GAME、GAUNTLET、TUTORIAL 1–8、ACHIEVEMENTS、SETTINGS、CREDITS。卡组来自 `chiriboga-engine/precons/`。

引擎 GPL-3.0，源码在 `chiriboga-engine/`。卡图为 NSG CC BY-ND。

---

# Jinteki (Godot)

[mtgred/netrunner](https://github.com/mtgred/netrunner) 的 Godot 4.7 客户端（标题里 **LEGACY JINTEKI**）。两条规则路径：

1. **离线 GDScript**：System Gateway **Beginner** 教学套牌，打到 **6** 议程分。卡图来自 [NoahTheDuke/netrunner-data](https://github.com/NoahTheDuke/netrunner-data) / NetrunnerDB。这是可玩的核心循环，不是 2000+ 张牌的完整规则。
2. **完整 Clojure 引擎**：本机跑 Jinteki（`lein run`，默认 `http://127.0.0.1:1042`）。Godot 通过 `/godot/*` JSON 桥把每一条动作交给 JVM 上的 `process-action`。卡牌效果以 Clojure 源码为准。

桥接补丁在 `clojure-bridge/`，用 `./clojure-bridge/apply.sh` 装进 mtgred/netrunner 源码树后重启服务器。

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

标题界面：

- **对战强力 AI · Runner / Corp** — 离线 GDScript 规则，对手用多步搜索
- **观看强力 AI 对战** / **Hotseat** — 同样是离线教学引擎
- **完整 Clojure 引擎 · Runner / Corp** — 连本机 Jinteki，规则走 2000+ 张牌的 JVM 引擎
- **观看 Clojure 引擎** / **Clojure Hotseat** — 同一套 HTTP 桥

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
godot --headless --path . -s res://tests/clojure_bridge.gd   # 无 Jinteki 时打印 SKIP
godot --headless --path . -s res://tests/chiriboga_bridge.gd  # 无 Chiriboga host 时打印 SKIP
```
