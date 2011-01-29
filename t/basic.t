use strictures 1;
use Test::More  0.96;
use Test::Fatal 0.003;

use syntax 'moo';

my $role = role Foo::Role 2.34 {
    sub role_method { __PACKAGE__ }
};

my $class = class Foo::Class 3.45 {
    sub class_method { __PACKAGE__ }
    with $role;
};

is $role,  'Foo::Role',  'correct role name returned';
is $class, 'Foo::Class', 'correct class name returned';

is $role->VERSION,  2.34, 'correct role version';
is $class->VERSION, 3.45, 'correct class version';

is $role->role_method,   $role,  'role method on role';
is $class->class_method, $class, 'class method on class';
is $class->role_method,  $role,  'role method on class';

my $implicit_role = do {
    package Bar::Role;
    use syntax 'moo';
    role {
        sub role_method { __PACKAGE__ }
    };
};

my $implicit_class = do {
    package Bar::Class;
    use syntax 'moo';
    class {
        sub class_method { __PACKAGE__ }
        with $implicit_role;
    };
};

is $implicit_role,  'Bar::Role',  'correct implicit role name returned';
is $implicit_class, 'Bar::Class', 'correct implicit class name returned';

is $implicit_role->role_method,   'Bar::Role',  'role method on role';
is $implicit_class->class_method, 'Bar::Class', 'class method on class';
is $implicit_class->role_method,  'Bar::Role',  'role method on class';

done_testing;
