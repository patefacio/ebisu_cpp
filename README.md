# Ebisu Cpp

[![Build Status](https://drone.io/github.com/patefacio/ebisu_cpp/status.png)](https://drone.io/github.com/patefacio/ebisu_cpp/latest)

Code generation library/toolkit that focuses on generating the structure of c++ code and as much of the boilerplate coding that goes with that in the creation of c++ systems. Much like its required companion library [ebisu](https://github.com/patefacio/ebisu) this library does what it can to leverage a convenient declarative approach encouraging heavy use of *cascades*.

## General C++ Code Generation Approach

As stated the focus is on c++ *structure* as opposed to attempting to support all aspects of the language. Specifically, the following are current structural targets for application:

### Structural Targets

* [Enum]: C++ enums, with some support for serialization and different flavors - such as *masks*.

          Example:

          enum_('submit_result')
          ..values = [
            'submit_succeeded',
            'submit_invalid_market',
            'submit_invalid_order_details' ],

          Generates:

          enum Submit_result {
            Submit_succeeded_e,
            Submit_invalid_market_e,
            Submit_invalid_order_details_e
          };

* [Class]: The heart of the language. With simple declarations, classes can be generated.

            Example:

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

            Generates:

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


* [Header]: A single header file, typically with a collection of C++ type things like includes, enums, classes, forward declarations, using statements

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

* [App]: A single application executable. 

* [AppArg]: An application argument that gets translated into *boost::program_option* code

### Functional Targets

In most large scale projects there are often those mundane tasks that scream for code generation. Here are some that are covered by *ebisu_cpp*

* *Serialization* Classes can be given support for serialization and the

* *Common Operators* Often support for various operators can (and should) be code generated. 

    * *operator==*

    * *operator<*

    * *operator<<*

    * *Constructors initializing members*


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

## Examples




