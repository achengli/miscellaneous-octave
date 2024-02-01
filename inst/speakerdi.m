## Copyright (C) 2024 Yassin Achengli
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.

## -*- texinfo -*-
## @deftypefn {speakerdi} {[@var{DI}, @var{w}] =} speakerdi(@var{freq}, @var{w}) 
## @deftypefnx {speakerdi} {[@var{DI}, @var{w}] =} speakerdi(@var{freq}, @var{w}, @var{N}) 
## @deftypefnx {speakerdi} {[@var{DI}, @var{w}, @var{f}] =} speakerdi(@var{freq}, @var{w}, @var{N}, @var{...}) 
## 
## Directivity diagram of spherical punctual sound source. The parameters @var{freq} and @var{a} 
## are the frequency and the radius of the source respectively.
## 
## Inputs:
## @itemize
## @item
## @var{freq}        Frequency ::Scalar
##
## @item 
## @var{a}           Diameter ::Scalar
##
## @item
## @var{N}?          How much points take to represent the diagram in polar representation ::Integer
##
## @item
## @var{c}?          Sound speed ::Scalar
##
## @item
## @var{graph}?      Show graphics ::Boolean
##
## @item
## @var{spherical}?  Spherical or hemispherical source ::Boolean
## @end itemize
## 
## Outputs:
## @itemize
## @item
## @var{DI}          Directivity along the axis from -pi/2 to pi/2 if hemispherical and -pi to pi otherwise
##
## @item
## @var{w}           Frequency vector
##
## @item
## @var{f}           Figure handler if @var{graph} is set
## @end itemize
##
## @seealso{besselj}
## @end deftypefn

function [DI, w, f] = speakerdi(freq, a, N, varargin)

  if (nargin < 2)
    print_usage();
  elseif (nargin == 2)
    N = 100;
  endif

  N = uint64(N);

  if (!isscalar(freq) || !isscalar(a) || !isscalar(N) ||...
    freq <= 0)
    fprintf("here\n")
    print_usage();
  endif

  phi = @(x) 2*besselj(0, x)./x;
  dB = @(x) 10*log10(x);

  iparser = inputParser();
  iparser.addParameter('c', 343, @isscalar);
  iparser.addSwitch('graph');
  iparser.addSwitch('spherical');

  iparser.parse(varargin{:});
  res = iparser.Results;
  c = res.c;
  graph = res.graph;
  spherical = res.spherical;

  lambda = c/freq;
  k = 2*pi/lambda;
  DImax = [(k*a)^2 / (1 - phi(2*k*a)), (k*a)^2]((k*a > 2) + 1);

  LOW_INT = [pi/2, pi]((spherical == true) + 1);
  w = linspace(-LOW_INT, LOW_INT, N);
  DI = DImax + dB(phi(k*a*sin(w)).^2);

  f = -1;
  if (graph)
    f = figure();
    polar(w, DI, 'b');
    title('Punctual Spheric Sound Source Directivity Diagram');
    xlabel('frequency [rad]');
    ylabel('Pressure amplitude [dB]');
  endif
endfunction
%!demo
%! freq = 355;
%! a = 0.009;
%! N = 1000;
%! [DI, w] = speakerdi(freq, a, N, 'graph');

%!test
%! [DI, w] = speakerdi(4e3, .09, 1000, 'c', 1400, 'spherical');
%! assert(ismatrix(DI) || isvector(DI))
%! assert(ismatrix(w) || isvector(w))
