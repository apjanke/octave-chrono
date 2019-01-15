function make_local
  %MAKE_LOCAL Build the octfiles for this repo
  %
  % Call this function if you are working with a local copy of this repo instead
  % of installing it as a package.
  octfcns = {
    '__oct_time_binsearch__'
    };
  for i = 1:numel (octfcns)
    octfcn = octfcns{i};
    mkoctfile (sprintf ('src/%s.cc', octfcn));
    delete (sprintf ('%s.o', octfcn));
    movefile (sprintf ('%s.oct', octfcn), 'inst');
    printf (sprintf ('Built %s\n', octfcn));
  endfor
endfunction
