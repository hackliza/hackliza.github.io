echo "Building website..."
hugo

COMMIT_MESSAGE="Publishing to gh-pages" 
echo "Commiting changes: '$COMMIT_MESSAGE'"
cd public && git add --all && git commit -m "$COMMIT_MESSAGE" && cd ..

echo "Uploading..."
git push origin gh-pages
