# 小鹤飞扬 rime 开源配置

> 小鹤官方网盘提供的rime挂接方案中的主码表和反查码表只提供了编译后的bin
> 
> 用网友反编译的文件替代了, 就算是删掉build目录也不影响重新部署

## 环境

鼠鬚管版本: 0.16.2  
词库版本：10.6.4  
系统: macos 12.7  

10.6.5 之后增加了一简词, 感觉没必要更新了.

## 引用文件

https://github.com/cubercsl/rime-flypy

http://flypy.ys168.com

## 改动地方

1. `default.custom.yaml`: 

屏蔽了方案切换, 因为只用到小鹤飞扬. 换方案直接换输出法了, 没必要占用快捷键.

屏蔽半角全角切换

```yml
patch:
  schema_list:
    - schema: flypy # 添加小鹤音形
    - schema: flypydz # 添加反查码表
  switcher/hotkeys: false # 定製喚出方案選單的快捷鍵, 默认是ctrl + `或者f4
    # - "Control+grave"  # 你看寫法並不是 Ctrl+` 而是與 IBus 一致的表示法
    # - F4

  key_binder/bindings:
    - when: always
    accept: "Shift+space"
    send: "Shift+space"

```

2. `flypy.schema.yaml`: 

默认英文符号

屏蔽半角全角切换

```yaml
- name: ascii_punct # 中英文符号
# states: [ 。，, ．， ]
reset: 1

#  - {accept: "Shift+space", toggle: full_shape, when: always} #切换全半角
```

3. `flypy_sys.txt`:

添加在线反查, 修改入门网址

```yaml
https://flypy.cc	orm
http://react.xhup.club/search	ofi
```

4. `squirrel.custom.yaml`:

屏蔽vscode的西文模式和vim模式

```yaml
patch:
  "app_options":
    com.microsoft.VSCode:
      ascii_mode: false  # 初始爲西文模式
      vim_mode: false    # 退出VIM插入模式自動切換輸入法狀態s
```

5. `flypy_extra.txt`

从多多版`10.9y`中导出的表外字,需要启用的话放到目录外重新部署
