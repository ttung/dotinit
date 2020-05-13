function syncmaster() {
    hg-pullmaster.sh && \
        [ $(hg boo -q | egrep '^t(ony)?tung' | wc -l) -ne 0 ] && hg push $(hg boo -q | egrep '^t(ony)?tung' | awk '/^/{print "-B"}1') -f && \
        hg sl
}
