# 小鹤飞扬 rime 开源配置

> 小鹤官方网盘提供的rime挂接方案中的主码表和反查码表只提供了编译后的bin
> 
> 用网友反编译的文件替代了, 就算是删掉build目录也不影响重新部署

## 环境

鼠鬚管版本: 0.16.2  
词库版本：10.9.4  
系统: macos 12.7  

10.9.5增加了一简词，并且把"发"从fav改为f1, "非"改为f2, 用不惯

## 引用文件

https://github.com/cubercsl/rime-flypy

http://flypy.ys168.com

## 个性化改动

### `default.custom.yaml`

屏蔽了方案切换, 因为只用到小鹤飞扬. 换方案直接换输出法了, 没必要占用快捷键: 

```yml
  switcher/hotkeys: false
    # - "Control+grave"
    # - F4
```

屏蔽了shift英文切换, 在系统设置shift切换输入法:

```yml
  ascii_composer/good_old_caps_lock: true
  ascii_composer/switch_key:
    Caps_Lock: noop
    Shift_L: noop
    Shift_R: noop
    Control_L: noop
    Control_R: noop
```

屏蔽半角全角切换: 

```yml
    - when: always
      accept: "Shift+space"
      send: "Shift+space"
```

### `flypy.schema.yaml`

屏蔽半角全角切换:

```yaml
#  - {accept: "Shift+space", toggle: full_shape, when: always} #切换全半角
```

### `flypy/flypy.web.dict.yaml`

添加在线反查, 修改入门网址

```yml
https://flypy.cc	orm
http://react.xhup.club/search	ofi
```

### `squirrel.custom.yaml`

屏蔽vscode的西文模式和vim模式

```yaml
patch:
  "app_options":
    com.microsoft.VSCode:
      ascii_mode: false  # 初始爲西文模式
      vim_mode: false    # 退出VIM插入模式自動切換輸入法狀態s
```

### todo

下载到10.9.4版本的widows安装包，尽量统一词库

单字和词库除了错误，不再增添，锁版本。