#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;
use Test::Exception;

use MooseX::Declare;

class Document::Page {
    has 'body' => (
        is      => 'rw',
        isa     => 'Str',
        default => '',
    );

    method create {
        $self->open_page;
        inner;
        $self->close_page;
    }

    method append_body ($appendage) {
        $self->body($self->body . $appendage);
    }

    method open_page  { $self->append_body('<page>') }
    method close_page { $self->append_body('</page>') }
}

class Document::PageWithHeadersAndFooters extends Document::Page {
    augment create {
        $self->create_header;
        inner;
        $self->create_footer;
    }

    method create_header { $self->append_body('<header/>') }
    method create_footer { $self->append_body('<footer/>') }
}

class TPSReport extends Document::PageWithHeadersAndFooters {
    augment create {
        $self->create_tps_report;
    }

    method create_tps_report {
       $self->append_body('<report type="tps"/>');
    }
}

my $tps_report = TPSReport->new;
isa_ok($tps_report, 'TPSReport');

is(
$tps_report->create,
q{<page><header/><report type="tps"/><footer/></page>},
'... got the right TPS report');
