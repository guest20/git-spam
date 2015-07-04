package Git::Spam::Commit;
#
#ABSTRACT: object representing a commit
#
use Object::Tiny::RW qw[ body subject author];
use Log::Any qw($log);
use warnings; use strict;

# ::Commit objects are created by ::Author

sub mangle {
    my ($self, $repo) = @_;

    # the commit message is formatted outside of here, but we want to make
    # some changes to the working copy on disk, so that we have something to
    # commit


    my @files   = eval { $repo->run('ls-files') };
    my @history = eval { $repo->run('log', '--oneline') };

    if (not @files and not @history) { 
        # this has to be the helo world commit.
        $self->{subject} = "Hello world";
        $self->{body}    = [];

        use Data::Dumper;
        print Dumper[
        $self->default_repo_content 
        ];
        #maybe just run $(dzil mint) here ?
        
    }
    else { 
        my $new_odds = $self->author->style->{additions}{new_file};
    }
    use Data::Dumper;
    print Dumper (\@files);
    
}


sub directory_change_weights { 
    # depending on the type of prject the repo is
    # (but just assume cpan dist)

}

sub default_repo_content {
    my $self = shift;

    my @meta = qw[ Foo Bar Baz Qux Fizz Buzz ];
    my @bs   = qw[ Singleton Factory Abstract ];

    my $top = delete $meta[ rand @meta ];

    my @packages = (
        ['Acme', $top],
        map { 
            ['Acme', $top, delete $meta[ rand @meta ] ]
        }
        0..rand @meta
    );

    my $files =  {
        bin => {
            (lc "acme-$top") => \ qq{/usr/bin/perl
    use Acme::$top;
    my \$a =Acme::$top->new_from_args(\\\@ARGV);
    exit \$a->run;},
            'report-bug' => \qq{:\necho "that's a feature"}
        },
        t => {
            '000-compiles.t' => 'use Test::More; fail("This software is nonsense");done_testing;'
        },
    };

    my @package_names = map { join '::', @$_ } @packages;

(
  (1==@$_)? $files->{lib}{ $_->[0]                            . '.pm'} :
  (2==@$_)? $files->{lib}{ $_->[0]}{$_->[1]                   . '.pm'} :
  (3==@$_)? $files->{lib}{ $_->[0]}{$_->[1]}{$_->[2]          . '.pm'} 
          : $files->{lib}{ $_->[0]}{$_->[1]}{$_->[2]}{$_->[3] . '.pm'} 
) = \(
    qq{package @{[ join '::', @$_]}; 
} . ($self->generated_gibberish( perl => { packages => \@package_names } ) || "\n" ).
q{
1}

) for @packages;

$files->{$_} = \"some misc cpan nonsense" for 
    'cpanfile',
    'dist.ini',
    'Makefile.PL',
    'MANIFEST',
    'META.json',
    'META.yml'
    ;

$files
}

sub generated_gibberish {
    my ($self, $type, $options ) = @_;
    die "only perl gibberish" if 'perl' ne $type;
    
    #   my @perl_in_this_repo = ` git ls-files *.pm `;
    #   my @text = slurp @perl_in_this_repo 
    #   %odds{$1}{$2} ++ while @text =~ /(\S+)\s(\S+)/;

    
    # some of these have matching close tokens, including (oddly) the ternary
    my @perl = (qw#
        for my $thing (@array {  
        if ( $thing  $other_thing  { 
        else { 
        $fixture-> run test pause resume send emit 
        while ( 1 
        continue next 
        unless (

        ?
        ->[ 
        ->{
        ->(

        use require do
        map grep filter first any

        $thing   
        $message $type $class 
        $self $self $self
        $package $package 

        __PACKAGE__ __FILE__ __SUB__

        @thing @items @lists
        %opts %options 

        -> ()
        ;

        /$regex/
        /$regex/smxg

        % + - * ^ 
        && || // == /= 

        > < = <= >=

        =~ =~ =~ 


        and or xor 


        CLOSE CLOSE CLOSE
        CLOSE CLOSE CLOSE
        CLOSE CLOSE CLOSE
        CLOSE CLOSE CLOSE
        CLOSE CLOSE CLOSE

        NEWLINE NEWLINE NEWLINE
        NEWLINE NEWLINE NEWLINE
        NEWLINE NEWLINE NEWLINE
        NEWLINE NEWLINE NEWLINE
        BLANKLINE 
        BLANKLINE 

    #,
    (exists $options->{packages} ? @{ $options->{packages} } : () ),
    );
    my %is_open = ( qw/
        (       )
        {       }
        ?       :
        ->[     ]
        ->{     }
        ->(     )
        ;       ;
    /);


    my $moar =1;
    my $opens=0;   my $ENOUGH_OPENS = 6;
    my @STACK;
    my @lines;
    my $line = '';

    while ($moar) { 
        my $thing = $perl[ rand @perl ];

        $opens++  if exists $is_open{ $thing };

        if ($is_open{ $thing } ){
            push @STACK, $thing;
        }
        
        if ($thing eq 'CLOSE' and @STACK){
            my $open =  pop @STACK;
            $thing = $is_open{ $open };
            
        }

        if ($thing eq 'NEWLINE' or $thing eq 'BLANKLINE') { 
            print  + ('    ' x @STACK ).  $line . "\n";

            push @lines, ('    ' x @STACK ).  $line;

            push @lines, '' if $thing eq 'BLANKLINE' and $lines[-1] ne "\n";

            $line = '';
        }
        elsif ($thing ne 'CLOSE') { 
            $line .= " "  . $thing;
        }

        if ($opens >= $ENOUGH_OPENS and not @STACK) {
            $moar =0
        }
    }
    

    join "\n", @lines;
}

1
