% Ambiente 2

%%%%%%%%% Objetos mapa %%%%%%%%%%

% aspirador
aspirador([]).

% sujeira
sujeira([[1, 1],[7, 2],[3, 4]]).

% lixeira
lixeira(p(5,5)).

% parede
parede(5,1).
parede(3,3).
parede(6,5).

% elevador 1
elevador(2,1).
elevador(2,2).
elevador(2,3).
elevador(2,4).
elevador(2,5).

% dock station
dock([10,2]).

% limite mapa
limite(0,11).

% tetos
tetos(0, 6).

% remove
retirar_sujeira(Elem,[Elem|Cauda],Cauda).
retirar_sujeira(Elem,[Cabeca|Cauda],[Cabeca|Resultado]) :- 
  retirar_sujeira(Elem,Cauda,Resultado).


%%%%%%%%%%%%%%% Verficações %%%%%%%%%%%%%%%%

pode_direita(nao, [X, Y]) :-
    D is X + 1, limite(_, D),
    D is X + 1, not(parede(D, _)).
pode_direita(sim, [X, Y]) :- not(pode_direita(nao, [X, Y])).

% verifica se pode andar para esquerda
pode_esquerda(nao, [X, Y]) :-
    E is X - 1, limite(E, _),
    E is X - 1, not(parede(E, _)).
pode_esquerda(sim, [X, Y]) :- not(pode_esquerda(nao, [X, Y])).

% verifica se pode subir o elevador
pode_pegar_elevador(sim, [X, Y]) :-
    N is Y + 1, not(tetos(_, N)), elevador(X, Y). % modificar para qualquer Y
pode_pegar_elevador(nao, [X, Y]) :- not(pode_pegar_elevador(sim, [X, Y])).


pode_finalizar(sim, sujeira) :-
    isEmpty(sujeira).
pode_finalizar(nao,sujeira).

len([],0).
len([_|T],N) :-
    len(T,X),
    N is X + 1.

isEmpty(L) :-
    len(L,X),
    X =:= 0.

soma([],0).
soma([X|Y],S) :-
    soma(Y,SI),
    S is SI + 1.

aspirador_cheio(sim, L) :-
    soma(L, S),
    S =:= 2.
aspirador_cheio(nao, L).



% esvaziar aspirador
esvaziar([],[]).
esvaziar([L1|L2], Novo_aspirador) :-
    remove_sujeira([L1|L2], Novo_aspirador),
    esvaziar(L2, Novo_aspirador).



%%%%%%%%%%%%%%%% Ações %%%%%%%%%%%%%%%%%%%%%%%%


su([X|Y], [X|Y]) :- lixeira(X, Y),
                    aspirador_cheio(sim, aspirador),
                    esvaziar(aspirador, L),writeln('lixeira').

su([X, Y], [X, Y]) :- pertence([X,Y], sujeira),
                      not(aspirador_cheio(sim, aspirador)), remove_sujeira([X|Y], L),writeln('pegou lixo').


% movimentar para direita
su([X, Y], [NX, Y]) :-
        NX is X + 1,
        pode_direita(sim, [X, Y]), writeln('andou para direita').

su([Pos, Sacola, Sujeiras], [Pos, Sacola2, Sujeiras2]) :-  	
    pertence(Pos,Sujeiras),										
    retirar_elemento(Pos,Sujeiras,Sujeiras2),					
    Sacola < 2,													
    Sacola2 is Sacola + 1, writeln('limpou sujeira').


% movimentar para esquerda
su([X, Y], [NX, Y]) :-
        NX is X - 1,
        pode_esquerda(sim, [X, Y]),writeln('andou para esquerda').


%su([X|Y], [X|Y]) :- dock([X|Y]), isEmpty(sujeira).


% movimentar para cima
su([X, Y], [X, NY]) :-
        NY is Y + 1,
        pode_pegar_elevador(sim, [X, Y]), writeln('subiu').

% movimentar para baixo
su([X, Y], [X, NY]) :-
        NY is Y - 1,
        pode_pegar_elevador(sim, [X, Y]),writeln('desceu').




%%%%%%%%%%%%% Solução %%%%%%%%%%%%%%%

% chamada principal
limparCenario(Inicial, Retorno) :- busca([[Inicial]], Retorno).

% busca a solucao
busca([[Estado|Caminho]|_], [Estado|Caminho]) :- dock(Estado), isEmpty(sujeira).
busca([Primeiro|Outros], Retorno) :-
    estende(Primeiro, Sucessores),
    concatena(Outros, Sucessores, NovaFronteira),
    busca(NovaFronteira, Retorno).

% bagof da solucao
estende([Estado|Caminho], ListaSucessores):-
    bagof([Sucessor, Estado|Caminho], (su(Estado, Sucessor), not(pertence(Sucessor, [Estado|Caminho]))), ListaSucessores), !.
estende(_, []).

% verificar se um elemento pertence a uma lista
pertence(Elem, [Elem|_ ]).
pertence(Elem, [ _| Cauda]) :- pertence(Elem, Cauda).

% concatenar duas listas
concatena([ ], L, L).
concatena([Cab|Cauda], L2, [Cab|Resultado]) :- concatena(Cauda, L2, Resultado).