This repositry has xtetsuji's dotfiles.

You can use at ordinary 

- Linux (especially Debian GNU/Linux & Ubuntu)
- macOS (Darwin)

environment maybe.

Now, I am using this dotfiles on my MacBook Air environment (Mountain Lion -> Mavericks),
and some version's Debian GNU/Linux environment.

## Features

### cdwt - Change Directory to git WorkTree

Interactive git worktree directory selector command.

```bash
cdwt
# select git worktree directories interactively
pwd
# change directory!
```

- Uses `fzf` for interactive selection if available
- Falls back to numbered selection if `fzf` is not installed
- Works in both bash and zsh environments

Those files license are **MIT License** without mentioned in it.

OGATA Tetsuji at 2013/03/19
OGATA Tetsuji at 2014/05/15
