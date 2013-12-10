while [[ 1 ]]; do
    USER_ID=$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM;
    FLAG=$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM;
    id=`./nsaless.checker.js put 127.0.0.1 $USER_ID $FLAG 2> last_put.log`;
    cat last_put.log;
    `./nsaless.checker.js get 127.0.0.1 $id $FLAG`;
done
