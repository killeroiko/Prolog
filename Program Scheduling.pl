:- consult(attends).

% Convert a list to a "set"
% 	"set" εννοούμε  μία λίστα που δεν έχει duplicate elements.
set([], []).
set([H|T], X):- member(H, T), !, set(T, X).
set([H|T], [H|X]):- set(T, X).


% Όλα τα μαθήματα
get_courses(W) :-
	findall(X, attends(_,X), L),
	set(L, S),
	sort(S, W).

% Όλοι οι μαθητές
get_students(W) :-
	findall(X, attends(X,_), L),
	set(L, S),
	sort(S, W).

schedule(A,B,C) :- 
	% βρες όλα τα μαθήματα
	get_courses(X),
	% πάρε ένα permutation όλων των μαθημάτων, και χώρισέ τα στις 3 βδομάδες
	% 3 μαθήματα στην πρώτη, 3 στην δεύτερη και 2 στην τρίτη
	permutation(Y,X),
	length(A,3),
	length(B,3),
	length(C,2),
	length(L1,6),
	append(L1,C,Y),
	append(A,B,L1).

% Το ζητούμενο κατηγόρημα schedule_errors/4 χρησιμοποιεί τα παρακάτω 
%   κατηγορήματα schedule_errors/5
schedule_errors(A,B,C,E) :-
	get_students(S),
	schedule_errors(A,B,C,E,S).

% το base case της αναδρομής
schedule_errors(_,_,_,0,[]).

schedule_errors(A,B,C,E,[X|T]) :-
	A = [A1,A2,A3],
	B = [B1,B2,B3],
	
	% αν ο μαθητής έχει τρία μαθήματα στην πρώτη βδομάδα ή 3 μαθήματα
	% στην δεύτερη βδομάδα, είναι δυσαρεστημένος
	((attends(X, A1),
	attends(X, A2),
	attends(X, A3));
	(attends(X, B1),
	attends(X, B2),
	attends(X, B3))),
	!,

	schedule_errors(A,B,C,E1,T),
	E is E1 + 1.

schedule_errors(A,B,C,E,[_|T]) :-
	schedule_errors(A,B,C,E,T).

% Το ζητούμενο κατηγόρημα minimal_schedule_errors/4 χρησιμοποιεί τα παρακάτω 
% κατηγορήματα: min_error/1, schedule/3, schedule_errors/4
minimal_schedule_errors(A,B,C,E) :-
% βρες τον ελάχιστο αριθμό δυσαρεστημένων μαθητών
  min_error(X),
  E is X,
	!,
	% βρες ένα πρόγραμμα όπου ο αριθμός των δυσαρεστημένων μαθητών είναι ο ελάχιστος.
	schedule(A,B,C),
	schedule_errors(A,B,C,E).

% βρες τον μικρότερο αριθμό δυσαρεστημένων μαθητών
min_error(X) :-
	% φτίαχνει μια λίστα απο αριθμούς δυσαρεστημένων μαθητών
    findall(E,find_error(E),W), 
	minlist(W,X).

% βρες τον αριθμό δυσαρεστημένων μαθητών για ένα πρόγραμμα
find_error(E):-
    schedule(A,B,C),
    schedule_errors(A,B,C,E).

% βρες τον ελάχιστο αριθμό μίας λίστας
minlist([X],X).
minlist([X,Y|T],Min) :-
    minlist([Y|T],MinT),
    min(X,MinT,Min).

min(X,Y,X) :- X =< Y.
min(X,Y,Y) :- X > Y.

% Το ζητούμενο κατηγόρημα score_schedule/4 χρησιμοποιεί τα παρακάτω 
% κατηγορήματα: get_students/1, score_schedule/5
score_schedule(A,B,C,S) :-
    % Επιστρέφει την λίστα ST όλων των μαθητών
    get_students(ST),
    % Κλήση του κατηγορήματος με την λίστα των μαθητών
    score_schedule(A,B,C,S,ST).


% weeek_ab/5 η εβδομάδα μαθημάτων (1η,2η) με τρείς μέρες, για έναν μαθητή
% W1,W2,W3 οι εξετάσημες ημέρες, X ο μαθητής, WS το σκόρ της εβδομάδας
week_ab(W1,W2,W3,X,WS):-
    
    % Αν δίνει Δευτέρα-Τετάρτη ή Τετάρτη-Παρασκευή, το σκόρ είναι 1
    ((attends(X,W1),attends(X,W2));(attends(X,W2),attends(X,W3))) ->  WS is 1;
    % Αν δίνει Δευτέρα-Παρασκευή, το σκόρ είναι 3
   	((attends(X,W1),attends(X,W3))) ->  WS is 3;
    % Αν δίνει Δευτέρα ή Τετάρτη ή Παρασκευή, το σκόρ είναι 7
    ((attends(X,W1));(attends(X,W2));(attends(X,W3))) ->  WS is 7;
    % Αν δίνει Δευτέρα και Τετάρτη και Παρασκευή, το σκόρ είναι -7
    ((attends(X,W1),attends(X,W2),attends(X,W3))) ->  WS is -7; 
    % Αν δέν δίνει καμία μέρα το σκόρ ειναι 0
    WS is 0.

% week_c/4 η εβδομάδα μαθημάτων (3η) με δύο μέρες, για έναν μαθητή
% C1,C2 οι εξετάσημες ημέρες, X ο μαθητής, CS το σκόρ της εβδομάδας
week_c(C1,C2,X,CS):-
    
	% Αν δίνει Δευτέρα-Τετάρτη, το σκόρ είναι 1
    ((attends(X,C1),attends(X,C2))) ->  CS is 1;
    % Αν δίνει Δευτέρα ή Τετάρτη, το σκόρ ειναι 7
    ((attends(X,C1));(attends(X,C2))) ->  CS is 7; 
    % Αν δέν δίνει καμία μέρα το σκόρ ειναι 0
    CS is 0.

% Αρχικοποίηση του κατηγορήματος score_schedule/5
score_schedule(_,_,_,0,[]).

% Κλήση του κατηγορήματος score_schedule/5 με
% A 1η εβδομάδα, B 2η εβδομάδα, C 3η εβδομάδα
% S το σκόρ του προγράματος, X ο πρ΄ωτος μαθητής, T οι υπόλοιποι μαθητές
score_schedule(A,B,C,S,[X|T]) :-
    % 1η εβδομάδα, Α1 Δευτέρα, Α2 Τετάρτη, Α3 Παρασκευή
    A = [A1,A2,A3],
    % 2η εβδομάδα, Β1 Δευτέρα, Β2 Τετάρτη, Β3 Παρασκευή
    B = [B1,B2,B3],
    % 3η εβδομάδα, C1 Δευτέρα, C2 Τετάρτη
    C = [C1,C2],
    
    % Βρές το (AS) σκόρ της πρώτης εβδομάδας
    week_ab(A1,A2,A3,X,AS),
    % Βρές το (BS) σκόρ της δεύτερης εβδομάδας
    week_ab(B1,B2,B3,X,BS),
    % Βρές το (CS) σκόρ της τρίτης εβδομάδας
    week_c(C1,C2,X,CS),!,
    
    % Αναδρομική κλήση με το συνολικό σκόρ όλων των εβδομάδων
    % T η λίστα χωρίς τον πρώτο μαθητή
    score_schedule(A,B,C,S1,T),
    S is S1 + AS + BS + CS.
    
score_schedule(A,B,C,S,[_|T]) :-
    score_schedule(A,B,C,S,T).

% Το ζητούμενο κατηγόρημα maximum_score_schedule/5, χρησιμοποιεί τα παρακάτω
% κατηγορήματα: max_score/1 , minimal_schedule_errors/4 , score_schedule/4
maximum_score_schedule(A,B,C,E,S) :-
	% βρες το μέγιστο σκορ
    max_score(X),
    S is X,
		!,
		
	% βρες ένα πρόγραμμα όπου ο αριθμός των δυσαρεστημένων μαθητών είναι ο ελάχιστος
    minimal_schedule_errors(A,B,C,E),
	% βρες ένα πρόγραμμα όπου το σκόρ είναι το μέγιστο
    score_schedule(A,B,C,S).

% βρες το μέγιστο σκόρ όλων των προγραμμάτων
max_score(X) :-
	% φτίαχνει μια λίστα με όλα τα σκόρ απο τα προγράμματα
    findall(S,find_score(S),W), 
	maxlist(W,X).

% βρες το σκόρ ενώς προγράμματος απο αυτά με τον μικρότερο αριθμό δυσαρεστημένων μαθητών
find_score(S):-
    minimal_schedule_errors(A,B,C,_),
    score_schedule(A,B,C,S).

% βρες τον μέγιστο αριθμό μίας λίστας
maxlist([X],X).
maxlist([X,Y|T],Max) :-
    maxlist([Y|T],MaxT),
    max(X,MaxT,Max).

max(X,Y,X) :- X >= Y.
max(X,Y,Y) :- X < Y.
