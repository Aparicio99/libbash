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
/// \file continue_builtin.h
/// \author Mu Qiao
/// \brief implementation for the continue builtin
///
#include <boost/lexical_cast.hpp>

#include "builtins/builtin_exceptions.h"
#include "core/interpreter_exception.h"

#include "builtins/continue_builtin.h"

int continue_builtin::exec(const std::vector<std::string>& bash_args)
{
  int nth = 1;

  if(bash_args.size() > 1)
  {
    throw interpreter_exception("continue: too many arguments");
  }
  else if(bash_args.size() == 1)
  {
    try
    {
      nth = boost::lexical_cast<int>(bash_args[0]);
    }
    catch(boost::bad_lexical_cast& e)
    {
      throw interpreter_exception("continue: argument should be an integer");
    }
  }

  throw continue_exception(nth);
}
