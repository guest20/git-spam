package Git::Spam::CommitStyle;

use Object::Tiny::RW qw[ author ];
use warnings; use strict;

sub format_message {
    my $self = shift;
    my $commit = shift;

    my $style = $commit->author->style;

    # format the commit
    my $string = '';

    $string =  '';

    $string .= ($string eq ''  ? '' : " ") . shift @{ $commit->{subject} }
                while @{ $commit->{subject} }                               # while there are more characters
                    and length( $string ) < $style->{Flags}{subject}{max}   # ... and we don't have enough
            ;

    # continue a long subject
    $string .= "\n..." . join ' ', @{ $commit->{subject} } if @{ $commit->{subject} };

    if (exists $commit->{body} ) { #
        $string .= "\n\n";

        for my $para ( @{ $commit->{body} } ) {
            my $line = '';
            for my $word (@$para) { 
                if ( 
                    (length ($line)  + length($word) ) 
                    > (eval { $style->{Flags}{body}{wrap} } || 30 + rand 30)  ) { 

                    $string .= "$line\n";
                    $line = $word;
                }
                else {
                    $line .= " $word";
                }
            }
            $string .= "\n";
        }
    }
    $string
}
1
