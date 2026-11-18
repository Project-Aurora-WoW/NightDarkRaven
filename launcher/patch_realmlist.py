#!/usr/bin/env python3
# ============================================================================
# Ночь темного Ворона — Патч realmlist.wtf и скачивание патчей клиента
# ============================================================================

import json
import os
import sys
import urllib.request
import urllib.error
from pathlib import Path

CONFIG_FILE = Path(__file__).parent / "config.json"


def load_config():
    if not CONFIG_FILE.exists():
        print(f"Конфиг не найден: {CONFIG_FILE}")
        sys.exit(1)
    with open(CONFIG_FILE, "r", encoding="utf-8") as f:
        return json.load(f)


def patch_realmlist(wow_path: str, realm_list: str):
    """Обновить realmlist.wtf в папке клиента WoW."""
    wow_path = Path(wow_path)
    wtf_dir = wow_path / "WTF"
    realm_list_file = wtf_dir / "realmlist.wtf"

    if not wtf_dir.exists():
        wtf_dir.mkdir(parents=True, exist_ok=True)

    realm_list_file.write_text(f"set realmlist {realm_list}\n", encoding="utf-8")
    print(f"[OK] realmlist.wtf обновлён: {realm_list_file}")
    print(f"     set realmlist {realm_list}")


def check_patches(web_url: str):
    """Проверить нужные патчи через веб-API."""
    url = f"{web_url}/api/clientpatches/check"
    try:
        with urllib.request.urlopen(url, timeout=10) as resp:
            data = json.loads(resp.read().decode("utf-8"))
        return data
    except Exception as e:
        print(f"[WARN] Не удалось проверить патчи: {e}")
        return {"needsUpdate": False, "patches": []}


def download_and_apply_patch(web_url: str, patch_id: int):
    """Скачать патч через веб-API и отметить как применённый."""
    url = f"{web_url}/api/clientpatches/{patch_id}/download?autoApply=true"
    try:
        with urllib.request.urlopen(url, timeout=10) as resp:
            content = resp.read().decode("utf-8")
            patch_name = resp.headers.get("X-Patch-Name", "Неизвестно")
            target_file = resp.headers.get("X-Target-File", "Неизвестно")
        print(f"[OK] Патч скачан: {patch_name}")
        print(f"     Целевой файл: {target_file}")
        print(f"     Содержимое:\n{content}")
        return True
    except Exception as e:
        print(f"[ERROR] Не удалось скачать патч #{patch_id}: {e}")
        return False


def main():
    config = load_config()
    wow_path = config.get("wowPath")
    realm_list = config.get("realmlist", "127.0.0.1")
    web_url = config.get("webUrl", "")

    if not wow_path:
        print("wowPath не указан в config.json")
        sys.exit(1)

    if not Path(wow_path).exists():
        print(f"Путь к WoW не существует: {wow_path}")
        sys.exit(1)

    # 1. Проверяем патчи
    if web_url:
        patch_data = check_patches(web_url)
        if patch_data.get("needsUpdate") and patch_data.get("patches"):
            print(f"[INFO] Найдено патчей к применению: {len(patch_data['patches'])}")
            for patch in patch_data["patches"]:
                print(f"  - #{patch['patch_id']} {patch['patch_name']} ({patch['target_file']})")
                download_and_apply_patch(web_url, patch["patch_id"])
        else:
            print("[INFO] Все патчи применены.")
    else:
        print("[WARN] webUrl не указан, пропускаем проверку патчей.")

    # 2. Патчим realmlist
    patch_realmlist(wow_path, realm_list)
    print("Готово. Запустите WoW.exe вручную.")


if __name__ == "__main__":
    main()