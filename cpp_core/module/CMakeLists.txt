/*
 * Ночь темного Ворона — CMake для AzerothCore.
 * Подключение: add_subdirectory(<путь к cpp_core/module>)
 * либо копирование папки в modules/ репозитория AzerothCore.
 */

set(MOD_NAME mod-nightdarkraven)

add_library(${MOD_NAME} MODULE
    ${CMAKE_CURRENT_SOURCE_DIR}/src/mod_nightdarkraven.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/include/mod_nightdarkraven.h
)

target_include_directories(${MOD_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)

target_link_libraries(${MOD_NAME} PRIVATE game)

set_target_properties(${MOD_NAME} PROPERTIES
    PREFIX ""
    OUTPUT_NAME "mod-nightdarkraven"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/modules"
)

if(WIN32)
    set_target_properties(${MOD_NAME} PROPERTIES SUFFIX ".dll")
endif()

message(STATUS "[NightDarkRaven] module configured: ${MOD_NAME}")
