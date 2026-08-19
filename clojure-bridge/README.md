# Godot ↔ Clojure engine bridge

Godot 不重写 2000 张牌。本目录把 [mtgred/netrunner](https://github.com/mtgred/netrunner) 的 JVM 规则引擎挂成 JSON HTTP，Godot 只做客户端。

## 安装到 Jinteki 源码树

```bash
# 默认目标 /home/ubuntu/netrunner
./clojure-bridge/apply.sh
# 或
./clojure-bridge/apply.sh /path/to/netrunner
```

然后重启 `lein run`。Mongo 里需要已经 `lein fetch` 过卡牌。

## 接口（无 CSRF）

| 方法 | 路径 | 作用 |
| --- | --- | --- |
| GET | `/godot/status` | 引擎是否活着、卡牌数量 |
| GET/POST | `/godot/new` | 开一局 System Gateway 入门套牌（自动 Keep + Corp 回合），默认 6 AP |
| GET | `/godot/state?id=` | 精简局面 |
| POST | `/godot/action` | `{"id","command","side","args"}`，command 与 `process-action` 相同 |

`/godot/new` 的 body 可带 `{"agenda_goal": 6}`。

动作例子：

```json
{"id":"…","command":"credit","side":"corp","args":{}}
{"id":"…","command":"play","side":"corp","args":{"card":{"cid":"…"}}}
{"id":"…","command":"run","side":"runner","args":{"server":"R&D"}}
{"id":"…","command":"choice","side":"corp","args":{"choice":{"uuid":"…"}}}
```

返回的 `actions` 是当前建议合法动作，Godot 直接画成按钮。
