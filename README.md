Installation
---

Install via npm:
```bash
npm install -g prjk
```


Configure 
---

To create a alias in your .bash_profile:
```bash
. prjk alias myfolder ~/test-folder # the dot is necessary
```

It will create an alias in your ~/.bash_profile


To run your recently created alias:
```bash
myfolder         # to go to the respective project's folder
myfolder .       # to list all folders
myfolder [abc]   # to list folders that have a, b or c in name
myfolder abc     # to list folders that have 'abc' in name
```

