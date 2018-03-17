sudo apt-get clean
sudo apt-get update
sudo apt-get install vim git tmate
curl https://raw.githubusercontent.com/DexterShepherd/dotfiles/master/vimrc.pi > ~/.vimrc

if ! [ -x "$(command -v processing-java)" ]; then
  echo 'installing processing-java' >&2
  curl https://processing.org/download/install-arm.sh | sudo sh
fi

