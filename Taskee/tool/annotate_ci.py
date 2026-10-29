#!/usr/bin/env python3
"""Turn Flutter, Dart, Gradle and Xcode log lines into GitHub Actions annotations.

Usage: python3 tool/annotate_ci.py <logfile> [path-prefix]

Annotations are visible through the check-run API, so build and test failures
can be read without downloading the full job log.
"""
import re
import sys


def esc(text):
    return text.replace('%', '%25').replace('\r', '%0D').replace('\n', '%0A')


def emit(level, message, file=None, line=None, col=None, prefix=''):
    props = []
    if file:
        props.append(f'file={prefix}{file}')
    if line:
        props.append(f'line={line}')
    if col:
        props.append(f'col={col}')
    head = f"::{level} {','.join(props)}::" if props else f'::{level}::'
    print(head + esc(message))


def main(path, prefix):
    with open(path, encoding='utf-8', errors='replace') as handle:
        lines = handle.read().splitlines()
    count = 0
    for index, raw in enumerate(lines):
        line = raw.strip()

        # flutter analyze: "  error • message • lib/x.dart:12:5 • rule"
        match = re.match(r'^(error|warning) • (.*?) • (\S+\.dart):(\d+):(\d+)', line)
        if match:
            emit(match.group(1), match.group(2), match.group(3), match.group(4), match.group(5), prefix)
            count += 1
            continue

        # Dart compiler: "lib/x.dart:12:5: Error: message"
        match = re.match(r'^(\S+\.dart):(\d+):(\d+): (Error|Warning): (.*)$', line)
        if match:
            level = 'error' if match.group(4) == 'Error' else 'warning'
            emit(level, match.group(5), match.group(1), match.group(2), match.group(3), prefix)
            count += 1
            continue

        # flutter test failure marker, with the lines that explain it
        if '[E]' in raw:
            block = [line]
            for nxt in lines[index + 1:index + 12]:
                if not nxt.strip() or nxt.strip().startswith('test/') or '[E]' in nxt:
                    break
                block.append(nxt.strip())
            emit('error', 'Test failed:\n' + '\n'.join(block))
            count += 1
            continue

        # Gradle failure detail
        if line.startswith('What went wrong'):
            block = [n.strip() for n in lines[index + 1:index + 6] if n.strip()]
            emit('error', 'Gradle: ' + ' '.join(block))
            count += 1
            continue

        # Kotlin compiler and Xcode errors
        if re.match(r'^(e: |error: )', line):
            emit('error', line)
            count += 1

    print(f'annotate_ci: {count} annotation(s) written from {path}')


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else '')
