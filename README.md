# git-spam
Create a series of spammy git commits to test your git hooks 

# Usage

link to `bin/git-spam` from somewhere in your `$PATH` then

```
$ cd not-important-repo
$ git-spam -f 
# ... pages of nonsense spewed out on terminal
$ git log --oneline
```

You now have a bundle of worthless nonsense in your history.

# What? why?

Sometimes you just want to test your `post-receive` hook, and you really don't have time to sit there 
waiting for someone to push some commits to you repo.

# Things that could make this project even better
- [ ] Support for generating nonsense in languages other than perl 
- [ ] Use a markov chain to generate commit messages
- [ ] ... for that matter, fetching all sorts of frequency info from another repo and using that
- [ ] ... with anonimisation options
- [ ] Options for pushing as other users (say with different ssh keys)
- [ ] Ability for bogus committers to revert commits too
- [ ] some kind of marker to indicate which commits came from this script (so they can be easily reverted)
- [ ] Have the bogus authors rebase commits (by running 2 instances at the same time?)
- [ ] Have some authors insist on doing merges 
- [ ] ... and have them resolve conflicts in their own favour, even when they're clearly being jerks and breaking the project >_<
