function pullmaster() {
    hg boo -d $(hg boo -q | egrep -v '(^tonytung|^master$)')
    hg pull --hidden
    hg boo -d $(hg oldbm)
    hg strip $(hg log -T '{node}\n' -r 'obsolete()')
    hg rebase -d master -s 'children(ancestors(master)) & (not ancestors(master)) & ancestors(author(ttung))'
    if [ $? -ne 0 ]; then
        return $?
    fi
    hg boo -d $(hg oldbm)
    hg strip $(hg log -T '{node}\n' -r 'unstable()')
    hg strip -r 'not (bookmark() or ancestors(bookmark()) or author(ttung))'
    return 0
}

function syncmaster() {
    pullmaster && \
        hg push $(hg boo -q | egrep '^tonytung' | awk '/^/{print "-B"}1') -f && \
        hg sl
}
