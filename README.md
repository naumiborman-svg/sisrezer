# Jinteki (Godot)

[mtgred/netrunner](https://github.com/mtgred/netrunner) 的 Godot 4.7 移植：System Gateway **Beginner** 教学套牌，打到 **6** 议程分。

卡牌数据与卡图来自 Jinteki 使用的 [NoahTheDuke/netrunner-data](https://github.com/NoahTheDuke/netrunner-data) / NetrunnerDB；规则是可玩的核心循环，不是 2000+ 张牌的完整 Clojure 引擎。

## 运行

```bash
godot --path .
```

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

- **对战强力 AI · Runner / Corp** — 对手用多步搜索 + 局面评估
- **观看强力 AI 对战** — 双方都是强力 AI
- **Hotseat** — 双方轮流点动作

右侧按钮是当前合法动作（点击、打出、安装、推进、打分、run、破冰……）。

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
```
