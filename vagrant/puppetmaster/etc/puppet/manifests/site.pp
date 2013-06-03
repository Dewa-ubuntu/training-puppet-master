# defaults.pp: local defaults
import "defaults.pp"

# defines.pp: locally defined types
import "defines.pp"

# base-classes.pp: classes, possibly parameterized
import "base-classes.pp"
import "ceph-base-classes.pp"

# classes.pp: non-parameterized wrapper classes
#                     for use with Puppet Dashboard
import "classes.pp"
import "ceph-classes.pp"

# nodes.pp: node-specific configuration
import "nodes.pp"
