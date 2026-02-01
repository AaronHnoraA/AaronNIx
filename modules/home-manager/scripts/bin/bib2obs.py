#!/opt/homebrew/anaconda3/bin/python3
# -*- coding: utf-8 -*-

import argparse
import os
import re
from urllib.parse import parse_qs, unquote, urlparse

import requests


def clean_field(value: str) -> str:
    """去除花括号和换行，首尾 strip。"""
    return value.replace("{", "").replace("}", "").replace("\n", " ").strip()


def extract_filename_from_obsidian_url(url: str) -> str:
    """
    支持两种格式：
      1) obsidian://open?...&file=...
      2) http://…/openlink.html?link=obsidian://…&file=…
    优先取最外层的 file 参数，其次解析 nested link，再 fallback 到 path 尾段。
    """
    parsed = urlparse(url)
    qs = parse_qs(parsed.query)
    if "file" in qs and qs["file"]:
        raw = qs["file"][0]
    elif "link" in qs and qs["link"]:
        nested = qs["link"][0]
        np = urlparse(nested)
        nqs = parse_qs(np.query)
        raw = nqs.get("file", [np.path.rsplit("/", 1)[-1]])[0]
    else:
        raw = parsed.path.rsplit("/", 1)[-1]
    return unquote(raw.split("/")[-1])


def parse_single_entry(text: str):
    """
    解析单条 @…{key, …} 为字典
    """
    m = re.match(r'@(\w+)\s*\{\s*([^,]+),', text)
    if not m:
        return None
    key = m.group(2).strip()
    fields = {}
    pattern = re.compile(r'(\w+)\s*=\s*(?:\{([^}]*)\}|"([^"]*)")', re.S)
    for name, v1, v2 in pattern.findall(text):
        val = v1 if v1 else (v2 or "")
        fields[name.lower()] = val.replace("\n", " ").strip()
    return {"ID": key, **fields}


def parse_bib_content(text: str) -> list[dict]:
    """
    逐行解析 BibTeX 条目，避免大括号嵌套问题
    """
    entries = []
    buffer = []
    level = 0
    for line in text.splitlines():
        s = line.strip()
        if s.startswith("@") and "{" in s:
            if buffer:
                e = parse_single_entry("\n".join(buffer))
                if e:
                    entries.append(e)
                buffer = []
            buffer.append(line)
            level = line.count("{") - line.count("}")
        elif buffer:
            buffer.append(line)
            level += line.count("{") - line.count("}")
            if level <= 0:
                e = parse_single_entry("\n".join(buffer))
                if e:
                    entries.append(e)
                buffer = []
    if buffer:
        e = parse_single_entry("\n".join(buffer))
        if e:
            entries.append(e)
    return entries


def load_bib(path: str) -> str:
    """加载本地或远程 .bib 文本内容。"""
    if path.startswith(("http://", "https://")):
        r = requests.get(path, timeout=10)
        r.raise_for_status()
        return r.text
    with open(path, encoding="utf-8") as fp:
        return fp.read()


def print_table(entries: list[dict], extra_fields: list[str], obsidian: bool):
    """打印 Markdown 表格：ID | Title | Link | …"""
    print(" ")
    headers = ["ID", "Title", "Link"] + extra_fields
    # 表头
    print("| " + " | ".join(f"**{h}**" for h in headers) + " |")
    print("| " + " | ".join(":---" for _ in headers) + " |")
    if not entries:
        row = ["（无匹配条目）", "—", "—"] + ["—"] * len(extra_fields)
        print("| " + " | ".join(row) + " |")
        return
    for e in entries:
        eid = e.get("ID", "")
        title = clean_field(e.get("title", ""))
        url = clean_field(e.get("url", ""))
        if obsidian:
            name = extract_filename_from_obsidian_url(url)
            link = f"[[{name}]]"
        else:
            link = f"[{url}]({url})" if url else "—"
        row = [eid, title, link
               ] + [clean_field(e.get(f, "—")) or "—" for f in extra_fields]
        print("| " + " | ".join(row) + " |")


def main(bib_paths: list[str], extra_fields: list[str]):
    print("# 参考文献总览\n\n---\n")
    errors = {}
    for path in bib_paths:
        name = os.path.basename(urlparse(path).path) or path
        print(f"## **文件：{name}**\n")
        try:
            raw = load_bib(path)
            all_entries = parse_bib_content(raw)
        except Exception as e:
            errors[path] = str(e).splitlines()[0]
            print(f"⚠️ 无法解析 `{path}`：{errors[path]}\n")
            continue
        print(f"共解析到 **{len(all_entries)}** 条目\n")
        obs = [
            e for e in all_entries if e.get("url", "").startswith("http")
            and "obsidian://" in e["url"]
        ]
        other = [e for e in all_entries if e not in obs]
        print("**Obsidian 笔记** 📒\n")
        print_table(obs, extra_fields, obsidian=True)
        print("\n**其他参考文献** 📖\n")
        print_table(other, extra_fields, obsidian=False)
        print()
    if errors:
        print("⚠️ **处理时遇到以下错误**")
        for p, msg in errors.items():
            print(f"- `{p}`: {msg}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="从.bib 提取 Obsidian内链和其他参考文献，输出Markdown表格")
    parser.add_argument("--fields",
                        "-f",
                        default="",
                        help="额外字段，如 author,year")
    parser.add_argument("bib_paths", nargs="+", help=".bib 文件路径或URL")
    args = parser.parse_args()
    extras = [f.strip().lower() for f in args.fields.split(",") if f.strip()]
    main(args.bib_paths, extras)
