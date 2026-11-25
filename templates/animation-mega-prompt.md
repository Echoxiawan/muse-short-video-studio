# 动画 mega prompt 模板（模式 C）

每场一份，复制后即可交给已定稿的生成步骤。字段名保持英文，便于模型按块读取：`FIRST FRAME` / `MOTION` / `CAMERA` / `LAST FRAME` / `SOUND` / `MUSIC` / `VO`。

画幅、风格锁定、角色锁定原文贴在每场开头。参考图加载顺序：**角色表 → 首帧 → 尾帧**，然后才是这段文本。

## 全局锁定（每场开头都贴）

按项目替换方括号，不要填入任何默认片厂风格。

```
[Style lock written in the project's chosen art style],
in exactly [16:9 landscape 1280x720 | 9:16 vertical 720x1280] aspect ratio,
no text, no watermark.
STRICT ASPECT RATIO LOCK: the output MUST be exactly [16:9 | 9:16] — the same
ratio locked in project intake. All attached references already share this
ratio; never introduce a mismatched one.
[Character lock: paste verbatim from the story bible for every character in this scene]
Keep every character exactly on-model with the attached sheets in all frames.
```

## 单场模板

```
[把上面的全局锁定整段贴在这里]

FIRST FRAME: [与本场首关键帧一致的画面描述；注明关键帧文件名，例如 k2-dock-lantern.webp]

MOTION: [按时间顺序写清动作，每一步都要符合现实物理。写清谁做了什么、物体如何响应。不要写做不到的动作。]

CAMERA: [推、拉、移、跟、环绕、升降等；写清起幅与落幅。禁止的运镜也写上。]

LAST FRAME: match [本场尾关键帧文件名]. [与该文件一致的画面描述。若存在下一场，该文件必须同时是下一场的 FIRST FRAME。]

SOUND: [环境声与拟音，具体到可听见的物件：脚步、布料、雨、火焰劈啪等]

MUSIC: [本场音乐如何进入、加强或退出；高潮场可写 music recedes / silence]

VO (narrator): "[故事圣经中本场的旁白原文，1–2 句。高潮场可省略本行]"
```

## MOTION 现实性检查

写完后逐个动词自问「现实里能这样发生吗？」：

- 要点燃有玻璃罩的灯：先打开罩门或侧窗，再把火靠近灯芯，再关上门。不要「隔着玻璃点燃」。
- 风要吹灭火：写清风如何进入（撕开纸罩、晃动灯架、从开口灌入），火焰如何摇晃再熄灭。
- 角色拿起或推开物体：先接触，再施力，再看到物体移动。
- 液体、火焰、布料、玻璃按常识运动，不要穿越固体。

任一动词不成立，就改写 `MOTION`，不要寄希望于模型「意会」。

## 提交前核对

- [ ] 七个字段齐全（无旁白的场可删 `VO`，但不要留空话）
- [ ] 全局锁定含画幅和角色原文
- [ ] `FIRST FRAME` / `LAST FRAME` 写了真实文件名，且跨场共用同一文件
- [ ] `MOTION` 已做现实性检查
- [ ] 用户已定稿，将按原文提交

---
改编说明：mega prompt 的七段结构、全局锁定与参考图顺序，改编自 Đặng Hữu Sơn（sonlovinbot）的动画提示词规范（MIT），并去掉默认片厂风格。
