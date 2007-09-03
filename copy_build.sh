if [ ! -e build/RandomWeb.saver ]; then
  echo "Already copied?"
  exit
fi
rm -rf /Users/g4b3/Library/Screen\ Savers/RandomWeb.saver && mv build/RandomWeb.saver /Users/g4b3/Library/Screen\ Savers/
