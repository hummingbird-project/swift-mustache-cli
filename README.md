# Mustache

Command line tool for rendering Mustache templates

## Overview

Mustache is a logic-less templating system for rendering text files.

The mustache command line tool processes a Mustache template with a context defined in YAML/JSON. While the template is always loaded from a file the context can be supplied to the process either from a file or from stdin.

## Usage

Render a mustache template file `template.mustache` with context defined in `context.yml` in YAML or JSON.

```bash
mustache context.yml template.mustache
```

Alternatively to render a mustache template file `template.mustache` with context read from stdin, replace the context file name with `-`.

```bash
cat context.yml | mustache - template.mustache
```

## Install

### Using mint

Use [mint](https://github.com/yonaskolb/Mint) to build and install mustache.

```bash
mint install hummingbird-project/swift-mustache-cli
```
