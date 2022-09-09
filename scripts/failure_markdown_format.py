#!/usr/bin/env python3

import os
import json
import sys
from typing import Tuple, List, Dict, Any

#: The array of colums to render into the markdown table.
COLUMNS = ('cve_list', 'package_name', 'package_version', 'hrefs')

FATAL_CVSS_SCORE = 'FATAL_CVSS_SCORE'


def column_title(column: str) -> str:
    """Render the specified column so that it can be used in the header column
    of a markdown table.
    """
    return column.replace('_', ' ').title()


def new_vulns_table(columns: Tuple[str], vulns: List[Dict[str, Any]]) -> str:
    """Render the provided vulnerability data into a markdown table.
    """
    lines = [
        '| ' + ' | '.join([column_title(column) for column in columns]) + ' |',
        '| ' + ' | '.join(['-'*len(column) for column in columns]) + ' |'
    ]

    # Filter out only the vulnerabilities that were flagged as fatal.
    fatal_vulns = [vuln for vuln in vulns if vuln['fatal'] == '1']

    lines.extend([
        f'| {vuln[column]} |' for vuln in fatal_vulns for column in columns
    ])

    return '\n'.join(lines)


def render_markdown_report(columns: Tuple[str], vulns: List[Dict[str, Any]]) -> str:
    """Render a markdown report detailing the fatal vulnerabilities detected.
    """
    header = '\n\n'.join([
        '# Critical Vulnerabilities',
        f'The following vulnerabilities exceeded the specified {FATAL_CVSS_SCORE} of {os.getenv(FATAL_CVSS_SCORE)}.'
    ])

    table = new_vulns_table(columns, vulns)

    return '\n\n'.join([header, table])

if __name__ == '__main__':
    # Read the vulnerabilities JSON array piped over stdin.
    vulns = json.loads("".join(sys.stdin))

    # Render the fatal vulnerabilities from our results as a markdown report.
    print(render_markdown_report(COLUMNS, vulns))
