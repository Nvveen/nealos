# nealbox: Debian + Nix + homeConfigurations.neal, baked in.
# changed: path. Built from the nealos repo root:  docker build -f hosts/nealbox/Dockerfile -t nealbox .
FROM debian:bookworm-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl xz-utils git sudo \
 && rm -rf /var/lib/apt/lists/*

# The user every project's container runs as. UID 1000 matches WSL; the Dev Containers
# CLI remaps it automatically on hosts where it differs.
RUN groupadd -g 1000 neal \
 && useradd -m -u 1000 -g 1000 -s /bin/bash neal \
 && echo 'neal ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/neal

# Single-user Nix owned by neal, like nixpkgs' devcontainer. No daemon, no systemd.
# The Nix sandbox doesn't work inside docker build.
RUN mkdir -m 0755 /nix && chown neal:neal /nix \
 && mkdir -p /etc/nix \
 && printf 'experimental-features = nix-command flakes\nsandbox = false\n' > /etc/nix/nix.conf

USER neal
ENV USER=neal
RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

# Build and activate home-manager from the repo. A bind mount rather than COPY,
# so the repo itself never ends up in the image; GC drops the build-only paths.
RUN --mount=type=bind,target=/tmp/nealos \
    . ~/.nix-profile/etc/profile.d/nix.sh \
 && HOME_MANAGER_BACKUP_EXT=bak \
    "$(nix build --no-link --print-out-paths path:/tmp/nealos#homeConfigurations.neal.activationPackage)/activate" \
 && nix-collect-garbage

# fish as the login shell, so any terminal (VS Code or docker exec) gets it.
USER root
RUN echo /home/neal/.nix-profile/bin/fish >> /etc/shells \
 && chsh -s /home/neal/.nix-profile/bin/fish neal
USER neal
WORKDIR /home/neal
ENV PATH=/home/neal/.nix-profile/bin:$PATH \
    LANG=C.UTF-8

# Defaults for every devcontainer using this image, so projects don't repeat them.
LABEL devcontainer.metadata='[{"remoteUser":"neal","customizations":{"vscode":{"extensions":["jnoortheen.nix-ide"]}}}]'

CMD ["/home/neal/.nix-profile/bin/fish", "-l"]