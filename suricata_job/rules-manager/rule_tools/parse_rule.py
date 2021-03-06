# coding:utf-8
import re
import os
from datetime import datetime, date
try:
    from .xlog import logging
except:
    import logging

Orgs = ['ET', 'GPL', 'TGI']


def parse_msg(full_msg):
    """
    将完整的规则消息;转化成能够使用的能够翻译的内容。 https://github.com/gmctl/suricata-et-rules-cn
    :param full_msg: 包含的是规则头部和规则选项。 pass、drop、reject、alert
    :return: slug, msg
    """
    matchd_org = re.match( '((' + '|'.join(Orgs) + ')\s+([0-9A-Z_]+))\s+(.*)', full_msg)
    if matchd_org:
        slug, msg = matchd_org.group(1), matchd_org.group(4)
        return slug, msg 
    
    matchd_thirty = re.match('([_0-9A-Z]+) (.*)', full_msg)
    if matchd_thirty:
        slug, msg = matchd_thirty.group(1), matchd_thirty.group(2) 
    else:
        slug, msg = 'TSC', full_msg
    return slug, msg 


def parse_rule_line(rule_line, detail=False):
    """
    将规则行生成为需要的内容和字段。 https://blog.csdn.net/whatday/article/details/85112763
    :param rule_line: 包含的是规则头部和规则选项。 pass、drop、reject、alert
    :return: msg, rev, sid, gid, classtype, reference, priority, metadata
    # TODO 告警消息, 版本, 组名, 类别, 相关信息, 优先级, 兼容suricata的字段
    """
    rule_lined = re.match("^(alert|log|pass|drop|reject)\s+(\w+).*?\((.*)\)", rule_line)
    if rule_lined:
        # 动作, 协议; action, protocol
        _tmp_dict = dict(
            action=rule_lined.group(1),
            protocol=rule_lined.group(2)
        )
        _patched = rule_lined.group(3)
        rule_options = re.findall("(\w+)\:(.*?);", _patched)
        for k, v in rule_options:
            _tmp_dict[k] = _tmp_dict[k] + "," + v if k in _tmp_dict.keys() else v
        if detail:
            _tmp_dict['rule_line'] = rule_line
        # TODO 2019-11-26 规则清洗增加
        created_at, updated_at = datetime.now().date(), datetime.now().date()
        created_at_matched = re.match('.*?created_at\s+(\d+)_(\d+)_(\d+).*?', rule_line)
        updated_at_matched = re.match('.*?updated_at\s+(\d+)_(\d+)_(\d+).*?', rule_line)
        if created_at_matched:
            created_at = date(*[int(created_at_matched.group(i+1)) for i in range(3)])
        if updated_at_matched:
            # print([int(updated_at_matched.group(i+1)) for i in range(3)])
            updated_at = date(*[int(updated_at_matched.group(i+1)) for i in range(3)])
        _tmp_dict['created_at'] = str(created_at)
        _tmp_dict['updated_at'] = str(updated_at)

        # TODO 修复两个BUG; 一个是可能存在前面有空格的，一个是存在可能没有写类别的。
        if "classtype" not in _tmp_dict.keys():
            _tmp_dict["classtype"] = "common-test"
        else:
            _tmp_dict["classtype"] = _tmp_dict["classtype"].strip()

        # TODO 2020-3.31 修复 \" 字符占用msg 的问题; 
        try:
            _tmp_dict['full_msg'] = re.match('.*?msg:\s*\"(.*?)\";.*', rule_line).group(1)
        except:
            print(rule_line)
        del _tmp_dict['msg']
        _slug, _msg = parse_msg(_tmp_dict['full_msg'])
        _tmp_dict = dict(**_tmp_dict, slug=_slug, msg=_msg)
        return _tmp_dict
    return None


def patch_rule_desc_cn():
    """
    通过逐条翻译后的结果重新进行映射。
    :return:
    # TODO 本方法已于12.30全部被 cate_v0 的定义内容取代
    """
    from .manager import RULE_MAIN_DIR, get_emerging_classes
    ruleclass_desc_cn_path = os.path.join(RULE_MAIN_DIR, 'tras_desc.txt')
    with open(ruleclass_desc_cn_path, "r", encoding='gb2312') as f:
        desc_cns = f.readlines()
        f.close()
    emerging_classes = get_emerging_classes()
    patchd = []
    for i in range(len(emerging_classes)):
        _tmp = emerging_classes[i]
        _cn_name = desc_cns[i].split('\n')[0]
        _tmp['cn_name'] = _cn_name
        patchd.append(_tmp)
    return patchd

