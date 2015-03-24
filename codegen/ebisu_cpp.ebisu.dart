import "dart:io";
import "package:path/path.dart" as path;
import "package:ebisu/ebisu.dart";
import "package:ebisu/ebisu_dart_meta.dart";
import "package:logging/logging.dart";

String _topDir;

void main() {

  Logger.root.onRecord.listen((LogRecord r) =>
      print("${r.loggerName} [${r.level}]:\t${r.message}"));
  String here = path.absolute(Platform.script.path);
  _topDir = path.dirname(path.dirname(here));
  useDartFormatter = true;
  System ebisu = system('ebisu_cpp')
    ..includesHop = true
    ..license = 'boost'
    ..pubSpec.homepage = 'https://github.com/patefacio/ebisu_cpp'
    ..pubSpec.version = '0.0.7'
    ..pubSpec.doc = 'A library that supports code generation of cpp and others'
    ..pubSpec.addDependency(new PubDependency('path')..version = ">=1.3.0<1.4.0")
    ..pubSpec.addDevDependency(new PubDependency('unittest'))
    ..rootPath = _topDir
    ..doc = 'A library that supports code generation of cpp'
    ..testLibraries = [
      library('test_cpp_enum'),
      library('test_cpp_member'),
      library('test_cpp_class'),
      library('test_cpp_method'),
      library('test_cpp_utils'),
      library('test_cpp_namer'),
      library('test_hdf5_support'),
    ]
    ..libraries = [
      library('ebisu_cpp')
      ..doc = cppLibraryDoc
      ..includesLogger = true
      ..imports = [
        'package:id/id.dart',
        'package:ebisu/ebisu.dart',
        'package:quiver/iterables.dart',
        "'package:path/path.dart' as path",
        'dart:io',
        'dart:collection',
      ]
      ..enums = [
        enum_('access')
        ..doc = '''
Access designation for a class member variable.

C++ supports *public*, *private* and *protected* designations. This designation
is at a higher abstraction in that selecting access determines both the c++
protection as well as the set of accessors that are generated. *Member*
instances have both *access* and *cppAccess* so full range is available, but
general cases should be covered by setting only the *access* variable of a
member.

* IA: *inaccessible* which provides no accessor with c++ access *private*.
  It is aliased to *ia*.

* RO: *read-only* which provides a read accessor with c++ access *private*.
  It is aliased to *ro*.

* RW: *read-write* which provides read and write accessor with c++ access *private*.
  It is aliased to *rw*.

* WO: *write-only* which provides write access and the c++ access is *private*.
  It is aliased to *wo*. It may sound counterintuitive, but a use case for this
  might be to accept the generated write accessor but hand code a read accessor
  requiring special logic.

Note: If the desire is to have a public member that is public and has no
accessors, set *cppAccess* to *public* andd set *access* to null.

# Examples

*cppAccess* null with *access* of *ro* gives:

    class C_1
    {
    public:
      //! getter for x_ (access is Ro)
      std::string const& x() const { return x_; }
    private:
      std::string x_ {};
    };

*cppAccess* CppAccess.protected with *access* of *ro* gives:

    class C_1
    {
    public:
      //! getter for x_ (access is Ro)
      std::string const& x() const { return x_; }
    protected:
      std::string x_ {};
    };
'''
        ..hasLibraryScopedValues = true
        ..values = [
          enumValue(id('ia'))
          ..doc = '**Inaccessible**. Designates a member that is *private* by default and no accessors',
          enumValue(id('ro'))
          ..doc = '**Read-Only**. Designates a member tht is *private* by default and a read accessor',
          enumValue(id('rw'))
          ..doc = '**Read-Write**. Designates a member tht is *private* by default and both read and write accessors',
          enumValue(id('wo'))
          ..doc = '''
**Write-Only**. Designates a member tht is *private* by default and
write accessor only.  Useful if you want the standard write accessor
but a custom reader.''',
        ],
        enum_('cpp_access')
        ..doc = '''
Cpp access designations:

  * public
  * private
  * protected

This designation is used in multiple contexts such as:

  * Overriding the protection of a member
  * On *Base* instances to indicate the access associated with inheritance
  * On class methods (ctor, dtor, ...) to designate access
'''
        ..hasLibraryScopedValues = true
        ..values = [
          enumValue(id('public'))
          ..doc = 'C++ public designation',
          enumValue(id('protected'))
          ..doc = 'C++ protected designation',
          enumValue(id('private'))
          ..doc = 'C++ private designation',
        ],
        enum_('ref_type')
        ..doc = 'Reference type'
        ..hasLibraryScopedValues = true
        ..values = [
          enumValue(id('ref'))
          ..doc = 'Indicates a reference to type: *T &*',
          enumValue(id('cref'))
          ..doc = 'Indicates a const reference to type: *T const&*',
          enumValue(id('vref'))
          ..doc = 'Indicates a volatile reference to type: *T volatile&*',
          enumValue(id('cvref'))
          ..doc = 'Indicates a const volatile reference to type: *T const volatile&*',
          enumValue(id('value'))
          ..doc = 'Indicates not a reference'
        ],
        enum_('ptr_type')
        ..doc = 'Standard pointer type declaration'
        ..hasLibraryScopedValues = true
        ..values = [
          enumValue(id('sptr'))
          ..doc = 'Indicates *std::shared_ptr< T >*',
          enumValue(id('uptr'))
          ..doc = 'Indicates *std::unique_ptr< T >*',
          enumValue(id('scptr'))
          ..doc = 'Indicates *std::shared_ptr< const T >*',
          enumValue(id('ucptr'))
          ..doc = 'Indicates *std::unique_ptr< const T >*',
        ],
      ]
      ..classes = [

        class_('installation_decorator')
        ..isAbstract = true
        ..doc = '''
Establishes an interface to allow decoration of classes and updates
(primarily additions) to an [Installation].
''',

        class_('entity')
        ..isAbstract = true
        ..doc = '''
Exposes common elements for named entities, including their [id] and
documentation. Additionally tracks parentage/ownership of entities.

This is abstract for purposes of ownership. Each [Entity] knows its
owning entity up until [Installation] which is the root entity. A call
to [generate] on [Installation] will [setOwnership] which subclasses
can trick down establishing ownership.

The purpose of linking all [Entity] instances in a virtual tree type
structure is so lookups can be done for entities.
'''
        ..members = [
          member('id')
          ..doc = 'Id for the entity'
          ..type = 'Id'..ctors = [''],
          member('brief')
          ..doc = 'Brief description for the entity',
          member('descr')
          ..doc = 'Description of entity',
          member('owner')
          ..doc = '''
The entity containing this entity (e.g. the [Class] containing the [Member]).
[Installation] is a top level entity and has no owner.
'''
          ..access = RO
          ..type = 'Entity',
          member('entity_path')
          ..doc = 'Path from root to this entity'
          ..type = 'List<Entity>'
          ..access = RO
          ..classInit = [],
          member('namer')
          ..doc = '''
Namer to be used when generating names during generation. There is a
default namer, [EbisuCppNamer] that is used if one is not provide. To
create your own naming conventions, provide an implementation of
[Namer] and set an assign that namer to a top-level [Entity], such as
the [Installation]. The assigned namer will be propogated to all
genration utilities.
'''
          ..access = IA
          ..type = 'Namer',
        ],
        class_('template')
        ..doc = '''
Represents a template declaration comprized of a list of [decls]
'''
        ..members = [
          member('decls')
          ..doc = 'List of decls in the template (i.e. the typename entries)'
          ..type = 'List<String>',
        ],
      ]
      ..parts = [
        part('utils')
        ..classes = [
          class_('const_expr')
          ..doc = 'Simple variable constexprs'
          ..extend = 'Entity'
          ..members = [
            member('type')
            ..doc = 'The c++ type of the constexpr',
            member('value')
            ..doc = 'The initialization for the constexpr'
            ..access = RO,
            member('namespace')
            ..doc = 'Any namespace to wrap the constexpr in'
            ..type = 'Namespace',
          ],
          class_('forward_decl')
          ..doc = 'A forward declaration'
          ..hasCtorSansNew = true
          ..members = [
            member('type')
            ..doc = 'The c++ type being forward declared'
            ..ctors = [''],
            member('namespace')
            ..doc = 'The namespace to which the class being forward declared belongs'
            ..type = 'Namespace'..ctorsOpt = [''],
          ],
          class_('code_generator')
          ..doc = 'Establishes an interface for generating code'
          ..isAbstract = true,
          class_('friend_class_decl')
          ..doc = 'Friend class declaration'
          ..isImmutable = true
          ..hasCtorSansNew = true
          ..members = [
            member('decl')
            ..doc = 'Declaration text without the *friend* and *class* keywords'
          ],
          class_('namespace')
          ..doc = 'Represents a c++ namespace which is essentially a list of names'
          ..members = [
            member('names')
            ..doc = 'The individual names in the namespace'
            ..type = 'List<String>'..classInit = [],
          ],
          class_('includes')
          ..doc = 'Collection of header includes'
          ..members = [
            member('included')
            ..doc = 'Set of strings representing the includes'
            ..access = RO
            ..type = 'Set<String>'
          ],
          class_('namer')
          ..doc = 'Provides support for consistent naming of C++ entities'
          ..isAbstract = true,
          class_('ebisu_cpp_namer')
          ..implement = [ 'Namer' ]
          ..doc = '''
Default namer establishing reasonable conventions, that are fairly
*snake* case heavy like the STL.
''',
          class_('google_namer')
          ..implement = [ 'Namer' ]
          ..doc = 'Namer based on google coding conventions',
          class_('base')
          ..doc = '''
A base class of another class.


The style of inheritance is determined by [virtual] and [access]. Examples:

Default is *not* virtual and [public] inheritance:

    class_('derived')
    ..bases = [
      base('Base')
    ];

gives:

    class Derived : public Base {};

With overrides:

    class_('derived')
    ..bases = [
      base('Base')
      ..isVirtual = true
      ..access = protected
    ];

Gives:

    class Derived :
      protected virtual Base
    {
    };
'''
          ..hasCtorSansNew = true
          ..members = [
            member('class_name')
            ..doc = 'The name of the class being derived from'
            ..ctors = [''],
            member('access')
            ..doc = 'Is base class public, protected, or private'
            ..type = 'CppAccess'..classInit = 'public',
            member('init')
            ..doc = 'How to initiailize the base class in ctor initializer',
            member('is_virtual')
            ..doc = 'If true inheritance is virtual'
            ..classInit = false,
            member('is_streamable')
            ..doc = 'If true and streamers are being provided, base is streamed first'
            ..classInit = false,
          ]
        ],
        part('file')
        ..classes = [
          class_('cpp_file')
          ..doc = '''
Establishes an interface and common elements for c++ file, such as
*Header* and *Impl*.'''
          ..isAbstract = true
          ..extend = 'Entity'
          ..members = [
            member('namespace')
            ..doc = 'Namespace associated with this file'
            ..type = 'Namespace',
            member('custom_blocks')
            ..doc = '''
List of blocks requiring custom code and therefore inserted into the
file with *Protect Blocks*. Note it is a list of *FileCodeBlock*
enumeration values. *CodeBlocks* can be used to inject code into
the location designated by their value. Additionally *CodeBlocks*
have support for a single custom *Protect Block*'''
            ..type = 'List<FileCodeBlock>'..classInit = [],
            member('code_blocks')
            ..doc = '''
Mapping of the *FileCodeBlock* to the corresponding *CodeBlock*.'''
            ..type = 'Map<FileCodeBlock, CodeBlock>'..access = IA..classInit = {},
            member('classes')
            ..doc = 'List of classes whose definitions are included in this file'
            ..type = 'List<Class>'..classInit = [],
            member('includes')
            ..doc = 'List of includes required by this c++ file'
            ..type = 'Includes'..access = RO..classInit = 'new Includes()',
            member('const_exprs')
            ..doc = 'List of c++ *constexprs* that will appear near the top of the file'
            ..type = 'List<ConstExpr>'..classInit = [],
            member('forward_decls')
            ..doc = 'List of forward declarations that will appear near the top of the file'
            ..type = 'List<ForwardDecl>'..classInit = [],
            member('usings')
            ..doc = 'List of using statements that will appear near the top of the file'
            ..type = 'List<String>'..classInit = [],
            member('enums')
            ..doc = 'List of enumerations that will appear near the top of the file'
            ..type = 'List<Enum>'..classInit = [],
            member('interfaces')
            ..doc = '''
List of interfaces for this header. Interfaces result in either:

* abstract base class with pure virtual methods
* static polymorphic base class with inline forwarding methods
'''
            ..type = 'List<Interface>'..classInit = []
          ],
        ],
        part('enum')
        ..classes = [
          class_('enum')
          ..doc = 'A c++ enumeration'
          ..extend = 'Entity'
          ..members = [
            member('values')
            ..doc = 'Strings for the values of the enum'
            ..type = 'List<String>'
            ..access = RO,
            member('ids')
            ..doc = 'Ids for the values of the enum'
            ..type = 'List<Id>'
            ..access = IA,
            member('value_names')
            ..doc = 'Names for values as they appear'
            ..type = 'List<String>'
            ..access = IA,
            member('value_map')
            ..doc = 'String value, numeric value pairs'
            ..type = 'Map<String, int>'
            ..access = RO,
            member('is_class')
            ..doc = 'If true the enum is a class enum as opposed to "plain" enum'..classInit = false,
            member('has_from_c_str')
            ..doc = 'If true adds from_c_str method'..classInit = false,
            member('has_to_c_str')
            ..doc = 'If true adds to_c_str method'..classInit = false,
            member('is_streamable')
            ..doc = 'If true adds streaming support'..classInit = false,
            member('is_mask')
            ..doc = 'If true the values are powers of two for bit masking'..classInit = false,
            member('is_nested')
            ..doc = 'If true is nested in class and requires *friend* stream support'..classInit = false,
          ],
        ],
        part('member')
        ..classes = [
          class_('member')
          ..doc = '''
A member or field included in a class.

## Basics

Members are typed (i.e. have [type]) and optionally initialized.

For example:

    member('widget')..type = 'Widget'..init = 'Widget()'

gives:

    Widget widget_ { Widget() };

For some C++ types (*double*, *int*, *std::string*, *bool*) the type
can be inferred if a suitable [init] is provided:

Examples:

    member('number')..init = 4
    member('pi')..init = 3.14
    member('default_tag')..init = 'empty'
    member('is_strong')..init = false

give respectively:

    int number_ { 4 };
    double pi_ { 3.14 };
    std::string default_tag_ { "empty" };
    bool is_strong_ { false };

## Encapsulation

Encapsulation can be achieved by setting [access] and/or
[cppAccess]. Setting [access] is the preferred approach since it
provides a consistent, sensible pattern for hiding and accessing
members (See [Access]).

*Read-Only* Example:

    (class_('c')
        ..members = [
          member('readable')..init = 'foo'..access = ro
        ])
    .definition

Gives:

    class C
    {
    public:
      //! getter for readable_ (access is Ro)
      std::string const& readable() const { return readable_; }
    private:
      std::string readable_ { "foo" };
    };


*Inaccessible* Example:

    (class_('c')
        ..members = [
          member('inaccessible')..init = 'foo'..access = ia
        ])
    .definition

Gives:

    class C
    {
    private:
      std::string inaccessible_ { "foo" };
    };

*Read-Write* Example:

    (class_('c')
      ..members = [
        member('read_write')..init = 'foo'..access = rw
      ])
    .definition

Gives:

    class C
    {
    public:
      //! getter for read_write_ (access is Rw)
      std::string const& read_write() const { return read_write_; }
      //! setter for read_write_ (access is Access.rw)
      void read_write(std::string & read_write) { read_write_ = read_write; }
    private:
      std::string read_write_ { "foo" };
    };


Note that read-write keeps the member *private* by default and allows
access through methods. However, complete control over C++ access of
members can be obtained with [cppAccess]. Here are two such examples:

No accessors, just C++ public:

    (class_('c')
      ..members = [
        member('full_control')..init = 'foo'..cppAccess = public
      ])
    .definition

Gives:

    class C
    {
    public:
      std::string full_control { "foo" };
    };

Finally, using both [access] and [cppAccess] for more control:

    (class_('c')
      ..members = [
        member('more_control')..init = 'foo'..access = ro..cppAccess = protected
      ])
    .definition


Gives:

    class C
    {
    public:
      //! getter for more_control_ (access is Ro)
      std::string const& more_control() const { return more_control_; }
    protected:
      std::string more_control_ { "foo" };
    };



'''
          ..extend = 'Entity'
          ..members = [
            member('type')..doc = 'Type of member',
            member('init')
            ..doc = """
Initialization of member.

If [type] of [Member] is null and [init] is set with a Dart type
which can reasonably map to a C++ type, then type is inferred.
Currently the mappings are:
    {
      int : int,
      double : double,
      string : std::string,
      bool : bool,
      List(...) : std::vector<...>,
    }

For example:

    member('name')..init = 'UNASSIGNED' => name is std::string
    member('x')..init = 0               => x is int
    member('pi')..init = 3.14           => pi is double

"""..access = RO,
            member('ctor_init')
            ..doc = '''
Rare usage - member b depends on member a (e.g. b is just a string rep of a
which is int), a is passed in for construction but b can be initialized directly
from a. If ctorInit is set on a member, any memberCtor will include this text to
initialize it''',
            member('access')
            ..doc = 'Idiomatic access of member'..type = 'Access'..classInit = 'ia',
            member('cpp_access')
            ..doc = 'C++ style access of member'..type = 'CppAccess'..access = WO,
            member('ref_type')
            ..doc = 'Ref type of member'..type = 'RefType'..classInit = 'value',
            member('is_by_ref')
            ..doc = 'Pass member around by reference'..type = 'bool'..access = WO,
            member('is_static')..doc = 'Is the member static'
            ..classInit = false,
            member('is_mutable')..doc = 'Is the member mutable'
            ..classInit = false,
            member('is_const')..doc = 'Is the member const'
            ..classInit = false
            ..access = WO,
            member('is_const_expr')..doc = 'Is the member a constexprt'
            ..classInit = false,
            member('has_no_init')
            ..doc = 'If set will not initialize variable - use sparingly'
            ..classInit = false,
            member('is_serialized_as_int')
            ..doc = 'Indicates this member is an enum and if serialized should be serialized as int'
            ..classInit = false,
            member('is_cereal_transient')
            ..doc = 'Indicates this member should not be serialized via cereal'
            ..classInit = false,
            member('is_streamable')
            ..doc = '''
Indicates member should be streamed if class is streamable.
One of the few flags defaulted to *true*, this flag provides
an opportunity to *not* stream specific members'''
            ..classInit = true,
            member('has_custom_streamable')
            ..doc = '''
Indicates a custom protect block is needed to hand code
the streamable for this member'''
            ..classInit = false
          ],
        ],
        part('class')
        ..enums = [
          enum_('class_code_block')
          ..doc = '''
The various supported code blocks associated with a C++ class. The
name indicates where in the class it appears. Within the class
definition the order is *public*, *protected* then
*private*. Additional locations for just before the class and just
after the class.

So, the following spec:

        (class_('c')
            ..customBlocks = [
              clsPreDecl,
              clsPublic,
              clsProtected,
              clsPrivate,
              clsPostDecl
            ])
        .definition


Gives the following content:

    // custom <ClsPreDecl C>
    // end <ClsPreDecl C>

    class C
    {
    public:
      // custom <ClsPublic C>
      // end <ClsPublic C>

    protected:
      // custom <ClsProtected C>
      // end <ClsProtected C>

    private:
      // custom <ClsPrivate C>
      // end <ClsPrivate C>

    };

    // custom <ClsPostDecl C>
    // end <ClsPostDecl C>
'''
          ..hasLibraryScopedValues = true
          ..values = [
            enumValue(id('cls_public'))
            ..doc = 'The custom block appearing in the standard *public* section',
            enumValue(id('cls_protected'))
            ..doc = 'The custom block appearing in the standard *protected* section',
            enumValue(id('cls_private'))
            ..doc = 'The custom block appearing in the standard *private* section',
            enumValue(id('cls_pre_decl'))
            ..doc = 'The custom block appearing just before the class definition',
            enumValue(id('cls_post_decl'))
            ..doc = 'The custom block appearing just after the class definition',
          ],
        ]
        ..classes = [
          class_('class_method')
          ..isAbstract = true
          ..members = [
            member('parent')..type = 'Class'..access = RO,
            member('is_logged')..doc = 'If true add logging'..classInit = false,
            member('template')..type = 'Template'..access = RO,
            member('cpp_access')
            ..doc = 'C++ style access of method'
            ..type = 'CppAccess'
            ..classInit = 'public',
          ],
          class_('default_method')
          ..isAbstract = true
          ..extend = 'ClassMethod'
          ..members = [
            member('has_custom')
            ..doc = 'Has custom code, so needs protect block'..classInit = false,
            member('top_inject')
            ..doc = '''
Code snippet to inject at beginning of method. The intent is for the
methods to have standard generated implementations, but to also
support programatic injection of implmementation into the
methods. This supports injection near the top of the method.'''
            ..classInit = '',
            member('bottom_inject')
            ..doc = '''
Supports injecting code near the bottom of the method. *See*
*topInject*'''
            ..classInit = '',
            member('uses_default')..classInit = false,
            member('has_delete')..classInit = false,
          ],
          class_('default_ctor')
          ..doc = 'Default ctor, autoinitialized on read'..extend = 'DefaultMethod',
          class_('copy_ctor')
          ..doc = 'Copy ctor, autoinitialized on read'..extend = 'DefaultMethod',
          class_('move_ctor')
          ..doc = 'Move ctor, autoinitialized on read'..extend = 'DefaultMethod',
          class_('assign_copy')..extend = 'DefaultMethod',
          class_('assign_move')..extend = 'DefaultMethod',
          class_('dtor')
          ..doc = 'Provides a destructor'
          ..extend = 'DefaultMethod'
          ..members = [
            member('is_abstract')..classInit = false
          ],
          class_('member_ctor_parm')
          ..doc = '''
A *Member Constructor Parameter*. Defines a single parameter to be passed to a
MemberCtor in order to initialize a single member variable. MemberCtor will
convert strings automatically into instances of MemberCtorParm. For example:

    memberCtor(['x', 'y'])

would produce the following constructor:

    class Point {
    public:
      Point(int x, int y) : x_{x}, y_{y} {}
    private:
      int x_;
      int y_;
    }

But to modify the parameter definition or initializtaion you might rather
construct and modify the MemberCtorParm instead of taking the default:

        final cls = class_('point')
          ..members = [ member('x')..init = 0, member('y')..init = 0 ]
          ..memberCtors = [
            memberCtor( [
              memberCtorParm('x')
              ..defaultValue = '42',
              memberCtorParm('y')
              ..defaultValue = '42'] )
          ];

which produces:

    class Point
    {
    public:
      Point(
        int x = 42,
        int y = 42) :
        x_ { x },
        y_ { y } {
      }

    private:
      int x_ { 0 };
      int y_ { 0 };
    };

'''
          ..hasCtorSansNew = true
          ..members = [
            member('name')
            ..doc = 'Name of member initialized by argument to member ctor'
            ..isFinal = true
            ..ctors = [''],
            member('member')
            ..doc = 'cpp member to be initialized'
            ..type = 'Member',
            member('parm_decl')..doc = '''
*Override* for arguemnt declaration. This is rarely needed. Suppose
you want to initialize member *Y y* from an input argument *X x* that
requires a special function *f* to do the conversion:

    Class(X x) : y_ {f(x)}

Which would be achieved by:

    memberCtor([
      memberCtorParm("y")
      ..parmDecl = "X x"
      ..init = "f(x)"
    ])

''',
            member('init')..doc = '''
*Override* of initialization text. This is rarely needed since
initialization of members in a member ctor is straightforward:

This definition:

    memberCtor(['x', 'y'])

would produce the following constructor:

    class Point {
    public:
      Point(int x, int y) : x_{x}, y_{y} {}
    private:
      int x_;
      int y_;
    }

But sometimes you need more:

    class Umask_scoped_set {
    public:
      Umask_scoped_set(mode_t new_mode) : previous_mode_{umask(new_mode)}
    ...
    }

Which would be achieved by:

    memberCtor([
      memberCtorParm("previous_mode")
      ..parmDecl = "mode_t new_mode"
      ..init = "umask(new_mode)"
    ])

'''
            ..access = WO,
            member('default_value')
            ..doc = '''
If set provides a default value for the parm in the ctor. For example:

    memberCtorParm('x')..defaultValue = '42'

where the type of member *x* is *int* might yield:

    Cls(int x = 42) : x_{x}

''',
          ],
          class_('member_ctor')
          ..doc = '''
Specificication for a member constructor. A member constructor is a constructor
with the intent of initializing one or more members of a class.

Assumig a class has members *int x* and *int y*
*memberCtor(["x", "y"])*

would generate the corresponding:

    Class(int x, int y) : x_{x}, y_{y} {}

If custom logic is additionally required, set the *hasCustom* flag to include a
custom block. In that case the class might look like:

    Class(int x, int y) : x_{x}, y_{y} {
      // custom <Class>
      // end <Class>
    }
'''
          ..extend = 'ClassMethod'
          ..members = [
            member('member_parms')
            ..doc = 'List of members that are passed as arguments for initialization'
            ..type = 'List<MemberCtorParm>'
            ..classInit = [],
            member('decls')
            ..doc = 'List of additional decls ["Type Argname", ...]'
            ..type = 'List<String>',
            member('has_custom')
            ..doc = 'Has custom code, so needs protect block'..classInit = false..access = WO,
            member('custom_label')
            ..doc = 'Label for custom protect block if desired'..access = WO,
            member('has_all_members')
            ..doc = 'If set automatically includes all members as args'
            ..classInit = false,
          ],
          class_('op_equal')
          ..doc = 'Provides *operator==()*'
          ..extend = 'ClassMethod',
          class_('op_less')
          ..doc = 'Provides *operator<()*'
          ..extend = 'ClassMethod',
          class_('op_out')
          ..doc = 'Provides *operator<<()*'
          ..extend = 'ClassMethod',
          class_('class')
          ..doc = '''
A C++ class.

Classes optionally have these items:

* A [template]
* A collection of [bases]
* A collection of [members]
* A collection of class local [usings]
* A collection of class local [enums]
* A collection of class local [forward_ptrs] which are like [usings] but standardized for pointer type
* A collection of *optionally included* standard methods including:

  * Constructors including:

    * [CopyCtor]
    * [MoveCtor]
    * [DefaultCtor]
    * Zero or more member initializing ctors [MemberCtor]

  * Assignment functions:

    * [AssignCopy]
    * [AssignMove]

  * [Dtor]

  * Standard Utility Methods

    * [OpEqual]
    * [OpLess]
    * [OpOut] - Support for streaming fields

* A fixed collection of indexed [codeBlocks] that can be used for
  providing *CustomBlocks* and/or for dynamically injecting code - see
  [CodeBlock].
'''
          ..extend = 'Entity'
          ..members = [
            member('definition')
            ..doc = '''
The contents of the class definition. *Inaccessible* and established
as a member so custom *definition* getter can be called multiple times
on the same class and results lazy-inited here'''
            ..access = IA,
            member('is_struct')
            ..doc = 'Is this definition a *struct*'
            ..classInit = false,
            member('template')
            ..doc = 'The template by which the class is parameterized'
            ..type = 'Template'..access = RO,
            member('usings')
            ..doc = '''
List of usings that will be scoped to this class near the top of
the class definition.'''
            ..type = 'List<String>'..classInit = [],
            member('usings_post_decl')
            ..doc = '''
List of usings to occur after the class declaration. Sometimes it is
useful to establish some type definitions directly following the class
so they may be reused among any client of the class. For instance if
class *Foo* will most commonly be used in vector, the using occuring
just after the class definition will work:

    using Foo = std::vector<Foo>;

'''
            ..type = 'List<String>'..classInit = [],
            member('bases')
            ..doc = '''
Base classes this class derives form.

'''
            ..type = 'List<Base>'..classInit = [],
            member('default_ctor')
            ..doc = 'The default constructor'
            ..type = 'DefaultCtor'..access = IA,
            member('copy_ctor')
            ..doc = 'The copy constructor'
            ..type = 'CopyCtor'..access = IA,
            member('move_ctor')
            ..doc = 'The move constructor'
            ..type = 'MoveCtor'..access = IA,
            member('assign_copy')
            ..doc = 'The assignment operator'
            ..type = 'AssignCopy'..access = IA,
            member('assign_move')
            ..doc = 'The assignment move operator'
            ..type = 'AssignMove'..access = IA,
            member('dtor')
            ..doc = 'The destructor'
            ..type = 'Dtor'..access = IA,
            member('member_ctors')
            ..doc = 'A list of member constructors'
            ..type = 'List<MemberCtor>'..classInit = [],
            member('op_equal')..type = 'OpEqual'..access = IA,
            member('op_less')..type = 'OpLess'..access = IA,
            member('op_out')..type = 'OpOut'..access = IA,
            member('forward_ptrs')..type = 'List<PtrType>'..classInit = [],
            member('enums_forward')..type = 'List<Enum>'..classInit = [],
            member('enums')..type = 'List<Enum>'..classInit = [],
            member('members')..type = 'List<Member>'..classInit = [],
            member('friend_class_decls')..type = 'List<FriendClassDecl>'..classInit = [],
            member('custom_blocks')..type = 'List<ClassCodeBlock>'..classInit = [],
            member('is_singleton')..classInit = false,
            member('code_blocks')
            ..access = RO
            ..type = 'Map<ClassCodeBlock, CodeBlock>'..classInit = {},
            member('is_streamable')
            ..doc = 'If true adds streaming support'..classInit = false,
            member('uses_streamers')
            ..doc = 'If true adds {using fcs::utils::streamers::operator<<} to streamer'
            ..classInit = false,
            member('includes_test')
            ..doc = 'If true adds test function to tests of the header it belongs to'
            ..classInit = false,
            member('is_immutable')
            ..doc = '''
If true makes all members const provides single member ctor
initializing all.

There are a few options to achieve *immutable* support. The first is
this type, where all fields are constant and therefore must be
initialized. An alternative concept is immutable from perspective of
user. This can be achieved with use of [addFullMemberCtor] and the
developer ensuring the members are not modified. This provides a
stronger guarantee of immutability.'''
            ..classInit = false,
            member('serializers')
            ..doc = 'List of processors supporting flavors of serialization'
            ..type = 'List<Serializer>'
            ..classInit = [],
            member('implemented_interfaces')
            ..doc = '''
List of interfaces this class implements. The [Interface] determines
whether the polymorphism is runtime via virtual methods or compile
time via call forwarding. The entries in the list must be either:

* Interface: identifying the interface implemented. The interface will
  be wrapped in an [AccessInterface] with [public] access.

* AccessInterface: which will be used directly

'''
            ..type = 'List'
            ..classInit = [],
            member('pack_align')
            ..doc = r'''
If set, will include *#pragma pack(push, $packAlign)* before the class
and *#pragma pack(pop)* after.
'''
            ..type = 'int',
          ],
        ],
        part('method')
        ..classes = [
          class_('parm_decl')
          ..extend = 'Entity'
          ..members = [
            member('type'),
          ],
          class_('method_decl')
          ..extend = 'Entity'
          ..members = [
            member('parm_decls')..type = 'List<ParmDecl>'..classInit = [],
            member('return_type'),
          ],
          class_('interface')
          ..extend = 'Entity'
          ..members = [
            member('is_virtual')
            ..doc = '''
If true interface results in pure abstract class, else *static
polymorphic* base.
'''
            ..classInit = false,
            member('method_decls')
            ..type = 'List<MethodDecl>'
            ..access = RO
            ..classInit = [],
          ],
          class_('access_interface')
          ..members = [
            member('interface')..type = 'Interface'..ctors = [''],
            member('cpp_access')..type = 'CppAccess'..classInit = 'public'
          ],
        ],
        part('serializer')
        ..enums = [
          enum_('serialization_style')
          ..doc = 'Serialization using *cereal* supports these types of serialization'
          ..hasLibraryScopedValues = true
          ..values = [
            id('json_serialization'),
            id('xml_serialization'),
            id('binary_serialization'),
          ]
        ]
        ..classes = [
          class_('serializer')
          ..doc = 'Establishes an interface for instance serialization'
          ..isAbstract = true,
          class_('dsv_serializer')
          ..doc = 'Provides support for serialization as *delimited separated values*'
          ..implement = [ 'Serializer' ]
          ..members = [
            member('delimiter')..classInit = ':',
          ],
          class_('cereal')
          ..doc = 'Adds support for serialization using *cereal*'
          ..implement = [ 'Serializer' ]
          ..members = [
            member('styles')..type = 'List<SerializationStyle>'..classInit = [],
          ],
        ],
        part('header')
        ..classes = [
          class_('header')
          ..doc = 'A single c++ header'
          ..extend = 'CppFile'
          ..members = [
            member('file_path')..access = RO,
            member('includes_test')..classInit = false,
            member('test')..type = 'Test'..access = IA,
            member('is_api_header')
            ..doc = '''
If true marks this header as special to the set of headers in its library in that:
(1) It will be automatically included by all other headers
(2) For windows systems it will be the place to provide the api decl support
(3) Will have code that initializes the api
'''
            ..classInit = false,
          ],
        ],
        part('impl')
        ..classes = [
          class_('impl')
          ..doc = 'A single implementation file (i.e. *cpp* file)'
          ..extend = 'CppFile'
          ..members = [
            member('file_path')..access = RO,
          ]
        ],
        part('lib')
        ..enums = [
          enum_('file_code_block')
          ..doc = '''
Set of pre-canned blocks where custom or generated code can be placed.
The various supported code blocks associated with a C++ file. The
name indicates where in the file it appears.

So, the following spec:

    final h = header('foo')
      ..includes = [ 'iostream' ]
      ..namespace = namespace(['foo'])
      ..customBlocks = [
        fcbCustomIncludes,
        fcbPreNamespace,
        fcbBeginNamespace,
        fcbEndNamespace,
        fcbPostNamespace,
      ];
    print(h.contents);

prints:

    #ifndef __FOO_FOO_HPP__
    #define __FOO_FOO_HPP__

    #include <iostream>

    // custom <FcbCustomIncludes foo>
    // end <FcbCustomIncludes foo>

    // custom <FcbPreNamespace foo>
    // end <FcbPreNamespace foo>

    namespace foo {
      // custom <FcbBeginNamespace foo>
      // end <FcbBeginNamespace foo>

      // custom <FcbEndNamespace foo>
      // end <FcbEndNamespace foo>

    } // namespace foo
    // custom <FcbPostNamespace foo>
    // end <FcbPostNamespace foo>

    #endif // __FOO_FOO_HPP__

'''
          ..hasLibraryScopedValues = true
          ..values = [
            enumValue(id('fcb_custom_includes'))
            ..doc = 'Custom block for any additional includes appearing just after generated includes',
            enumValue(id('fcb_pre_namespace'))
            ..doc = 'Custom block appearing just before the namespace declaration in the code',
            enumValue(id('fcb_begin_namespace'))
            ..doc = 'Custom block appearing at the begining of and inside the namespace',
            enumValue(id('fcb_end_namespace'))
            ..doc = 'Custom block appearing at the end of and inside the namespace',
            enumValue(id('fcb_post_namespace'))
            ..doc = 'Custom block appearing just after the namespace declaration in the code',
          ]
        ]
        ..classes = [
          class_('lib')
          ..doc = 'A c++ library'
          ..extend = 'Entity'
          ..implement = [ 'CodeGenerator' ]
          ..members = [
            member('namespace')..type = 'Namespace'..classInit = 'new Namespace()',
            member('headers')..type = 'List<Header>'..classInit = [],
            member('tests')..type = 'List<Test>'..classInit = [],
          ],
        ],
        part('app')
        ..enums = [
          enum_('arg_type')
          ..doc = '''
Set of argument types supported by command line option processing.
'''
          ..requiresClass = true
          ..values = [
            enumValue(id('int'))
            ..doc = 'The command line arg is an integer',
            enumValue(id('double'))
            ..doc = 'The command line arg is a double',
            enumValue(id('string'))
            ..doc = 'The command line arg is a string',
            enumValue(id('flag'))
            ..doc = 'The command line arg is a flag - i.e. a boolean',
          ]
        ]
        ..classes = [
          class_('app_arg')
          ..doc = '''
Metadata associated with an argument to an application.  Requires and
geared to features supported by boost::program_options.
'''
          ..extend = 'Entity'
          ..members = [
            member('type')..type = 'ArgType'..classInit = 'ArgType.STRING',
            member('short_name'),
            member('is_multiple')..classInit = false,
            member('is_required')..classInit = false,
            member('default_value')..type = 'Object'..access = RO,
          ],
          class_('app')
          ..doc = '''

A C++ application. Application related files are generated in location based on
[namespace] the namespace. For example, the following code:

    app('date_time_converter')
      ..namespace = namespace(['fcs'])
      ..args = [
        arg('timestamp')
        ..shortName = 't'
        ..descr = 'Some form of timestamp'
        ..isMultiple = true
        ..type = ArgType.STRING,
        arg('date')
        ..shortName = 'd'
        ..descr = 'Some form of date'
        ..isMultiple = true
        ..type = ArgType.STRING,
      ];

will generate a C++ file containing *main* at location:

    \$root/cpp/app/date_time_converter/date_time_converter.cpp

Since [App] extends [Impl] it supports local instances of
[constExprs] [usings], [enums], [forwardDecls], and [classes],
as well as [headers] and [impls] which may be part of the
application and not necessarily suited for a separate library.
'''
          ..extend = 'Impl'
          ..implement = [ 'CodeGenerator' ]
          ..members = [
            member('args')
            ..doc = 'Command line arguments specific to this application'
            ..type = 'List<AppArg>'..classInit = [],
            member('namespace')
            ..doc = 'Namespace associated with application code'
            ..type = 'Namespace'..access = IA,
            member('headers')
            ..doc = '''
Additional headers that are associated with the application itself, as
opposed to belonging to a reusable library.'''
            ..type = 'List<Header>'..classInit = [],
            member('impls')
            ..doc = '''
Additional implementation files associated with the application
itself, as opposed to belonging to a reusable library.'''
            ..type = 'List<Impl>'..classInit = [],
            member('required_libs')
            ..doc = '''
Libraries required to build this executable. *Warning* potentially
deprecated in the future. Originally when generating boost jam files
it was convenient to associate the required libraries directly in the
code generation scripts. With cmake it was simpler to just incorporate
protect blocks where the required libs could be easily added.
'''
            ..type = 'List<String>'..classInit = [],
            member('builders')
            ..doc = 'List of builders to generate build scripts of a desired flavor (bjam,...)'
            ..type = 'List<AppBuilder>'..classInit = [],
          ],
          class_('app_builder')
          ..doc = '''
Base class establishing interface for generating build scripts for
libraries, apps, and tests'''
          ..isAbstract = true
          ..implement = [ 'CodeGenerator' ]
          ..members = [
            member('app')..type = 'App'
          ],
        ],
        part('cmake_support')
        ..classes = [
          class_('cmake_installation_builder')
          ..extend = 'InstallationBuilder',
        ],
        part('jam_support')
        ..classes = [
          class_('jam_installation_builder')
          ..doc = '''
Effectively just a placeholder, the presence of which in an installation
indicates bjam shoud be set up per app and tests in the installation.
'''
          ..extend = 'InstallationBuilder',
          class_('jam_app_builder')
          ..extend = 'AppBuilder',
          class_('jam_test_builder')
          ..extend = 'TestBuilder',
          class_('site_config')
          ..implement = [ 'CodeGenerator' ]
          ..members = [
            member('installation')..type = 'Installation'..ctors = [''],
          ],
          class_('user_config')
          ..implement = [ 'CodeGenerator' ]
          ..members = [
            member('installation')..type = 'Installation'..ctors = [''],
          ],
          class_('jam_constant')
          ..members = [
            member('constant'),
            member('value'),
          ],
          class_('jam_file_top')
          ..implement = [ 'CodeGenerator' ]
          ..members = [
            member('installation')..type = 'Installation'..ctors = [''],
            member('include_paths')..type = 'List<String>'..classInit = [],
            member('constants')..type = 'List<JamConstant>'..classInit = [],
          ],
          class_('jam_root')
          ..implement = [ 'CodeGenerator' ]
          ..members = [
            member('installation')..type = 'Installation'..ctors = [''],
          ],
        ],
        part('script')
        ..classes = [
          class_('script')
          ..extend = 'Entity'
          ..implement = [ 'CodeGenerator' ]
          ..members = [
          ],
        ],
        part('test')
        ..classes = [
          class_('test')
          ..extend = 'Impl'
          ..implement = [ 'CodeGenerator' ]
          ..members = [
            member('file_path')..access = RO,
            member('header_under_test')..type = 'Header',
            member('headers')..type = 'List<Header>'..classInit = [],
            member('impls')..type = 'List<Impl>'..classInit = [],
            member('test_functions')..type = 'List<String>'..classInit = []..access = RO,
            member('test_implementations')..type = 'Map<String, String>'..classInit = {}..access = RO,
            member('required_libs')..type = 'List<String>'..classInit = [],
          ],
          class_('test_builder')
          ..isAbstract = true
          ..implement = [ 'CodeGenerator' ]
          ..doc = 'Creates builder for test folder'
          ..members = [
            member('lib')..type = 'Lib'..ctors = [''],
            member('directory')..ctors = [''],
            member('tests')..type = 'List<Test>'..ctors = ['']
          ],
        ],
        part('installation')
        ..classes = [
          class_('installation_container')
          ..doc = 'Mixin that brings in the installation that this child belongs to'
          ..isAbstract = true
          ..members = [
            member('installation')..type = 'Installation',
          ],
          class_('installation_builder')
          ..isAbstract = true
          ..implement = [ 'CodeGenerator' ]
          ..doc = '''
Creates builder for an installation (ie ties together all build artifacts)
'''
          ..members = [
            member('installation')..type = 'Installation'
          ],
          class_('installation')
          ..extend = 'Entity'
          ..implement = [ 'CodeGenerator' ]
          ..members = [
            member('root')..doc = 'Fully qualified path to installation'..access = RO,
            member('paths')..type = 'Map<String, String>'..classInit = {}..access = RO,
            member('libs')..type = 'List<Lib>'..classInit = [],
            member('apps')..type = 'List<App>'..classInit = [],
            member('tests')..type = 'List<Test>'..classInit = [],
            member('scripts')..type = 'List<Script>'..classInit = [],
            member('builders')
            ..doc = 'List of builders for the installation (bjam, cmake)'
            ..type = 'List<InstallationBuilder>'..classInit = [],
          ],
          class_('path_locator')
          ..members = [
            member('env_var')
            ..doc = 'Environment variable specifying location of path, if set this path is used'
            ..isFinal = true,
            member('default_path')
            ..doc = 'Default path for the item in question'
            ..isFinal = true,
            member('path')..access = RO,
          ],
        ],
      ],

      library('hdf5_support')
      ..imports = [
        'package:ebisu_cpp/ebisu_cpp.dart',
        'package:id/id.dart',
      ]
      ..doc = 'Provide C++ classes support for reading/writing to hdf5 packet table'
      ..parts = [
        part('packet_table')
        ..classes = [
          class_('class_not_found_exception')
          ..doc = '''
Indicates a class could not be found in the [Installation] for adding
hdf5 packet table support
'''
          ..implement = ['Exception']
          ..members = [
            member('message')
            ..isFinal = true
            ..access = RO
            ..doc = 'Exception details',
          ],
          class_('log_group')
          ..hasCtorSansNew = true
          ..members = [
            member('class_name')
            ..doc = 'Name of class, *snake case*, to add a packet table log group'
            ..ctors = ['']
            ..isFinal = true,
            member('member_names')
            ..doc = '''
Name of members of class, *snake case*, to include in the packet table
log group. An empty list will include all members in the table.
'''
            ..type = 'List<String>'
            ..ctorInit = 'const []'
            ..ctorsOpt = ['']
            ..isFinal = true,
          ],
          class_('packet_table_decorator')
          ..isImmutable = true
          ..hasCtorSansNew = true
          ..implement = [
            'InstallationDecorator',
          ]
          ..members = [
            member('log_groups')..type = 'List<LogGroup>'
          ]
        ]
      ],

    ];

  ebisu.generate();
}

////////////////////////////////////////////////////////////////////////////////
// Large doc comment for the cpp library
final cppLibraryDoc = '''
Library to facilate generation of c++ code.

The intent is to get as declarative as possible with the specification of C++
entities to make code generation as simple and fun as possible. The primary
focus of these utilities is in generating the *structure* of c++ code. This is
achieved by modeling the C++ language at a relatively high level and selectively
choosing what parts of the language lend themselves to the approach.

For sample code that uses this library to generate its structure see:
[fcs project](https://github.com/patefacio/fcs)

For a small taste, the following is the current description of a small C++
library called *raii* which provides a few utilities for handling the *resource
acquisition is initialization* idiom.

    import 'package:ebisu_cpp/cpp.dart';
    import '../../lib/installation.dart';

    final raii = lib('raii')
      ..namespace = namespace([ 'fcs', 'raii' ])
      ..headers = [
        header('change_tracker')
        ..includes = [ 'boost/call_traits.hpp' ]
        ..classes = [
          class_('change_tracker')
          ..descr = \'\'\'
    Tracks current/previous values of the given type of data. For some
    algorithms it is useful to be able to examine/perform logic on
    current value and compare or evalutate how it has changed since
    previous value.\'\'\'
          ..template = [ 'typename T' ]
          ..customBlocks = [clsPublic]
          ..members = [
            member('current')..type = 'T'..access = ro,
            member('previous')..type = 'T'..access = ro,
          ],
          ...
        ],
        header('api_initializer')
        ..test.customBlocks = [ fcbPreNamespace ]
        ..test.includes.addAll(['vector', 'fcs/utils/streamers/containers.hpp', ])
        ..includes = [ 'list', 'map', 'memory' ]
        ..usings = [
          'Void_func_t = void (*)(void)',
        ]
        ..classes = [
          class_('functor_scope_exit')
          ..includesTest = true
          ..template = [ 'typename FUNCTOR = Void_func_t' ]
          ..usings = [ 'Functor_t = FUNCTOR' ]
          ..customBlocks = [ clsPublic ]
          ..memberCtors = [ memberCtor(['functor']) ]
          ..members = [
            member('functor')..type = 'Functor_t'..hasNoInit = true..access = ro,
          ],
          ...
          class_('api_initializer')
          ..usings = [
            'Api_initializer_registry_t = Api_initializer_registry< INIT_FUNC, UNINIT_FUNC >'
          ]
          ..template = [
            'typename INIT_FUNC = Void_func_t',
            'typename UNINIT_FUNC = Void_func_t',
          ]
          ..customBlocks = [ clsPublic ]
        ]
      ];

    addItems() => installation.addLib(raii);

    main() {
      addItems();
      installation.generate();
    }

When that script is run, the following is output:

    No change: \$TOP/fcs/cpp/fcs/raii/change_tracker.hpp
    No change: \$TOP/fcs/cpp/fcs/raii/api_initializer.hpp
    No change: \$TOP/fcs/cpp/tests/fcs/raii/test_change_tracker.cpp
    No change: \$TOP/fcs/cpp/tests/fcs/raii/test_api_initializer.cpp

So when the script is run the code is *regenerated* and any changed files will
be indicated as such. In this case, since the code was previously generated, it
indicates there were no updates.
''';
