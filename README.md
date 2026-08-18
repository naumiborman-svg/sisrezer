# 坦克大战

用 Godot 4.7 做的接近 NES《Battle City》(1985) 的坦克大战。

关卡数据来自 [feichao93/battle-city](https://github.com/feichao93/battle-city) 的 35 张原作地图与敌军队列。

## 运行

本机已安装 `godot` 时：

```bash
godot --path .
```

或在 Godot 编辑器中打开本仓库。

## 操作

- **WASD / 方向键**：移动
- **空格 / J**：开火
- **Enter**：开始 / 结束后返回标题
- **P / Esc**：暂停

## 规则（接近原作）

- 保护底部老鹰基地，消灭本关 20 辆敌军
- 共 35 关；战场最多同时 4 辆敌坦克
- 敌军四种：普通 / 快速 / 火力 / 装甲（装甲 4 血）
- 第 4、11、18 辆敌坦克闪光，被击中后掉落道具（场上只留一个）
- 道具：生命、星星、手榴弹、时钟、头盔、铲子
- 玩家星星 0–3：更快炮弹 → 双发 → 可打穿钢墙
- 砖墙可打碎；钢墙需 3 星；水不能过；冰面会滑；草丛遮挡
- 死亡后星星清零并重生；每 20000 分加一条命
- 基地被毁或生命耗尽则失败

## 开发

```bash
godot --headless --path . --import --quit
godot --headless --path . -s res://tests/smoke.gd
godot --headless --path . -s res://tests/rules.gd
```
