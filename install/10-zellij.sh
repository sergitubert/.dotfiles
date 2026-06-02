ZELLIJ_VERSION=$(curl -s "https://api.github.com/repos/zellij-org/zellij/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -sLo /tmp/zellij.tar.gz "https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz"
tar -xf /tmp/zellij.tar.gz -C /tmp zellij
sudo install /tmp/zellij /usr/local/bin
rm /tmp/zellij.tar.gz /tmp/zellij
