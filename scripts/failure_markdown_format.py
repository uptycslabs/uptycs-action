#!/usr/bin/env python3

import json, sys

newline = "\n"
dnewline = f"{newline}{newline}"
vulns = json.loads("".join(sys.stdin))

fmt_vuln_header = lambda vuln: f'# {vuln["cve_list"]} {vuln["package_name"]} {vuln["package_version"]}'
fmt_vuln_hrefs = lambda vuln: newline.join(["<" + href + ">" for href in vuln["hrefs"].split(",") if href])
fmt_vuln = lambda vuln: dnewline.join([fmt_vuln_header(vuln), vuln["description"], fmt_vuln_hrefs(vuln)])

print(dnewline.join([fmt_vuln(vuln) for vuln in vulns]))
