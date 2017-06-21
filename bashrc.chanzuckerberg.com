function pullmaster() {
    local oldmaster=$(hg log -T '{node}\n' -r master)
    hg pull --hidden && hg rebase -d master -s "children($oldmaster) and (not(ancestor(master)))" && hg boo -d $(hg oldbm)
}
