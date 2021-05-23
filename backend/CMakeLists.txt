cmake_minimum_required(VERSION 3.12)

project(backend)

add_executable(backend app.cpp)
target_compile_features(backend PRIVATE cxx_std_17)

find_library(PTHREAD_LIBRARY pthread)
target_link_libraries(backend PRIVATE ${PTHREAD_LIBRARY})

find_package(fmt CONFIG REQUIRED)
target_link_libraries(backend PRIVATE fmt::fmt fmt::fmt-header-only)

find_package(unofficial-http-parser CONFIG REQUIRED)
target_link_libraries(backend PRIVATE unofficial::http_parser::http_parser)

find_package(restinio CONFIG REQUIRED)
target_link_libraries(backend PRIVATE restinio::restinio)
