About
---
!(prjk usage)[http://cristianobecker.com/static/images/prjk.gif]

Using shell alias to make navigation in the file system easier. It can be helpful when working in multiple projects in a workspace, since it's faster to type an alias that navigates into a folder instead to type the fullpath


Installation
---

Install via npm:
```bash
npm install -g prjk
```


Usage
---

To create an alias in your .bash_profile:
```bash
. prjk alias myfolder ~/test-folder # the dot is necessary
```

It will create an alias in your ~/.bash_profile (or ~/.bashrc)


To run your recently created alias:
```bash
myfolder         # to go to the respective projects' folder
myfolder .       # to list all folders (limited in 20 results)
myfolder [abc]   # to list folders that have a, b or c in name
myfolder abc     # to list folders that have 'abc' in name
```

