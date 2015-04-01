Installation
---

Run this command in terminal:
```bash
make install
```

It will create the tests folder and the global reference to the command


Test 
---

To create a alias in your .bash_profile (future use):
```bash
prjk alias myfolder test-folder # >> ~/.bash_profile && source ~/.bash_profile
```

To navigate in your project's folder:
```bash
prjk go test-folder 
prjk go test-folder dif
prjk go test-folder 1 # will open a menu with options
```

In future, the command will be used through the alias:
```bash
myfolder # to go to the respective project's folder
myfolder search # to go to the folder that matches with the "search" string
```

PS: today, this script only outputs the destiny folder. The "change directory" feature will be added in future.
