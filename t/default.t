use strictures 1;
use Test::More  0.96;
use Test::Fatal 0.003;

use syntax 'moo/default';

my $post_modifier;
my $role = role Foo::Role 2.34 {
    method role_method { __PACKAGE__ }
    after class_method { $post_modifier++ }
};

my $class = class Foo::Class 3.45 {
    has bar => (
        is  => 'rw',
        isa => quote_sub q{ die "no good\n" if $_[0] < 10 },
    );
    method class_method { __PACKAGE__ }
    with $role;
};

is $role,  'Foo::Role',  'correct role name returned';
is $class, 'Foo::Class', 'correct class name returned';

is $role->VERSION,  2.34, 'correct role version';
is $class->VERSION, 3.45, 'correct class version';

is $role->role_method,   $role,  'role method on role';
is $class->class_method, $class, 'class method on class';
is $class->role_method,  $role,  'role method on class';

ok $post_modifier, 'method modifier worked';

my $obj = $class->new(bar => 15);
is(exception { $obj->bar(7) }, "no good\n", 'quote_sub');

my $nested_class = class Foo::Nested {
    use syntax method => { -as => 'met' };
    met foo { 23 }
};

is $nested_class->foo, 23, 'nested imports still work';

do {
    package TestInv;
    use syntax 'moo/default' => {
        -modifier => { -invocant => '$rs' },
        -method   => { -invocant => '$rs' },
    };
    my $inv = class Foo::RenamedInv {
        method foo ($n) { $n }
        method bar ($n) { $rs->foo($n) }
        around bar ($n) { 2 * $rs->$orig($n) }
    };
    ::is $inv->bar(23), 46, 'renamed invocant';
};

do {
    package TestImplicit;
    use syntax 'moo/default';
    class 2.34 {
        method foo { 23 }
    };
    ::is __PACKAGE__->foo, 23, 'implicit package name';
};


my $cleaned = class Foo::Cleaned {
    use Scalar::Util qw( blessed );
    use namespace::clean;
    sub check { blessed shift }
};

is $cleaned->new->check, 'Foo::Cleaned', 'import use';
ok not($cleaned->can('blessed')), 'no blessed method';
ok not($cleaned->can('has')), 'no has method';

done_testing;
