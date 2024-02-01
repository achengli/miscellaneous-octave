## Copyright (C) 2023-2024 Yassin Achengli <achengli@github.com>
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
## @deftypefn {acoustics} {[@var{X}, @var{freq}, @var{Xcomplex}] =} spd(@var{x}, @var{t})
## @deftypefnx {acoustics} {[@var{X}, @var{freq}, @var{Xcomplex}] =} spd(@var{x}, @var{t}, @var{freq_window})
##
## Calculates the SPD "Spectral Power Density" of a given signal with certain temporal axis
##
## Inputs:
## @itemize
## @item
## @var{x} Time domain signal
##
## @item
## @var{t} Temporal axis or sample rate
##
## @item
## @var{freq_window} Frequency bandwidth of fft (As more bigger it is as more detailed the result would 
## be but with a huge amount of computing time).
## @end itemize
##
## Outputs:
## @itemize
## @item
## @var{X} SPD
##
## @item
## @var{freq} conjoint frequency domain vector
##
## @item
## @var{Xcomplex} Complex fourier transform
## @end itemize
## @seealso{signal/spectgram}
## @end deftypefn

function [X, freq, Xcomplex] = spd(x,t,freq_window)

  if (nargin < 2) 
    print_usage()
  endif

  if (length(t) != 1) 
    fs = abs(1/(t(2) - t(1)));
  else
    fs = t;
  endif

  if (nargin == 3)
    if (~ismatrix(freq_window))
      freq_max = freq_window;
    else
      if (length(freq_window) == 2)
        freq_min = freq_window(1); freq_max = freq_window(2);
      endif
    endif
  endif

  Xcomplex = fftshift(fft(x)); 
  X = abs(Xcomplex);
  N = length(abs(X));

  if (exist('freq_max', 'var') && exist('freq_min', 'var')) 
    freq = linspace(freq_min, freq_max, abs(freq_max - freq_min)*N/fs)*fs/N;
  else
    freq = linspace(-N/2,N/2, N)*fs/N;
  endif
endfunction
