# This XML grammar is the one used for turning XML into trees.  It's based on Krunen's, and 
# will hopefully be merged back into something at some point.  

grammar XML::Grammar::Document;

rule TOP {
  ^
  <xmldecl>?      [ <comment> | <pi> ]*
  <doctypedecl>?  [ <comment> | <pi> ]*
  <root=element>  [ <comment> | <pi> ]*
  $
  {*}
}

token comment { '<!--' ~ '-->' <content> {*} }
token pi { '<?' ~ '?>' <content> {*} }
token content { .*? {*} }

rule xmldecl {
   '<?xml'
   'version'  '=' '"' ~ '"' <version>
   'encoding' '=' '"' ~ '"' <encoding>
   '?>'
   {*}
}
token version { <-[\"]>+ {*} }
token encoding { <-[\"]>+ {*} }
token value { <-[\"]>+ {*} }

rule doctypedecl {
  '<!DOCTYPE ' <name> ~ '>' <content>
  {*}
}

rule element {
  '<' <name> {*}  #= opentag
  <attribute>*
  [
  | '/>'
  | '>' <child>* '</' $<name> '>' {*} #= closetag
  ]
}

rule attribute {
    <name> '=' '"' ~ '"' <value>
    {*}
}

rule child {
  | <element>
  | <cdata>
  | <text=textnode>
  | <comment>
  | <pi>
  {*}
}

token cdata {
 '<![CDATA[' ~ ']]>' <content>
  {*}
}

token textnode { <-[<]>+ {*} }
token name { <.alpha><.ident>+[<.ident>+]? {*} }

