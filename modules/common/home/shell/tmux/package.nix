{
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  installShellFiles,
  tmux,
  procps,
  jq,
  fish,
}:
buildGoModule rec {
  pname = "lazy-tmux";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "alchemmist";
    repo = "lazy-tmux";
    tag = "v${version}";
    hash = "sha256-jFhm+bFh4ao98b1cIbTeUvvuoExLQKcEvTjBb4qfddo=";
  };
  vendorHash = "sha256-Vu7JcBglIfF+aTX9/GPUjmYsvPb99S4ozh9m/lmxKEY=";

  subPackages = [ "cmd/lazy-tmux" ];
  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];
  nativeCheckInputs = [
    tmux
    procps
    jq
  ];
  postInstall = ''
    installShellCompletion --fish --name lazy-tmux.fish ${./completions/lazy-tmux.fish}

    wrapProgram "$out/bin/lazy-tmux" \
      --prefix PATH : ${
        lib.makeBinPath [
          tmux
          procps
        ]
      }
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ fish ];
  installCheckPhase = ''
    runHook preInstallCheck
    fish --no-config ${./tests/completions.fish} "$out"
    runHook postInstallCheck
  '';

  meta = {
    description = "Tmux session manager with lazy restoration and a TUI picker";
    homepage = "https://github.com/alchemmist/lazy-tmux";
    license = lib.licenses.mit;
    mainProgram = "lazy-tmux";
    platforms = lib.platforms.linux;
  };
}
