.PHONEY:	clean

top=../../..
forms= Formf1065.pm Formf1065Draft.pm
class_prefix=Bivio::UI::PDF::Form::F1065::Y1999::Form
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
	../Null.pm \
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
	DateXlator.pm \
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
xlator_set=Bivio::UI::PDF::Form::F1065::Y1999::XlatorSet

deps= \
	$(addprefix $(top)/Form/, $(modules)) \
	XlatorSet.pm \
	$(pdfs)

Form%.pm : %.pdf
	$(top)/Form/buildFormModule.pl $@ $(class_prefix)$* $(parent) $< $(xlator_set)

all:	$(forms)

$(forms):	$(deps)

clean:
	rm -f $(forms)
