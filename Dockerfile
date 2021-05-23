FROM gcc:10.2.0 AS vcpkg-env

RUN apt-get update && \
    apt-get install -y git curl unzip tar && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/microsoft/vcpkg /backend/vcpkg
RUN /backend/vcpkg/bootstrap-vcpkg.sh -disableMetrics
RUN ln -s /backend/vcpkg/vcpkg /usr/bin/vcpkg


FROM vcpkg-env AS backend-build

RUN apt-get update && \
    apt-get install -y cmake zip libgl-dev && \
    rm -rf /var/lib/apt/lists/*

RUN vcpkg install --clean-after-build restinio
RUN rm -rf \
        /backend/vcpkg/buildtrees \
        /backend/vcpkg/downloads

ADD ./backend /backend/src
WORKDIR /backend/src/build

RUN cmake .. -DCMAKE_TOOLCHAIN_FILE=/backend/vcpkg/scripts/buildsystems/vcpkg.cmake && \
    cmake --build .


FROM ubuntu:20.04

RUN groupadd -r ape && useradd -r -g ape ape
USER ape

COPY --from=backend-build /backend/src/build/backend /backend/

EXPOSE 20100/tcp

ENTRYPOINT [ "./backend/backend" ]
