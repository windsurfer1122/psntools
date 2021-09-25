#!/bin/sh -eu

### optional: create a single AsciiDoc source (resolve all includes)
### wget -N https://raw.githubusercontent.com/asciidoctor/asciidoctor-extensions-lab/master/scripts/asciidoc-coalescer.rb
### ATTENTION! All preprocessor directives will be resolved (if using original, without monkey patch).
###            https://docs.asciidoctor.org/asciidoc/latest/key-concepts/#preprocessor-directives

MYDIR="$(dirname "${0}")"
MYDIR="${MYDIR:+${MYDIR}/}"

## optional: create a single AsciiDoc source (resolve all includes)
if [ 0 -eq 1 ]; then
  ${MYDIR}asciidoc-coalescer.rb -i -o ${MYDIR}../README.adoc ${MYDIR}../README-psntools.adoc
fi

## pandoc conversion from DocBook5 to reStructuredText, needs AsciiDoctor settings: :idprefix: / :idseparator: -
cd "${MYDIR}../"
asciidoctor -b docbook -a 'idprefix=' -a 'idseparator=-' -o README.xml README-psntools.adoc
## workaround for default idprefix/idseparator
if [ 0 -eq 1 ]; then
  gawk -i inplace -e '
{
  if (match($0, /xml:id="[^"]*"/, result)) {
    sub("=\"_", "=\"", result[0])
    gsub("_", "-", result[0])
    print substr($0, 1, RSTART-1) result[0] substr($0, RSTART+RLENGTH)
  } else {
    print $0
  }
}
' README.xml
fi
#
pandoc -f docbook -t rst -s --toc -o README.rst README.xml
rm README.xml
