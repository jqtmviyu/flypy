# 小鹤飞扬 rime 开源配置

> 小鹤官方网盘提供的rime挂接方案中的主码表和反查码表只提供了编译后的bin
> 
> 用网友反编译的文件替代了, 就算是删掉build目录也不影响重新部署

## 环境

鼠鬚管版本: 0.16.2  
词库版本：10.9.z  
系统: macos 12.7  

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
[入门]	orm
http://react.xhup.club/search	ofi
[反查]	ofi
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

### `flypy.dict.yaml`

开启了二重简码, 关闭了一码词.

如果是windows系统想统一词库, 则下载10.9.z版本(没找到,只保留了10.9.y), 打开设置里的码表, 清空自带的用户词库(对应的一码词)