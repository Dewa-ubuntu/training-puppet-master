# base-classes.pp: classes, possibly parameterized
import "base-classes.pp"

# classes.pp: non-parameterized wrapper classes
#                     for use with Puppet Dashboard
import "classes.pp"

# nodes.pp: node-specific configuration
import "nodes.pp"
