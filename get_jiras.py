#!/usr/bin/env python

##
# Authored by Erik Babel and Travis Wyatt; modified by Chris Corea
##

import json
import re
from macpath import split

jsonString = open("build_json.txt").read()
parsed = json.loads(jsonString)
changeset = parsed['changeSet']
changes = changeset['items']

# RegEx pattern captures one or more JIRA ticket names from a commit message.
#
# Examples of allowed commit messages:
#   [PRO-1234] message
#	[jira PRO-1234] message
#   [jira:PRO-1234] message
#   [PRO-1234,PRO-133] message
#   [jira:PRO-1234,PRO-133] message
#   [jira:PRO-1234,jira:PRO-133] message
#   [PRO-1234,PRO-133;RTL-6213] message
#   [PRO-1234;PRO-133,rtl-6213] message
pattern = "^\[((?:(?:jira\:?\s*)?\w+-\d+[,;]?[\s]?)+)+\].*$"
p = re.compile(pattern, re.IGNORECASE)

jiras = []
for change in changes:
    m = p.match(change['msg'])
    if m:
        names = re.split('[,; ]', m.groups()[0])
        jiras.extend([x.lstrip('jira:').lstrip('JIRA:').lstrip('jira').lstrip('JIRA').strip() for x in names])

jiras = list(set(jiras)) # remove duplicates (order is lost)
print ' '.join(jiras)
