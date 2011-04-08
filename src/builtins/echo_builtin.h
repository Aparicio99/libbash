/*
   Please use git log for copyright holder and year information

   This file is part of libbash.

   libbash is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 2 of the License, or
   (at your option) any later version.

   libbash is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with libbash.  If not, see <http://www.gnu.org/licenses/>.
*/
///
/// \file echo_builtin.h
/// \author Nathan Eloe
/// \brief class that implements the echo builtin
///

#ifndef LIBBASH_BUILTINS_ECHO_BUILTIN_H_
#define LIBBASH_BUILTINS_ECHO_BUILTIN_H_

#include <cstdlib>
#include <iterator>
#include "../cppbash_builtin.h"

///
/// \class echo_builtin
/// \brief the echo builtin for bash
///
class echo_builtin: public virtual cppbash_builtin
{
  public:
    BUILTIN_CONSTRUCTOR(echo)

    ///
    /// \brief runs the echo plugin on the supplied arguments
    /// \param bash_args the arguments to the echo builtin
    /// \return exit status of echo
    ///
    virtual int exec(const std::vector<std::string>& bash_args);
  private:
    ///
    /// \brief determines the options passed as arguments
    /// \param string string to check for arguments
    /// \param suppress_nl returns back whether to suppress newlines
    /// \param enable_escapes returns back whether to enable escapes
    /// \return false if all options have been processed
    bool determine_options(const std::string &string, bool &suppress_nl, bool &enable_escapes);

    /// \brief transforms escapes in echo input
    /// \return false when further output should be suppressed
    void transform_escapes(const std::string &string);
};

#endif
