# CMakeLists для модуля AzerothCore: NightDarkRaven
# Подключается из корневого CMakeLists.txt AzerothCore:
#   add_subdirectory(src/modules/custom/NightDarkRaven)

set(MODULE_NAME NightDarkRaven)

set(${MODULE_NAME}_SOURCES
    src/NightDarkRaven.cpp
)

set(${MODULE_NAME}_HEADERS
    include/NightDarkRaven.h
)

add_library(${MODULE_NAME} MODULE
    ${${MODULE_NAME}_SOURCES}
    ${${MODULE_NAME}_HEADERS}
)

target_include_directories(${MODULE_NAME} PRIVATE include)
target_link_libraries(${MODULE_NAME} PRIVATE worldserver)

# Копируем скомпилированный модуль в папку модулей worldserver
set_target_properties(${MODULE_NAME} PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin/Release/modules
)