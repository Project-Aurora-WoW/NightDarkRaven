#!/usr/bin/env python3
# ============================================================================
# Ночь темного Ворона — Патч realmlist.wtf для WoW 3.3.5a
# ============================================================================

import json
import os
import sys
from pathlib import Path

CONFIG_FILE = Path(__file__).parent / "config.json"


def load_config():
    if not CONFIG_FILE.exists():
        print(f"Конфиг не найден: {CONFIG_FILE}")
        sys.exit(1)
    with open(CONFIG_FILE, "r", encoding="utf-8") as f:
        return json.load(f)


def patch_realmlist(wow_path: str, realm_list: str):
    wow_path = Path(wow_path)
    wtf_dir = wow_path / "WTF"
    realm_list_file = wtf_dir / "realmlist.wtf"

    if not wtf_dir.exists():
        wtf_dir.mkdir(parents=True, exist_ok=True)

    realm_list_file.write_text(f"set realmlist {realm_list}\n", encoding="utf-8")
    print(f"[OK] realmlist.wtf обновлён: {realm_list_file}")
    print(f"     set realmlist {realm_list}")


def main():
    config = load_config()
    wow_path = config.get("wowPath")
    realm_list = config.get("realmlist", "127.0.0.1")

    if not wow_path:
        print("wowPath не указан в config.json")
        sys.exit(1)

    if not Path(wow_path).exists():
        print(f"Путь к WoW не существует: {wow_path}")
        sys.exit(1)

    patch_realmlist(wow_path, realm_list)
    print("Готово. Запустите WoW.exe вручную.")


if __name__ == "__main__":
    main()