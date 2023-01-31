# Git Gossip

A utility for removing secrets from git commits

## Installation

### From Source

In order to install git gossip from source, you must have the following
installed:

* make
* pandoc

Once the build dependencies are installed, run the following command to build
and install the application to `/usr/local`. 

```bash
make && sudo make install
```

If you would rather install the application to `$HOME/.local` run the following
command:

```bash
make && PREFIX="$HOME/.local" make install
```

## Getting Started

Run the following command within a git repository to configure it for usage with
`git-gossip`:

```bash
git gossip init
```

Once the repository is initialized, run the following command to protect the
value of the property `SECRET_PASSWORD` within `.env` files.

```bash
git gossip add SECRET_PASSWORD
```

Be sure to commit the `.gitattributes` and `.gitgossip` files that are created
after running `git gossip init`. Also rerun `git gossip init` when initially
cloning a repository that is configured to use `git gossip`.

