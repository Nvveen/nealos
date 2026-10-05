# nealbox: Debian + Nix + home-manager from the nealos flake.
# Build from the repo root: docker build -f hosts/nealbox/Dockerfile -t ghcr.io/nvveen/nealbox .
FROM debian:trixie-slim

# bash with pipefail, so a failed curl in a pipe fails the build.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Basic tools, user `neal` (UID 1000) with passwordless sudo,
# and a user-owned /nix for single-user Nix.
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl wget xz-utils git procps less sudo \
 && rm -rf /var/lib/apt/lists/* \
 && useradd -m -u 1000 neal \
 && echo 'neal ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/neal \
 && mkdir -m 0755 /nix /etc/nix && chown neal /nix \
 && printf 'experimental-features = nix-command flakes\nsandbox = false\n' > /etc/nix/nix.conf

USER neal
WORKDIR /home/neal
ENV USER=neal PATH=/home/neal/.nix-profile/bin:$PATH

RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

# Apply the flake's home config exactly like on a host. -b backup moves Debian's
# default dotfiles aside instead of failing. Then make fish the login shell.
COPY --chown=neal . /tmp/nealos
RUN nix run home-manager -- switch -b backup --flake path:/tmp/nealos#neal \
 && sudo usermod -s /home/neal/.nix-profile/bin/fish neal

CMD ["/home/neal/.nix-profile/bin/fish", "-l"]