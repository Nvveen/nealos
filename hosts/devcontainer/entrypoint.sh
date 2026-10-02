set -euo pipefail

nix-daemon > /tmp/nix-daemon.log 2>&1 &
until nix --store daemon store ping >/dev/null 2>&1; do
	sleep 0.1
done
exec "$@"