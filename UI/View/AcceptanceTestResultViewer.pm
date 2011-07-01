# Copyright (c) 2007-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::AcceptanceTestResultViewer;
use strict;
use Bivio::Base 'View.Method';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub acceptance_test_detail {
    view_put(
	xhtml => FRAMESET(
	    Join([
		FRAME({
		    NAME => 'header',
		    SRC => ['->format_uri', 'DEV_ACCEPTANCE_TEST_HEADER'],
		}),
		FRAME({
		    NAME => 'transaction_list',
		    SRC => ['->format_uri', 'DEV_ACCEPTANCE_TEST_TRANSACTION_LIST'],
		}),
		FRAMESET(
		    Join([
			FRAME({
			    NAME => 'req',
			}),
			FRAME({
			    NAME => 'res',
			 }),
		     ]),
		    {
			COLS => '30%, 70%'
		    },	    
		),
	    ]),
	    {
		ROWS => '80px,20%,45%',
	    }
	),
    );
    return;
}

sub acceptance_test_header {
     view_put(xhtml => 
		  Join([
		      HEAD(
			  STYLE(_css(), {
			      TYPE => 'text/css',
			  }),
		      ),
		      BODY(Join([
			  H1(Join([
			      String('Acceptance Test Results for "'),
			      [b_use('Model.AcceptanceTestTransactionList'), '->get_test_name', ['->req']],
			      String('"'),
			  ])),
			  BR(),
			  Link({
			      value => 'Back to test list',
			      link_target => '_top',
			      href => URI({
				  task_id => 'DEV_ACCEPTANCE_TEST_LIST',
			      })}),
		      ])),
		  ]),
	  );
     return;
 }


sub acceptance_test_list {
    view_put(xhtml =>
		 Join([
		     HEAD(
			 STYLE(_css(), {
			     TYPE => 'text/css',
			 }),
		     ),
		     BODY(Join([		     
			 H1('Acceptance Test Results'),
			 vs_paged_list('AcceptanceTestList', [
			     ['test_name', {
				 column_widget => Link({
				     value  => String(['test_name']),
				     href => URI({
					 task_id => 'DEV_ACCEPTANCE_TEST_DETAIL',
					 path_info => ['test_name'],
				     }),
				 }),
				 column_data_class => 'test_name',		
			     }],
			     ['age', {
				 column_data_class => 'age',		
			     }],
			     ['timestamp', {
				 column_data_class => 'timestamp',		
			     }],
			     ['outcome', {
				 column_data_class => 'outcome',		
			     }],
			 ]),
		     ])),
		 ]));
    return;
}

sub acceptance_test_request {
    view_put(xhtml  =>
		 Join([
		     HEAD(
			 STYLE(_css(), {
			     TYPE => 'text/css',
			 }),
		     ),
		     BODY(
			 PRE([b_use('Model.AcceptanceTestTransactionList'), '->get_http_request',
			      ['->req', 'path_info'],
			      ['->req', 'query', 'q'],
			      ['->req', 'query', 's'],
			  ], {
			      CLASS => 'headers',
			  }),
		     ),
		 ]),
	 );
    return;
 }

sub acceptance_test_response {
    view_put(xhtml =>
		 [b_use('Model.AcceptanceTestTransactionList'), '->get_http_response',
		  ['->req', 'path_info'],
		  ['->req', 'query', 'q'],
		  ['->req', 'query', 's'],
	      ]);
    return;
 }

sub acceptance_test_transaction_list {
    view_put(xhtml =>    
		 Join([
		     HEAD(
			 Join([
			     STYLE(_css(), {
				 TYPE => 'text/css',
			     }),
			     SCRIPT(_javascript(), {
				 TYPE => 'text/javascript',
			     }),
			 ]),
		     ),
		     BODY(Join([
			 vs_list('AcceptanceTestTransactionList', [
			     ['request_response_number', {
				 column_widget => Link({
				     value => Join([['request_number'], String('/'), ['response_number']]),
				     href => '#nonesuch',
				     ONCLICK =>  Join([
					 String('display(this.parentNode.parentNode, '),
					 ['request_number'],
					 String(', '),
					 ['response_number'],
					 String(', '),
					 q{'}, ['->req', 'path_info'], q{'},
					 String(');'),
				     ]),
				 }),
				 column_data_class => 'request_response_number',
			     }],
			     ['test_line_number', {
				 column_data_class => 'test_line_number',		
			 }],
			     ['http_status', {
				 column_data_class => 'http_status',		
			     }],
			     ['command', {
				 column_data_class => 'command',		
			     }],
			 ]),
		     ])),
		 ]));
    return;
}

sub pre_compile {
    my($self) = @_;
    view_parent('AcceptanceTestResultViewer->xhtml')
	unless $self->get('view_name') eq 'xhtml';
    return;
}

sub xhtml {
    my($self) = @_;
    view_class_map('XHTMLWidget');
    view_shortcuts('UIXHTML.ViewShortcuts');
    view_put(
	xhtml => '',
    );
    view_main(SimplePage(view_widget_value('xhtml')));
    return;
}

sub _css {
    return << 'EOF';
* {
    font-family: "Verdana", "Geneva", "sans-serif";
}

a {
    color: darkblue;
    font-size:13px;
}
a:hover {
    color: cyan;
}
table {
    font-size:13px;
}
h1 {
    font-size:16px;
}
.test_name {
   width: 200px;
}
.age {
   width: 100px;
}
.timestamp {
   width: 150px;
}
.outcome {
   width: 100px;
}
.headers {
    font-family: "Consolas", "Courier", "fixed";
    margin-top: 10px;
    font-weight: bold;
}
.request_response_number {
   width: 70px;
}
.test_line_number {
   width: 65px;
}
.http_status {
   width: 50px;
}
.unselected {
   background-color: none;
}
.selected {
   background-color: yellow;
}
EOF
}

sub _javascript {
   return <<'EOF';
<!--
function display(element, req, res, path) {
   if (selected != null) {
        selected.className = "unselected"; 
   }
   selected = element;
   selected.className = "selected";
   top.frames['req'].location.href = "/acceptance-test-request" + path + "?q=" + req + "&s=" + res;
   top.frames['res'].location.href = "/acceptance-test-response" + path + "?q=" + req + "&s=" + res;
   return 0;
}
var selected;

-->
EOF
}

1;
