## Logging Goals

- Use an actively managed, high quality, open source logging solution

- Make it simple to add logging support to a *library*.

- Provide a mechanism to ensure that logging can be removed entirely,
  i.e. no checks against log level. It is important that liberal
  logging incur no cost if desired.

## Logging Solution

### Open Source Implementation

The open source logging solution selected is
[spdlog](https://github.com/gabime/spdlog). The logger is fast,
flexible and easy to use.

### Make it simple to add logging support to a *library*

In order to include logging in a library, assign the *requiresLogging*
property to true. When this is done a corresponding logging header
will be created in the library.

For example:

    final h5_utils = lib('h5_utils')
      ..requiresLogging = true
      ..namespace = namespace(['ebisu', 'h5', 'utils'])
      ...

The *requiresLogging* will:

- generate *h5_utils_logging.hpp*. This file defines a template logger
  class *H5_utils_logger<>* and an instance of the logger. Since the
  instance is in a header it is important that the same logger is
  resolved by any translation units using it. This is achieved with an
  accessor that returns a function static instance of the logger.

- ensure all other headers within the library include the logging
  header. This is for convenience.

### Support *null logger* Implementation

The goal is to easily be able build the code with 0 impact from
logging even when logging statements are present. This is intended for
performance critical code in which even checks for log-level are not
desirable. In order to support this the logger *spdlog* logger
implementation is not used directly, but rather used via a wrapper
logger class. The wrapper logger class provides the same API as
spdlog. The *H5_utils_logger<>* class has two specializations
provided, one which just forwards log calls to spdlog's logger and the
other which forwards the args to a null logger.

    namespace {
        ////////////////////////////////////////////////////////////////////////////////
        // Logging takes place by default in DEBUG mode only
        // If logging is desired for *release* mode, define RELEASE_HAS_LOGGING
        #if defined(DEBUG) || defined(RELEASE_HAS_LOGGING)
          using H5_utils_logger_t = H5_utils_logger<spdlog::logger>;
        #else
          using H5_utils_logger_t = H5_utils_logger<ebisu::logger::Null_logger_impl>;
          H5_utils_logger_t h5_utils_logger_impl;
        #endif

        H5_utils_logger_t::Logger_impl_t h5_utils_logger = H5_utils_logger_t::logger();
    }
