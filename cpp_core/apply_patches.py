#!/usr/bin/env python3
# ============================================================================
# Ночь темного Ворона — Автоустановка C++ патчей для AzerothCore
# ============================================================================

import os
import sys
import shutil
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent.absolute()
PATCHES_DIR = SCRIPT_DIR / "patches"

def find_azerothcore():
    """Поиск AzerothCore в текущей и родительских директориях"""
    candidates = [
        Path.cwd() / "ac-server",
        Path.cwd().parent / "ac-server",
        Path.cwd() / "azerothcore-wotlk",
        Path.cwd().parent / "azerothcore-wotlk",
    ]
    for c in candidates:
        if c.exists() and (c / "CMakeLists.txt").exists():
            return c
    return None

def apply_patch_with_patch(patch_file, ac_dir):
    """Применить патч через утилиту patch"""
    import subprocess
    try:
        result = subprocess.run(
            ["patch", "-p1", "-i", str(patch_file)],
            cwd=ac_dir,
            capture_output=True,
            text=True,
            timeout=30
        )
        if result.returncode == 0:
            print(f"  [OK] {patch_file.name}")
            return True
        else:
            print(f"  [FAIL] {patch_file.name}: {result.stderr[:200]}")
            return False
    except FileNotFoundError:
        print(f"  [SKIP] {patch_file.name}: утилита patch не найдена")
        return None
    except Exception as e:
        print(f"  [ERROR] {patch_file.name}: {e}")
        return False

def apply_patch_manual(patch_file, ac_dir):
    """Ручное применение патча (вставка кода в файлы)"""
    print(f"  [MANUAL] {patch_file.name} - требуется ручное вставление кода")
    print(f"    См. комментарии в файле патча для точных мест вставки")
    return None

def main():
    print("=" * 60)
    print("Ночь темного Ворона — Автоустановка C++ патчей")
    print("=" * 60)
    
    ac_dir = find_azerothcore()
    if not ac_dir:
        print("\n[ERROR] AzerothCore не найден!")
        print("\nУкажите путь вручную или склонируйте AzerothCore:")
        print("  git clone https://github.com/azerothcore/azerothcore-wotlk.git ac-server")
        print("\nИли запустите скрипт из папки с ac-server.")
        sys.exit(1)
    
    print(f"\n[INFO] Найден AzerothCore: {ac_dir}")
    
    # Список патчей в порядке применения
    patches = [
        "01_player_skills.h.patch",
        "02_player_skills.cpp.patch",
        "03_unit_solo.h.patch",
        "04_unit_solo.cpp.patch",
        "05_worldserver_solo_login.patch",
        # 06_lua_bridge.cpp требует отдельной обработки
        # 07_database_schema.sql требует выполнения в MySQL
    ]
    
    success = 0
    failed = 0
    manual = 0
    
    for patch_name in patches:
        patch_file = PATCHES_DIR / patch_name
        if not patch_file.exists():
            print(f"  [MISSING] {patch_name} не найден")
            failed += 1
            continue
        
        result = apply_patch_with_patch(patch_file, ac_dir)
        if result is True:
            success += 1
        elif result is None:
            manual += 1
        else:
            failed += 1
    
    print("\n" + "=" * 60)
    print(f"Результат: {success} применено, {failed} ошибок, {manual} вручную")
    print("=" * 60)
    
    # Инструкции для Lua моста и БД
    print("\n[NEXT STEPS]")
    print("1. Скопируйте 06_lua_bridge.cpp в папку скриптов Lua AzerothCore")
    print("2. Добавьте его в CMakeLists.txt той же папки")
    print("3. Выполните 07_database_schema.sql в базе данных world")
    print("4. Импортируйте SQL контент из server/sql/")
    print("5. Соберите сервер: cmake .. && make -j$(nproc)")
    print("=" * 60)

if __name__ == "__main__":
    main()