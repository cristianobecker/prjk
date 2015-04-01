install: ;
	mkdir test-folder
	for f in "test-1" "test-2" "other-1" "different-1"; do (cd test-folder && mkdir $f); done

	mkdir -p ~/bin
	ln -s `echo $(cd bin && pwd)'/prjk.sh'` ~/bin/prjk
