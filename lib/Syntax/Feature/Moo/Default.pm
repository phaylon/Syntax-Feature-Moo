use strictures 1;

# ABSTRACT: Extended Moo class/role syntax

package Syntax::Feature::Moo::Default;
use parent 'Syntax::Feature::Moo';

use Syntax::Feature::Method             0.001   ();
use Syntax::Feature::Function           0.001   ();
use Syntax::Feature::Sugar::Callbacks   0.001   ();
use Carp                                        qw( croak );
use Params::Classify                    0.011   qw( is_ref );
use Sub::Quote                                  ();
use Data::Dump                                  qw( pp );

use namespace::clean 0.18;

$Carp::Internal{ +__PACKAGE__ }++;

sub _default_inner {
    'method'            => $_[1]{ -method },
    'function'          => $_[1]{ -function },
    'sugar/callbacks'   => {
        -invocant   => $_[1]{ -modifier }{ -invocant },
        -callbacks  => {
            before  => {},
            after   => {},
            around  => { -before => ['$orig'] },
        },
    },
}

sub _common_preamble {
    sprintf('use Sub::Quote %s',
        join ', ', map pp($_),
            @{ $_[1]{ -sub_quote } || [qw( quote_sub )] },
    ),
}

sub _final_preamble {
    $_[1]{ -no_clean } ? (
        'use namespace::clean',
        'no namespace::clean',
    ) : (),
}

1;

__END__

=head1 SYNOPSIS

    use syntax 'moo/default';

    class Foo 2.34 {
        has class_attr => (...);
        method class_method { ... }
    };

    role Bar 3.45 {
        has role_attr => (...);
        method role_method { ... }
        before something { ... }
    };

=head1 DESCRIPTION

This is an extended version of L<Syntax::Feature::Moo> that will provide
some further extensions and libraries by default. Namely:

=over

=item * L<Syntax::Feature::Function>

To provide a C<fun> keyword. You can override the settings passed to
this extension by setting the L</-function> option.

=item * L<Syntax::Feature::Method>

To provide a C<method> keyword. You can override the settings passed to
this extension by setting the L</-method> option.

=item * L<Syntax::Feature::Sugar::Callbacks>

This extension will be used to provide C<around>, C<before> and C<after>
syntax that mimics that of L<Syntax::Feature::Method>. You can change the
invocant by setting the L</-modifier> option.

=item * L<Sub::Quote>

An inline function callback generator compatible with L<Moo>. By default
only L<Moo/quote_sub> will be provided, but you can override the import
arguments by setting the L</-sub_quote> option.

=item * L<namespace::clean>

This won't really be available, it is used to clean up after the imports
and extensions have been setup. It will be reset after it has done its job,
so you can safely re-use it.

=back

=head1 OPTIONS

The same rules as in L<Syntax::Feature::Moo> apply here. Additionally
the following options are recognized:

=head2 -method

    use syntax 'moo/default' => { -method => { -as => 'met' } };

    class Foo::Bar {
        met baz ($n) { $n * $n }
    };

Can be used to override the options for the L<Syntax::Feature::Method>
extension.

=head2 -function

    use syntax 'moo/default' => { -function => { -as => 'f' } };

    class Foo::Bar {
        method baz { f ($n) { $n * $n } }
    };

Can be used to override the options for the L<Syntax::Feature::Function>
extension.

=head2 -sub_quote

    use syntax 'moo/default' => {
        -sub_quote => [qw( quote_sub unquote_sub )],
    };

Can be used to override the import arguments for L<Sub::Quote>.

=head2 -no_clean

This option will deactivate the usage of L<namespace::clean> to clean up
after all automatic imports have been done.

=head2 -modifier

This can be used to set options for the method modifier sugar. Currently,
only C<-invocant> is supported:

    use syntax 'moo/default' => {
        -modifier => { -invocant => '$rs' },
        -method   => { -invocant => '$rs' },
    };

    class Foo extends Bar {
        method sorted_rs { $rs->search_rs({}, { order_by => 'foo' }) }
        before insert { $rs->log('insert') }
    };

As you can see, this makes mostly sense when paired with
L<Syntax::Feature::Method/-invocant>.

=head1 SEE ALSO

=over

=item * L<syntax>

=item * L<Syntax::Feature::Moo>

=item * L<Moo::Role>

=item * L<Function::Parameters>

=item * L<Method::Signatures::Simple>

=item * L<Sub::Quote>

=item * L<Syntax::Feature::Method>

=item * L<Syntax::Feature::Function>

=back

=cut
