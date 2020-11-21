echo "Building website into public..."
hugo
cd public && git add --all && git commit -m "Publishing to gh-pages" && cd ..

echo "Website built, execute 'git push origin gh-pages'"
