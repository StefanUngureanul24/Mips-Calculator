# MIPS - calculatrice
Le but de ce mini-projet est de créer une calculatrice basique.

## Première version
La première version du calculatrice contenait toutes les fonctions pour l'affichage.

## Version finale (detailles)
Apres avoir téléchargé le code du depart, le premier défi a été de bien observé chaque fonction et comment établir les liens entre ces fonctions.

### La partie integer
Apres avoir dépasé cette étape, j'ai ajouté les commandes de chaque fonction **operation_integer**.<br /> Ensuite, j'ai ajouté une fonction **read_operation** qui lit la chaîne de caractères ajouté par l'utilisateur. Ensuite, j'ai ajouté l'appel de la fonction **read_operation** dans **calculator_integer_loop**, pour lire la signe de l'opération. <br /> Après avoir lu le signe de l'opération, j'ai stocké dans un registre (*$t0*) le premiere caractère et puis j'ai fait la comparaison avec les autres signes de l'opération. Pour faciliter cette démarche, au lieu de prendre chaque caractère du *operators*, qui était déjà défini dans le code du depart, j'ai ajouté un tag pour chaque signe individuellement:
* *plus: .byte '+'*
* *minus: .byte '-'*
* *multiplication: .byte '*'*
* *division: .byte '/'* <br />
Ensuite, dans un registre (*$t1*), j'ai mis chaque fois le signe de chaque opération, pour determiner avec *beq* si la signe que l'utilisateur a ajouté est égal à la signe qu'on a en ce moment-là dans dans le registre *$t1*. Si on trouve une égalité, on va faire un **branch** vers l'opération détérminé (*faireAddition*, *faireSubstraction*, *faireMultiplication* ou *faireDivision*), où on demande l'utilisateur de ajouter un deuxième élément pour faire le calcul, et puis on met les deux valeurs dans les registres *$a0* et *$a1*, qui correspondent aux registrer des arguments pour les fonctions qu'on va appeler pour l'operation qu'on a determiné. <br />
Avec les autres opérations (*min*, *max*, *pow*, *abs*), j'ai rencontré un autre défi: on peut plus comparer que le premier caractère de la chaîne qu'on vient d'ajouter. Par conséquent, dans un registre (*$t1*), j'ai mis l'adresse du string qui correspond à l'opération qu'on a ajouté (*string_max*, *string_min*, *string_pow* ou bien *string_abs*) et dans un autre registre (*$t2*) le premier caractère du string. <br />
Dans le cas des opérations **puissance** et **valeur absolue**, j'ai comparé les premiers deux caractères et si on trouve une égalité, on va faire un **branch** vers l'opération détérmine, mais cette méthode ne fonctionne plus pour les operations **minimum** et **maximum**, puisque le nom des deux opérations commence avec *m*. Ainsi, en faisant la comparaison du premier caractère, celle-ci, au cas où on trouve l'égalité avec le caractère *m*, fera un **branch** vers *min_or_max*, où dans deux autres registres, on va mettre le deuxième caractère de *string_max* et *string_min* respectivement, et juste après cette comparaison on va faire un **branch** vers *faireMaximum*, qui détérmine le maximum ou *faireMinimum*, qui détérmin le minimum. <br />
Une autre particularité c'est dans le cas de l'opération **valeur absolue**, qui ne necessite pas l'ajout d'un deuxième élément, ainsi le **branch** vers *faireAbsolue* est le seul qui ne demande pas l'utilisateur d'ajouter un deuxième élément.

### La partie float
L'implémentation de la partie flottant est assez similaire avec la partie entière, l'ajout de commands dans les fonctions **operation_float** et la comparaison entre la signe de l'opération ajouté et chaque signe qu'on avait ajouté dans la partie *.data*, et puis faire le **branch** vers l'opération qui correspond à la signe qu'on a ajouté. <br />
La difficulté principale que j'ai rencontré, c'était le fait que l'**assembleur MIPS** ne nous permet pas de faire ni des chargements immédiats dans les registrer, ni des **branching**s. <br />
L'implémentation des premiers 4 opérations (addition, soustraction, multiplication, division), la seule particularité a été d'utiliser la commande speciale pour de *single_precision* (*add.s*, *sub.s*, *mul.s*, *div.s*). <br />
Pour les operations qui détérmine le minimum, respectivement le maximum, pour comparer les deux valeurs j'ai utilisé la commande *c.le.s* qui renvoie soit **true**, soit **false**. Après determiner si c'est soit **true**, soit **false**, j'ai utilisé la commande *bc1f*, pour faire un **branch** si on a **false** ou *bf1t* si on a **true** comme résultat. <br />
Il y a une autre particularité dans le fonctions *operation_float_pow* et *operation_float_abs*: pour bien déterminer la puissance (dans *operation_float_pow*), j'ai eu besoin de les valeur **1.0** et **0.0**, ainsi j'ai ajouté dans la partie *.data* *fp0* où j'ai mis la valeur **0.0** et *fp1* où j'ai mis la valeur **1.0**.



