function pullmaster() {
    hg pull --hidden && hg rebase -d master -s 'children(ancestors(master) and (not master)) & bookmark(r"re:tonytung-*")'
    hg boo -d $(hg oldbm)
}
