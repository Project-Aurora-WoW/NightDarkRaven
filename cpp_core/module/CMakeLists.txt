# Ночь темного Ворона — CMake для AzerothCore.
# Подключение через AC_ADD_SCRIPT, как обычный модуль в modules/.

AC_ADD_SCRIPT("${CMAKE_CURRENT_LIST_DIR}/src/mod_nightdarkraven.cpp")

# Мост C++ -> Lua (Eluna). Подключается только при сборке с Lua.
if (WITH_LUA)
    AC_ADD_SCRIPT("${CMAKE_CURRENT_LIST_DIR}/src/mod_nightdarkraven_lua.cpp")
endif()
