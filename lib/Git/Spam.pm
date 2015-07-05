package Git::Spam;

##############################################################################

=head1 NAME

Git::Spam - generate a bunch of noise on a git repo.

=head1 ABSTRACT

Produce a flow of commits and/or pushes to a named git repo in order to 
allow one to test hooks and nonsense like that.

=head1 USAGE

 bin/git-spam

The script has usage information and won't actaully be noisy until you 
specify C<-f>. This is mostly to stop folks accidently destroyign the wrong
repository while plaing with C<git-spam>).

=cut


