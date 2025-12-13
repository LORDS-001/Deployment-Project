if [ ! -f index.html ]; then
    echo "ERROR: index.html file not found!"
    exit 1
fi

if [ ! -s index.html ]; then
    echo "ERROR: index.html is empty!"
    exit 1
fi

echo "Test successful: index.html exists and is not empty."
exit 0