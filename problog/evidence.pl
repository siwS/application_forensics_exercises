% names to list of strings to calculate size

name_to_list('krause',[k,r,a,u,s,e]).
name_to_list('weber',[w,e,b,e,r]).
name_to_list('jimenez',[j,i,m,e,n,e,z]).
name_to_list('woodard',[w,o,o,d,a,r,d]).
name_to_list('campos',[c,a,m,p,o,s]).
name_to_list('empty',[e,m,p,t,y]).

a_length(X,Y) :-  name_to_list(X,L), length(L,Y).

% sort to only display one permutation of results

sort_n('empty',0).
sort_n('krause',1).
sort_n('weber',2).
sort_n('jimenez',3).
sort_n('woodard',4).
sort_n('campos',5).

% possibility of a person to drive at work

0.8::drive('krause').
0.8::drive('weber').
0.5::drive('jimenez').
0.5::drive('woodard').
0.5::drive('campos').

% possibility of a person not to drive at work

0.2::not_drive('krause').
0.2::not_drive('weber').
0.5::not_drive('jimenez').
0.5::not_drive('woodard').
0.5::not_drive('campos').

% length of the file is the sum of the lengths of all the driver's name or 'empty' 

file_size(X,Y,Z,W,Length) :-
    a_length(X,XL), a_length(Y,YL), a_length(Z,ZL), a_length(W,WL), Length is XL+YL+ZL+WL.
    
% different scenarios: if 1, 2, 3, 4 or none drove to work this particular day

drivefour(X,Y,Z,W,E) :- drive(X), drive(Y), drive(Z), drive(W), not_drive(E)
    , X\=Y, X\=Z, X\=W, Y\=Z, Y\=W,  Z\=W, E\=X, E\=Z, E\=W.

drivethree(W,X,Y,Z,E1, E2) :- drive(X), drive(Y), drive(Z), W = 'empty', not_drive(E1), not_drive(E2),
    X\=Y, X\=Z, X\=E1, X\=E2, Y\=Z, Y\=E1, Y\=E2, Z\=E1, Z\=E2, E1\=E2.

drivetwo(Z,W,X,Y,E1,E2,E3) :- drive(X), drive(Y), Z = 'empty', W = 'empty', 
    not_drive(E1), not_drive(E2), not_drive(E3),
    X\=Y, X\=E1, X\=E2, X\=E3, 
    Y\=E1, Y\=E2, Y\=E3, 
    E1 \=E2, E1\=E3, E2\=E3.

driveone(Y,Z,W,X,E1,E2,E3,E4) :-  drive(X), Y = 'empty', Z = 'empty', W = 'empty', 
    not_drive(E1), not_drive(E2), not_drive(E3),
    not_drive(E4),
    X\=E1, X\=E2, X\=E3, X\=E4,
    E1 \=E2, E1\=E3, E1 \=E4, E2\=E3, E2\=E4, E3\=E4.

drivezero(X,Y,Z,W,E1,E2,E3,E4,E5) :- X = 'empty', Y = 'empty', Z = 'empty', W = 'empty', 
    not_drive(E1), not_drive(E2), not_drive(E3), not_drive(E4), not_drive(E5),
    E1\=E2, E1\=E3, E1 \=E4, E1\=E5,
    E2\=E3, E2\=E4, E2\=E5, E3\=E4, E3\=E5, E4\=E5.

% all different possible combinations for a file
% sorted so that we only get each combination once

combination(X,Y,Z,W) :- 
    (
        drivezero(X,Y,Z,W,E1,E2,E3,E4,E5)
        ;   
        drivefour(X,Y,Z,W,E)
        ;
        drivethree(X,Y,Z,W, E1,E2)
        ;
        drivetwo(X,Y,Z,W, E1,E2,E3)
        ;
        driveone(X,Y,Z,W, E1,E2,E3,E4)
    ), 
    
    sort_n(X,XS), sort_n(Y,YS), sort_n(Z,ZS), sort_n(W,WS),
    
    (
        XS = 0
        ;
        XS < YS
    )
    ,
    (
        YS = 0
        ;
        YS < ZS
    )
    ,
    (
        ZS = 0
        ;
        ZS < WS
    ).


% Predicates used to support evidence

% length of file of a specific combination

file(Length) :- combination(X,Y,Z,W), file_size(X,Y,Z,W,Length).

% particular person parked on a given day

parked(K) :- combination(X,Y,Z,W),
            (X=K ; Y=K; Z=K; W=K).


% evidence: size of the file, after removing the standard data has to be 24
% added all other sizes to false to prevent results from appearing in query with 0 possibility

evidence(file(24), true).
evidence(file(25), false).
evidence(file(21), false).
evidence(file(20), false).
evidence(file(22), false).
evidence(file(23), false).
evidence(file(26), false).

% evidence: campos parked this day

evidence(parked('campos'),true).

% query for possible combinations

query(combination(_,_,_,_)).

% Results we are getting with this query are:

% combination('empty','krause','jimenez','campos')	 0.051020408
% combination('empty','krause','woodard','campos')	 0.051020408
% combination('krause','weber','jimenez','campos')	 0.57142857
% combination('krause','weber','woodard','campos')	 0.40816327

% Sum of all possibilities: 1



