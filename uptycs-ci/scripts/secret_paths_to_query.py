#!/usr/bin/env python3

import csv
import sys

from typing import List


def format_paths_query(paths: List[str]):
    """Format the provided list of paths into a portion of a SQL query which
    filters on ANY of the provided paths.
    """
    return 'path LIKE ' + ' OR path LIKE '.join(paths)


if __name__ == '__main__':
    # Read the paths to scan from stdin formatted as a bash array and quote
    # them so that they can be injected into a query for osquery.
    paths = [path for path in csv.reader(sys.stdin, delimiter=',')][0]
    quoted_paths = [f"'{path}'" for path in paths]
    
    print(format_paths_query(quoted_paths), end=None)
