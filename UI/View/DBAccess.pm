# Copyright (c) 2007-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::DBAccess;
use strict;
use Bivio::Base 'View.Method';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_DBAMF) = b_use('Model.DBAccessModelForm');

#TODO: Can do this more clearly by returning a widget value for xhtml.
# Seems like these could be their own page type, but not sure why it needs its own css, could
# just be in View.CSS (perhaps conditionally)
sub absolute_path {
    # mega-kluge to disable caching
    return shift->get('view_method') . '(0x0)';
}

sub dbaccess_model_form {
    my($self) = @_;
    view_put(
        xhtml => Join([
                HEAD(
                    Join([
                        STYLE(_css(), {
                            TYPE => 'text/css',
                        }),
                        TITLE([\&_model_name]),
                    ])
                ),
                BODY(Join([
                    vs_simple_form('DBAccessModelForm' => [
                        DIV_header_panel(Join([
                            H1(Join([String('Model: '), [\&_model_name]])),
                            Grid([
                                [
                                    Link('Model list', 'DEV_DBACCESS_MODEL_LIST'),
                                    DIV_search_result(String(['Model.DBAccessModelForm', 'status'])),
                                    [
                                        sub {
                                            my($source) = @_;
                                            return unless $source->ureq('query', 'c');
                                            return Link('show in table', {
                                                task_id => 'DEV_DBACCESS_ROW_LIST',
                                            });
                                        }
                                    ],
                                ],
                            ])
                        ])),
                        Grid([
                            [
                                DIV_button_panel(
                                    Join([
                                        map(FormButton($_ . '_button'),
                                            qw(clear_form)),
                                    ]),
                                ),
                                DIV_button_panel(
                                    Join([
                                        map(FormButton($_ . '_button'),
                                            qw(first prev search next last)),
                                    ]),
                                ),
                                DIV_button_panel(
                                    Join([
                                        map(FormButton($_ . '_button'),
                                            qw(update create delete)),
                                    ]),
                                ),
                            ],
                        ]),
                        Grid([
                            map(
                                [
                                    Join([_label($_)])->put(
                                        row_control => _row_enabled($_),
                                        row_class => If(_read_only($_),
                                               'row_read_only',
                                               'row_editable'),
                                    ),
                                    DIV_field_value(
                                        If (_read_only($_),
                                            _form_field($_, 1),
                                            _form_field($_, 0),
                                        )
                                    ),
                                    _related_links($_),
                                ],                                
                                @{$_DBAMF->get_qualified_fields},
                            ),
                        ]),
                    ],
                    1,
                )])),
            ]));
    return;                     
}

sub dbaccess_model_list {
    view_put(xhtml =>
                 Join([
                     HEAD(
                         Join([
                             TITLE('Model List'),
                             STYLE(_css(), {
                                 TYPE => 'text/css',
                             }),                             
                         ]),
                      ),
                     BODY(Join([                     
                         H1('Property Models'),
                          vs_paged_list('DBAccessModelList', [
                             ['name', {
                                  column_widget => Link({
                                      value  => String(['name']),
                                      href => URI({
                                          task_id => 'DEV_DBACCESS_MODEL_FORM',
                                          path_info => ['name'],
                                         query => {
                                             n => 1,
                                         },
                                      }),
                                  }),
                                  column_data_class => 'name',                
                             }],
                                     
                         ]),
                     ])),
                 ]));
    return;
}

sub dbaccess_row_list {
    view_put(xhtml => Join([
        HEAD(
            Join([
                TITLE(Join([[\&_model_name], String(' List')])),
                STYLE(_css(), {
                    TYPE => 'text/css',
                }),
            ]),
        ),
        BODY(Join([
            DIV_header_panel(
                Join([
                    H1(Join([String('Model: '), [\&_model_name]])),
                    Grid([[
                        Link('Model list', 'DEV_DBACCESS_MODEL_LIST'),
                    ]]),
                ])
            ),
            vs_paged_list('DBAccessRowList', [
                ['index', {
                    column_widget =>                                      
                        Link({
                            value  =>  String(['index']),
                            href => URI({
                                task_id => 'DEV_DBACCESS_MODEL_FORM',
                                path_info => [\&_model_name],
                                query => [
                                    sub {
                                        my($source) = @_;
                                        my($query)= $source->req('query');
#TODO: Should be computed in DBAccessRowList
                                        $query->{n} = $source->get('index');
                                        return $query;
                                    },
                                ],
                            }),
                        }),
                    column_data_class => 'index',                
                }],
                map(
                    [
                        $_,
                        {column_heading => String(_unqualified($_))},
                    ],
                    @{$_DBAMF->get_qualified_fields},
                ),
            ]),
        ])),
    ]));
    return;
}

sub pre_compile {
    my($self) = @_;
    view_parent('DBAccess->xhtml')
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

            
sub _form_field {
    my($qualified_field_name, $read_only) = @_;
    return FormField({
        field => 'DBAccessModelForm.' . $qualified_field_name,
        form_field_label => 'DBAccessModelForm.prev_button',
        edit_attributes => {
            label => '',
            wf_want_select => 1,
            disabled => $read_only,
            is_read_only => $read_only,
            readonly => $read_only,
        }});
}

sub _model_name {
    my($source) = @_;
    my($mn) = $source->req('path_info') =~ qr{^/(.*)};
    return $mn;
}

sub _related_links {
    my($qualified_field) = @_;
    my($model_name, $field) = $qualified_field =~ qr{([^\.]*)\.(.*)};
    my($related) = $_DBAMF->get_related($model_name, $field);
    my($count) = {};
    map($count->{$_->{model}}++,  @$related); 
    return DIV_related_links(
        UL(
            Join([
                map(
                    _related_link($qualified_field, $_, $count->{$_->{model}} > 1),
                    sort(
                        {$a->{model} cmp $b->{model}}
                        @$related,
                    ),
                ),
            ]),
        ),
    );
}

sub _related_link {
    my($qualified_field, $related, $duplicate) = @_;
    my($label)
        = ' '
        . $related->{model}
        . ($duplicate ? "($related->{field})" : '')
        . ' ';
    return LI(
        If(
            [
                'Model.DBAccessModelForm',
                '->relation_exists',
                $qualified_field,
                $related->{model},
                $related->{field},
            ],
            Link(
                String($label),
#TODO: should be encapsulated in DBAccessModelForm -- if uri is undef then won't render link
                [          
                  sub {
                      my($source) = @_;
                      return {
                          path_info => $related->{model},
                          query => {
                              n => 1,
                              $related->{field} => $source->req('Model.DBAccessModelForm', $qualified_field),
                          },
                      };
                  },
                ],
            ),
            String($label),
        ),
    ); 
}

sub _row_enabled {
    my($field) = @_;
    return [
        sub {
            my($source) = @_;
            my($prefix) = substr($source->req('path_info'), 1) . '.';
            return index($field, $prefix) == 0;
        }
    ];
}

sub _read_only {
    my($qualified_field) = @_;
    return [
        sub {
            my($source) = @_;
            my($field) = $qualified_field =~ qr{[^\.]*\.(.*)};
            return ((($source->req('query') || {})->{'_' . $field} || 0) == 0) ? 1 : 0;
        }
    ];
}

sub _label {
    my($qualified_field) = @_;
    return [
        sub {
            my($source) = @_;
            my($field) = $qualified_field =~ qr{[^\.]*\.(.*)};
            my($label) = $field;
            $label =~ s/_/ /g;
            my($query) = {%{$source->req('query') || {}}};
            my($p) = '_' . $field;
            $query->{$p} = 1 unless (delete($query->{$p}) || 0 == 1);
            my($link) = DIV(Link($label . ': ', URI({
                path_info => $source->req('path_info'),
                query => $query,
            })));
            $link->put(class => 'field_label');  
            return $link;
        }
    ];
}

sub _css {
    return << 'EOF';
* {
    font-family: "Verdana", "Geneva", "sans-serif";
    font-size:13px;
}

a {
    color: blue;
    text-decoration: none;
}
a:hover {
    color: cyan;
}
h1 {
    font-size:16px;
}
tr.row_read_only {
   background-color: #F0FFFF;
}

tr.row_editable {
   background-color: #FFF0F0;
}

div.header_panel {
  padding: 10px;
  background-color: #F0F0F0;
}

div.field_err {
   color: #A05050;
   font-weight: bold;
}

div.field_label {
   padding: 10px;
   font-weight: bold;
}

div.field_value {
   margin: 5px;
   font-weight: bold;
}
div.search_result {
   margin: 5px;
   margin-left: 15px;
   font-weight: bold;
}
div.button_panel {
   padding: 10px;
   background-color: #FFFFD0;
}
tr.row_read_only textarea {
   color: grey;
}
tr.row_editable textarea {
}
div.related_links li {
  display: inline;
  border-left: 1px solid grey;
  padding-left: 0.3em;
  padding-right: 0.3em;
  color: grey;
}
div.related_links li:first-child
{
  border-left: none;
}

tr.b_odd_row {
  background-color: #FFFFD0;
}
tr.b_even_row {
  background-color: #F0FFFF;
}
tr.b_heading_row {
  background-color: #EEEEEE;
}
td.index {
  font-weight: bold;
}
EOF
}

sub _javascript {
   return <<'EOF';
EOF
}

sub _unqualified {
    my($qualified_field) = @_;
    my($field) = $qualified_field =~ qr{([^\.]*)$};
    return $field;
}

1;
