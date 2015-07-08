# git-spam
Create a series of spammy git commits to test your git hooks 

# Usage

link to `bin/git-spam` from somewhere in your `$PATH` then

```bash
$ cd /tmp/nowhere
$ git init # or clone
$ ~/github/git-spam/bin/git-spam -f 
Switching to 'Spammy McJerkerson' for [1,5] commits
   comitted 9: Hello world
   comitted 1: Bazza broke his leg playing cricket the other day I'm
   comitted 1: your better half gidday BYO Ridgy-didge G'day . bloody
# ...
$ git log --oneline
5eda348 I'm a seppo Clown's Bloody Ripper Bazza broke his leg 
07cfd00 Ta My clubby cossie's No Wuckas The local Fair Dinkum!!
c59f039 corge foobar garply bar qux garply
# ...
$
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
