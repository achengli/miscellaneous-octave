function r = poly_mod (a, p)
  r = a(find (a, 1):end);
  while (length (r) >= length (p))
    if (r(1) == 1)
      r(1:length(p)) = xor(r(1:length(p)), p);
    endif
    r = r(2:end);
  endwhile
endfunction
