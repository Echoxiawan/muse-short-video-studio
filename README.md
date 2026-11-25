# Muse Short Video Studio

把四个开源 Muse 视频 skill 取长补短后，整合成的一个总 skill。共享出片约束和路由，下面挂四种可选模式；按模式选用提示词、连续性方法和执行后端，不要擅自接成一条从头跑到尾的超级管线。

技能文件：[`SKILL.md`](./SKILL.md)

## 四种模式

先确认要做什么，只选一种主模式；出片前可以先跑策划模式。

| 模式 | 适用 | 核心做法 |
| --- | --- | --- |
| A 前期策划 | 只要脚本、分镜、美术和声音方向，先不生成 | 按需加载导演等角色，产出策划包；字幕与画面提示词解耦；本阶段不发起付费请求 |
| B 电影感短片 | 实拍感短片、提示词实验、多段拼长片 | 带时间轴的实战模板；按约 10 秒拆段，用续接快照顺序生成，再无损拼接 |
| C 动画短片 / IP 故事 | 需要角色连贯和场次衔接的动画或剧情 | 先锁画幅和 Story Bible；Match Cut（上一场末帧 = 下一场首帧，且必须是同一文件）；mega prompt：FIRST FRAME / MOTION / CAMERA / LAST FRAME / SOUND / MUSIC / VO |
| D 执行后端（默认关闭） | 照片说话、旧照修复上色、视频换人、无脸旁白短片 | 必须先确认执行通道；第三方 API、订阅和额度都要先征得同意再调用 |

商业广告或品牌大片：先 A 再 B。需要人物连续的动画或剧情片，不要用模式 D 的「最多几场并行拼接」。

## 共同硬规则

- 单段按约 10 秒上限规划；更长的必须拆段再拼接。
- 开始前先锁定画幅、成片语言和大致片长；提示词里写清精确比例。
- 提示词先交给用户定稿，再按定稿原文送去生成。
- 不承诺锁脸或人物全程同一人。续接快照、参考图、角色表只能提高延续的概率。
- 密钥和 token 只走环境变量或密钥库，不写入仓库或聊天。
- 付费、第三方 API、周额度必须先说明并得到同意再用。可能已经扣费的任务禁止自动重提。
- 上传或本地文件名使用 ASCII，避免非 ASCII 文件名被上游拒绝。
- 不要把某一种口音、某一家动画厂画风、某一个第三方模型或某条内部命令路径写成全局默认。

## 使用方法

把本仓库的 `SKILL.md` 放到你的 agent 技能目录中即可，例如：

```text
.cursor/skills/muse-short-video-studio/SKILL.md
```

或在支持技能库的助手里安装 / 导入同名 skill。agent 会先按模式路由，再执行对应流程。

第三方执行通道（例如通过 useapi.net 调用用户自己的 Muse 订阅）默认关闭，不是安装后就会自动调用。

## 不是什么

- 不是 Meta 官方 skill，也不绑定某一个付费视频接口。
- 模式 A 里的「Muse」在源项目中指缪斯 / 灵感，不是专供 Meta Muse 出片。
- 不保证人物身份锁定；需要强锁脸时，应改走用户指定、更适合参考图锁脸的下游模型，或停下说明限制。

## 来源与致谢

流程借鉴自以下 MIT 许可的开源项目，整合时保留原作者声明：

- [masonmosen/muse-video-prompt-skill](https://github.com/masonmosen/muse-video-prompt-skill)（Mason Mosen）：Muse 内置视频的提示词与成片闭环
- [sonlovinbot-team/Muse-animated-short-film](https://github.com/sonlovinbot-team/Muse-animated-short-film)（Đặng Hữu Sơn / sonlovinbot）：动画短片的角色表、剧本、首尾帧衔接与合成
- [LuoJiangYong/muse-video-skill](https://github.com/LuoJiangYong/muse-video-skill)（Jiang Yong Luo）：前期策划引擎
- [useapi/muse-api](https://github.com/useapi/muse-api) 的 `muse-video` skill（useapi.net）：第三方执行层，非 Meta 官方接口

第三方 API 的使用条款与收费以该服务当时规则为准，MIT 许可不覆盖其服务本身。

## 许可

本仓库以 [MIT License](./LICENSE) 发布。
