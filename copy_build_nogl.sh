if [ ! -e "build/RandomWebNOGL.saver" ]; then
  echo "Already copied?"
  exit
fi
rm -rf /Users/g4b3/Library/Screen\ Saver/RandomWebNOGL.saver/ && mv build/RandomWebNOGL.saver /Users/g4b3/Library/Screen\ Savers/

