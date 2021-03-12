
#code to check for debug-sync
if ! $XB_BIN --help 2>&1 | grep -q debug-sync; then
    skip_test "Requires --debug-sync support"
fi
