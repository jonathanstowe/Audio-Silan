use v6;

class Audio::Silan {
   use File::Which;
   use JSON::Fast;

   class X::NoSilan is Exception {
      has Str $.message = "No silan executable found";
   }

   has Str $!silan-path;

   multi submethod BUILD()  {
      my $sp = which('silan');

      if not $sp.defined {
         X::NoSilan.new.throw;
      }
      else {
         $!silan-path = $sp;
      }
   }

}
# vim: expandtab shiftwidth=4 ft=perl6
