cat<< _EOF_.abc >/dev/null
blah
blah
_EOF_.abc
echo hi

cat > "/dev/null" <<-"EOF"
    #!/bin/sh
    java -Dtijmp.jar="$(java-config -p tijmp)" -agentlib:tijmp "${@}"
EOF

cat > "/dev/null" <<-\EOF
    #!/bin/sh
    java -Dtijmp.jar="$(java-config -p tijmp)" -agentlib:tijmp "${@}"
EOF

cat<< 'FOO'
blah
blah
FOO

cat <<'FOO BAR'
one two three
FOO BAR

cat <<"FOO BAR"
one two three
FOO BAR
