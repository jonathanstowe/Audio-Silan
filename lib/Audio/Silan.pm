use v6;

class Audio::Silan {
    use File::Which;
    use JSON::Fast;

    class X::NoSilan is Exception {
        has Str $.message = "No silan executable found";
    }

    class X::NoFile is Exception {
        has Str $.filename is required;
        method message() {
            return "File '{ $.filename }' does not exist";
        }
    }

    class Info {
        has Rat $.duration;
        has Int $.sample-rate;
        has Rat $.start;
        has Rat $.end;
    }

    has Str $.silan-path;
    has Numeric $.threshold is rw;
    has Numeric $.hold-off   is rw;

    method silan-path() { 
        if not $!silan-path.defined {
            my $sp = which('silan');
            if not $sp.defined {
                X::NoSilan.new.throw;
            }
            else {
                $!silan-path = $sp;
            }
        }

        if not $!silan-path.IO.x {
            X::NoSilan.new.throw;
        }

        $!silan-path;
    }

    method find-boundaries(Str $file) returns Promise {
        start {
            if not $file.IO.r {
                X::NoFile.new(filename => $file).throw;
            }
            else {
                my @args = self.build-args($file);
                my $proc = run(@args, :out, :err);

                if $proc.exitcode == 0 {
                    my $out = $proc.out.slurp-rest;

                    my $data = from-json($out);
                    my $duration = $data{"file duration"};
                    my $sample-rate = $data{"sample rate"};
                    my ( $start, $end ) = $data<sound>[0].list;

                    Info.new(:$duration, :$sample-rate, :$start, :$end);
                }
            }
        }
    }

    method build-args(Str $file ) {
        my @args = (self.silan-path, '-b', '--format', 'json');

        if $!threshold.defined {
            @args.append('--threshold', $!threshold.Str);
        }
        if $!hold-off.defined {
            @args.append('--holdoff', $!hold-off.Str);
        }
        @args.append($file);
        @args;
    }

}
# vim: expandtab shiftwidth=4 ft=perl6
