.PHONEY:	clean

top=../../..
pdf=f1065.pdf
class=Bivio::UI::PDF::Form::f1065::y1999::Form
parent=Bivio::UI::PDF::Form::Form
modules=  \
	../Array.pm \
	../ArrayIterator.pm \
	../Body.pm \
	../Boolean.pm \
	../BuiltUpdate.pm \
	../ClearUpdate.pm \
	../Comment.pm \
	../Dictionary.pm \
	../DirectObj.pm \
	../Emit.pm \
	../FirstParsedUpdate.pm \
	../Header.pm \
	../IndirectObj.pm \
	../IndirectObjRef.pm \
	../Name.pm \
	../Number.pm \
	../ObjRef.pm \
	../OpaqueUpdate.pm \
	../ParsedUpdate.pm \
	../Pdf.pm \
	../PdfObj.pm \
	../Regex.pm \
	../Section.pm \
	../Stream.pm \
	../String.pm \
	../StringAngle.pm \
	../StringParen.pm \
	../Strings.pm \
	../Trailer.pm \
	../Update.pm \
	../Xref.pm \
	ButtonXlator.pm \
	FloatXlator.pm \
	Form.pm \
	FracXlator.pm \
	IntXlator.pm \
	MoneyXlator.pm \
	RadioBtnXlator.pm \
	Request.pm \
	StringCatXlator.pm \
	StringXlator.pm \
	TaxId1Xlator.pm \
	TaxId2Xlator.pm \
	Xlator.pm \
	XlatorSet.pm
xlator_set=Bivio::UI::PDF::Form::f1065::y1999::XlatorSet

form=$(top)/Form

deps= \
	$(addprefix $(form)/, $(modules)) \
	XlatorSet.pm \
	$(pdf)

Form.pm:	$(deps)
	$(form)/buildFormModule.pl $@ $(class) $(parent) $(pdf) $(xlator_set)

clean:
	rm -f Form.pm
