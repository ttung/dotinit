function syncmaster() {
    hg-pullmaster.sh && \
        hg push $(hg boo -q | egrep '^tonytung' | awk '/^/{print "-B"}1') -f && \
        hg sl
}
