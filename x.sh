for file in `git diff --dirstat=files,0 HEAD~1 | sed 's/^[ 0-9.]*% //g' | awk -F/ 'BEGIN {OFS="/"} {print $1,$2,""}'`; do
    echo File $file
    if [ -f $file/Dockerfile ]; then
        echo Dockerfile!
    fi
done

echo "action_state=`dirname a/b/c`"