# coding:utf-8
import os
import sys

sys.path.append('.')

from rule_tools.manager import RuleManager, RULE_MAIN_DIR, DISABLE_CONF_PATH
RuleManager.push__all_in_one_file(
    file_dir=RULE_MAIN_DIR,
    disable_conf=DISABLE_CONF_PATH,
    saved_path='d://suricata-alert-20210111.rules'
)


