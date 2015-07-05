package Git::Spam::Commit;
#
#ABSTRACT: object representing a commit
#
use Object::Tiny::RW qw[ body subject author];
use Log::Any qw($log);
use warnings; use strict;

# ::Commit objects are created by ::Author

sub mangle { # git operations happen here, lol
    my ($self, $repo, $style) = @_;

    my $author= $self->author;

    my @files   = split /\n/,eval { $repo->run('ls-files') } || ();
    my @history = eval { $repo->run('log', '--oneline') } || ();

    my ($files); # keys are git-added, and comitted with $text
    if (not @files and not @history) { 
        #maybe just run $(dzil mint) here ?

        # this has to be the helo world commit.
        $self->{subject} = ["Hello","world"]; # [words]
        $self->{body}    = [[]];                # [ [words] ]

        $files = $self->default_repo_content;

        $self->write_things(
            $repo->{work_tree} => $files
        );

        
    }
    else { 
        #my $new_odds = $self->author->style->{additions}{new_file};

        my %modify_exts # should come from author...
            #      odds of modify, odds to insert stuff, odds to remove
            = ( pl => [1/@files,     0.002      ,         0.01  ,            'perl'], 
                pm => [1/@files,     0.002      ,         0.01  ,            'perl'],
             );

        # randomly mangle files in the repo
        for my $repo_file (@files) { 
            my ($ext) = $repo_file =~ /[.](\w+)$/;

            my $file = $repo->{work_tree} . '/' . $repo_file;

            my $odds = exists $modify_exts{ $ext } ? $modify_exts{ $ext } : [1,undef];
            $log->tracef( 'consider %s ext=%s %s', $file, $ext, $odds);

            if ( $odds and $odds->[0] < rand) {
                # roll dice on changing the files
                $log->tracef( '... modifying ');

                $files->{$repo_file} = "patched";

                open my $in, '<', $file or do {
                    $log->critf("Couldn't open %s, %s - it will be spared.", $file, $!);
                    next;
                };
                unlink $file; 
                open my $out, '>', $file or do {
                    $log->critf("Couldn't open %s, %s - I just destroyed its contents, oops.", $file, $!);
                    next;
                };
                my $options = { ENOUGH_OPENS => 1 };
                while (defined( $_ = <$in>) ) {
                    
                    # odds to insert stuff
                    print { $out } $self->generated_gibberish( $odds->[-1], $options )
                        if $odds->[1] > rand;  

                    # odds to skip a line
                    print { $out } $_
                        if ($odds->[2] < rand) .. 0.75 > rand ;
            
                }
            }
        }
            
    }

    # format up a commit message
    my $text = $style->format_message( $self );

    # pretend to be the guy and commit it
    local @ENV{ qw[ 
        GIT_AUTHOR_NAME
        GIT_COMMITTER_NAME

        GIT_COMMITTER_EMAIL
        GIT_AUTHOR_EMAIL 
    ] } = (
        $author->name,
        $author->name,
        $author->email,
        $author->email,
    );

    # keys of the hash should be fine to git add...
    $repo->run( add => keys %$files );
    $repo->run( commit => 
        "-m$text",
        '--',
         keys %$files
    );

    $log->infof('comitted %s: %s', 
        $text =~ /^(.*)$/ ? $1 : '',
        0+keys %$files,
    )

    # the commits will be pushed (if they are pushed) by the loop in ::Command
    
}

sub write_things {
    my ($self, $dest,$things)  = @_;

    $log->debugf("Writing things to %s", $dest);
    

    for my $dir ( keys  %$things ) {
        $log->debugf('... %s is a %s', $dir, ref $things->{ $dir } );
        if ('HASH' eq ref $things->{ $dir } ) { 
            # hash makes it a directory
            mkdir "$dest/$dir"
                or  $log->warnf("Can't mkdir %s: %s", "$dest/$dir", $!);
            $self->write_things( "$dest/$dir", $things->{ $dir } );
        }
        elsif('SCALAR' eq ref $things->{ $dir } ){
            # scalar ref makes it a file
            open my $file, '>', "$dest/$dir"
                or die $log->critf("Can't open %s for writing: %s", "$dest/$dir", $!);
            print { $file } ${ $things->{ $dir } }
                or die  $log->critf("write to %s: %s", "$dest/$dir", $!);
    
        }
    }

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
        1..rand @meta
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
            '000-compiles.t' => \'use Test::More; fail("This software is nonsense");done_testing;'
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
    my $opens=0;   my $ENOUGH_OPENS = $options->{ENOUGH_OPENS} || 6;
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
            # print  + ('    ' x @STACK ).  $line . "\n";

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
