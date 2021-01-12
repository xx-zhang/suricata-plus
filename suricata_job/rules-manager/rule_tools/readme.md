## 2019-11-25
- 注意规则文件的文本 `rules/ruleclass.config` 文件中,前后不应该出现空格 
- 当前规则的翻译是批量翻译，没有进行逐条文本翻译。主要是初步分裂。
- 注意上面的翻译文件在 `rules/tras_desc.txt` 下，如果修改需要进行更新

## 2019-11-26
- 增加规则集时候，分类标签的统一管理化。
> 如果规则分类中没有当前的这个分类标签, 那么就取others，
如果分类标签不在当前列表, 那么自己增加。

## 2020-4-13
- 加载最新的规则集合

```bash 

git clone https://github.com/suricata-rules/suricata-rules && wget https://rules.emergingthreats.net/open/suricata-5.0/emerging.rules.tar.gz && tar xf emerging.rules.tar.gz && git clone https://github.com/ptresearch/AttackDetection && git clone https://code.aliyun.com/rapidinstant/web-attack-rules.git

# git clone https://github.com/gmctl/rzx-suri-rules 
```