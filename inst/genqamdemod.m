## Copyright (C) 2025 Yassin Achengli 
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{x} =} genqamdemod (@var{y}, @var{c})
##
## Demodulation of a modulated complex sequence @var{y} onto an integer sequence 
## with values in the range of @code{[0 @dots{} M-1]} defined as $var{x}, where
## @code{M = length (c) - 1} and @var{c} is a column vector specifying the signal 
## constellation mapping to be used.
##
## @example
## @group
## qam = [-1+i 1+i 1-i -1-i];
## y = 2 * randn (1, 1e4) - 1 + 2i * randn(1, 1e4) - i;
## x = genqamdemod (y, qam);
## yp = genqammod (x, qam);
## z = awgn (yp, 20);
## plot (z, "rx")
## @end group
## @end example
## @seealso{genqammod}
## @end deftypefn

function x = genqamdemod (y, c)

  if (nargin != 2)
    print_usage ();
  endif

  if (ndims (y) != 2 || ndims (c) != 2)
    print_usage ();
  endif

  # if it is not set as column vector, will be fit as a column vector
  y = reshape (y, numel (y), 1); 
  c = reshape (c, 1, numel (c));
  M = length (y);
  
  Ym = y * ones (1, length(c));
  C = ones (M, 1) * c;
  
  evm = abs (Ym - C);
  x = zeros (size (y));
  
  for r = 1:size (evm, 1)
    f = find (evm(r, :) == min (evm(r, :))) - 1;
    x(r) = f(1);
  endfor
  x = x';
endfunction
%!test
%! assert (genqamdemod ([3+2i .23-.34i], [-1+.5i 1-.5i]), [1 1])
%! assert (genqamdemod (genqammod ([1 2 1 0 3], [-1+i 1+i 1-i -1-1i]), [-1+i 1+i 1-i -1-1i]), [1 2 1 0 3])

%% Test input validation
%!error genqamdemod()
%!error genqamdemod(1)
%!error genqamdemod(1,2,3)
