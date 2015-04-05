Installation
---

Install via npm:
```bash
npm install -g prjk
```


Configure 
---

To create an alias in your .bash_profile:
```bash
. prjk alias myfolder ~/test-folder # the dot is necessary
```

It will create an alias in your ~/.bash_profile


To run your recently created alias:
```bash
myfolder         # to go to the respective projects' folder
myfolder .       # to list all folders (limited in 20 results)
myfolder [abc]   # to list folders that have a, b or c in name
myfolder abc     # to list folders that have 'abc' in name
```

