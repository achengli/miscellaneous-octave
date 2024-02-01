## Copyright (C) 2023 Yassin Achengli <0619883460@uma.es>
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
## @deftypefn {signal} {[@var{signal}, @var{BW}, @var{LF}] =} randtones(@var{t}, @var{Ntones}, @var{BW})
## @deftypefnx {signal} {[@var{signal}, @var{BW}, @var{LF}] =} randtones(@var{t}, @var{Ntones}, @var{BW}, @dots{})
## 
## This function generates a multiplex of various tones which are between the frecuencies @code{central_frec - BW/2}
## and @code{central_frec + BW/2}.
## This function has basic parameters and various options to modify the behavior to your wishes.
## 
## Input aruments
## @itemize
## @item @var{t}
## Timeline vector or scalar.
## 
## @item @var{Ntones}
## Number of random frecuency tones wich will be multiplexed.
## 
## @item @var{BW}
## Sugested bandwidth. 
## @end itemize
##
## Output arguments:
## @itemize
## @item @var{signal}
## Multiplexed signal
## 
## @item @var{BW}
## Occupied bandwidth.
## 
## @item @var{LF}
## First frecuency of non null spectrum.
## @end itemize
##
## Options:
## @itemize
## @item amplitude <string> Maximum amplitude of the tones. default: 1
## @item amplitude_function <function_handle> Amplitude alter depending on frecuency. default: @code{@(x) exp(-abs(frec-central_frec))}
## @item distribution <string|function_handle> Which distribution function must be used. default: 'uniform'
## @item central_frec <scalar> Around the central frecuency of the used spectrum.
## @item distribution_params <Struct|Vector> Distribution arguments
## @end itemize
##
## Example of usage:
## @example
## @group
## fs = 44100;
## t = linspace(-10,10,10*fs);
## [s, BW, LF] = randtones(t, 10, 100e3, 'central_frec', 50e3, distribution, 'normal', 'amplitude', 2);
## @end group
## @end example
##
## @seealso{rectpuls, tripuls}
## @end deftypefn
function [signal, BW, LF] = randtones(t, Ntones, BW, varargin)
  if (nargin < 3)
    print_usage()
  endif

  t_validator = @(x) ismatrix(x) || isscalar(x) || isvector(x);
  if (Ntones < 1 || !t_validator(t) || !isscalar(BW) || BW <= 0)
    print_usage();
  endif

  p = inputParser();
  p.addParameter('amplitude', 1, @isscalar)
  distribution_validator = @(x) is_function_handle(x) || ischar(x);
  p.addParameter('distribution','uniform',distribution_validator) 
  p.addParameter('central_frec', 0, @isscalar)
  p.addParameter('distribution_params', struct(), @isstruct)
  p.addParameter('amplitude_function', @(f) exp(abs(f - central_frec)), @is_function_handle)
  p.parse(varargin{:})
  parameters = p.Results;
  amplitude = parameters.amplitude;
  distribution = parameters.distribution;
  central_frec = parameters.central_frec;
  distribution_params = parameters.distribution_params;
  frecuency_range = [central_frec - BW/2, central_frec + BW/2];

  pp = inputParser();
  pp.addParameter('mu',central_frec,@isscalar)
  pp.addParameter('var',BW/2,@isscalar)
  pp.addParameter('lambda',1,@isscalar)
  k_poisson_validator = @(k) isinteger(k) || k >= 0;
  pp.addParameter('k',1,@k_poisson_validator)
  pp.parse(distribution_params)
  distribution_params = pp.Results

  mu = distribution_params.mu; variance = distribution_params.var;
  if (ischar(distribution))
    switch (distribution)
      case {'normal','gaussian'}
        distribution_function = @(x) movvar(movmean(randn(x),mu),variance);
      case 'exponential'
        mn = 1/distribution_params.lambda; vr = 1/distribution_params.lambda^2;
        distribution_function = @(x) movvar(movmean(rande(x),mn),vr);
      case 'poisson'
        k = distribution_params.lambda;
        distribution_function = @(x) movvar(movmean(randp(k,x),k),k);
      otherwise
        distribution_function = @(x) rand(x)*variance + mu;
      endswitch
  else
    distribution_function = distribution;
  endif

  amplitude = amplitude * randn(1,Ntones); amplitude = reshape(amplitude, 1,length(amplitude));
  frecuencies = distribution_function([1,Ntones]); frecuencies = reshape(frecuencies, length(frecuencies),1);
  t = reshape(t,1,length(t));

  signal = amplitude * sin(2*pi*frecuencies*t);
  LF = min(frecuencies); BW = max(frecuencies) - min(frecuencies);
endfunction

%!demo
%! fs = 44100;
%! t = 0:1/fs:3-1/fs;
%! Ntones = 10;
%! BW = 2e3;
%! central_frec = 1400;
%! [signal, bw, lf] = randtones(t, Ntones, BW,'central_frec', central_frec);
%! figure
%! plot(t, signal, 'linewidth', 2);
%! fprintf('- BandWidth: %d\n- Lower Frecuency: %d', bw, lf, 'distribution', 'gaussian');
