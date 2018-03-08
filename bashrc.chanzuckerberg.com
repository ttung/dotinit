function pullmaster() {
    hg pull --hidden
    hg boo -d $(hg oldbm)
    hg strip $(hg log -T '{node}\n' -r 'obsolete()')
    hg rebase -d master -s 'children(ancestors(master) and (not master)) & bookmark(r"re:tonytung-*")'
    if [ $? -ne 0 ]; then
        return $?
    fi
    hg boo -d $(hg oldbm)
    hg strip $(hg log -T '{node}\n' -r 'unstable()')
    return 0
}

function syncmaster() {
    pullmaster && \
        hg push $(hg boo -q | egrep '^tonytung' | awk '/^/{print "-B"}1') -f && \
        hg sl
}
