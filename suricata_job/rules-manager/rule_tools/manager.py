# coding:utf-8
import os
import sys
import re

RULE_MAIN_DIR = 'D:\\home\\suri_main'
if not os.path.exists(RULE_MAIN_DIR):
    print('NOT Exist DIR')
    exit(0)

ClassificationMappingPath = os.path.join(RULE_MAIN_DIR, *['classification.config'])
DISABLE_CONF_PATH = os.path.join(RULE_MAIN_DIR, *['disable.conf'])

Add_RuleTxt = True

from .parse_rule import parse_rule_line


def read_file(filepath):
    try:
        with open(os.path.join(filepath), "r", ) as f:
            filestrs = f.readlines()
            f.close()
    except UnicodeDecodeError as e:
        print(filepath)
        filestrs = ""

    return filestrs


def list_all_rulefiles(file_dir=RULE_MAIN_DIR):
    return [x for x in os.listdir(file_dir) if re.match(".*?\.rules", x)]


def get_rules_parsed_by_filename(filepath):
    # from .parse_rule import parse_rule_line
    rule_lines = read_file(filepath)
    res = []
    for line in rule_lines:
        line_parsed = parse_rule_line(line, detail=Add_RuleTxt)
        if line_parsed:
            if "classtype" not in line_parsed.keys():
                # 修改默认没有归类的规则到这里。
                line_parsed['classtype'] = 'protocol-command-decode'
            res.append(line_parsed)
            # 增加所属文件的这个内容
            line_parsed['belong_file'] = filepath

    return res


def get_emerging_classes():
    """
    TODO: 获取规则的分类类别; 其中官方规则已经给了这个文件;
    务必保证文件格式中,前后没有空格！！！
    config classification:shortname,short description,priority
    :return: [*dict, ]
    注意如果要逐条翻译, 这里可以调用翻译脚本翻译出来 `cn_name` 写入
    """
    with open(ClassificationMappingPath, "r", encoding='utf-8') as f:
        lines = f.readlines()
        f.close()
    classifications = []
    for line in lines:
        matched = re.match("config classification: (.*?),(.*?),(\d+).*?", line)
        if matched:
            classifications.append(dict(
                shortname=matched.group(1).strip(),
                short_description=matched.group(2).strip(),
                priority=int(matched.group(3).strip()),
            ))
    return classifications


def parse_file_path_abs_dir(dirpath=RULE_MAIN_DIR):
    collect_rule_files = []
    for x in os.listdir(dirpath):
        _path = os.path.join(dirpath, x)
        if os.path.isdir(_path):
            collect_rule_files.extend(parse_file_path_abs_dir(_path))
            continue
        matched_rule_file = re.match('.*?.rules$', x)
        if matched_rule_file:
            collect_rule_files.append(_path)
    return collect_rule_files


class RuleManager:
    """
    规则管理合一测试的管理。
    """
    @staticmethod
    def get_all_rules_based_dir(file_dir):
        res = []
        files = parse_file_path_abs_dir(file_dir)
        for filepath in files:
            res.extend(get_rules_parsed_by_filename(filepath))
        return res

    @staticmethod
    def push__all_in_one_file(file_dir, saved_path='all_in_one_rule.rules', disable_conf=None):
        rules = RuleManager.get_all_rules_based_dir(file_dir)
        if disable_conf:
            disable_sids = RuleXableManager(disable_conf=disable_conf).get_disable_ruleids(rules=rules)
        else:
            disable_sids = []
        active_rules = [x for x in rules if x['sid'] not in disable_sids]
        with open(saved_path, "w+") as f:
            for _rule in active_rules:
                f.write(_rule['rule_line'])
            f.close()
        return

    @staticmethod
    def parse_sigle_rulefile(path=RULE_MAIN_DIR):
        return get_rules_parsed_by_filename(file_dir='', filename=path)

    @staticmethod
    def collected_rules_by_dirpath(dirpath='E:\\workspace\\ids_project\docs\\suricata_home'):
        paths = parse_file_path_abs_dir(dirpath=dirpath)
        res = []
        for x in paths:
            _current_rule_sets = get_rules_parsed_by_filename(x)
            res.extend(_current_rule_sets)
        return res


class RuleXableManager:
    # TODO: 切记不要在配置文件中用 \n 字符。
    def __init__(self, disable_conf='e://disable.conf'):
        self.disable_conf = disable_conf

    def get_disable_filters(self):
        with open(self.disable_conf, "r") as f:
            lines = f.read().split('\n')
            f.close()
        filter_types = []
        for x in lines:
            if re.match('^#.*', x):
                # print('没有匹配到{},可能是空行或者#注释的'.format(x))
                continue
            if re.match('^re:(.*)', x):
                matchd_partern = re.match('^re:(.*)', x).group(1)
                filter_types.append(dict(type='re', content=matchd_partern))
                continue
            if re.match('^\d+', x):
                sid = re.match('(\d+)', x).group(1)
                filter_types.append(dict(type='sid', content=sid))
        return filter_types

    def get_disable_ruleids(self, rules=None):
        filter_types = self.get_disable_filters()

        rule_ids = []

        for rule in rules:
            for x in filter_types:
                if x['type'] == 'sid':
                    if rule['sid'] == int(x['content']):
                        rule_ids.append(rule['sid'])
                if x['type'] == 're':
                    matched = re.match('.*?' + x['content'] + '.*?', rule['rule_line'])
                    if matched:
                        rule_ids.append(rule['sid'])
        # TODO 2019-12-27 目前 14739
        return rule_ids

    def diable_in_rules(self):
        sids = self.get_disable_ruleids()
        # IpsRule.objects.all().update(active=True)
        # IpsRule.objects.filter(sid__in=sids).update(active=False)
        return True
