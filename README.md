# Jinteki (Godot)

[mtgred/netrunner](https://github.com/mtgred/netrunner) 的 Godot 4.7 移植：System Gateway **Beginner** 教学套牌，打到 **6** 议程分。

卡牌数据与卡图来自 Jinteki 使用的 [NoahTheDuke/netrunner-data](https://github.com/NoahTheDuke/netrunner-data) / NetrunnerDB；规则是可玩的核心循环，不是 2000+ 张牌的完整 Clojure 引擎。

## 运行

```bash
godot --path .
```

标题界面：

- **Play as Runner** — 你操控 Runner，AI 操控 Corp
- **Play as Corp** — 相反
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
```
