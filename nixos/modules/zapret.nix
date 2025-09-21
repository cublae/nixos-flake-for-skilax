{ pkgs, ...}:
let
  zapretfiles = pkgs.fetchFromGithub {
    owner = "Flowseal";
    repo = "zapret-discord-youtube";
    rev = "v1.8.3";
    sparseCheckout = [ "bin" "lists" ];
    hash = "";
  };
  bin = "${zapretfiles}/bin/";
  lists = "${zapretfiles}/lists/";
  GameFilter = "1024-65535";
in
{
  networking.firewall.extraCommands = ''
    ip46tables -t mangle -I POSTROUTING -p tcp --dport 443 -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:6 -m mark ! --mark 0x40000000/0x40000000 -j NFQUEUE --queue-num 200 --queue-bypass
    ip46tables -t mangle -A POSTROUTING -p udp -m multiport --dports 443,50000:50100 -m mark ! --mark 0x40000000/0x40000000 -j NFQUEUE --queue-num 200 --queue-bypass
  '';
  systemd.services.zapret = {
    description = "DPI bypass service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      ExecStart = ''
        ${pkgs.zapret}/bin/nfqws --pidfile=/run/nfqws.pid --qnum 200 \
        --filter-udp=443 --hostlist="${lists}list-general.txt" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="${bin}quic_initial_www_google_com.bin" --new \
        --filter-udp=50000-50100 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-repeats=6 --new \
        --filter-tcp=80 --hostlist="${lists}list-general.txt" --dpi-desync=fake,fakedsplit --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new \
        --filter-tcp=443 --hostlist="${lists}list-general.txt" --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=badseq --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="${bin}tls_clienthello_www_google_com.bin" --dpi-desync-fake-tls-mod=rnd,dupsid,sni=www.google.com --new \
        --filter-udp=443 --ipset="${lists}ipset-all.txt" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="${bin}quic_initial_www_google_com.bin" --new \
        --filter-tcp=80 --ipset="${lists}ipset-all.txt" --dpi-desync=fake,fakedsplit --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new \
        --filter-tcp=443,${GameFilter} --ipset="${lists}ipset-all.txt" --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=badseq --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="${bin}tls_clienthello_www_google_com.bin" --dpi-desync-fake-tls-mod=rnd,dupsid,sni=www.google.com --new \
        --filter-udp=${GameFilter} --ipset="${lists}ipset-all.txt" --dpi-desync=fake --dpi-desync-autottl=2 --dpi-desync-repeats=10 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="${bin}quic_initial_www_google_com.bin" --dpi-desync-cutoff=n2
      '';
      Type = "simple";
      PIDFile = "/run/nfqws.pid";
      Restart = "always";
      RuntimeMaxSec = "1h"; # This service loves to crash silently or cause network slowdowns. It also restarts instantly. Restarting it at least hourly provided the best experience.
    }; 
  };
}