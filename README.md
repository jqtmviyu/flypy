# 小鹤音形 rime 配置

1. 基于官方 `10.9c` 提取的码表, 利用ai生成配置和反查码表
2. 小鹤网盘提供的rime挂接方案是编译后的bin, 不小心删除build目录会导致异常
3. 码表锁定在 **10.9.c**, 不再更新, 10.9z把"发"从f2改为f1, "非"改为f2, 10.9.4 之后加了一简词, 用不惯

## 使用与部署

将配置文件放入 Rime 用户配置目录，然后部署

| 平台 | 前端 | 配置记录版本 |
|---|---|---|
| macOS | 鼠须管 Squirrel | 0.16.2 |
| Windows | 小狼毫 Weasel | 0.17.4|
| Linux | fcitx5-rime | arch |

lua 脚本需要前端包含 librime-lua。打开本地 CHM 帮助需要系统关联 CHM 阅读器；Linux 剪贴板反查使用 `wl-paste` 或 `xclip`。

## 文件结构

| 文件或目录 | 用途 |
|---|---|
| `default.custom.yaml` | 方案列表、Shift/Caps 行为、方案切换热键 |
| `flypy.schema.yaml` | 主方案，引擎、按键、Lua 和简繁转换 |
| `flypy.dict.yaml` | 正式词库汇总，控制子词库导入顺序 |
| `flypy/` | 正式使用的分组词库与用户词库 |
| `flypydz.schema.yaml` | 缺码通配反查方案，供主方案依赖 |
| `flypydz.dict.yaml` | 单字反查码表 |
| `lua/flypy_direct_translator.lua` | 日期时间、状态开关、网页与目录打开、搜索、剪贴板反查 |
| `lua/flypy_symbols_translator.lua` | 符号分类菜单与编码跳转 |
| `lua/flypy_poem_translator.lua` | 带换行的《蜀道难》全文 |
| `lua/calculator_translator.lua` | `=` 引导的计算器 |
| `squirrel.custom.yaml` | macOS 外观与应用选项 |
| `weasel.custom.yaml` | Windows 外观 |
| `flypy_help.chm` | 本地帮助文档 |

### 添加个人词条

| 文件 | 同码时的位置 |
|---|---|
| `flypy/flypy.user.top.dict.yaml` | 在基础词库之前 |
| `flypy/flypy.user.dict.yaml` | 在基础词库之后 |

## 输入与按键

| 按键 | 行为 |
|---|---|
| `[` / `]` | 候选翻页 |
| `;` | 有候选时选择次选；也用作快符引导键 |
| `Tab` | 组字时取消输入 |
| 右 Shift | 主方案中绑定为组字时取消输入 |
| `Ctrl+.` | 切换中英标点 |
| `Ctrl+,` | 切换简繁，繁体使用 `s2tw.json` |
| `;f` | 重复最近一次上屏内容 |

### 个人偏好定制

* 屏蔽了方案切换, 因为只用到小鹤飞扬

```yaml
# default.custom.yaml
# 原
switcher/hotkeys:
   - "Control+grave"
   - F4

# 现
switcher/hotkeys: []
```

* macos平台屏蔽了shift切换中英文, 用Karabiner实现shift切换中英输入法

```yaml
# default.custom.yaml
ascii_composer/switch_key:
  Caps_Lock: noop
  Shift_L: noop   # noop: 关闭shift中文切换;commit_code 开启
  Shift_R: noop
  Control_L: noop
  Control_R: noop
```

* 屏蔽了半角全角切换, 经常误触

```yaml
# flypy.schema.yaml
#  - {accept: "Shift+space", toggle: full_shape, when: always} #切换全半角
```

* 简繁体切换快捷键从 `Control+j` 改成 `Control+comma`，因为 Ctrl+J 常被 tui agent 当换行

```yaml
# flypy.schema.yaml
# - { accept: "Control+j", toggle: simplification, when: always }
- { accept: "Control+comma", toggle: simplification, when: always }
```

* 默认使用英文符号, 编程时英文符号用的多

```yaml
# flypy.schema.yaml
# 原本是0
  - name: ascii_punct
    states: [。，, ．，]
    reset: 1
```

* 屏蔽 VSCode 的西文模式和 vim 模式

```yaml
# squirrel.custom.yaml
"app_options":
  com.microsoft.VSCode:
    ascii_mode: false
    vim_mode: false
```

## 直通功能

| 编码 | 功能或输出示例 |
|---|---|
| `orq` | `2026年10月30日`、`2026-10-30` |
| `ouj` | `9:08 星期五`、`9点08分`、纯数字 Unix 时间戳（秒） |
| `orm` | 打开 `flypy_help.chm` |
| `oav` | 打开当前 Rime 用户配置目录 |
| `oss` | 用最近一次上屏文本进行必应搜索 |
| `ofi` | 读取剪贴板文字，在候选注释中显示单字编码 |
| `ovy` | 切换中英标点 |
| `oqb` | 切换全半角 |
| `ojf` | 切换简繁 |
| `oqm` | 切换全码字 |
| `oei` | 切换二重简码 |
| `xhgw` | 打开小鹤官网 `https://flypy.cc` |
| `xhwp` | 打开小鹤网盘 `https://flypy.ysepan.com` |
| `xhrm` | 打开在线帮助 `https://flypy.cc/help/#/` |
| `udnj` | 确认诗名候选后，输出带换行的《蜀道难》全文 |
| `=1+1` | 计算器，输出 `1+1=2` |
