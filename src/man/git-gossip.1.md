%GIT-GOSSIP(1) | .ENV Secret Scrubbing

# NAME

git-gossip - A utility for preventing secrets in .env files from being added

# SYNOPSIS

**git gossip init**

**git gossip add** _variable_ ...

# EXAMPLES

**git gossip init**
: Configures a repo with the ability to use **git-gossip**

**git gossip add** *SECRET_PASSWORD* *SECRET_API_KEY*
: Prevents the values of *SECRET_PASSWORD* and *SECRET_API_KEY* from being
committed to the repository.

