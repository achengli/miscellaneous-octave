function x_gf = gf (x, m, prim_poly)

  if (nargin == 1)
    m = [];
  elseif (nargin == 2)
    prim_poly = ones (length (m));
  elseif (nargin > 3)
    print_usage();
  endif

  if (isscalar (prim_poly))
    prim_poly = dec2bin(prim_poly) - '0';
  endif

  if (length(prim_poly) ~= m + 1)
    error ('Primitive polynomial must be order %d', m);
  endif

  x = x(:);
  x_gf = zeros (length (x), m);

  for idx = 1:length (x)
    bin_poly = dec2bin (x(i)) - '0';
    bin_poly = mod (bin_poly, 2);

    bin_poly = [zeros (1, max (0, m*2 - length (bin_poly))), bin_poly];
    bin_poly= poly_mod (bin_poly, prim_poly);

    if (length (bin_poly) < m)
      bin_poly = [zeros (1, m - length (bin_poly)), bin_poly];
    endif

    x_gf(i, :) = bin_poly (end - m + 1:end)l;
  endfor

endfunction
