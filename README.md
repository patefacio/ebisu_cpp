# Ebisu Cpp

[![Build Status](https://drone.io/github.com/patefacio/ebisu_cpp/status.png)](https://drone.io/github.com/patefacio/ebisu_cpp/latest)

Code generation library/toolkit that focuses on generating the structure of c++ code and as much of the boilerplate coding that goes with that in the creation of c++ systems. Much like its required companion library [ebisu](https://github.com/patefacio/ebisu) this library does what it can to leverage a convenient declarative approach encouraging heavy use of *cascades*.

## General C++ Code Generation Approach

As stated the focus is on c++ *structure* as opposed to attempting to support all aspects of the language. On any large system there is some combination of boilerplate and hand-crafted custom business logic. The larger the amount of boilerplate the larger the benefit of code generation. In order to make the use of code generation palatable in the face of large amounts of custom code it is important to be able to have the two live nicely side-by-side. In *ebisu* and *ebisu_cpp* this is accomplished with *Protect Blocks* also called *Custom Blocks*. A *custom block* is code that exists in generated output that is protected because it has been hand coded. Custom blocks are designated with special comments, which are labeled with *tags*. Here are some examples:

For C++, a custom block with a *tag* of *ClsPublic Change_tracker* designating the class public section (ClsPublic) of class *Change_tracker*:

    template <typename T>
    class Change_tracker {
     public:
      // custom <ClsPublic Change_tracker>
           **** CUSTOM CODE WRITTEN HERE ****
      // end <ClsPublic Change_tracker>

      //! getter for current_ (access is Ro)
      T current() const { return current_; }

      //! getter for previous_ (access is Ro)
      T previous() const { return previous_; }

     private:
      T current_{};
      T previous_{};
    };

All code around the *custom block* is generated. Any code within a *Custom Block* is preserved from one run to the next of the code generation. 

For *cmake* a custom block with *tag* of *date_time_converter libs* designating additional libraries required for the *date_time_converter* application:

    target_link_libraries(date_time_converter
    # custom <date_time_converter libs>
      ${Boost_DATE_TIME_LIBRARY}
      ${Boost_REGEX_LIBRARY}
    # end <date_time_converter libs>
      ${Boost_PROGRAM_OPTIONS_LIBRARY}
      ${Boost_SYSTEM_LIBRARY}
      ${Boost_THREAD_LIBRARY}
    )


### Structural Targets

Specifically, the following are some of the current structural targets for covered by *ebisu_cpp*:

* [Enum]: C++ enums, with some support for serialization and different flavors - such as *masks*.

          Example:

          enum_('submit_result')
          ..values = [
            'submit_succeeded',
            'submit_invalid_market',
            'submit_invalid_order_details' ],

          Generates Content:

          enum Submit_result {
            Submit_succeeded_e,
            Submit_invalid_market_e,
            Submit_invalid_order_details_e
          };
  In addition to the basic enum, support is provided for converting
  enum values to and from strings, streaming and mask enums.
  
* [Class]: The heart of the language. With simple declarations, classes can be generated:

                  class_('change_tracker')
                  ..descr = '''
            Tracks current/previous values of the given type of data. For some
            algorithms it is useful to be able to examine/perform logic on
            current value and compare or evalutate how it has changed since
            previous value.'''
                  ..template = [ 'typename T' ]
                  ..customBlocks = [clsPublic]
                  ..members = [
                    member('current')..type = 'T'..access = ro,
                    member('previous')..type = 'T'..access = ro,
                  ],
  Which generates content:

            /**
             Tracks current/previous values of the given type of data. For some
             algorithms it is useful to be able to examine/perform logic on
             current value and compare or evalutate how it has changed since
             previous value.
            */
            template <typename T>
            class Change_tracker {
             public:
              // custom <ClsPublic Change_tracker>
                 ...                
              // end <ClsPublic Change_tracker>

              //! getter for current_ (access is Ro)
              T current() const { return current_; }

              //! getter for previous_ (access is Ro)
              T previous() const { return previous_; }

             private:
              T current_{};
              T previous_{};
            };


* [Header]: A single header file, typically with a collection of C++ type things like [includes], enums, classes, forward declarations, using statements

            Example:
            
            final raii = lib('raii')
              ..namespace = namespace([ 'fcs', 'raii' ])
              ..headers = [
                header('change_tracker')
                ..includes = [ 'boost/call_traits.hpp' ]
                ..classes = [
                  class_('change_tracker')
                  ...
                ]

            Generates File:

                $TOP/fcs/cpp/fcs/raii/change_tracker.hpp

* [Impl]: A single cpp implementation, typically with a collection of C++ type things like includes, enums, classes, forward declarations, using statements

* [Lib]: C++ libraries. C++ Libarary sometimes has a newer connotation in that there is a concept of *header only* library which implies no library at all. In *ebisu_cpp* [Lib] does not necessarily mean a C++ archive is created. Rather it is a collection of code generated within a *namespace* in a consistent directory structure that may or may not entail the creation of a C++ archive.

        final utils = lib('utils')
          ..namespace = namespace([ 'fcs', 'utils' ])
          ..headers = [
            header('block_indenter')
            ...,
            header('fixed_size_char_array')
            ...,
            header('utils')
            ...,
            header('version_control_commit')
            ...,
            header('histogram')
            ...,
          ];

        Generates Files:
        No change: $TOP/fcs/cpp/fcs/utils/block_indenter.hpp
        No change: $TOP/fcs/cpp/fcs/utils/fixed_size_char_array.hpp
        No change: $TOP/fcs/cpp/fcs/utils/utils.hpp
        No change: $TOP/fcs/cpp/fcs/utils/version_control_commit.hpp
        No change: $TOP/fcs/cpp/fcs/utils/histogram.hpp


* [App]: A single application executable.

            final date_time_converter = app('date_time_converter')
              ..namespace = namespace(['fcs'])
              ..customBlocks = [ fcbEndNamespace ]
              ..includes = [
                'fcs/timestamp/conversion.hpp',
                'fcs/utils/streamers/table.hpp',
                'fcs/timestamp/conversion.hpp',
                'stdexcept',
              ]
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

        Generates: $TOP/fcs/cpp/app/date_time_converter/date_time_converter.cpp
        If run in context of installation updates build scripts with targets content:

        ######################################################################
        # Application build directives
        ######################################################################
        add_executable(date_time_converter
          app/date_time_converter/date_time_converter.cpp
        )

        target_link_libraries(date_time_converter
        # custom <date_time_converter libs>
          ${Boost_DATE_TIME_LIBRARY}
          ${Boost_REGEX_LIBRARY}
        # end <date_time_converter libs>
          ${Boost_PROGRAM_OPTIONS_LIBRARY}
          ${Boost_SYSTEM_LIBRARY}
          ${Boost_THREAD_LIBRARY}
        )
        add_executable(display_csv
          app/display_csv/display_csv.cpp
        )




* [AppArg]: An application argument that gets translated into *boost::program_option* code. Even when using helpful libraries like *boost::program_options*, there is typically large amounts of boilerplate code. The arguments associated with an application are localized into a single class containing the program options as fields. So for the example application above:

          struct Program_options {
            Program_options(int argc, char** argv) {...}
            static boost::program_options::options_description const& description() {...}
            static void show_help(std::ostream& out) {...}
            //! getter for help_ (access is Ro)
            bool help() const { return help_; }
            //! getter for timestamp_ (access is Ro)
            std::vector<std::string> const& timestamp() const { return timestamp_; }
            //! getter for date_ (access is Ro)
            std::vector<std::string> const& date() const { return date_; }
            friend inline std::ostream& operator<<(std::ostream& out,
                                                   Program_options const& item) {

           private:
            bool help_{};
            std::vector<std::string> timestamp_{};
            std::vector<std::string> date_{};
          };
          ...
          int main(int argc, char** argv) {
            using namespace fcs;
            try {
              Program_options options = {argc, argv};
              if (options.help()) {
                Program_options::show_help(std::cout);
                return 0;
              }
          ...
          }

* [Test]: A generated test. 

* [Script]: Any large C++ installation will typically require or benefit from some set of scripts.

* [Installation]: The *kit and caboodle*. An installation is a collection of *libs*, *apps*, *tests* and *scripts*. When an installation is generated it generates all artifacts, taking care to leave all protect blocks in tact.


### Functional Targets

In most large scale projects there are often those mundane tasks that scream for code generation. Here are some that are covered by *ebisu_cpp*

* *Common Operators* Often support for various operators can (and should) be code generated. Assume you have a class that looks something like:

            class_('code_packages_value')
            ..opEqual
            ..opLess
            ..streamable = true
            ..members = [
              member('name')..type = 'fcs::utils::Fixed_size_char_array<64>',
              member('descr')..type = 'fcs::utils::Fixed_size_char_array<256>',
            ];

    The following common operators are generated.    

    * *operator==*: Equality operator

            bool operator==(Code_packages_value const& rhs) const {
              return this == &rhs || (name == rhs.name && descr == rhs.descr);
            }

    * *operator<*: Less than operator

            bool operator<(Code_packages_value const& rhs) const {
              return name != rhs.name
                         ? name < rhs.name
                         : (descr != rhs.descr ? descr < rhs.descr : (false));
            }

    * *operator<<*: Streaming operator

            friend inline std::ostream& operator<<(std::ostream& out,
                                                   Code_packages_value const& item) {
              out << '\n' << "name:" << item.name;
              out << '\n' << "descr:" << item.descr;
              return out;
            }

* Other types of methods are easily generated.

    * *Constructors initializing members*. For example to add a member
       initializing constructor that initializes the member *name*,
       the following addition will work:

            class_('code_packages_value')
            ..opEqual
            ..opLess
            ..memberCtors = [ memberCtor(['name']) ]
            ...
       Which will cause the addition of:
       
            Code_packages_value(
              fcs::utils::Fixed_size_char_array<64> name) :
              name_ { name } {
            }
       Note, that it is accepting the name by value. Depending on your code this may not be desirable, and in this case it is not. A simple modification to the member will address it:
       
            member('name')
            ..byRef = true
            ..type = 'fcs::utils::Fixed_size_char_array<64>',
       Now we have pass by reference, much better:

            Code_packages_value(
              fcs::utils::Fixed_size_char_array<64> const & name) :
              name_ { name } {
            }


* *Serialization* Classes can be given support for serialization and the

## Large Scale Code Generation

Perhaps you want to generate all code, business logic as well as structure. This is a common task when the functionality is very pattern oriented.

### More on Custom Blocks

Typically, the set of *custom blocks* associated with some type of entity are determined up front. For instance, for C++ classes you can specify inclusing of any of the following custom blocks:

    class_('foo')
    ..customBlocks = [clsPreDecl, clsPublic, clsProtected, clsPrivate, clsPostDecl]

Similarly for any C++ file, *Header*, *Impl*, or *App* which is an *Impl*, you can choose from:

    app('date_time_converter')
    ..namespace = namespace(['fcs'])
    ..customBlocks = [
      fcbCustomIncludes, fcbPreNamespace, fcbPostNamespace,
      fcbBeginNamespace, fcbEndNamespace ]

Essentially the predefined set of *custom blocks* for an entity comprise the set matching the best guess of the code generation author as to where additional custom code might be required. The name indicates the location, so *fcbCustomIncludes* is a protection block near the top of the file, just below any pre-registered include statements, allowing the C++ developer to throw in new includes as they are developing without regenerating. Similarly, *fcbPreNamespace* is the location just above the namespace declaration containing the meat of the structure and logic. The interesting thing about these locations is that they represent not only where a user might like enter hand written code, they are also the location where a large scale code generation effort might like to programatically include more generated content.

## Generated Code Requirements

* *boost* Used for *program_options* to support application arguments. Used for *date_time*, and *thread_local_storage* support when using database orm facilities.

* *cereal* Used for serialization.

## Philosophies/Goals

* Always support generating code around custom code. Alternatively always provide hooks for custom code to be inserted into generated code.

* Make usage of *ebisu_cpp* simple enough to be used on tasks where hand-coding is still the bulk of the effort, but the option to incorporate code generation is still desired

* Where possible steer generation towards good practices

    * Encourage good member encapsulation
    * Encourage namespace usage
    * Encourage consistent directory structure/layout
    * Encourage consistent file structure/layout

## Target Applications

## Why Dart

There are many code generation systems out there and this sort of
thing can be done in any number of languages. Dart has a very nice set
of facilities that make it perfect for this type of work.

### Compiled Languages vs Scripting Languages

### Templates vs Code Functions



## Examples




