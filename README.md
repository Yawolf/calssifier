<div id="table-of-contents">
<h2>Table of Contents</h2>
<div id="text-table-of-contents">
<ul>
<li><a href="#orgheadline1">1. Introduccion</a></li>
<li><a href="#orgheadline4">2. Implementacion</a>
<ul>
<li><a href="#orgheadline2">2.1. Clasificador Euclideo</a></li>
<li><a href="#orgheadline3">2.2. Clasificador Estadistico</a></li>
</ul>
</li>
<li><a href="#orgheadline5">3. Resultados UCI</a></li>
<li><a href="#orgheadline6">4. Validacion Cruzada UCI</a></li>
<li><a href="#orgheadline7">5. Dataset MNIST</a></li>
<li><a href="#orgheadline8">6. Validacion cruzada MNIST</a></li>
<li><a href="#orgheadline9">7. Anexo</a></li>
</ul>
</div>
</div>


# Introduccion<a id="orgheadline1"></a>

Esta es la practica propuesta por la asignaura **Reconocimiento de Formas** de la
Universidad Politecnica de Madrid (UPM), Espana<sup><a id="fnr.1" class="footref" href="#fn.1">1</a></sup>.

La practica consiste en programar 2 reconocedores, uno basado en distancias euclideas
y otro en probabilidades gausianas. Es cierto que la practica se propuso para ser 
hecha en python pero, debido a ciertos errores causados por el sistema de tipos 
en el que, al almacenar datos propios de la libreria *Numpy* <sup><a id="fnr.1.100" class="footref" href="#fn.1">1</a></sup> en estructuras built-in
de python, los valores de las variables variaban al ser redondeadas o truncadas. Por
ello he decidido hacer la practica en **Julia** <sup><a id="fnr.2" class="footref" href="#fn.2">2</a></sup>, un lenguaje de programacion matematico
al estilo de Matlab <sup><a id="fnr.3" class="footref" href="#fn.3">3</a></sup>.

Antes de nada, decir que es mi primer programa hecho en julia y, por tanto, no es
de extraniar que el codigo no sea el mas optimo asi como que ciertas funciones esten
tipadas y otras se haga uso de la inferencia de julia.

# Implementacion<a id="orgheadline4"></a>

NOTA: Toda la implementacion se puede encontrar aqui <https://github.com/Yawolf/calssifier>

La implementacion de los clasificadores es sencilla. Como he mencionado antes, han sido
programados en Julia, lo que nos permite un manejo de matrices muy bueno, facilitandonos
la programacion.

## Clasificador Euclideo<a id="orgheadline2"></a>

Este clasificador se ajusta al siguiente algoritmo:

<div class="VERBATIM">
get<sub>matrix</sub> from file
get<sub>classes</sub> from matrix
get<sub>average</sub> from matrix and classes
categorize using matrix, classes and average

</div>

1.  En primer lugar se obtiene la matriz leyendola del CSV o *.data*
2.  De la matriz que hemos leido se extraen las clases y se hace un *nub*<sup><a id="fnr.4" class="footref" href="#fn.4">4</a></sup> del vector
    resultante.
3.  Creando un diccionario usando las clases como key, calculamos la media de cada uno de
    los valores de los "vectores" de cada clase y se insertan como value.
4.  Una ve hecho todo lo anterior por cada elemento de la matriz se calcula su distancia
    euclidea con cada uno de los *averages* anteriores, el que este mas cerca sera la
    clase que se le asigne y se comparara con la que se nos da para ver si es verdad.

Como se puede observar, el funcionamiento e implementacion de dicho reconocedor es 
sencillo.

## Clasificador Estadistico<a id="orgheadline3"></a>

Este clasificador tiene un algoritmo mas complejo de implementacion:

<div class="VERBARIM">
get training and testing from file
separate training by classes
get covariance from classes
get mean from classes
classify using testing, classes, mean and covariance

</div>

1.  En primer lugar se hace un split de la matriz dando lugar a 2 "submatrices", una
    sera la matriz de entrenamiento, otra sera la de testing
2.  Una vez obtenida la matriz de entrenamiento, esta se subdivide en otras matrices
    mas pequenias en la que todos los elementos de cada una de ellas pertenecen a la
    misma clase. Esto es, submatrices por clases.
3.  Una vez conseguidas las matrices de clases, se calcula la covarianza de cada una
    de ellas.
4.  Usando otra vez las matrices de clases se calcula la media de cada uno de los
    parametros de cada clase.
5.  Usando el subset *testing*, las matrices de clases, sus covarianzas y sus
    medias, se calcula la probabilidad de que, cada elemento del dataset *testing*
    pretenezca a una u otra clase, para ello se usa la formula de la distribucion
    gaussiana y se compara el resultado de la mejor opcion con el original.

Siguiendo estos pasos se consigue reconocer estadisticamente cada elemnto.

# Resultados UCI<a id="orgheadline5"></a>

Ahora se presentaran los resultados para los dataset sacados de la UCI <sup><a id="fnr.5" class="footref" href="#fn.5">5</a></sup>. Estos
dataset son los siquientes:

-   wine.data
-   cancer.data
-   iris.data
-   wineR.data
-   cancerR.data
-   irisR.data

Todos ellos se pueden encontrar en la carpeta *test* de este repositorio. Cabe destacar
que los dataset cuyo nombre termina en una 'R' cotienen los mismos datos que sus
equivalentes sin 'R', solo que sus datos han sido desordenados para obetener una mejor
aleatoriedad.

    $> sort -R wine.data >> wineR.data

Se presentan ahora las tasas de acierto de los clasificadores, tanto el euclidiano como el
estadistico:

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-right" />

<col  class="org-right" />

<col  class="org-right" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Clasificador</th>
<th scope="col" class="org-right">wine.data</th>
<th scope="col" class="org-right">iris.data</th>
<th scope="col" class="org-right">cancer.data</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">Euclideo</td>
<td class="org-right">72.47191011235955%</td>
<td class="org-right">92.66666666666666%</td>
<td class="org-right">61.86291739894551%</td>
</tr>


<tr>
<td class="org-left">Estadistico</td>
<td class="org-right">99.43820224719101%</td>
<td class="org-right">98.0%</td>
<td class="org-right">97.36379613356766%</td>
</tr>
</tbody>
</table>

Notese que la precision del clasificador estadistico es superior en muchos sentidos a la
del euclideo, siendo este mas sencillo de programar, pero mas ineficiente a la hora de
clasificar

Un ejemplo de como se ejecutan los test:

    # Dentro del mismo direcotrio del src
    $> julia
    julia> include("clasific_eucl.jl")
    julia> include("clasific_estad.jl")
    julia> include("clasific_gauss.jl")
    julia> euclideo.start("wine.data") # euclideo
    ...
    julia> gauss.start("wine.data") # estadistico gaussiano

# Validacion Cruzada UCI<a id="orgheadline6"></a>

Ahora se van a presentar los resultados de la validacion cruzada, para ello se ha
decidido que el fichero de entrenamiento y el de test sea el mismo, se han hecho 
10 folds para estar acorde al apartado siguiente. Los resultados son los siquientes

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-right" />

<col  class="org-right" />

<col  class="org-right" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Clasificador</th>
<th scope="col" class="org-right">wine.data</th>
<th scope="col" class="org-right">iris.data</th>
<th scope="col" class="org-right">cancer.data</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">Euclideo</td>
<td class="org-right">71.99197860962568%</td>
<td class="org-right">92.66666666666666%</td>
<td class="org-right">59.68614718614719%</td>
</tr>


<tr>
<td class="org-left">Estadistico</td>
<td class="org-right">99.43820224719101%</td>
<td class="org-right">98.0%</td>
<td class="org-right">97.36379613356766%</td>
</tr>
</tbody>
</table>

# Dataset MNIST<a id="orgheadline7"></a>

Ahora se usara el dataset MNIST <sup><a id="fnr.6" class="footref" href="#fn.6">6</a></sup>, la cual cuentiene 60.000 elementos con 10 
variables cada uno de ellos.

Para ejecutar se usan estos mandatos:

    # Dentro del mismo direcotrio del src
    $> julia
    julia> include("clasific_eucl.jl")
    julia> include("clasific_estad.jl")
    julia> include("clasific_gauss.jl")
    julia> gauss.start("datos_procesados.npy",(1,500),1) # estadistico gaussiano

En este caso estamos usando las primeras 500 filas del CSV para entrenar y, al haber
pasado un 1 como argumento, usaremos el mismo subset para entrenar y para testear.
Cambiando dicho flag, se usara el segundo subset para testear.

    julia> euclideo.start("datos_procesados.npy",(1,500),2)
    ...
    julia> gauss.start("datos_procesados.npy",(1,500),2)

Los resultados son los siquientes:

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-right" />

<col  class="org-right" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">&#xa0;</th>
<th scope="col" class="org-right">Estadistico</th>
<th scope="col" class="org-right">Euclideo</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">D1 and D1</td>
<td class="org-right">84.90420168067226%</td>
<td class="org-right">88.6%</td>
</tr>
</tbody>

<tbody>
<tr>
<td class="org-left">D1 and D2</td>
<td class="org-right">94.6%</td>
<td class="org-right">85.8890756302521%</td>
</tr>


<tr>
<td class="org-left">&#xa0;</td>
<td class="org-right">&#xa0;</td>
<td class="org-right">&#xa0;</td>
</tr>
</tbody>
</table>

Se observa que para cantidades pequenias, el euclideo y el estadistico tienen una 
diferencia mucho menor que en el caso de tener muchos elementos.

# Validacion cruzada MNIST<a id="orgheadline8"></a>

Igual que en el apartado de validacion cruzada con UCI, aqui se ha subdividido la
matriz en 10 submatrices.

Los resultados son los siquientes:

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-right" />

<col  class="org-right" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">&#xa0;</th>
<th scope="col" class="org-right">Euclideo</th>
<th scope="col" class="org-right">Estadistico</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">D1 and D1</td>
<td class="org-right">88.6%</td>
<td class="org-right">84.90420168067229%</td>
</tr>
</tbody>

<tbody>
<tr>
<td class="org-left">D1 and D2</td>
<td class="org-right">85.8890756302521%</td>
<td class="org-right">94.6%</td>
</tr>
</tbody>
</table>

# Anexo<a id="orgheadline9"></a>

<div id="footnotes">
<h2 class="footnotes">Footnotes: </h2>
<div id="text-footnotes">

<div class="footdef"><sup><a id="fn.1" class="footnum" href="#fnr.1">1</a></sup> <div class="footpara">ETSIINF-UPM: <https://www.fi.upm.es/></div></div>

<div class="footdef"><sup><a id="fn.2" class="footnum" href="#fnr.2">2</a></sup> <div class="footpara">Numpy: <http://www.numpy.org/></div></div>

<div class="footdef"><sup><a id="fn.3" class="footnum" href="#fnr.3">3</a></sup> <div class="footpara">Julia-lang: <http://julialang.org/></div></div>

<div class="footdef"><sup><a id="fn.4" class="footnum" href="#fnr.4">4</a></sup> <div class="footpara">nub: <http://hackage.haskell.org/package/base-4.8.1.0/docs/Data-List.html#v:nub></div></div>

<div class="footdef"><sup><a id="fn.5" class="footnum" href="#fnr.5">5</a></sup> <div class="footpara">UCI: <http://archive.ics.uci.edu/ml/></div></div>

<div class="footdef"><sup><a id="fn.6" class="footnum" href="#fnr.6">6</a></sup> <div class="footpara">MNIST: <http://yann.lecun.com/exdb/mnist/></div></div>


</div>
</div>
