#!/usr/bin/env python3
"""Backfill Bulgarian (bg) translations for company rules (notifications
type=='rule') across ALL DSPs. Bulgarian text comes from a pre-translated
JSON (/tmp/bg_rules_bg.json, keyed by 'dsp|ruleId') — NO external service is
called. Writes translations.bg into the admin copy and every existing driver
copy. Idempotent: skips docs that already have a non-empty translations.bg.
Set DRY=1 to only count."""
import json, os, subprocess, urllib.request, urllib.error, sys

DRY = os.environ.get("DRY") == "1"
PROJ = "codriver-eu"
BASE = f"https://firestore.googleapis.com/v1/projects/{PROJ}/databases/(default)/documents"
TOKEN = subprocess.check_output(
    ["bash", "-lc",
     "CLOUDSDK_PYTHON=/opt/homebrew/opt/python@3.12/bin/python3.12 "
     "gcloud auth print-access-token"]).decode().strip()
H = {"Authorization": "Bearer " + TOKEN, "Content-Type": "application/json"}
BG = json.load(open("/tmp/bg_rules_bg.json", encoding="utf-8"))


def runquery(parent, sq):
    req = urllib.request.Request(BASE + parent + ":runQuery",
                                 data=json.dumps({"structuredQuery": sq}).encode(),
                                 method="POST", headers=H)
    with urllib.request.urlopen(req, timeout=60) as r:
        d = json.loads(r.read().decode())
    return [x["document"] for x in d if "document" in x]


def patch(path, bgv):
    body = {"fields": {"translations": {"mapValue": {"fields": {"bg": {"mapValue": {"fields": {
        "title": {"stringValue": bgv["title"]},
        "body": {"stringValue": bgv["body"]},
    }}}}}}}}
    url = BASE + path + "?updateMask.fieldPaths=translations.bg"
    req = urllib.request.Request(url, data=json.dumps(body).encode(), method="PATCH", headers=H)
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            r.read()
        return True
    except urllib.error.HTTPError as e:
        sys.stderr.write(f"PATCH fail {path}: {e.code} {e.read().decode()[:120]}\n")
        return False


def gstr(fields, k):
    x = fields.get(k)
    return (x or {}).get("stringValue", "") if x else ""


def has_bg(fields):
    tr = fields.get("translations", {}).get("mapValue", {}).get("fields", {}) \
        if fields.get("translations") else {}
    if "bg" in tr:
        row = tr["bg"].get("mapValue", {}).get("fields", {})
        return bool(gstr(row, "title") or gstr(row, "body"))
    return False


def main():
    dsps = [d["name"].split("/")[-1] for d in runquery("", {"from": [{"collectionId": "users"}],
        "where": {"fieldFilter": {"field": {"fieldPath": "role"}, "op": "IN", "value": {"arrayValue": {
            "values": [{"stringValue": "admin"}, {"stringValue": "user"}, {"stringValue": "developer"}]}}}},
        "limit": 2000})]
    print(f"DSP candidates: {len(dsps)}  DRY={DRY}  bg_rules_loaded={len(BG)}")
    n_admin = n_driver = n_skip = n_missing = 0
    for dsp in dsps:
        rules = runquery(f"/users/{dsp}", {"from": [{"collectionId": "notifications"}],
            "where": {"fieldFilter": {"field": {"fieldPath": "type"}, "op": "EQUAL",
                      "value": {"stringValue": "rule"}}}, "limit": 300})
        if not rules:
            continue
        print(f"DSP {dsp}: {len(rules)} rules")
        for doc in rules:
            rid = doc["name"].split("/")[-1]
            bgv = BG.get(f"{dsp}|{rid}")
            if not bgv or (not bgv.get("title") and not bgv.get("body")):
                n_missing += 1
                continue
            if has_bg(doc.get("fields", {})):
                n_skip += 1
            elif not DRY and patch(f"/users/{dsp}/notifications/{rid}", bgv):
                n_admin += 1
        # driver fan-out copies
        drivers = runquery(f"/users/{dsp}", {"from": [{"collectionId": "drivers"}], "limit": 2000})
        for dd in drivers:
            tid = dd["name"].split("/")[-1]
            try:
                dn = runquery(f"/users/{dsp}/drivers/{tid}", {"from": [{"collectionId": "notifications"}],
                    "where": {"fieldFilter": {"field": {"fieldPath": "type"}, "op": "EQUAL",
                              "value": {"stringValue": "rule"}}}, "limit": 300})
            except Exception:
                continue
            for nd in dn:
                rid = nd["name"].split("/")[-1]
                bgv = BG.get(f"{dsp}|{rid}")
                if not bgv or (not bgv.get("title") and not bgv.get("body")):
                    continue
                if has_bg(nd.get("fields", {})):
                    continue
                if DRY:
                    n_driver += 1
                elif patch(f"/users/{dsp}/drivers/{tid}/notifications/{rid}", bgv):
                    n_driver += 1
    print(f"\nSUMMARY admin_patched={n_admin} driver_patched={n_driver} "
          f"already_had_bg={n_skip} missing_translation={n_missing}")


main()
