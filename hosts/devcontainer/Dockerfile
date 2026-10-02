FROM nixos/nix:latest AS build
WORKDIR /src
COPY . .
RUN nix --extra-experimental-features 'nix-command flakes' \
    build --no-write-lock-file --out-link /home-manager \
    .#homeConfigurations.devcontainer.activationPackage \
    && nix --extra-experimental-features 'nix-command flakes' \
      copy --no-check-sigs --to 'local?root=/export' "$(readlink -f /home-manager)" \
    && mkdir -p /export/opt \
    && cp --no-dereference /home-manager /export/opt/home-manager

FROM nixos/nix:latest
COPY --from=build /export/nix /nix
COPY --from=build /export/opt /opt
RUN printf '%s\n' 'NAME=Nealos' 'ID=nealos' 'PRETTY_NAME="Nealos development container"' > /etc/os-release

RUN cp -L /etc/passwd /etc/passwd.new \
    && mv /etc/passwd.new /etc/passwd \
    && cp -L /etc/group /etc/group.new \
    && mv /etc/group.new /etc/group \
    && printf '%s\n' 'neal:x:1000:1000:Neal van Veen:/home/neal:/bin/bash' >> /etc/passwd \
    && printf '%s\n' 'neal:x:1000:' >> /etc/group \
    && mkdir -p /home/neal /nix/var/nix/profiles/per-user/root \
    && chown 1000:1000 /home/neal \
    && ln -s /opt/home-manager /nix/var/nix/profiles/per-user/root/devcontainer-home \
    && printf '\nexperimental-features = nix-command flakes\ntrusted-users = root neal\n' >> /etc/nix/nix.conf \
    && nix --extra-experimental-features 'nix-command flakes' \
      profile install --profile /nix/var/nix/profiles/default .#coreutils

COPY hosts/devcontainer/entrypoint.sh /usr/local/bin/nealos-entrypoint
ENV HOME=/root USER=root
LABEL org.opencontainers.image.source="https://github.com/Nvveen/nealos"
ENTRYPOINT ["/root/.nix-profile/bin/bash", "/usr/local/bin/nealos-entrypoint"]
CMD ["sleep", "infinity"]
